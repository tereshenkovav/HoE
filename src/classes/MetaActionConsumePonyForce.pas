unit MetaActionConsumePonyForce;

interface
uses MetaAction, BattleField, Classes, MinMaxValues ;

type
  TMetaActionConsumePonyForce = class(TMetaAction)
  private
    MinValue:Integer ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, PonyUnits, ObjModule, HitViewer, SysUtils ;

{ TMetaActionConsumePonyForce }

function TMetaActionConsumePonyForce.Apply(Cell: TCell): Boolean;
var value,delta:Integer ;
    pu:TPonyUnit ;
begin
  Result:=False ;

  if not (Cell._Object is TPonyUnit) then Exit ;

  pu:=TPonyUnit(Cell._Object) ;

  value:=pu.GetMaxHealth div 2 ;
  if value<MinValue then value:=MinValue ;
  delta:=value-pu.GetHealth ;
  if pu.IncHealth(delta,True) then begin
    HV.addNewHit(Cell,hsBad,value) ;
    Result:=True ;
  end;
  pu.SetMaxHealth(value) ;

  value:=pu.GetMaxEnergy div 2 ;
  if value<MinValue then value:=MinValue ;
  delta:=value-pu.GetEnergy ;
  if pu.IncEnergy(delta,True) then begin
    Result:=True ;
  end;
  pu.SetMaxEnergy(value) ;

end;

function TMetaActionConsumePonyForce.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
var pu:TPonyUnit ;
begin
  if not (Cell._Object is TPonyUnit) then begin
    Result:=False ;
    errmsg:='Нет пони для применения' ;
  end
  else begin
    pu:=TPonyUnit(Cell._Object) ;
    if (pu.GetHealth<pu.GetMaxHealth)or(pu.GetEnergy<pu.GetMaxEnergy) then begin
      Result:=False ;
      errmsg:='Забирать силы можно только у полностью отдохнувшей и здоровой пони' ;
    end
    else begin
      if (pu.GetHealth<=MinValue)or(pu.GetEnergy<=MinValue) then begin
        Result:=False ;
        errmsg:='С этой пони нельзя больше забирать силы' ;
      end
      else
        Result:=True ;
    end;
  end;
end;

constructor TMetaActionConsumePonyForce.Create(Params: TStringList);
begin
  inherited Create(Params);
  MinValue:=StrToIntWt0(params.Values['MinValue']) ;
end;

initialization

  RegisterMetaAction(TMetaActionConsumePonyForce) ;

end.
