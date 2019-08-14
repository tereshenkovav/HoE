unit StepActionDamage;

interface
uses StepAction, Classes, BattleField, MinMaxValues ;

type
  TStepActionDamage = class(TStepAction)
  private
    DamageValue:TMinMaxValues ;
    IsAbsolute:Boolean ;
    Target:Integer ;
  public
    Dist:Integer ;
    function Apply(Cell:TObject):Boolean ; override ;
    constructor Create(Params:TStringList) ; override ;
  end;

implementation
uses ObjModule, simple_oper, CellFinder, MonsterUnits, HitViewer ;

{ TStepActionDamage }

function TStepActionDamage.Apply(Cell: TObject): Boolean;
var RList:TCellListNoOwn ;
    TargetCell:TCell ;
    i,comp:Integer ;
    z:Boolean ;
    damage:Integer ;
    iskilled:Boolean ;
begin
  RList:=GetCellFinder().GetCellsOnDistN(TCell(Cell),
    Dist,[spIgnoreTerrain,spIncludeBusyCell]);

  if RList.Count=0 then Exit ;

  RList.SortByQDistanceTo(TCell(Cell)) ;

  comp:=0 ;
  for i := 0 to RList.Count - 1 do
    if RList[i].IsMonster() then begin
      TargetCell:=RList[i] ;

      if IsAbsolute then
        z:=TMonsterUnit(TargetCell._Object).DecHealthForKill(damage,iskilled)
      else begin
        damage:=DamageValue.GetRndBetween ;
        z:=TMonsterUnit(TargetCell._Object).DecHealth(damage,iskilled) ;
      end;

      if z then begin
        HV.AddNewHit(TargetCell,hsGood,-damage);
        if iskilled then TargetCell.ClearObject ;
      end;

      Inc(comp) ;
      if comp>=Target then Break ;
    end;

end;

constructor TStepActionDamage.Create(Params: TStringList);
begin
  inherited Create(Params);
  DamageValue:=TMinMaxValues.Create(
    StrToIntWt0(params.Values['MinValue']),
    StrToIntWt0(params.Values['MaxValue'])) ;
  IsAbsolute:=params.Values['Absolute']='true' ;  
  Dist:=StrToIntWt0(params.Values['Dist']) ;
  Target:=StrToIntWt0(params.Values['Target']) ;
end;

initialization

  RegisterStepAction(TStepActionDamage) ;

end.
