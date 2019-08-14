unit MetaActionHarvest;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionHarvest = class(TMetaAction)
  private
    BuildObject:string ;
  public
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses ObjModule, FoodResource, StoneResource ;
{ TMetaActionHarvest }

function TMetaActionHarvest.Apply(Cell: TCell): Boolean;
begin
  if Cell.IsEmpty() then Exit ;

  if Cell._Object is TStoneResource then begin
    BF.IncStone(TStoneResource(Cell._Object).GetStoneCount()) ;
    Cell.ClearObject() ;
  end
  else
  if Cell._Object is TFoodResource then begin
    BF.IncFood(TFoodResource(Cell._Object).GetFoodCount()) ;
    Cell.ClearObject() ;
  end;
end;

function TMetaActionHarvest.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if Cell.IsEmpty then begin
    Result:=False ;
    errmsg:='Нет ресурса для сбора!' ;
  end
  else
  if not Cell._Object.IsResource then begin
    Result:=False ;
    errmsg:='Нет ресурса для сбора!' ;
  end
  else
    Result:=True ;
end;

initialization

  RegisterMetaAction(TMetaActionHarvest) ;

end.
