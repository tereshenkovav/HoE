unit MetaActionRepair;

interface
uses MetaAction, BattleField, Classes, MinMaxValues ;

type
  TMetaActionRepair = class(TMetaAction)
  private
    RestoreValue:Integer ;
    IsAbsolute:Boolean ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, Buildings, ObjModule, HitViewer ;

{ TMetaActionRepair }

function TMetaActionRepair.Apply(Cell: TCell): Boolean;
var rest:Integer ;
begin
  Result:=False ;
  if not (Cell._Object is TBuilding) then Exit ;

  if not TBuilding(Cell._Object).IsReparable then Exit ;

  if IsAbsolute then
    rest:=TBuilding(Cell._Object).MaxHealth-TBuilding(Cell._Object).Health
  else
    rest:=RestoreValue ;

  if (rest>0)and(TBuilding(Cell._Object).Health<TBuilding(Cell._Object).MaxHealth) then
  if TBuilding(Cell._Object).Repair(rest) then begin
    HV.addNewHit(Cell,hsGood,rest) ;
    Result:=True ;
  end;
end;

function TMetaActionRepair.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not (Cell._Object is TBuilding) then begin
    Result:=False ;
    errmsg:='Чинить можно только здания' ;
  end
  else
  if not TBuilding(Cell._Object).IsReparable then begin
    Result:=False ;
    errmsg:='Этот объект не подлежит починке' ;
  end
  else
    Result:=True ;
end;

constructor TMetaActionRepair.Create(Params: TStringList);
begin
  inherited Create(Params);
  RestoreValue:=StrToIntWt0(params.Values['Value']) ;
  IsAbsolute:=params.Values['Absolute']='true' ;
end;

initialization

  RegisterMetaAction(TMetaActionRepair) ;

end.

