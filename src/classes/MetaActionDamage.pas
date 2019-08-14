unit MetaActionDamage;

interface
uses MetaAction, BattleField, Classes, MinMaxValues ;

type
  TMetaActionDamage = class(TMetaAction)
  private
    DamageValue:TMinMaxValues ;
    IsAbsolute:Boolean ;
    Divide:Integer ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, MonsterUnits, ObjModule, HitViewer ;

{ TMetaActionDamage }

function TMetaActionDamage.Apply(Cell: TCell): Boolean;
var damage:Integer ;
    iskilled,z:Boolean ;
begin
  Result:=False ;
  if not Cell.IsMonster() then Exit ;

  if IsAbsolute then
    z:=TMonsterUnit(Cell._Object).DecHealthForKill(damage,iskilled)
  else begin
    if Divide>0 then
      damage:=Round(TMonsterUnit(Cell._Object).GetHealth*(Divide/100)) - 1  
    else
      damage:=DamageValue.GetRndBetween ;
    z:=TMonsterUnit(Cell._Object).DecHealth(damage,iskilled) ;
  end;

  if z then begin
    HV.AddNewHit(Cell,hsGood,-damage);
    if iskilled then Cell.ClearObject ;
  end;

  Result:=True ;
end;

function TMetaActionDamage.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsMonster then begin
    Result:=False ;
    errmsg:='Нет врагов для атаки' ;
  end
  else
    Result:=True ;
end;

constructor TMetaActionDamage.Create(Params: TStringList);
begin
  inherited Create(Params);
  DamageValue:=TMinMaxValues.Create(
    StrToIntWt0(params.Values['MinValue']),
    StrToIntWt0(params.Values['MaxValue'])) ;
  IsAbsolute:=params.Values['Absolute']='true' ;
  Divide:=StrToIntWt0(params.Values['Divide']) ;    
end;

initialization

  RegisterMetaAction(TMetaActionDamage) ;

end.
