unit StepActionRestore;

interface
uses StepAction, Classes, BattleField, MinMaxValues ;

type
  TStepActionRestore = class(TStepAction)
  private
    RestoreValue:TMinMaxValues ;
    IsAbsolute:Boolean ;
    Target:Integer ;
  public
    Dist:Integer ;
    function Apply(Cell:TObject):Boolean ; override ;
    constructor Create(Params:TStringList) ; override ;
  end;

implementation
uses ObjModule, simple_oper, CellFinder, MonsterUnits, HitViewer, PonyUnits ;

{ TStepActionRestore }

function TStepActionRestore.Apply(Cell: TObject): Boolean;
var RList:TCellListNoOwn ;
    TargetCell:TCell ;
    i,comp:Integer ;
    z:Boolean ;
    rest:Integer ;
    PU:TPonyUnit ;
begin
  RList:=GetCellFinder().GetCellsOnDistN(TCell(Cell),
    Dist,[spIgnoreTerrain,spIncludeBusyCell]);

  if RList.Count=0 then Exit ;

  RList.SortByQDistanceTo(TCell(Cell)) ;

  comp:=0 ;
  for i := 0 to RList.Count - 1 do
    if RList[i].IsPonyUnit() then begin
      TargetCell:=RList[i] ;
      PU:=TPonyUnit(TargetCell._Object) ;
      if IsAbsolute then
        rest:=PU.GetMaxEnergy-PU.GetEnergy
      else
        rest:=RestoreValue.GetRndBetween ;

      if (rest>0)and(PU.GetEnergy<PU.GetMaxEnergy) then
        if PU.IncEnergy(rest) then begin
          HV.addNewHit(TargetCell,hsEnergy,rest) ;
          Inc(comp) ;
          Result:=True ;
        end;

      if comp>=Target then Break ;
    end;

end;

constructor TStepActionRestore.Create(Params: TStringList);
begin
  inherited Create(Params);
  RestoreValue:=TMinMaxValues.Create(
    StrToIntWt0(params.Values['MinValue']),
    StrToIntWt0(params.Values['MaxValue'])) ;
  IsAbsolute:=params.Values['Absolute']='true' ;
  Dist:=StrToIntWt0(params.Values['Dist']) ;
  Target:=StrToIntWt0(params.Values['Target']) ;
end;

initialization

  RegisterStepAction(TStepActionRestore) ;

end.
