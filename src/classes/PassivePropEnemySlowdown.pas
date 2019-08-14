unit PassivePropEnemySlowdown;

interface
uses PassiveProp, Classes ;

type
  TPassivePropEnemySlowdown = class(TPassiveProp)
  public
    SlowdownDist:Integer ;
    constructor Create(Params:TStringList) ; override ;
    function AddInfo():string ; override ;
  end;

implementation
uses simple_oper, SysUtils ;

{ TPassivePropEnemySlowdown }

function TPassivePropEnemySlowdown.AddInfo: string;
begin
  Result:='Замедление врагов: радиус '+IntToStr(SlowdownDist) ;
end;

constructor TPassivePropEnemySlowdown.Create(Params: TStringList);
begin
  inherited Create(Params);
  SlowdownDist:=StrToIntWt0(Params.Values['Dist']) ;
end;

initialization

  RegisterPassiveProp(TPassivePropEnemySlowdown) ;

end.
