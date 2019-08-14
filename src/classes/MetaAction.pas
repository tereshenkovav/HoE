unit MetaAction;

interface
uses BattleField, Classes ;

type
  TMetaAction = class
  private
  protected
    SavedParams:TStringList ;
  public
    class function IsNamed(const Name:string):Boolean ;
    constructor Create(Params:TStringList) ; virtual ;
    function Apply(Cell:TCell):Boolean ; virtual ; abstract ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; virtual ;
  end;

  TMetaActionClass = class of TMetaAction ;

  TNullMetaAction = class(TMetaAction)
  private
    MetaName:string ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

procedure RegisterMetaAction(MAC:TMetaActionClass) ;
function CreateMetaAction(Params:TStringList):TMetaAction ;

implementation
uses contnrs, SysUtils ;

var GMetaActionList:TClassList=nil ;

function GetMetaActionList():TClassList ;
begin
  if GMetaActionList=nil then GMetaActionList:=TClassList.Create ;
  Result:=GMetaActionList ;
end;

procedure RegisterMetaAction(MAC:TMetaActionClass) ;
begin
  GetMetaActionList.Add(MAC) ;
end;

function CreateMetaAction(Params:TStringList):TMetaAction ;
var i:Integer ;
begin
  for i := 0 to GetMetaActionList.Count - 1 do
    if TMetaActionClass(GetMetaActionList[i]).IsNamed(Params.Values['Code']) then begin
      Result:=TMetaActionClass(GetMetaActionList[i]).Create(Params);
      Exit ;
    end;
  Result:=TNullMetaAction.Create(Params) ;
end;

{ TNullMetaAction }

function TNullMetaAction.Apply(Cell: TCell): Boolean;
begin
  Result:=False ;
end;

function TNullMetaAction.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  Result:=False ;
  errmsg:='Неизвестный тип метадействия: '+MetaName ;  
end;

constructor TNullMetaAction.Create(Params: TStringList);
begin
  MetaName:=Params.Values['MetaAction'] ;
  SavedParams:=TStringList.Create ;
  SavedParams.Assign(Params);
end;

{ TMetaAction }

function TMetaAction.CanApplyToCell(Cell: TCell; var errmsg: string): Boolean;
begin
  Result:=False ;
end;

constructor TMetaAction.Create(Params: TStringList);
begin
  SavedParams:=TStringList.Create ;
  SavedParams.Assign(Params);
end;

class function TMetaAction.IsNamed(const Name: string): Boolean;
begin
  Result:=LowerCase(ClassName)=LowerCase('TMetaAction'+Name) ;
end;

end.
