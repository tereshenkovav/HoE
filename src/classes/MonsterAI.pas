unit MonsterAI ;

interface
uses BattleField, MonsterUnits, GameObject, LinkedList, Constants, PonyAction, CommonClasses ;

type
  TEmulation = (OnlyEmulate,FullAction) ;

  TMonsterBattleTask = class
  public
    _Target:TGameObject ;
    // –азрешать атаковать иные цели, если в радиусе немедленной атаки
    AllowImmediateAttackOtherUnit:Boolean ;
    // –азрешать атаковать иные цели, если в радиусе хода
    AllowOneStepAttackOtherUnit:Boolean ;
    // ќтключение даст "охранный" режим
    AllowWalkToTarget:Boolean ;
  end;

  TMonsterAI = class
  private
    LinkMO:TLinkedList ;
    ListActiveMonster:TGameObjectListNoOwn ;
    _BF:TBattleField ;
    Active:Boolean ;
    TekI:Integer ;
    arr_focused:array[0..255] of Boolean ;
    arr_burned:array[0..255] of Boolean ;
    
    function GetBattleTaskForMonster(Monster:TMonsterUnit):TMonsterBattleTask ;
    function CreateTargetList():TGameObjectListNoOwn ;
    function ExecTekMonster(out Acted:Boolean;
      Emulation:TEmulation=FullAction):Boolean;

    procedure DoAttackFromTo(FromCell,ToCell:TCell) ;
    procedure AssignBattleTaskForMonster(M:TMonsterUnit) ;
    function CurrentMonster():TMonsterUnit ;
    procedure TestAndAssignBattleTaskForMonster(M:TMonsterUnit) ;
  public
    constructor Create(BF:TBattleField) ;
    destructor Destroy ; override ;
    procedure BeginStep() ;
    function IsStepFinished():Boolean ;
    function StepProgress():Single ;
    procedure Update(dt:Single) ;
    procedure FireTotalAttack() ;
    procedure HoldMonsterToGround(M:TMonsterUnit) ;
  end ;

implementation
uses ObjectMover, PonyUnits, TAVHGEUtils, SysUtils, NeutralUnits,
  CellFinder, ObjModule, HitViewer, CommonProc ;

{ TMonsterAI }

constructor TMonsterAI.Create(BF: TBattleField);
begin
  _BF:=BF ;
  _BF.SetMAI(Self) ;
  LinkMO:=TLinkedList.Create(TMonsterUnit,TGameObject,False) ;
  ListActiveMonster:=TGameObjectListNoOwn.Create ;
  Active:=False ;
end;

destructor TMonsterAI.Destroy;
begin
  ListActiveMonster.Free ;
  LinkMO.Free ;
  inherited Destroy ;
end;

procedure TMonsterAI.DoAttackFromTo(FromCell, ToCell: TCell);
var iskilled:Boolean ;
    attackvalue:Integer ;
    ae:TAttackEvent ;
    RList:TCellListNoOwn ;
    i:Integer ;
    focused:Boolean ;
begin
  attackvalue:=TMonsterUnit(FromCell._Object).GenAttackValue() ;

  focused:=False ;

  if attackvalue>0 then begin
  if not focused then begin
    BF.ImmediateRunTo(ToCell.XonMap,ToCell.YonMap);
    focused:=True ;
  end;
  if (ToCell._Object is TPonyUnit) then begin
    TPonyUnit(ToCell._Object).DecHealth(attackvalue,iskilled) ;
    if TMonsterUnit(FromCell._Object).IsStun() then
      TPonyUnit(ToCell._Object).SetStun(1) ;
    HV.AddNewHit(ToCell,hsBad,-attackvalue) ;
  end
  else
  begin
    ToCell._Object.DoAttackFromEnemy(attackvalue,ae) ;
    _BF.AddAttackEvent(ae) ;
    HV.AddNewHit(ToCell,hsBad,ae.msg) ;
  end;
  end;

  if TMonsterUnit(FromCell._Object).IsSplashAttack then begin
    RList:=GetCellFinder().GetCellsOnDistN(ToCell,
      TMonsterUnit(FromCell._Object).SplashAttackRadius,
      [spIgnoreTerrain,spIncludeBusyCell]) ;
    RList.Delete(ToCell);
    for i := 0 to RList.Count - 1 do
      if not RList[i].IsEmpty() then
        if RList[i]._Object is TPonyUnit then begin
          attackvalue:=TMonsterUnit(FromCell._Object).GenSplashAttackValue() ;
          TPonyUnit(RList[i]._Object).DecHealth(attackvalue,iskilled) ;
          if not focused then begin
            BF.ImmediateRunTo(ToCell.XonMap,ToCell.YonMap);
            focused:=True ;
          end;
          HV.AddNewHit(RList[i],hsBad,-attackvalue) ;
        end;
    RList.Free ;
  end;


end;

function TMonsterAI.ExecTekMonster(out Acted:Boolean;
  Emulation:TEmulation=FullAction):Boolean;

function CanAttackFromCell(CellSrc:TCell; out TargetCell:TCell):Boolean ;
var i:Integer ;
begin
  Result:=False ;
  TargetCell:=nil ;
  for i := 0 to CellSrc.GetLinkCount-1 do
    if not CellSrc.GetLinked(i).IsEmpty then
      if CellSrc.GetLinked(i)._Object.IsEnemyTarget() then begin
        Result:=True ;
        TargetCell:=CellSrc.GetLinked(i) ;
        Exit ;
      end;
end ;

function CanAttackConcreteTarget(CellSrc:TCell; const TargetCell:TCell):Boolean ;
var i:Integer ;
begin
  Result:=False ;
  for i := 0 to CellSrc.GetLinkCount-1 do
    if CellSrc.GetLinked(i)=TargetCell then
      Result:=True ;
end ;

function RunMonsterMoving(CellDst:TCell; const OnlyTest:Boolean=False):Boolean ;
var RunList:TCellListNoOwn ;
begin
  RunList:=_BF.CreateListCellsOnWayForPonyWalk(_BF.GetCellByObject(CurrentMonster()),
       CellDst,CurrentMonster().GetMaxStep()) ;

  if OnlyTest then
    Result:=RunList.Count>0 
  else begin
    TObjectMover(_BF.GetOM).RunMovingProcess
      (_BF.GetCellByObject(CurrentMonster()),RunList) ;
    Result:=True ;
  end ;

end ;

procedure ProcessBurn(out iskilled:Boolean) ;
var delta:Integer ;
    Cell:TCell ;
begin
  CurrentMonster().DecHealthByBurn(delta,iskilled) ;
  Cell:=_BF.GetCellByObject(CurrentMonster()) ;
  HV.AddNewHit(Cell,hsGood,-delta) ;
end ;

var CellList:TCellListNoOwn ;
    CellStart:TCell ;
    TargetCellFinded,NextCell:TCell ;
    i:Integer ;
    minr,r:Single ;

    StepLength:Integer ;
    BT:TMonsterBattleTask ;
    iskilled:Boolean ;
    z:Boolean ;
begin
  Result:=True ;
  acted:=False ;

  TestAndAssignBattleTaskForMonster(CurrentMonster) ;

  try

  if CurrentMonster().IsFreezed() then Exit ;
  if CurrentMonster().IsSleeped() then Exit ;
  if CurrentMonster().IsPassive() then Exit ;
  

  if Emulation=FullAction then
    if CurrentMonster().IsBurned then
      if not arr_burned[TekI] then begin
        arr_burned[TekI]:=True ;
        ProcessBurn(iskilled) ;
        if iskilled then begin
          _BF.GetCellByObject(CurrentMonster).ClearObject ;
          Exit ;
        end;
      end;

  StepLength:=CurrentMonster().GetMaxStep() ;
  BT:=GetBattleTaskForMonster(CurrentMonster()) ;
  CellStart:=_BF.GetCellByObject(CurrentMonster()) ;

  except
    on E:Exception do begin
      mHGE.System_Log('Error EM step 0: '+E.Message+', tek='+IntToStr(TekI)+' emul='+IntToStr(ord(Emulation)));
        z:=True ;
      end;
  end;
  // 1. ѕроверка возможности немедленной атаки на цель
  try
  if CanAttackConcreteTarget(CellStart,_BF.GetCellByObject(BT._Target)) then begin
    if Emulation=FullAction then
      DoAttackFromTo(CellStart,_BF.GetCellByObject(BT._Target)) ;
    acted:=True ;
    Exit ;
  end;
    except
      on E:Exception do begin
        mHGE.System_Log('Error EM step 1: '+E.Message+', tek='+IntToStr(TekI)+' emul='+IntToStr(ord(Emulation)));
        z:=True ;
      end;
    end;


  // 1.1. ѕроверка возможности немедленной атаки на кого-нибудь кроме
  try
  if BT.AllowImmediateAttackOtherUnit then
    if CanAttackFromCell(CellStart,TargetCellFinded) then begin
      if Emulation=FullAction then
        DoAttackFromTo(CellStart,TargetCellFinded) ;
      acted:=True ;
      Exit ;
    end;
      except
      on E:Exception do begin
        mHGE.System_Log('Error EM step 1.1: '+E.Message+', tek='+IntToStr(TekI)+' emul='+IntToStr(ord(Emulation)));
        z:=True ;
      end;
    end;

  // 2. ѕроверка возможности приблизитьс€ к цели дл€ атаки
  try
  CellList:=_BF.GetCellsOnDistNForPonyWalk(CellStart,StepLength) ;
  for i := 0 to CellList.Count - 1 do
    if CanAttackConcreteTarget(CellList[i],_BF.GetCellByObject(BT._Target)) then begin
      if Emulation=FullAction then
        RunMonsterMoving(CellList[i]) ;
      acted:=True ;
      Result:=False ;
      Exit ;
    end;
      except
      on E:Exception do begin
        mHGE.System_Log('Error EM step 2: '+E.Message+', tek='+IntToStr(TekI));
        z:=True ;
      end;
    end;

  // 2.1. ѕроверка возможности приблизитьс€ к кому-нибудь дл€ атаки
  try
  if BT.AllowOneStepAttackOtherUnit then
    for i := 0 to CellList.Count - 1 do
      if CanAttackFromCell(CellList[i],TargetCellFinded) then begin
        if Emulation=FullAction then
          RunMonsterMoving(CellList[i]) ;
        Result:=False ;
        acted:=True ;
        Exit ;
      end;
      except
      on E:Exception do begin
        mHGE.System_Log('Error EM step 2.1: '+E.Message+', tek='+IntToStr(TekI));
        z:=True ;
      end;
    end;

  // 3. –асчет продвижени€, чтобы оказатьс€ ближе к цели
  if CellList.Count=0 then Exit ;

  if BT.AllowWalkToTarget then begin

  if BT._Target=nil then begin
    mHGE.System_Log('Empty target for monster');
    Exit ;
  end;

  if _BF.GetCellByObject(BT._Target)=nil then begin
    mHGE.System_Log('Error get cell for target: '+TPonyUnit(BT._Target).Code);
  end;

  try

  minr:=CellList[0].CalcQDistanceTo(_BF.GetCellByObject(BT._Target)) ;
  NextCell:=CellList[0] ;
  for i := 1 to CellList.Count - 1 do begin
    r:=CellList[i].CalcQDistanceTo(_BF.GetCellByObject(BT._Target)) ;
    if r<minr then begin
      minr:=r ;
      NextCell:=CellList[i] ;
    end;
  end;
      except
      on E:Exception do begin
        mHGE.System_Log('Error EM step 3: '+E.Message+', tek='+IntToStr(TekI));
        z:=True ;
      end;
    end;

    try
      if Emulation=FullAction then begin
        RunMonsterMoving(NextCell) ;
        acted:=True ;
      end
      else begin
        acted:=RunMonsterMoving(NextCell,True) ;
      end;
    except
      on E:Exception do begin
        mHGE.System_Log('Error EM step 3_: '+E.Message+', tek='+IntToStr(TekI));
        z:=True ;
      end;
    end;


  end; // if BT.AllowWalkToTarget

end;

procedure TMonsterAI.FireTotalAttack;
var i:Integer ;
begin
  ListActiveMonster.Clear ;
  for i := 0 to _BF.CellCount - 1 do
    if not _BF.GetCell(i).IsEmpty then
      if _BF.GetCell(i)._Object is TMonsterUnit then begin
        if TMonsterUnit(_BF.GetCell(i)._Object).IsPassive then Continue ;
        if TMonsterUnit(_BF.GetCell(i)._Object).Tag='nofired' then Continue ;

        AssignBattleTaskForMonster(TMonsterUnit(_BF.GetCell(i)._Object)) ;

        with TMonsterBattleTask(LinkMO[
          TMonsterUnit(_BF.GetCell(i)._Object)]) do begin
            AllowImmediateAttackOtherUnit:=True ;
            AllowOneStepAttackOtherUnit:=True ;
            AllowWalkToTarget:=True ;
        end;
        TMonsterUnit(_BF.GetCell(i)._Object).ClearHoldGround() ;
      end;
end;

procedure TMonsterAI.HoldMonsterToGround(M:TMonsterUnit) ;
var BT:TMonsterBattleTask ;
begin
  BT:=TMonsterBattleTask(LinkMO[M]) ;
  if BT<>nil then begin
    BT.AllowImmediateAttackOtherUnit:=True ;
    BT.AllowOneStepAttackOtherUnit:=True ;
    BT.AllowWalkToTarget:=False ;
  end;
end;

function SortGOByRank(p1,p2:Pointer):Integer ;
begin
  Result:=TGameObject(p2).GetRank() - TGameObject(p1).GetRank();
end;

procedure TMonsterAI.AssignBattleTaskForMonster(M: TMonsterUnit);
var List:TGameObjectListNoOwn ;
    BT:TMonsterBattleTask ;
    CellList:TCellListNoOwn ;
    i:Integer ;
    bigrank:Integer ;
begin
  List:=CreateTargetList() ;
  if List.Count=0 then begin
    mHGE.System_Log('Empty target list for monster: '+M.Code);
    Exit ;
  end;

  // «десь должна быть модель, выбирающа€ правильные цели
  // и боевые задачи, исход€ из установок кампании
  // и параметров отдельных монстров

  // “екуща€ модель - случайна€ цель и разрешено атаковать все
  BT:=TMonsterBattleTask.Create() ;
  case M.MonsterStrategy of
    msDefault: BT._Target:=List[Round(Random(List.Count))] ;
    msAttackNearFirst: begin
      CellList:=TCellListNoOwn.Create ;
      for i := 0 to List.Count - 1 do
        CellList.AddIfAssigned(BF.GetCellByObject(List[i])) ;
      CellList.SortByQDistanceTo(BF.GetCellByObject(M));
      BT._Target:=CellList[0]._Object ;
      CellList.Free ;
    end;
    msAttackByRank: begin
      List.CustomSort(SortGOByRank) ;
      bigrank:=List[0].GetRank() ;
      for i := 1 to List.Count - 1 do
        if List[i].GetRank()<>bigrank then Break ;
      if i>List.Count then i:=List.Count ;
      BT._Target:=List[Round(Random(i))] ;
    end;
    else
      BT._Target:=List[Round(Random(List.Count))] ;
  end;

  BT.AllowImmediateAttackOtherUnit:=not M.IsPassive() ;
  BT.AllowOneStepAttackOtherUnit:=not M.IsPassive() ;
  BT.AllowWalkToTarget:=not (M.IsHoldGround() or M.IsPassive()) ;

  if LinkMO[M]<>nil then LinkMO.Delete(M) ;
  LinkMO.Add(BT,M) ;

  mHGE.System_Log('Set target for monster: '+BT._Target.SpriteTag);

  List.Free ;
end;

procedure TMonsterAI.BeginStep;
var i:Integer ;
    M:TMonsterUnit ;
    Cell:TCell ;
    BT:TMonsterBattleTask;
begin
  // ќчистка флагов всех пони "не было атаки"
  for i := 0 to _BF.CellCount - 1 do
    if not _BF.GetCell(i).IsEmpty then
      if _BF.GetCell(i)._Object is TPonyUnit then
        TPonyUnit(_BF.GetCell(i)._Object).ClearUnderAttack() ;

  ListActiveMonster.Clear ;
  for i := 0 to _BF.CellCount - 1 do
    if not _BF.GetCell(i).IsEmpty then
      if _BF.GetCell(i)._Object is TMonsterUnit then begin
        M:=TMonsterUnit(_BF.GetCell(i)._Object) ;
        if not M.SkipStep then
          ListActiveMonster.Add(M)
        else
          M.SkipStep:=False ;
      end;

  for i := 0 to ListActiveMonster.Count - 1 do begin
     M:=TMonsterUnit(ListActiveMonster[i]) ;
     TestAndAssignBattleTaskForMonster(M) ;
  end ;

  if ListActiveMonster.Count>0 then begin
    Active:=True ;
    TekI:=0 ;
    for i := 0 to 255 do begin
      arr_focused[i]:=False ;
      arr_burned[i]:=False ;
    end;
  end
  else
    Active:=False ;

end;

function TMonsterAI.IsStepFinished: Boolean;
begin
  Result:=not Active ;
end;

function TMonsterAI.StepProgress: Single;
begin
  if Active then Result:=TekI/ListActiveMonster.Count else
  Result:=0 ;
end;

procedure TMonsterAI.TestAndAssignBattleTaskForMonster(M: TMonsterUnit);
var BT:TMonsterBattleTask ;
    Obj:TGameObject ;
begin
   BT:=GetBattleTaskForMonster(M) ;

   if BT=nil then
     AssignBattleTaskForMonster(M)
   else
   if BT._Target=nil then
     AssignBattleTaskForMonster(M)
   else
   if _BF.GetCellByObject(BT._Target)=nil then
     AssignBattleTaskForMonster(M) ;

   // јтаковать принудительно
   BT:=GetBattleTaskForMonster(M) ;
   if M.IsAttackedFrom(Obj) then begin
      mHGE.System_Log('monster attacked!');
      BT.AllowImmediateAttackOtherUnit:=True ;
      BT.AllowOneStepAttackOtherUnit:=True ;
      BT.AllowWalkToTarget:=True ;
      BT._Target:=Obj ;
      if _BF.GetCellByObject(BT._Target)=nil then
        AssignBattleTaskForMonster(M) ;
   end;

end;

function TMonsterAI.CreateTargetList(): TGameObjectListNoOwn;
var i:Integer ;
begin
  Result:=TGameObjectListNoOwn.Create ;
  for i := 0 to _BF.CellCount - 1 do
    if not _BF.GetCell(i).IsEmpty then
      if _BF.GetCell(i)._Object.IsEnemyTarget() then
        Result.Add(_BF.GetCell(i)._Object) ;
end;

function TMonsterAI.CurrentMonster: TMonsterUnit;
begin
  Result:=TMonsterUnit(ListActiveMonster[TekI])
end;

function TMonsterAI.GetBattleTaskForMonster(Monster: TMonsterUnit): TMonsterBattleTask;
begin
  Result:=TMonsterBattleTask(LinkMO[Monster]) ;
end;

procedure TMonsterAI.Update(dt: Single);
var acted:Boolean ;
    z:Boolean ;
begin
  if not Active then Exit ;

  if TObjectMover(_BF.GetOM).IsMovingProcess then Exit ;
  if _BF.IsOverMapMovingProcess then Exit ;
  if _BF.IsExistsTranspObjs() then Exit ;


  if TekI>=ListActiveMonster.Count then begin
    Active:=False ; Exit ;
  end;
  
  if not arr_focused[TekI] then begin
    try
    ExecTekMonster(acted,OnlyEmulate) ;
    except
      on E:Exception do
        mHGE.System_Log('Error exectekmonster emul: '+E.Message+', tek='+IntToStr(TekI));
    end;
    arr_focused[TekI]:=True ;
    if UseFollowingCamera() then
      if acted then _BF.SetFocusMovingPoint(
        _BF.GetCellByObject(ListActiveMonster[TekI])) ;
  end
  else begin
    try
    z:=ExecTekMonster(acted) ;
    except
      on E:Exception do begin
        mHGE.System_Log('Error exectekmonster real: '+E.Message+', tek='+IntToStr(TekI));
        z:=True ;
      end;
    end;

    if z then begin
      //ExecBurnMonster() ;
      Inc(TekI) ;
    end;
  end;
  
end;

end.
