unit MetaActionHeal;

interface
uses MetaAction, BattleField, Classes, MinMaxValues ;

type
  TMetaActionHeal = class(TMetaAction)
  private
    HealValue:TMinMaxValues ;
    IsAbsolute:Boolean ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, PonyUnits, ObjModule, HitViewer ;

{ TMetaActionHeal }

function TMetaActionHeal.Apply(Cell: TCell): Boolean;
var heal:Integer ;
begin
  Result:=False ;
  if not (Cell._Object is TPonyUnit) then Exit ;

  if IsAbsolute then
    heal:=TPonyUnit(Cell._Object).GetMaxHealth-TPonyUnit(Cell._Object).GetHealth
  else
    heal:=HealValue.GetRndBetween ;

  if (heal>0)and(TPonyUnit(Cell._Object).GetHealth<TPonyUnit(Cell._Object).GetMaxHealth) then
    if TPonyUnit(Cell._Object).IncHealth(heal) then begin
      HV.addNewHit(Cell,hsGood,heal) ;
      Result:=True ;
    end;
end;

function TMetaActionHeal.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not (Cell._Object is TPonyUnit) then begin
    Result:=False ;
    errmsg:='Нет пони для лечения' ;
  end
  else
    Result:=True ;
end;

constructor TMetaActionHeal.Create(Params: TStringList);
begin
  inherited Create(Params);
  HealValue:=TMinMaxValues.Create(
    StrToIntWt0(params.Values['MinValue']),
    StrToIntWt0(params.Values['MaxValue'])) ;
  IsAbsolute:=params.Values['Absolute']='true' ;  
end;

initialization

  RegisterMetaAction(TMetaActionHeal) ;

end.
