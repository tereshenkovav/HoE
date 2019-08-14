unit StepActionCreateRes;

interface
uses StepAction, Classes, BattleField, MinMaxValues ;

type
  TStepActionCreateRes = class(TStepAction)
  private
    next:Integer ;
    ResValue:TMinMaxValues ;
    ResType:string ;
    PeriodDef:Integer ;
    Dist:Integer ;
  public
    function Apply(Cell:TObject):Boolean ; override ;
    constructor Create(Params:TStringList) ; override ;
  end;

implementation
uses ObjModule, GameObject, SysUtils, simple_oper, CellFinder ;

{ TStepActionCreateRes }

function TStepActionCreateRes.Apply(Cell: TObject): Boolean;
var RList:TCellListNoOwn ;
    TargetCell:TCell ;
    idx:Integer ;
    z:Boolean ;
    GO:TGameObject ;
    Params:TStringList ;
begin
  Dec(next) ;
  if next>0 then Exit ;

  RList:=GetCellFinder().GetCellsOnDistN(TCell(Cell),
    Dist,[spIgnoreTerrain,spIncludeBusyCell]);

  if RList.Count=0 then Exit ;

  idx:=Round(Random(RList.Count)) ;

  if RList[idx].IsEmpty() then begin
    Params:=TStringList.Create ;
    Params.Values['exactcount']:=IntToStr(ResValue.GetRndBetween()) ;
    Params.Values['EnemyTarget']:='true' ;
    GO:=GetGOFactory(BF).CreateGameObject(ResType,Params) ;
    Params.Free ;
    if GO<>nil then BF.AddGameObject(GO,RList[idx]) ;
  end ;

  next:=PeriodDef ;

  RList.Free ;
end;

constructor TStepActionCreateRes.Create(Params: TStringList);
begin
  inherited Create(Params);
  ResValue:=TMinMaxValues.Create(
    StrToIntWt0(params.Values['MinValue']),
    StrToIntWt0(params.Values['MaxValue'])) ;
  Dist:=StrToIntWt0(params.Values['Dist']) ;
  PeriodDef:=StrToIntWt0(params.Values['PeriodDef']) ;
  next:=PeriodDef ;
  ResType:=params.Values['ResType'] ;
end;

initialization

  RegisterStepAction(TStepActionCreateRes) ;

end.
