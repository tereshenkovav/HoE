unit StepAction;

interface
uses Classes ;

type
  TStepAction = class
  private
  protected
    SavedParams:TStringList ;
  public
    class function IsNamed(const Name:string):Boolean ;
    constructor Create(Params:TStringList) ; virtual ;
    function Apply(Cell:TObject):Boolean ; virtual ; abstract ;
    function AddInfo():string ; virtual ;
  end;

  TStepActionClass = class of TStepAction ;

  TNullStepAction = class(TStepAction)
  private
    StepName:string ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TObject):Boolean ; override ;
  end;

procedure RegisterStepAction(MAC:TStepActionClass) ;
function CreateStepAction(Params:TStringList):TStepAction ;

implementation
uses contnrs, SysUtils ;

var GStepActionList:TClassList=nil ;

function GetStepActionList():TClassList ;
begin
  if GStepActionList=nil then GStepActionList:=TClassList.Create ;
  Result:=GStepActionList ;
end;

procedure RegisterStepAction(MAC:TStepActionClass) ;
begin
  GetStepActionList.Add(MAC) ;
end;

function CreateStepAction(Params:TStringList):TStepAction ;
var i:Integer ;
begin
  for i := 0 to GetStepActionList.Count - 1 do
    if TStepActionClass(GetStepActionList[i]).IsNamed(Params.Values['Code']) then begin
      Result:=TStepActionClass(GetStepActionList[i]).Create(Params);
      Exit ;
    end;
  Result:=TNullStepAction.Create(Params) ;
end;

{ TNullStepAction }

function TNullStepAction.Apply(Cell: TObject): Boolean;
begin
  Result:=False ;
end;

constructor TNullStepAction.Create(Params: TStringList);
begin
  StepName:=Params.Values['StepAction'] ;
  SavedParams:=TStringList.Create ;
  SavedParams.Assign(Params);
end;

{ TStepAction }

function TStepAction.AddInfo: string;
begin
  Result:='' ;
end;

constructor TStepAction.Create(Params: TStringList);
begin
  SavedParams:=TStringList.Create ;
  SavedParams.Assign(Params);
end;

class function TStepAction.IsNamed(const Name: string): Boolean;
begin
  Result:=LowerCase(ClassName)=LowerCase('TStepAction'+Name) ;
end;

end.
