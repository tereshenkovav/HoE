unit PassivePropIDDQD;

interface
uses PassiveProp, Classes ;

type
  TPassivePropIDDQD = class(TPassiveProp)
  public
    constructor Create(Params:TStringList) ; override ;
  end;

implementation
uses simple_oper ;

{ TPassivePropIDDQD }

constructor TPassivePropIDDQD.Create(Params: TStringList);
begin
  inherited Create(Params);
end;

initialization

  RegisterPassiveProp(TPassivePropIDDQD) ;

end.
