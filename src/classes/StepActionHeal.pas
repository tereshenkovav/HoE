unit StepActionHeal;

interface
uses StepAction, Classes, BattleField, MinMaxValues ;

type
  TStepActionHeal = class(TStepAction)
  private
    HealValue:TMinMaxValues ;
    IsAbsolute:Boolean ;
    Target:Integer ;
  public
    Dist:Integer ;
    function Apply(Cell:TObject):Boolean ; override ;
    constructor Create(Params:TStringList) ; override ;
  end;

implementation
uses ObjModule, simple_oper, CellFinder, MonsterUnits, HitViewer, PonyUnits ;

{ TStepActionHeal }

function TStepActionHeal.Apply(Cell: TObject): Boolean;
var RList:TCellListNoOwn ;
    TargetCell:TCell ;
    i,comp:Integer ;
    z:Boolean ;
    heal:Integer ;
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
        heal:=PU.GetMaxHealth-PU.GetHealth
      else
        heal:=HealValue.GetRndBetween ;

      if (heal>0)and(PU.GetHealth<PU.GetMaxHealth) then
        if PU.IncHealth(heal) then begin
          HV.addNewHit(TargetCell,hsGood,heal) ;
          Result:=True ;
          Inc(comp) ;
        end;

      if comp>=Target then Break ;
    end;

end;

constructor TStepActionHeal.Create(Params: TStringList);
begin
  inherited Create(Params);
  HealValue:=TMinMaxValues.Create(
    StrToIntWt0(params.Values['MinValue']),
    StrToIntWt0(params.Values['MaxValue'])) ;
  IsAbsolute:=params.Values['Absolute']='true' ;
  Dist:=StrToIntWt0(params.Values['Dist']) ;
  Target:=StrToIntWt0(params.Values['Target']) ;
end;

initialization

  RegisterStepAction(TStepActionHeal) ;

end.
