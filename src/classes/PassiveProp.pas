unit PassiveProp;

interface
uses Classes ;

type
  TPassiveProp = class
  protected
    SavedParams:TStringList ;
  public
    class function IsNamed(const Name:string):Boolean ;
    constructor Create(Params:TStringList) ; virtual ;
    function AddInfo():string ; virtual ;
  end;

  TPassivePropClass = class of TPassiveProp ;

  TNullPassiveProp = class(TPassiveProp)
  private
    PropName:string ;
  public
    constructor Create(Params:TStringList) ; override ;
  end;

procedure RegisterPassiveProp(PPC:TPassivePropClass) ;
function CreatePassiveProp(Params:TStringList):TPassiveProp ;

implementation
uses contnrs, SysUtils ;

var GPassivePropList:TClassList=nil ;

function GetPassivePropList():TClassList ;
begin
  if GPassivePropList=nil then GPassivePropList:=TClassList.Create ;
  Result:=GPassivePropList ;
end;

procedure RegisterPassiveProp(PPC:TPassivePropClass) ;
begin
  GetPassivePropList.Add(PPC) ;
end;

function CreatePassiveProp(Params:TStringList):TPassiveProp ;
var i:Integer ;
begin
  for i := 0 to GetPassivePropList.Count - 1 do
    if TPassivePropClass(GetPassivePropList[i]).IsNamed(Params.Values['Code']) then begin
      Result:=TPassivePropClass(GetPassivePropList[i]).Create(Params);
      Exit ;
    end;
  Result:=TNullPassiveProp.Create(Params) ;
end;

{ TNullPassiveProp }

constructor TNullPassiveProp.Create(Params: TStringList);
begin
  PropName:=Params.Values['PassiveProp'] ;
  SavedParams:=TStringList.Create ;
  SavedParams.Assign(Params);
end;

{ TPassiveProp }

function TPassiveProp.AddInfo: string;
begin
  Result:='' ;
end;

constructor TPassiveProp.Create(Params: TStringList);
begin
  SavedParams:=TStringList.Create ;
  SavedParams.Assign(Params);
end;

class function TPassiveProp.IsNamed(const Name: string): Boolean;
begin
  Result:=LowerCase(ClassName)=LowerCase('TPassiveProp'+Name) ;
end;

end.
