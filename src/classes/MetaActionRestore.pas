unit MetaActionRestore;

interface
uses MetaAction, BattleField, Classes, MinMaxValues ;

type
  TMetaActionRestore = class(TMetaAction)
  private
    RestoreValue:TMinMaxValues ;
    IsAbsolute:Boolean ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, PonyUnits, ObjModule, HitViewer ;

{ TMetaActionRestore }

function TMetaActionRestore.Apply(Cell: TCell): Boolean;
var rest:Integer ;
begin
  Result:=False ;
  if not (Cell._Object is TPonyUnit) then Exit ;

  if IsAbsolute then
    rest:=TPonyUnit(Cell._Object).GetMaxEnergy-TPonyUnit(Cell._Object).GetEnergy
  else
    rest:=RestoreValue.GetRndBetween ;

  if (rest>0)and(TPonyUnit(Cell._Object).GetEnergy<TPonyUnit(Cell._Object).GetMaxEnergy) then
  if TPonyUnit(Cell._Object).IncEnergy(rest) then begin
    HV.addNewHit(Cell,hsEnergy,rest) ;
    Result:=True ;
  end;
end;

function TMetaActionRestore.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not (Cell._Object is TPonyUnit) then begin
    Result:=False ;
    errmsg:='Нет пони для восстановления' ;
  end
  else
    Result:=True ;
end;

constructor TMetaActionRestore.Create(Params: TStringList);
begin
  inherited Create(Params);
  RestoreValue:=TMinMaxValues.Create(
    StrToIntWt0(params.Values['MinValue']),
    StrToIntWt0(params.Values['MaxValue'])) ;
  IsAbsolute:=params.Values['Absolute']='true' ;  
end;

initialization

  RegisterMetaAction(TMetaActionRestore) ;

end.

