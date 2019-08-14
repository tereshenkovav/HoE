unit PassivePropSpaceProtect;

interface
uses PassiveProp, Classes ;

type
  TPassivePropSpaceProtect = class(TPassiveProp)
  public
    ProtectDist:Integer ;
    constructor Create(Params:TStringList) ; override ;
    function AddInfo():string ; override ;
  end;

implementation
uses simple_oper, SysUtils ;

{ TPassivePropSpaceProtect }

function TPassivePropSpaceProtect.AddInfo: string;
begin
  Result:='Защита от Пустоты: радиус '+IntToStr(ProtectDist) ;
end;

constructor TPassivePropSpaceProtect.Create(Params: TStringList);
begin
  inherited Create(Params);
  ProtectDist:=StrToIntWt0(Params.Values['Dist']) ;
end;

initialization

  RegisterPassiveProp(TPassivePropSpaceProtect) ;

end.
