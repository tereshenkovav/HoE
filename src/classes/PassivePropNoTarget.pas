unit PassivePropNoTarget;

interface
uses PassiveProp, Classes ;

type
  TPassivePropNoTarget = class(TPassiveProp)
  public
    constructor Create(Params:TStringList) ; override ;
  end;

implementation
uses simple_oper ;

{ TPassivePropNoTarget }

constructor TPassivePropNoTarget.Create(Params: TStringList);
begin
  inherited Create(Params);
end;

initialization

  RegisterPassiveProp(TPassivePropNoTarget) ;

end.
