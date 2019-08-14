unit BattleField ;

interface
uses Terrain, GameObject, AbstractList, contnrs, Windows, CommonClasses,
  MiniMap, Classes, KeyStrList, MessageList, BattleTask, FogManager ;

type
  TBattleField = class ;// forward

  TSearchParam = (spIncludeBusyCell,spIgnoreTerrain{,spIgnoreWater}) ;
  TSearchParams = set of TSearchParam ;

  TCell = class
  private
    idxi:Integer ;
    idxj:Integer ;
    ListLinks:TObjectList ;
    arr_links_directed:array[0..5] of TCell ;
    procedure ClearLinks() ;
    procedure AddLink(Cell:TCell; dir:Integer) ;
  public
    tmpCachedTerrain:TTerrain ;
    _Terrain:TTerrain ;
    _Object:TGameObject ;
    _BF:TBattleField ;
    FogState:TFogState ;
    showEmptyClearing:Integer ;
    tmpMapChar:char ; // Используется для того, чтобы редактор не затирал объекты,
    // установленные через спецсимволы на карте
    constructor Create(BF:TBattleField) ;
    destructor Destroy ; override ;
    function XC:Integer ;
    function YC:Integer ;
    function XwShift():Integer ;
    function YwShift():Integer ;
    function XOnMap:Integer ;
    function YOnMap:Integer ;
    function IsEmpty():Boolean ;
    procedure SetObject(GO:TGameObject) ;
    function TransactObject(CellDst:TCell):Boolean ;
    procedure ClearObject(kill:Boolean=True) ;
    function GetLinkCount():Integer ;
    function GetLinked(i:Integer):TCell ;
    function GetLinkByDir(dir:Integer):TCell ;
    function GetMostTerrainAround():TTerrain ;
    function GetMaxTranspFromSpaceAround():Integer ;
    function IsMouseIn(x,y:Integer):Boolean ;
    function IsSpace():Boolean ;
    function IsMonster():Boolean ;
    function IsPonyUnit():Boolean ;
    function IsBuilding():Boolean ;
    function GetStepNeed():Integer ;
    function IsSlowdownCell():Boolean ;
    // Процедура вычисляет "условное" расстояние до ячейки,
    // выражаемое в том, что ячейка ближе, если Q-метрика меньше
    function CalcQDistanceTo(CellDst:TCell):Single ;
    function CalCCDistanceTo(CellDst:TCell):Single ;
    function GetRealTerr():TTerrain ;
    function IsCellLinked(CellTest:TCell):Boolean ;
    function getLinkedDirs():string ;
    function IsShowObjectOnMiniMap():Boolean ;
    property CellI:Integer read idxi ;
    property CellJ:Integer read idxj ;
  end ;

  TCellList = class(TAbstractList)
  private
    function GetItem(i:Integer):TCell  ;
  public
    property Items[i:Integer]:TCell read GetItem ; default ;
  end ;

  TCellListNoOwn = class(TAbstractListNoOwn)
  private
    function GetItem(i:Integer):TCell  ;
  public
    procedure AddIfAssigned(Cell:TCell) ;
    procedure RemoveIfInList(List:TCellListNoOwn) ;
    procedure RemoveNonEmptyCells() ;
    procedure SortByQDistanceTo(Cell:TCell) ;
    property Items[i:Integer]:TCell read GetItem ; default ;
  end ;

  TMoveRes = record
    stoppedx:Boolean ;
    stoppedy:Boolean ;
  end;

  TMicroCell = class
  public
    _Terrain:TTerrain ;
    borderdir:Integer ;
    XC:Integer ;
    YC:Integer ;
    constructor Create(ATerr:TTerrain; Aborderdir,AXC,AYC:Integer) ;
  end;

  TBattleField = class
  private
    ListCells:TCellList ;
    StaticShift:TPoint ;
    Shift:TPointSingle ;
    MaxRightBottom:TPoint ;
    ActiveCell:TCell ;
    CurrentStep:Integer ;
    // Ресурсы
    Food:Integer ;
    Stone:Integer ;
    Wood:Integer ;
    ismoving:Boolean ;
    targetCell:TCell ;
    fix_pause:Single ;
    OM:TObject ;
    PAP:TObject ;
    EM:TObject ;
    ListAttacked:TObjectList ;
    ListFlags:TStringList ;
    ScriptVars:TKeyStrList ;
    MAI:TObject ;
    BT:TBattleTask ;
    superfast:Boolean ;

    StoredPonyCell:TCell ;
    StoredPony:TObject ;

    MessageList:TMessageList ;

    FMaxCellI:Integer ;
    FMaxCellJ:Integer ;

    extinfomodel:string ;

    store:TObjectList ;
    inttimer:Single ;
    cellarr:array of array of TCell ;

    procedure FastMoveFocus() ;
    procedure RefreshSlowDown() ;
  public
    NoSpaceProtection:Boolean ;
    SlowDownList:TCellListNoOwn ;
    TowerList:TCellListNoOwn ;
    MapName:string ;
    MapFile:string ;
    VictoryFlag:Boolean ;
    DefeatFlag:Boolean ;
    AttackedDefeatString:string ;
    DeathAllow:Boolean ;
    DefaultSandStone:Boolean ;
    ProgressiveMonster:Boolean ;
    RegressiveFarms:Boolean ;
    FM:TFogManagerClass ;
    DefaultMonsterStrategy:string ;
    ReadyForAfterStep:Boolean ;
    constructor Create() ;
    destructor Destroy ; override ;
    function AddCell(idxi,idxj:Integer; T:TTerrain):TCell ;
    function AddGameObject(GO:TGameObject; idxi,idxj:Integer):TCell ; overload ;
    function AddGameObject(GO:TGameObject; Cell:TCell):TCell ; overload ;
    function CellCount():Integer ;
    function GetCell(i:Integer):TCell ;
    function GetCellMicroTerrBetweenDirAndNext(i:Integer; dir:Integer):TTerrain ;
    function GetCellByXY(x,y:Integer):TCell ;
    function GetCellByIJ(idxi,idxj:Integer):TCell ;
    function GetCellByObject(GO:TGameObject):TCell ;
    function GetCellByFirstObjectTag(tag:string):TCell ;

    procedure MakeInternalLinks() ;
    procedure CalcMapSize() ;
    procedure BuildCellArray() ;
    function GetTerrSnapshot():string ;                                     

    function CreateMiniMap():TMiniMap ;
    procedure UpdateMiniMap(MM:TMiniMap) ;
    function GetShift():TPointSingle ;

    function CreateListCellsOnWay(CellStart,
      CellFinish:TCell; maxdist:Integer;
      Params:TSearchParams=[]):TCellListNoOwn ;
    function CreateListCellsOnWayForPonyWalk(CellStart,
      CellFinish:TCell; maxdist:Integer):TCellListNoOwn ;

    function GetCellsOnDistN(CellStart:TCell;dist:Integer;
      Params:TSearchParams=[]):TCellListNoOwn ;
    function GetCellsOnDistNForPonyWalk(CellStart: TCell;
      dist:Integer): TCellListNoOwn;

    procedure SetStaticShift(dx,dy:Integer) ;
    function MoveOverMap(dx,dy:Integer; dt:Single;
      multspeed:Single=1):TMoveRes ;

    function IsOverMapMovingProcess():Boolean ;
    function IsTeleportProcessing():Boolean ;
    procedure SetFocusMovingPoint(i,j:Integer) ; overload ;
    procedure SetFocusMovingPoint(Cell:TCell) ; overload ;
    procedure SetFocusMovingPointXY(x, y: Integer);
    procedure ImmediateRunTo(x,y: Integer) ;
    
    procedure setActiveCell(Cell:TCell) ;
    function IsActiveCell():Boolean ;
    function GetActiveCell():TCell ;
    procedure clearActiveCell() ;
    function getActiveObject():TGameObject ;

    function IsObjectAtPos(ObjCode:string; i,j:Integer):Boolean ;
    function tmpGetMinObjectPos(ObjCode: string; out i:Integer;
      out j: Integer): Boolean;
    function GetObjectPos(ObjCode: string; out i:Integer;
      out j: Integer): Boolean;
    function GetObjectCell(ObjCode: string; out Cell:TCell): Boolean;

    procedure NextStep(afterstep:Boolean=false) ;
    function GetCurrentStep():Integer ;

    procedure SetResources(AStone,AFood:Integer) ;
    function GetFood():Integer ;
    function GetStone():Integer ;
    function GetWood():Integer ;
    function DecStone(ADelta:Integer):Boolean ;
    function DecFood(ADelta:Integer):Boolean ;
    function DecWood(ADelta:Integer):Boolean ;
    function IncStone(ADelta:Integer):Boolean ;
    function IncFood(ADelta:Integer):Boolean ;
    function IncWood(ADelta:Integer):Boolean ;

    procedure Update(dt:Single) ;
    function IsExistsTranspObjs():Boolean ;
    function GetOM():TObject ;
    function GetEM():TObject ;
    function GetPAP():TObject ;
    procedure SetEmptyManager(AEM:TObject) ;

    procedure SetMAI(AMAI:TObject) ;
    function GetMAI:TObject ;

    procedure AddAttackEvent(ae:TAttackEvent) ;
    function IsObjectAttacked(O:TGameObject):Boolean ;

    procedure SetFlag(FlagName:string) ;
    procedure ClearFlag(FlagName:string) ;
    function IsFlag(FlagName:string):Boolean ;
    procedure IncScriptVar(VarName:string; Delta:Integer=1) ;
    procedure SetScriptVar(VarName:string; VarValue:Integer) ;
    function GetScriptVar(VarName:string):Integer ;

    function getObjCountByClass(C:TGameObjectClass):Integer ;
    function getObjCountByCode(ObjCode:string):Integer ;
    function getObjCountByTag(ObjTag:string):Integer ;

    function IsMagicLockedAtCell(Cell:TCell):Boolean ;

    function CreateStepInfo():TStringList ;
    function GetPonyList: TStringList;

    function GetBattleTask():TBattleTask ;

    procedure ClearStepInfo() ;

    function CreateProtectedCellList: TCellListNoOwn;
    function CreateSlowdownCellList: TCellListNoOwn;
    function CreateTowerCellList: TCellListNoOwn;
    function CreateMonsterStepsCellList: TCellListNoOwn;
    function CreatePoisonCellList: TCellListNoOwn;    
    function CreateMagicLockCellList: TCellListNoOwn;
    function CreateMagicStoleCellList: TCellListNoOwn;

    procedure SavePonyPos() ;
    function isPonyPosSaved():Boolean ;
    procedure clearPonyPos() ;
    procedure RestorePonyPos() ;

    function GetMessageList():TMessageList ;
    function CreateMicroCellList():TObjectList ;

    procedure SetFogManagerStd() ;
    procedure SetFogManagerNight() ;

    function getExtInfo():string ;
    procedure setExtInfoModel(model:string) ;

    function getUserActionInfo():string ;

    function findObjectInStore(Code:string; var GO:TGameObject):Boolean ;
    procedure extractObjectFromStore(GO:TGameObject) ;
    procedure addObjectInStore(GO:TGameObject) ;

    function IsDeathAllow(Pony:TGameObject):Boolean ;

    function GetFoodIncAtMoment():Integer ;
    function GetStoneIncAtMoment():Integer ;

    procedure SetIntTimer(secs:Single) ;
    function IsTimerProcessed():Boolean ;

    function getSpaceCount():Integer ;
    function canProduceResource():Boolean ;

    property MaxCellI:Integer read FMaxCellI ;
    property MaxCellJ:Integer read FMaxCellJ ;

  end ;

procedure setCellParams(width,height:Integer) ;

var
  CELL_WIDTH,CELL_HEIGHT:Integer ;

const
  AFTERSTEP=true ;
    
implementation
uses TAVHGEUtils, SysUtils, Math, simple_oper, ObjectMover,
  PonyAction, PonyUnits, EmptyPlace, Buildings, CommonProc,
  EmptyManager, CellFinder, MonsterUnits, NeutralUnits,
  FFGame, Constants, StoneResource, FoodResource, PassivePropSpaceProtect,
  PassiveProp, PassivePropEnemySlowdown, CellBuilder, StepAction, StepActionDamage,
  StepActionHeal, StepActionRestore, TAVStrUtils, BuiltinMapFuncs, ObjModule,
  Player ;

procedure setCellParams(width,height:Integer) ;
begin
  CELL_WIDTH:=width ;
  CELL_HEIGHT:=height ;
end;

{ TCell }

procedure TCell.AddLink(Cell: TCell; dir:Integer);
begin
  ListLinks.Add(Cell) ;
  arr_links_directed[dir]:=Cell ;
end;

function TCell.CalcQDistanceTo(CellDst: TCell): Single;
begin
  Result:=Sqrt(sqr(XC-CellDst.XC)+sqr(YC-CellDst.YC)) ;
end;

function TCell.CalcCDistanceTo(CellDst: TCell): Single;
begin
  Result:=Sqrt(sqr(CellI-CellDst.CellI)+sqr(CellJ-CellDst.CellJ)) ;
end;

procedure TCell.ClearLinks;
begin  ListLinks.Clear ; end;

procedure TCell.ClearObject(kill:Boolean=True);
begin
  if kill then
    if Assigned(_Object) then _Object.ProcessRemove() ;
  _Object:=nil ;
  _BF.RefreshSlowDown() ;
end;

constructor TCell.Create(BF:TBattleField);
begin
  _BF:=BF ;
  ListLinks:=TObjectList.Create(False) ;
  tmpMapChar:=chr(0) ;
  FogState:=fsVisible ;
  showEmptyClearing:=0 ;
end;

destructor TCell.Destroy;
begin
  ListLinks.Free ;
  inherited Destroy ;
end;

function TCell.GetLinkByDir(dir: Integer): TCell;
begin
  Result:=arr_links_directed[dir] ;
end;

function TCell.GetLinkCount: Integer;
begin  Result:=ListLinks.Count ; end;

function TCell.GetLinked(i: Integer): TCell;
begin  Result:=TCell(ListLinks[i]) ; end;

function TCell.getLinkedDirs: string;
var i:Integer ;
begin
  Result:='' ;
  for i := 0 to 5 do
    if arr_links_directed[i]<>nil then
      if arr_links_directed[i].tmpMapChar='W' then
        Result:=Result+IntToStr(i) ;
end;

function TCell.GetMaxTranspFromSpaceAround: Integer;
var i,max:Integer ;
begin
  max:=0 ;
  for i := 0 to GetLinkCount - 1 do
    if not GetLinked(i).IsEmpty() then
      if max<GetLinked(i)._Object.GetTransp() then
        max:=GetLinked(i)._Object.GetTransp() ;
  Result:=max ;
end;

function TCell.GetMostTerrainAround: TTerrain;
var i,j,itern:Integer ;
    KSL:TKeyStrList ;
    BorderList,NewList,OldList:TCellListNoOwn ;
    Linked:TCell ;
begin

  if tmpCachedTerrain<>nil then begin
    Result:=tmpCachedTerrain ;
    Exit ;
  end;

  KSL:=TKeyStrList.Create ;

  BorderList:=TCellListNoOwn.Create ;
  OldList:=TCellListNoOwn.Create ;
  NewList:=TCellListNoOwn.Create ;

  BorderList.Add(Self) ;

  itern:=0 ;
  repeat
    Result:=nil ;

    KSL.Clear() ;
    NewList.Clear ;
    for j := 0 to BorderList.Count - 1 do begin
       for i := 0 to BorderList[j].GetLinkCount - 1 do begin
         Linked:=BorderList[j].GetLinked(i) ;
         if not (OldList.IsObjectIn(Linked) or
                 BorderList.IsObjectIn(Linked)) then begin
           if not Linked._Terrain.UseSubLayer then
             KSL.Inc(Linked._Terrain.Name);
           NewList.Add(Linked) ;
         end;
       end;
       OldList.Add(BorderList[j]) ;
    end;

    KSL.SortByValue(True);

    if KSL.Count>0 then Result:=Terrains().GetByName(KSL.Key[0]) ;

    BorderList.Clear() ;
    for i := 0 to NewList.Count - 1 do
      BorderList.Add(NewList[i]) ;

    Inc(itern) ;
    if itern>5 then Result:=Terrains.GetByCodeChar('L') ;
     
  until Result<>nil ;

  tmpCachedTerrain:=Result ;
  
  BorderList.Free ;
  OldList.Free ;
  NewList.Free ;
  KSL.Free ;
end;

function TCell.GetRealTerr: TTerrain;
begin
  if IsSpace() then Result:=Terrains().GetByCodeChar('@') else
  if _Terrain.UseSubLayer then Result:=GetMostTerrainAround()
  else Result:=_Terrain ;  
end;

function TCell.GetStepNeed: Integer;
begin
  Result:=_Terrain.intGetStepNeed() ;
end;

function TCell.IsBuilding: Boolean;
begin
  if IsEmpty() then Result:=False else Result:=_Object is TBuilding ;
end;

function TCell.IsCellLinked(CellTest: TCell): Boolean;
var i:Integer ;
begin
  Result:=False ;
  for i := 0 to GetLinkCount - 1 do
    if GetLinked(i)=CellTest then Result:=True ;
end;

function TCell.IsEmpty: Boolean;
begin
  Result:=(_Object=nil) ;
end;

function TCell.IsMonster: Boolean;
begin
  if IsEmpty() then Result:=False else Result:=_Object is TMonsterUnit ;
end;

function TCell.IsMouseIn(x, y: Integer): Boolean;
var absx,absy:Integer ;
begin

  absx:=abs(x-XC) ;
  absy:=abs(y-YC) ;

  if (absx<=CELL_WIDTH/2) then begin
    // Оптимизированный способ - убрали лишнее

    {if (absy<=0.3*CELL_HEIGHT) then begin
      Result:=True ;
      Exit ;
    end;}

    if {(absy>0.3*CELL_HEIGHT)and}
      (absy-0.3*CELL_HEIGHT<0.2*CELL_HEIGHT*(2/CELL_WIDTH)*(CELL_WIDTH/2-absx)) then begin
      Result:=True ;
      Exit ;
    end;
  end ;

  Result:=False ;
end;

function TCell.IsPonyUnit: Boolean;
begin
  Result:=False ;
  if _Object<>nil then Result:=_Object is TPonyUnit ;
end;

function TCell.IsShowObjectOnMiniMap: Boolean;
begin
  if FogState<>fsVisible then begin
    Result:=False ;
    Exit ;
  end;

  if IsEmpty  then
    Result:=False
  else
    Result:=not _Object.IsNoMapping();
end;

function TCell.IsSlowdownCell: Boolean;
begin
  if _BF.SlowDownList<>nil then
    Result:=_BF.SlowDownList.IsObjectIn(Self) 
  else
    Result:=False ;
end;

function TCell.IsSpace: Boolean;
begin
  Result:=False ;
  if _Object<>nil then Result:=_Object is TEmptyPlace ;
end;

procedure TCell.SetObject(GO: TGameObject);
begin
  _Object:=GO ;
end;

function TCell.TransactObject(CellDst: TCell): Boolean;
begin
  CellDst.SetObject(_Object);
  if CellDst.XC>XC then _Object.RotToRight else
  if CellDst.XC<XC then _Object.RotToLeft ;

  ClearObject(False) ;
end;

function TCell.XC: Integer;
begin
  Result:=idxi*CELL_WIDTH ;
  if idxj mod 2 = 1 then Dec(Result,CELL_WIDTH div 2);
  Inc(Result,CELL_WIDTH) ;

  Dec(Result,Round(_BF.Shift.X)) ;
  Inc(Result,_BF.StaticShift.X) ;
  Dec(Result,7) ; // Поправка, чтобы не было пустот
end;

function TCell.YC: Integer;
begin
  Result:=idxj*Round(CELL_HEIGHT*(4/5)) ;
  Inc(Result,CELL_HEIGHT div 2) ;

  Dec(Result,Round(_BF.Shift.Y)) ;
  Inc(Result,_BF.StaticShift.Y) ;
  Dec(Result,3) ; // Поправка, чтобы не было пустот
end;

function TCell.XOnMap: Integer;
begin
  Result:=idxi*CELL_WIDTH ;
  if idxj mod 2 = 1 then Dec(Result,CELL_WIDTH div 2);
  Inc(Result,CELL_WIDTH) ;
end;

function TCell.YOnMap: Integer;
begin
  Result:=idxj*Round(CELL_HEIGHT*(4/5)) ;
  Inc(Result,CELL_HEIGHT div 2) ;
end;

function TCell.XwShift: Integer;
begin
  if IsEmpty() then Result:=XC else Result:=XC+Round(_Object.ShiftView.X) ;
end;

function TCell.YwShift: Integer;
begin
  if IsEmpty() then Result:=YC else Result:=YC+Round(_Object.ShiftView.Y) ;
end;

{ TCellList }

function TCellList.GetItem(i: Integer): TCell;
begin
  Result:=TCell(inherited GetItem(i)) ;
end;

{ TBattleField }

procedure TBattleField.AddAttackEvent(ae: TAttackEvent);
begin
  if not ae.doFix then Exit ;

  if ae._object.IsMustSurvive() and (not (ae._object is TBuilding)) then begin
    SetResultMsg('Причина поражения: '+AttackedDefeatString) ;
    DefeatFlag:=True ;
  end ;

  if ListAttacked.IndexOf(ae._object)=-1 then
    ListAttacked.Add(ae._Object) ;

  if ae.doDelete then begin
    GetCellByObject(ae._object).ClearObject() ;
    if ae._object.IsMustSurvive() and (ae._object is TBuilding) then begin
      SetResultMsg('Причина поражения: '+AttackedDefeatString) ;
      DefeatFlag:=True ;
    end ;
  end;

end;

function TBattleField.AddCell(idxi, idxj: Integer; T: TTerrain): TCell;
var C:TCell ;
begin

  C:=TCell.Create(Self) ;
  C._Terrain:=T ;
  C.idxi:=idxi ; C.idxj:=idxj ;

  ListCells.Add(C) ;

  Result:=C ;
end;

// Дублирование кода
function TBattleField.AddGameObject(GO: TGameObject; idxi,
  idxj: Integer): TCell;
begin
  Result:=GetCellByIJ(idxi,idxj) ;
  if Result<>nil then
    AddGameObject(GO,Result) ;  
end;

// Дублирование кода
function TBattleField.AddGameObject(GO:TGameObject; Cell:TCell):TCell ;
begin
  Result:=Cell ;
  if Result<>nil then begin
    Result.setObject(GO) ;
    RefreshSlowDown() ;
  end;
end ;

procedure TBattleField.CalcMapSize;
var i:Integer ;
begin
  MaxRightBottom.X:=GetCell(0).XC() ;
  MaxRightBottom.Y:=GetCell(0).YC() ;
  FMaxCellI:=GetCell(0).idxi ;
  FMaxCellJ:=GetCell(0).idxj ;

  for i := 1 to CellCount - 1 do begin
    if MaxRightBottom.X<GetCell(i).XC() then
      MaxRightBottom.X:=GetCell(i).XC() ;
    if MaxRightBottom.Y<GetCell(i).YC() then
      MaxRightBottom.Y:=GetCell(i).YC() ;
    if MaxCellI<GetCell(i).idxi then
      FMaxCellI:=GetCell(i).idxi ;
    if MaxCellJ<GetCell(i).idxj then
      FMaxCellJ:=GetCell(i).idxj ;
  end;

  Dec(MaxRightBottom.X,6) ; // Поправки, чтобы не было пустот
  Inc(MaxRightBottom.Y,3) ;

  mHGE.System_Log('map max RightBottom %d %d',[
   MaxRightBottom.X,MaxRightBottom.Y]);

end;

function TBattleField.canProduceResource: Boolean;
var i: Integer;
begin
  Result:=False ;
  for i := 0 to CellCount - 1 do
    if GetCell(i).IsBuilding() then
      if Pos('House',TBuilding(GetCell(i)._Object).Code)=1 then begin
        Result:=True ;
        Exit ;
      end;
end;

function TBattleField.CellCount: Integer;
begin  Result:=ListCells.Count ; end;

procedure TBattleField.clearActiveCell;
begin
  ActiveCell:=nil ;
end;

constructor TBattleField.Create;
begin
  ListCells:=TCellList.Create ;
  ListAttacked:=TObjectList.Create(False) ;
  ListFlags:=TStringList.Create ;
  ScriptVars:=TKeyStrList.Create ;
  BT:=TBattleTask.Create ;
  store:=TObjectList.Create(False) ;
  
  StaticShift.X:=0 ;
  StaticShift.Y:=0 ;
  Shift.X:=0 ;
  Shift.Y:=0 ;

  CurrentStep:=0 ;

  VictoryFlag:=False ;
  DefeatFlag:=False ;
  DeathAllow:=False ;
  DefaultSandStone:=False ;

  FM:=TFogManagerNoFog ;

  NoSpaceProtection:=False ;
  inttimer:=0 ;
  ReadyForAfterStep:=False ;
end;

destructor TBattleField.Destroy;
begin
  ListCells.Free ;
  ListAttacked.Free ;
  ListFlags.Free ;
  inherited;
end;

function TBattleField.GetActiveCell: TCell;
begin
  Result:=ActiveCell ;
end;

function TBattleField.GetBattleTask: TBattleTask;
begin
  Result:=BT ;
end;

function TBattleField.GetCell(i: Integer): TCell;
begin  Result:=ListCells[i] ; end;

function TBattleField.GetCellByFirstObjectTag(tag: string): TCell;
var i:Integer ;
begin
  Result:=nil ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object.Tag=tag then begin
        Result:=GetCell(i) ;
        Break ;
      end;
end;

function TBattleField.GetCellByIJ(idxi, idxj: Integer): TCell;
begin
  if idxi<0 then begin Result:=nil ; Exit ; end ;
  if idxj<0 then begin Result:=nil ; Exit ; end ;
  if idxi>FMaxCellI then begin Result:=nil ; Exit ; end ;
  if idxj>FMaxCellJ then begin Result:=nil ; Exit ; end ;
  Result:=cellarr[idxi,idxj] ;
end;

function TBattleField.GetCellByObject(GO: TGameObject): TCell;
var i:Integer ;
begin
  Result:=nil ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object=GO then begin
      Result:=GetCell(i) ;
      Break ;
    end;
end;

function TBattleField.GetCellByXY(x, y: Integer): TCell;
var i:Integer ;
begin
  Result:=nil ;
  for i := 0 to CellCount - 1 do
    if GetCell(i).IsMouseIn(x,y) then begin
      Result:=GetCell(i) ;
      Break ;
    end;
end;

function TBattleField.GetCellMicroTerrBetweenDirAndNext(i,
  dir: Integer): TTerrain;
var dir2:Integer ;
    Terr1,Terr2:TTerrain ;
begin
  dir2:=dir+1 ;
  if dir2=6 then dir2:=0 ;
  
  Result:=nil ;
  if GetCell(i).GetLinkByDir(dir)<>nil then
  if GetCell(i).GetLinkByDir(dir2)<>nil then begin
    Terr1:=GetCell(i).GetLinkByDir(dir).GetRealTerr() ;
    Terr2:=GetCell(i).GetLinkByDir(dir2).GetRealTerr() ;

    if (Terr1=Terr2)and(Terr1<>GetCell(i).GetRealTerr()) then Result:=Terr1 ;
  end ;


end;

function TBattleField.GetCellsOnDistN(CellStart: TCell;
  dist: Integer; Params:TSearchParams=[]): TCellListNoOwn;
begin
  Result:=GetCellFinder().GetCellsOnDistN(CellStart,dist,Params) ;
end;

function TBattleField.GetCellsOnDistNForPonyWalk(CellStart: TCell;
  dist: Integer): TCellListNoOwn;
var params:TSearchParams ;
begin
  params:=[] ;
  Result:=GetCellFinder().GetCellsOnDistN(CellStart,dist,Params) ;
end;

function TBattleField.getObjCountByCode(ObjCode: string): Integer;
var i:Integer ;
begin
  Result:=0 ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then begin
      if GetCell(i)._Object is TPonyUnit then
        if TPonyUnit(GetCell(i)._Object).Code=ObjCode then Inc(Result) ;
      if GetCell(i)._Object is TNeutralUnit then
        if TNeutralUnit(GetCell(i)._Object).Code=ObjCode then Inc(Result) ;
      if GetCell(i)._Object is TMonsterUnit then
        if TMonsterUnit(GetCell(i)._Object).Code=ObjCode then Inc(Result) ;
      if GetCell(i)._Object is TBuilding then
        if TBuilding(GetCell(i)._Object).Code=ObjCode then Inc(Result) ;
    end;
end;

function TBattleField.getObjCountByTag(ObjTag: string): Integer;
var i:Integer ;
begin
  Result:=0 ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object.Tag=ObjTag then Inc(Result) ;
end;

function TBattleField.CreateListCellsOnWay(CellStart,CellFinish: TCell;
  maxdist:Integer; Params:TSearchParams=[]): TCellListNoOwn;
begin
  Result:=GetCellFinder().CreateListCellsOnWay(CellStart,CellFinish,maxdist,Params) ;
end;

function TBattleField.CreateListCellsOnWayForPonyWalk(CellStart,CellFinish: TCell;
  maxdist:Integer): TCellListNoOwn;
var params:TSearchParams ;
begin
  params:=[] ;
  Result:=GetCellFinder().CreateListCellsOnWay(CellStart,CellFinish,maxdist,
    params) ;
//  SlowDownList.Free ;
//  SlowDownList:=nil ;
end;

function TBattleField.getActiveObject: TGameObject;
begin
  Result:=ActiveCell._Object ;
end;

function TBattleField.IsActiveCell: Boolean;
begin
  Result:=ActiveCell<>nil ;
end;

function TBattleField.IsDeathAllow(Pony: TGameObject): Boolean;
begin
  if DeathAllow then Result:=True else Result:=TPonyUnit(Pony).DeathAllow ;
end;

function TBattleField.IsExistsTranspObjs: Boolean;
var i:Integer ;
begin
  Result:=False ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      Result:=Result or (GetCell(i)._Object.GetTransp>0) ;

end;

function TBattleField.IsFlag(FlagName: string): Boolean;
begin
  Result:=ListFlags.IndexOf(FlagName)<>-1 ;
end;

function TBattleField.IsMagicLockedAtCell(Cell: TCell): Boolean;
var i:Integer ;
    RList:TCellListNoOwn ;
begin
  Result:=False ;

  for i := 0 to CellCount - 1 do
    if not getCell(i).IsEmpty then
      if getCell(i)._Object is TMonsterTent then begin
        RList:=getCellFinder().GetCellsOnDistN(getCell(i),
          TMonsterTent(getCell(i)._Object).MagicLockDist(),
          [spIgnoreTerrain,spIncludeBusyCell]) ;
        if RList.IsObjectIn(Cell) then Result:=True ;
        RList.Free ;
      end;

end;

function TBattleField.IsObjectAtPos(ObjCode: string; i, j: Integer): Boolean;
var Cell:TCell ;
begin
  Result:=False ;
  Cell:=GetCellByIJ(i,j) ;
  if Cell<>nil then
    if not Cell.IsEmpty() then begin
      if Cell._Object.Tag=ObjCode then Result:=True ;
      if Cell._Object is TPonyUnit then
        if TPonyUnit(Cell._Object).Code=ObjCode then Result:=True ;
      if Cell._Object is TNeutralUnit then
        if TNeutralUnit(Cell._Object).Code=ObjCode then Result:=True ;
      if Cell._Object is TMonsterUnit then
        if TMonsterUnit(Cell._Object).Code=ObjCode then Result:=True ;
    end;
end;

function TBattleField.GetObjectPos(ObjCode: string; out i:Integer;
  out j: Integer): Boolean;
var k:Integer ;
begin
  Result:=False ;
  for k := 0 to CellCount - 1 do
    if not GetCell(k).IsEmpty() then begin
      if GetCell(k)._Object.Tag=ObjCode then Result:=True ;
      if GetCell(k)._Object is TPonyUnit then
        if TPonyUnit(GetCell(k)._Object).Code=ObjCode then
          Result:=True ;
      if GetCell(k)._Object is TNeutralUnit then
        if TNeutralUnit(GetCell(k)._Object).Code=ObjCode then Result:=True ;
      if GetCell(k)._Object is TMonsterUnit then
        if TMonsterUnit(GetCell(k)._Object).Code=ObjCode then Result:=True ;
      if Result then begin
        i:=GetCell(k).CellI ;
        j:=GetCell(k).CellJ ;
        Break ;
      end;
    end;
end;

function TBattleField.tmpGetMinObjectPos(ObjCode: string; out i:Integer;
  out j: Integer): Boolean;
var k:Integer ;
    z:Boolean ;
begin
  Result:=False ;
  for k := 0 to CellCount - 1 do
    if not GetCell(k).IsEmpty() then begin
      z:=False ;
      if GetCell(k)._Object.Tag=ObjCode then
        z:=True ;
      if GetCell(k)._Object is TPonyUnit then
        if TPonyUnit(GetCell(k)._Object).Code=ObjCode then
          z:=True ;
      if GetCell(k)._Object is TNeutralUnit then
        if TNeutralUnit(GetCell(k)._Object).Code=ObjCode then z:=True ;
      if GetCell(k)._Object is TMonsterUnit then
        if TMonsterUnit(GetCell(k)._Object).Code=ObjCode then z:=True ;
      if z then begin
        if Result then begin
          i:=Min(GetCell(k).CellI,i) ;
          j:=Min(GetCell(k).CellJ,j) ;
        end
        else begin
          i:=GetCell(k).CellI ;
          j:=GetCell(k).CellJ ;
        end ;
        Result:=True ;
      end;
    end;
end;

// [!] Дублирование выше
function TBattleField.GetObjectCell(ObjCode: string; out Cell:TCell): Boolean;
var k:Integer ;
begin
  Result:=False ;
  for k := 0 to CellCount - 1 do
    if not GetCell(k).IsEmpty() then begin
      if GetCell(k)._Object is TPonyUnit then
        if TPonyUnit(GetCell(k)._Object).Code=ObjCode then
          Result:=True ;
      if GetCell(k)._Object is TNeutralUnit then
        if TNeutralUnit(GetCell(k)._Object).Code=ObjCode then Result:=True ;
      if GetCell(k)._Object is TMonsterUnit then
        if TMonsterUnit(GetCell(k)._Object).Code=ObjCode then Result:=True ;
      if Result then begin
        Cell:=GetCell(k) ;
        Break ;
      end;
    end;
end;

function TBattleField.IsObjectAttacked(O: TGameObject): Boolean;
begin
  Result:=ListAttacked.IndexOf(O)<>-1 ;
end;

function TBattleField.IsOverMapMovingProcess: Boolean;
begin
  //
  Result:=ismoving or (fix_pause>0);
end;

function TBattleField.isPonyPosSaved: Boolean;
begin
  Result:=(StoredPony<>nil) ;
end;

function TBattleField.IsTeleportProcessing: Boolean;
var i:Integer ;
begin
  Result:=False ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i).IsPonyUnit then
        if TPonyUnit(GetCell(i)._Object).IsTeleported then begin
          Result:=True ;
          Break ;
        end ;
end;

function TBattleField.IsTimerProcessed: Boolean;
begin
  Result:=inttimer>0 ;
end;

procedure TBattleField.MakeInternalLinks;

  procedure AddLinkIfCellExist(Cell:TCell; i,j:Integer;
    dir:Integer) ;
  var Linked:TCell ;
  begin
    Linked:=GetCellByIJ(i,j) ;
    if Linked<>nil then Cell.AddLink(Linked,dir);
  end ;

var i,idxi,idxj,x1,x2:Integer ;
    ispar:Boolean ;
begin
  for i := 0 to CellCount - 1 do begin
    GetCell(i).ClearLinks ;
    idxi:=GetCell(i).idxi ;
    idxj:=GetCell(i).idxj ;
    ispar:=idxj mod 2 = 0 ;

    if ispar then begin
      x1:=idxi ; x2:=idxi+1 ;
    end
    else begin
      x1:=idxi-1 ; x2:=idxi ;
    end ;

    AddLinkIfCellExist(GetCell(i),x1,idxj-1,0) ;
    AddLinkIfCellExist(GetCell(i),x2,idxj-1,1) ;
    AddLinkIfCellExist(GetCell(i),idxi+1,idxj,2) ;
    AddLinkIfCellExist(GetCell(i),x2,idxj+1,3) ;
    AddLinkIfCellExist(GetCell(i),x1,idxj+1,4) ;
    AddLinkIfCellExist(GetCell(i),idxi-1,idxj,5) ;
  end;

end;

function TBattleField.MoveOverMap(dx, dy: Integer; dt: Single;
  multspeed:Single=1):TMoveRes ;
var SPEEDX:Integer ;
    SPEEDY:Integer ;
    deltax,deltay:Integer ;
begin
  Result.stoppedx:=False ;
  Result.stoppedy:=False ;

  SPEEDX:=Round(CELL_WIDTH*12*multspeed) ;
  SPEEDY:=Round(CELL_HEIGHT*12*multspeed) ;
  if superfast then begin
    SPEEDX:=SPEEDX*3 ;
    SPEEDY:=SPEEDY*3 ;
  end ;

  if (dx<>0)and(dy<>0) then begin
    SPEEDX:=Round(SPEEDX*Sqrt(0.5)) ;
    SPEEDY:=Round(SPEEDY*Sqrt(0.5)) ;
  end ;

  Shift.X:=Shift.X+SPEEDX*dx*dt ;
  Shift.Y:=Shift.Y+SPEEDY*dy*dt ;
  if Shift.X<0 then begin Result.stoppedx:=True ; Shift.X:=0 ; end ;
  if Shift.Y<0 then begin Result.stoppedy:=True ; Shift.Y:=0 ; end ;

  deltax:=WO.Width-StaticShift.X-2*CELL_WIDTH div 3 ;
  deltay:=WO.Height-2*CELL_HEIGHT div 3;

  if Shift.X>MaxRightBottom.X-deltax then begin
    Shift.X:=MaxRightBottom.X-deltax ;
    Result.stoppedx:=True ;
  end;
  if Shift.Y>MaxRightBottom.Y-deltay then begin
    Shift.Y:=MaxRightBottom.Y-deltay ;
    Result.stoppedy:=True ;
  end;

end;

procedure TBattleField.NextStep(afterstep:Boolean=false);
var i:Integer ;
    IsDefByEmpty:Boolean ;
begin
  // Обход объектов
  // Сначала здания - так нужно, чтобы пища сначала выработалась,
  // а потом списалась на пони
  // Тирека обходим в начале
  // Без этого пони попадают в ловушку, если выше Тирека

  if afterstep then begin

  for i := 0 to CellCount - 1 do
    if GetCell(i)._Object is TMonsterTirek then GetCell(i)._Object.NextAfterStep() ;

  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object is TBuilding then GetCell(i)._Object.NextAfterStep() ;

  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if (not(GetCell(i)._Object is TBuilding)) and
         (not(GetCell(i)._Object is TMonsterTirek)) then GetCell(i)._Object.NextAfterStep() ;

  end
  else begin
  
  for i := 0 to CellCount - 1 do
    if GetCell(i)._Object is TMonsterTirek then GetCell(i)._Object.NextStep() ;

  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object is TBuilding then GetCell(i)._Object.NextStep() ;

  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if (not(GetCell(i)._Object is TBuilding)) and
         (not(GetCell(i)._Object is TMonsterTirek)) then GetCell(i)._Object.NextStep() ;


  TEmptyManager(EM).NextStep(IsDefByEmpty) ;
  if IsDefByEmpty then DefeatFlag:=True ;

  Inc(CurrentStep) ;
  end;
end;

procedure TBattleField.RefreshSlowDown;
begin
  if SlowDownList<>nil then SlowDownList.Free ;
  SlowDownList:=CreateSlowDownCellList() ;
  if TowerList<>nil then TowerList.Free ;
  TowerList:=CreateTowerCellList() ;
end;

procedure TBattleField.RestorePonyPos;
begin
  if not isPonyPosSaved() then Exit ;

  TPonyUnit(StoredPony).PopState() ;
  clearActiveCell() ;
  GetCellByObject(TGameObject(StoredPony)).TransactObject(StoredPonyCell) ;
  setActiveCell(StoredPonyCell);
  clearPonyPos() ;
end;

procedure TBattleField.SavePonyPos;
begin
  StoredPony:=GetActiveCell()._Object ;
  StoredPonyCell:=GetActiveCell() ;
  TPonyUnit(StoredPony).PushState() ;
end;

function TBattleField.GetCurrentStep():Integer ;
begin
  Result:=CurrentStep ;
end ;

function TBattleField.GetEM: TObject;
begin
  Result:=EM ;
end;

function TBattleField.getExtInfo: string;
var split:TStringList ;
begin
  if extinfomodel='' then begin Result:='' ; Exit ; end ;

  split:=CreateStringListBySep(extinfomodel,';') ;
  if split.Count=0 then Result:='' else Result:=MapFuncs_formatExtInfo(self,split) ;
  split.Free ;
end;

procedure TBattleField.setActiveCell(Cell: TCell);
begin
  ActiveCell:=Cell ;
end;

procedure TBattleField.SetStaticShift(dx, dy: Integer);
begin
  StaticShift.X:=dx ;
  StaticShift.Y:=dy ;
end;

procedure TBattleField.Update(dt: Single);
var deltax,deltay,dx,dy:Integer ;
    MR:TMoveRes ;
    sx,sy:Integer ;
    i:Integer ;
begin
  if ismoving then begin

    deltax:=TargetCell.XC-
       ((StaticShift.X+2*CELL_WIDTH div 3)+
       ((WO.Width-StaticShift.X-2*CELL_WIDTH div 3) div 2)) ;
    deltay:=TargetCell.YC-
       ((2*CELL_HEIGHT div 3)+
       ((WO.Height-2*CELL_HEIGHT div 3) div 2)) ;

    if abs(deltax)<CELL_WIDTH/4 then dx:=0 else dx:=sign(deltax) ;
    if abs(deltay)<CELL_HEIGHT/4 then dy:=0 else dy:=sign(deltay) ;

    if (dx<>0)or(dy<>0) then begin
       MR:=MoveOverMap(dx,dy,dt,1) ;
       sx:=Alternate(MR.stoppedx,1,0) ;
       sy:=Alternate(MR.stoppedy,1,0) ;
      // mHGE.System_Log('t.x=%d t.y=%d sh.x=%d sh.y=%d deltax=%d deltay=%d dx=%d dy=%d sx=%d sy=%d',
       //  [TargetCell.XC,TargetCell.YC,Round(Shift.X),Round(Shift.Y),deltax,deltay,dx,dy,sx,sy]);
       if MR.StoppedX and MR.StoppedY then ismoving:=False ;
       if MR.StoppedX and (dy=0) then ismoving:=False ;
       if MR.StoppedY and (dx=0) then ismoving:=False ;
    end
    else
       ismoving:=False ;

  end
  else
    superfast:=False ;

  if fix_pause>0 then fix_pause:=fix_pause-dt ;

  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      GetCell(i)._Object.Update(dt);

  for i := 0 to CellCount - 1 do
    if Pos('FlameWall',GetCell(i)._Terrain.Name)=1 then
      if GetCell(i).IsMonster then
        //if not GetCell(i)._Object.IsFlyer then
          if not TMonsterUnit(GetCell(i)._Object).IsBurned then
            TMonsterUnit(GetCell(i)._Object).Burn() ;

  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if (GetCell(i)._Object is TPonyUnit) then
        if (TPonyUnit(GetCell(i)._Object).IsKilled())and
           IsDeathAllow(GetCell(i)._Object) then begin
           ClearActiveCell() ;
           GetCell(i).ClearObject() ;
        end;

  if inttimer>0 then inttimer:=inttimer-dt ;

end;


procedure TBattleField.SetFocusMovingPoint(i, j: Integer);
begin
  TargetCell:=GetCellByIJ(i,j) ;
  if TargetCell=nil then Exit ;
  
  ismoving:=True ;
  fix_pause:=1 ;
end;

procedure TBattleField.SetEmptyManager(AEM: TObject);
begin
  EM:=AEM ;
end;

procedure TBattleField.setExtInfoModel(model: string);
begin
  extinfomodel:=model ;
end;

procedure TBattleField.SetFlag(FlagName: string);
begin
  if not IsFlag(FlagName) then ListFlags.Add(FlagName) ;
end;

procedure TBattleField.SetFocusMovingPoint(Cell: TCell);
begin
  SetFocusMovingPoint(Cell.idxi,Cell.idxj) ;
end;

procedure TBattleField.SetFocusMovingPointXY(x, y: Integer);
var Cell:TCell ;
    i:Integer ;
begin
  Cell:=GetCell(0) ;

  for i := 1 to CellCount - 1 do
    if Sqr(GetCell(i).XonMap-x)+Sqr(GetCell(i).YonMap-y)<
       Sqr(Cell.XonMap-x)+Sqr(Cell.YonMap-y) then Cell:=GetCell(i) ;

  SetFocusMovingPoint(Cell) ;
end;

procedure TBattleField.SetFogManagerStd;
begin
  FM:=TFogManagerStd ;
end;

procedure TBattleField.SetIntTimer(secs: Single);
begin
  inttimer:=secs ;
end;

procedure TBattleField.SetFogManagerNight;
begin
  FM:=TFogManagerNight ;
end;

procedure TBattleField.SetMAI(AMAI: TObject);
begin
  MAI:=AMAI ;
end;

procedure TBattleField.SetResources(AStone,AFood:Integer) ;
begin
  Stone:=AStone ;
  Food:=AFood ;
end ;

function TBattleField.GetFood():Integer ;
begin  Result:=Food ; end ;

function TBattleField.GetFoodIncAtMoment: Integer;
var i:Integer ;
begin
  Result:=0 ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then begin
      if GetCell(i)._Object is TBuilding then
        Inc(Result,TBuilding(GetCell(i)._Object).CalcProduceFoodAtMoment()) ;
      if GetCell(i)._Object is TPonyUnit then
        Dec(Result,TPonyUnit(GetCell(i)._Object).GetDecFoodAtMoment()) ;
    end ;
end;

function TBattleField.GetStoneIncAtMoment: Integer;
var i:Integer ;
begin
  Result:=0 ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object is TBuilding then
        Inc(Result,TBuilding(GetCell(i)._Object).CalcProduceStoneAtMoment()) ;
end;

function TBattleField.GetTerrSnapshot: string;
var i:Integer ;
begin
  Result:=StringOfChar('L',CellCount) ;
  for i := 0 to CellCount - 1 do
    Result[i+1]:=GetCell(i)._Terrain.CharCode ;    
end;

function TBattleField.getUserActionInfo: string;
begin
  Result:=MapFuncs_getUserActionInfo(self) ;
end;

function TBattleField.GetMAI: TObject;
begin
  Result:=MAI ;
end;

function TBattleField.GetMessageList: TMessageList;
begin
  if MessageList=nil then MessageList:=TMessageList.Create ;
  Result:=MessageList ;
end;

function TBattleField.getObjCountByClass(C: TGameObjectClass): Integer;
var i:Integer ;
begin
  Result:=0 ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object is C then Inc(Result) ;
end;

function TBattleField.GetOM: TObject;
begin
  if OM=nil then OM:=TObjectMover.Create(Self,200);
  Result:=OM ;
end;

function TBattleField.GetPAP: TObject;
begin
  if PAP=nil then PAP:=TPonyActionPermits.Create() ;
  Result:=PAP ;
end;

function TBattleField.GetScriptVar(VarName: string): Integer;
begin
  Result:=ScriptVars[VarName] ;
end;

function TBattleField.GetShift: TPointSingle;
begin
  Result:=Shift ;
end;

function TBattleField.getSpaceCount: Integer;
var i:Integer ;
begin
  Result:=0 ;
  for i := 0 to CellCount - 1 do
    if GetCell(i).showEmptyClearing>0 then Inc(Result)
    else begin
      if GetCell(i).IsSpace() then Inc(Result) ;
    end;
end;

function TBattleField.GetStone():Integer ;
begin  Result:=Stone ; end ;

function TBattleField.GetWood: Integer;
begin  Result:=Wood ; end;

function TBattleField.DecStone(ADelta:Integer):Boolean ;
begin
  Result:=(Stone>=ADelta) ;
  if Result then Dec(Stone,ADelta) ;
end ;

function TBattleField.DecWood(ADelta: Integer): Boolean;
begin
  Result:=(Wood>=ADelta) ;
  if Result then Dec(Wood,ADelta) ;
end;

function TBattleField.DecFood(ADelta:Integer):Boolean ;
begin
  Result:=(Food>=ADelta) ;
  if Result then Dec(Food,ADelta) ;
end ;

procedure TBattleField.IncScriptVar(VarName: string; Delta:Integer=1);
begin
  ScriptVars.Inc(VarName,Delta) ;
end;

procedure TBattleField.SetScriptVar(VarName: string; VarValue:Integer);
begin
  ScriptVars.Value[VarName]:=VarValue ;
end;

function TBattleField.IncStone(ADelta:Integer):Boolean ;
begin  Inc(Stone,ADelta) ; end ;

function TBattleField.IncWood(ADelta: Integer): Boolean;
begin  Inc(Wood,ADelta) ; end;

procedure TBattleField.FastMoveFocus() ;
var deltax,deltay,dx,dy:Integer ;
    MR:TMoveRes ;
    sx,sy:Integer ;
begin
  while ismoving do begin

    deltax:=TargetCell.XC-
       ((StaticShift.X+2*CELL_WIDTH div 3)+
       ((WO.Width-StaticShift.X-2*CELL_WIDTH div 3) div 2)) ;
    deltay:=TargetCell.YC-
       ((2*CELL_HEIGHT div 3)+
       ((WO.Height-2*CELL_HEIGHT div 3) div 2)) ;

    if abs(deltax)<CELL_WIDTH/4 then dx:=0 else dx:=sign(deltax) ;
    if abs(deltay)<CELL_HEIGHT/4 then dy:=0 else dy:=sign(deltay) ;

    if (dx<>0)or(dy<>0) then begin
       MR:=MoveOverMap(dx,dy,0.01,1) ;
       sx:=Alternate(MR.stoppedx,1,0) ;
       sy:=Alternate(MR.stoppedy,1,0) ;
      // mHGE.System_Log('t.x=%d t.y=%d sh.x=%d sh.y=%d deltax=%d deltay=%d dx=%d dy=%d sx=%d sy=%d',
       //  [TargetCell.XC,TargetCell.YC,Round(Shift.X),Round(Shift.Y),deltax,deltay,dx,dy,sx,sy]);
       if MR.StoppedX and MR.StoppedY then ismoving:=False ;
       if MR.StoppedX and (dy=0) then ismoving:=False ;
       if MR.StoppedY and (dx=0) then ismoving:=False ;
    end
    else
       ismoving:=False ;

  end;
end;

function TBattleField.findObjectInStore(Code: string;
  var GO: TGameObject): Boolean;
var i:Integer ;
begin
  Result:=False ;
  for i := 0 to store.Count - 1 do
    if store[i] is TPonyUnit then begin
      if TPonyUnit(store[i]).Code=Code then begin
        GO:=TGameObject(store[i]) ;
        Result:=True ;
        Break ;
      end;
    end ;     
end;

procedure TBattleField.extractObjectFromStore(GO: TGameObject);
begin
  store.Extract(GO) ;
end;

procedure TBattleField.addObjectInStore(GO: TGameObject);
begin
  if store.IndexOf(GO)=-1 then store.Add(GO) ;
end;

procedure TBattleField.BuildCellArray;
var i,j:Integer ;
begin
  SetLength(cellarr,FMaxCellI+1,FMaxCellJ+1) ;

  for i := 0 to FMaxCellI do
    for j := 0 to FMaxCellJ do
      cellarr[i,j]:=nil ;

  for i := 0 to ListCells.Count - 1 do begin
    cellarr[ListCells[i].idxi,ListCells[i].idxj]:=ListCells[i] ;
  end;
end;

procedure TBattleField.ImmediateRunTo(x, y: Integer);
var deltax,deltay:Integer ;
begin
  deltax:=WO.Width-StaticShift.X-2*CELL_WIDTH div 3 ;
  deltay:=WO.Height-2*CELL_HEIGHT div 3;

  Shift.X:=x-deltax/2 ;
  Shift.Y:=y-deltay/2 ;

  if Shift.X<0 then Shift.X:=0 ;
  if Shift.Y<0 then Shift.Y:=0 ;

  if Shift.X>MaxRightBottom.X-deltax then Shift.X:=MaxRightBottom.X-deltax ;
  if Shift.Y>MaxRightBottom.Y-deltay then Shift.Y:=MaxRightBottom.Y-deltay ;
end;

function TBattleField.IncFood(ADelta:Integer):Boolean ;
begin  Inc(Food,ADelta) ; end ;

function TBattleField.CreateMicroCellList: TObjectList;
var i:Integer ;
begin
  Result:=TObjectList.Create ;

  for i := 0 to CellCount - 1 do begin
    // upper
    if GetCell(i).idxj=0 then begin
      if GetCell(i).GetLinkByDir(2)<>nil then
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),1,
          GetCell(i).XC+CELL_WIDTH div 2,
          GetCell(i).YC-Round(CELL_HEIGHT*(4/5)))) ;
      if GetCell(i).GetLinkByDir(5)<>nil then
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),2,
          GetCell(i).XC-CELL_WIDTH div 2,
          GetCell(i).YC-Round(CELL_HEIGHT*(4/5)))) ;
    end;
    // lower
    if GetCell(i).idxj=MaxCellJ then begin
      if GetCell(i).GetLinkByDir(2)<>nil then
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),6,
          GetCell(i).XC+CELL_WIDTH div 2,
          GetCell(i).YC+Round(CELL_HEIGHT*(4/5)))) ;
      if GetCell(i).GetLinkByDir(5)<>nil then
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),7,
          GetCell(i).XC-CELL_WIDTH div 2,
          GetCell(i).YC+Round(CELL_HEIGHT*(4/5)))) ;
    end;
    // left
    if GetCell(i).idxi=0 then begin
      if GetCell(i).idxj mod 2 = 0  then
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),4,
          GetCell(i).XC-CELL_WIDTH,
          GetCell(i).YC))
      else begin
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),5,
          GetCell(i).XC-CELL_WIDTH div 2,
          GetCell(i).YC-Round(CELL_HEIGHT*(4/5)))) ;
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),3,
          GetCell(i).XC-CELL_WIDTH div 2,
          GetCell(i).YC+Round(CELL_HEIGHT*(4/5)))) ;
      end;
    end;
    // right
    if GetCell(i).idxi=MaxCellI then
      if GetCell(i).idxj mod 2 = 1  then begin
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),10,
          GetCell(i).XC+CELL_WIDTH div 2,
          GetCell(i).YC-Round(CELL_HEIGHT*(4/5)))) ;
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),8,
          GetCell(i).XC+CELL_WIDTH div 2,
          GetCell(i).YC+Round(CELL_HEIGHT*(4/5)))) ;
      end;

    if GetCell(i).idxi=MaxCellI-1 then
      if GetCell(i).idxj mod 2 = 0  then begin
        Result.Add(TMicroCell.Create(GetCell(i).GetRealTerr(),9,
          GetCell(i).XC+CELL_WIDTH,
          GetCell(i).YC)) ;
      end ;

  end;

end;

function TBattleField.CreateMiniMap():TMiniMap ;
var i:Integer ;
    MapSize:TPoint ;
begin
  MapSize.X:=GetCell(0).CellI ;
  MapSize.Y:=GetCell(0).CellJ ;

  for i := 1 to CellCount - 1 do begin
    if MapSize.X<GetCell(i).CellI then
      MapSize.X:=GetCell(i).CellI ;
    if MapSize.Y<GetCell(i).CellJ then
      MapSize.Y:=GetCell(i).CellJ ;
  end;

  Result:=TMiniMap.Create(MapSize.X,MapSize.Y,MaxRightBottom.X,
    MaxRightBottom.Y) ;
  UpdateMiniMap(Result) ;
end ;

procedure TBattleField.UpdateMiniMap(MM: TMiniMap);
var i:Integer ;
    C:Cardinal ;
    Obj:TGameObject ;
begin
  // Перестроить определение цвета
  for i := 0 to CellCount - 1 do begin
    if GetCell(i).FogState=fsDark then
      C:=$FF202020
    else  
    if GetCell(i).IsSpace then C:=$FF202020 else
    if GetCell(i).IsShowObjectOnMiniMap() then begin
      Obj:=GetCell(i)._Object ;
      if Obj is TNeutralUnit then begin
        if TNeutralUnit(Obj).Code='stonewall' then begin
          if MM.NoLandscape then C:=$FF000000 else
            C:=$FF5D0909
        end
        else
        if TNeutralUnit(Obj).Code='castlewall' then begin
          if MM.NoLandscape then C:=$FF000000 else
            C:=$FF404040
        end
        else
        if TNeutralUnit(Obj).Code='guard' then
          C:=$FFFFFF00
        else
        if Pos('pony_',TNeutralUnit(Obj).Code)=1 then
          C:=$FFFFFF00
        else
          C:=$FFFFFFFF ;
      end
      else
      if Obj is TPonyUnit then begin
        C:=$FF00FF00 ;
      end
      else
      if Obj is TMonsterUnit then begin
        C:=$FFFF0000 ;
      end
      else
      if (Obj is TStoneResource)or(Obj is TFoodResource) then begin
        C:=$FF1E00FF ;
      end
      else
      if (Obj is TBuilding) then begin
        C:=$FF00FF00 ;
      end
      else
        C:=$FFFFFFFF ;
    end
    else begin
      if MM.NoLandscape then
      C:=$FF000000
      else begin
        C:=GetCell(i)._Terrain.Color ;
        if GetCell(i).tmpMapChar='W' then
          C:=$FFA0A0A0 ;
        if GetCell(i).FogState=fsFog then
          C:=Gradient(C,$FF000000,0.5) ;
      end;
    end;

    MM.SetColor(GetCell(i).CellI,GetCell(i).CellJ,C) ;
  end;
end;

function TBattleField.CreateStepInfo: TStringList;
var i:Integer ;
begin
  Result:=TStringList.Create ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object is TPonyUnit then
        Result.Add(TPonyUnit(GetCell(i)._Object).Code+'='+
          StrToHex(TPonyUnit(GetCell(i)._Object).GetStepInfo())) ;
end;

function TBattleField.GetPonyList: TStringList;
var i:Integer ;
begin
  Result:=TStringList.Create ;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object is TPonyUnit then
        if TPonyUnit(GetCell(i)._Object).Code<>'scorpion' then
        if TPonyUnit(GetCell(i)._Object).Code<>'warship' then
        if TPonyUnit(GetCell(i)._Object).Code<>'redship' then
          Result.Add(TPonyUnit(GetCell(i)._Object).Code) ;
  Result.Sort;      
end;

procedure TBattleField.ClearFlag(FlagName: string);
begin
  if IsFlag(FlagName) then ListFlags.Delete(ListFlags.IndexOf(FlagName)) ;
end;

procedure TBattleField.clearPonyPos;
begin
  StoredPony:=nil ;
end;

procedure TBattleField.ClearStepInfo;
var i:Integer ;
begin
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object is TPonyUnit then
        TPonyUnit(GetCell(i)._Object).ClearStepInfo() ;
end;

function TBattleField.CreateProtectedCellList: TCellListNoOwn;
var i:Integer ;
    ListOver:TCellListNoOwn ;
    SP:TPassivePropSpaceProtect ;
begin
  Result:=TCellListNoOwn.Create;

  if NoSpaceProtection then Exit ;

  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object.getPassiveProp(TPassivePropSpaceProtect,TPassiveProp(SP)) then begin
        ListOver:=GetCellsOnDistN(GetCell(i),
          SP.ProtectDist,[spIncludeBusyCell,spIgnoreTerrain]) ;
        ListOver.Add(GetCell(i)) ; // Включаем сам объект в зону защиты
        Result.AddNoExistFrom(ListOver) ;
        ListOver.Free ;
      end
      else begin
        if ObjModule.PL.GetHardLevel()=hlImmortal then
           if GetCell(i).IsPonyUnit then
              Result.AddIfNoExist(GetCell(i)) ;
      end;
        
end;

function TBattleField.CreatePoisonCellList: TCellListNoOwn;
var i:Integer ;
    ListOver:TCellListNoOwn ;
begin
  Result:=TCellListNoOwn.Create;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i).IsMonster then 
        if TMonsterUnit(GetCell(i)._Object).IsPoison() then begin
        ListOver:=GetCellsOnDistN(GetCell(i),
          TMonsterUnit(GetCell(i)._Object).PoisonDist(),[spIncludeBusyCell,spIgnoreTerrain]) ;
        ListOver.Add(GetCell(i)) ; // Включаем сам объект в зону
        Result.AddNoExistFrom(ListOver) ;
        ListOver.Free ;
      end;
end;

function TBattleField.CreateMagicLockCellList: TCellListNoOwn;
var i:Integer ;
    ListOver:TCellListNoOwn ;
begin
  Result:=TCellListNoOwn.Create;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i).IsMonster then 
        if GetCell(i)._Object is TMonsterTent then begin
        ListOver:=GetCellsOnDistN(GetCell(i),
          TMonsterTent(GetCell(i)._Object).MagicLockDist(),[spIncludeBusyCell,spIgnoreTerrain]) ;
        ListOver.Add(GetCell(i)) ; // Включаем сам объект в зону
        Result.AddNoExistFrom(ListOver) ;
        ListOver.Free ;
      end;
end;

function TBattleField.CreateMagicStoleCellList: TCellListNoOwn;
var i:Integer ;
    ListOver:TCellListNoOwn ;
begin
  Result:=TCellListNoOwn.Create;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i).IsMonster then
        if GetCell(i)._Object is TMonsterTirek then begin
        ListOver:=GetCellFinder().FastGetAllCellsOnRadius(GetCell(i),
          TMonsterTirek(GetCell(i)._Object).MagicStoleDist()) ;
        Result.AddNoExistFrom(ListOver) ;
        ListOver.Free ;
      end;
end;

function TBattleField.CreateSlowdownCellList: TCellListNoOwn;
var i:Integer ;
    ListOver:TCellListNoOwn ;
    SP:TPassivePropEnemySlowdown ;
    SF:TCellFinder ;
begin
  SF:=TCellFinder.Create ;
  Result:=TCellListNoOwn.Create;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then
      if GetCell(i)._Object.getPassiveProp(TPassivePropEnemySlowdown,TPassiveProp(SP)) then begin
        ListOver:=SF.GetCellsOnDistN(GetCell(i),
          SP.SlowdownDist,[spIncludeBusyCell,spIgnoreTerrain]) ;
        Result.AddNoExistFrom(ListOver) ;
        ListOver.Free ;
      end;
  SF.Free ;    
end;

function TBattleField.CreateMonsterStepsCellList: TCellListNoOwn;
var i:Integer ;
    ListOver:TCellListNoOwn ;
    SF:TCellFinder ;
begin
  Result:=TCellListNoOwn.Create;
  for i := 0 to CellCount - 1 do
    if GetCell(i).IsMonster then begin
        ListOver:=GetCellsOnDistNForPonyWalk(GetCell(i),
          TMonsterUnit(GetCell(i)._Object).GetMaxStep()) ;
        Result.AddNoExistFrom(ListOver) ;
        ListOver.Free ;
      end;
end;

function TBattleField.CreateTowerCellList: TCellListNoOwn;
var i:Integer ;
    ListOver:TCellListNoOwn ;
    SADamage:TStepActionDamage ;
    SAHeal:TStepActionHeal ;
    SARestore:TStepActionRestore ;
    SF:TCellFinder ;
begin
  SF:=TCellFinder.Create ;
  Result:=TCellListNoOwn.Create;
  for i := 0 to CellCount - 1 do
    if not GetCell(i).IsEmpty then begin
      if GetCell(i)._Object.getStepAction(TStepActionDamage,TStepAction(SADamage)) then begin
        ListOver:=SF.GetCellsOnDistN(GetCell(i),
          SADamage.Dist,[spIncludeBusyCell,spIgnoreTerrain]) ;
        Result.AddNoExistFrom(ListOver) ;
        ListOver.Free ;
      end;
      if GetCell(i)._Object.getStepAction(TStepActionHeal,TStepAction(SAHeal)) then begin
        ListOver:=SF.GetCellsOnDistN(GetCell(i),
          SAHeal.Dist,[spIncludeBusyCell,spIgnoreTerrain]) ;
        Result.AddNoExistFrom(ListOver) ;
        ListOver.Free ;
      end;
      if GetCell(i)._Object.getStepAction(TStepActionRestore,TStepAction(SARestore)) then begin
        ListOver:=SF.GetCellsOnDistN(GetCell(i),
          SARestore.Dist,[spIncludeBusyCell,spIgnoreTerrain]) ;
        Result.AddNoExistFrom(ListOver) ;
        ListOver.Free ;
      end;
    end;
  SF.Free ;    
end;

{ TCellListNoOwn }

procedure TCellListNoOwn.AddIfAssigned(Cell: TCell);
begin
  if Cell<>nil then Add(Cell) ;  
end;

function TCellListNoOwn.GetItem(i: Integer): TCell;
begin
  Result:=TCell(inherited GetItem(i)) ;
end;

procedure TCellListNoOwn.RemoveIfInList(List: TCellListNoOwn);
var i:Integer ;
begin
  i:=0 ;
  while i<Count do
    if List.IsObjectIn(Items[i]) then Delete(Items[i]) else Inc(i) ;
end;

procedure TCellListNoOwn.RemoveNonEmptyCells;
var i:Integer ;
begin
  i:=0 ;
  while i<Count do
    if not Items[i].IsEmpty() then Delete(Items[i]) else Inc(i) ;
end;

var _SortCell:TCell ;

function funcSortByQDist(p1,p2:Pointer):Integer ;
begin
  Result:=Round(TCell(p1).CalcQDistanceTo(_SortCell)-TCell(p2).CalcQDistanceTo(_SortCell)) ;
end ;

procedure TCellListNoOwn.SortByQDistanceTo(Cell: TCell);
begin
  _SortCell:=Cell ;
  List.Sort(funcSortByQDist);
end;

{ TMicroCell }

constructor TMicroCell.Create(ATerr: TTerrain; Aborderdir, AXC, AYC: Integer);
begin
  _Terrain:=ATerr ;
  XC:=AXC ;
  YC:=AYC ;
  borderdir:=Aborderdir ;
end;

end.
