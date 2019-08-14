unit ObjectMover ;

interface
uses BattleField ;

type
  TObjectMover = class
  private
    delay,pause:Single ;
    active:Boolean ;
    //_CellStart:TCell ;
    CellList:TCellListNoOwn ;
    poz:Integer ;
    _BF:TBattleField ;
    procedure DoNextStep() ;
  public
    constructor Create(BF:TBattleField; MS_BY_STEP:Integer) ;
    procedure RunMovingProcess(CellStart:TCell;
      ACellList:TCellListNoOwn) ;
    function IsMovingProcess():Boolean ;
    procedure StopMovingProcess() ;
    procedure Update(dt:Single) ;
  end ;

implementation
uses StepRules ;

{ TObjectMover }

constructor TObjectMover.Create(BF:TBattleField; MS_BY_STEP: Integer);
begin
  _BF:=BF ;
  delay:=MS_BY_STEP/1000 ;
  active:=False ;
end;

procedure TObjectMover.DoNextStep;
var dx,dy:Single ;
    d:Integer ;
begin

  //[!] Жирное дублирование с CellFinder 
  d:=TStepRules.GetStepNeed(CellList[poz+1]._Terrain,CellList[poz]._Object) ;
  if not CellList[poz]._Object.IsFlyer then
    if CellList[poz+1].IsSlowdownCell() then d:=6 ;

  CellList[poz]._Object.DecStep(d) ;

  CellList[poz].TransactObject(CellList[poz+1]) ;
  //if _BF.GetActiveCell=CellList[poz] then
  //  _BF.setActiveCell(CellList[poz+1]);

  Inc(poz) ;

  if poz<CellList.Count-1 then begin
    pause:=delay ;

    dx:=CellList[poz+1].XC-CellList[poz].XC ;
    dy:=CellList[poz+1].YC-CellList[poz].YC ;
    CellList[poz]._Object.startShiftView(0,0,dx/delay,dy/delay);
  end
  else begin
    active:=False ;
    if not CellList[poz].IsEmpty() then begin
      CellList[poz]._Object.stopShiftView() ;
      if CellList[poz]._Object.CanRule then
         _BF.setActiveCell(CellList[poz]) ;
    //_BF.clearActiveCell() ;
    end ;
  end;
end;

function TObjectMover.IsMovingProcess: Boolean;
begin
  Result:=active ;
end;

procedure TObjectMover.RunMovingProcess(CellStart: TCell;
  ACellList: TCellListNoOwn);
var dx,dy:Single ;
begin
  CellList:=ACellList ;

  poz:=0 ;
  active:=True ;
  CellList.Insert(CellStart,0) ;

  if CellList.Count=1 then begin
    active:=False ;
    Exit ;
  end;

  pause:=delay ;

  // Дублирование
  dx:=CellList[poz+1].XC-CellList[poz].XC ;
  dy:=CellList[poz+1].YC-CellList[poz].YC ;
  CellList[poz]._Object.startShiftView(0,0,dx/delay,dy/delay);

  //DoNextStep() ;
end;

procedure TObjectMover.StopMovingProcess;
begin
  active:=False ;
end;

procedure TObjectMover.Update(dt: Single);
begin
  if active then begin
    pause:=pause-dt ;
    if pause<=0 then DoNextStep() ;
  end;
end;

end.