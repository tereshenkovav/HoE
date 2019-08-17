unit FFGame;

interface
uses PonyAction, CommonClasses, GameObject, BattleField, SpriteEffects,
  HGEAnim, Classes, SysUtils, Windows ;

procedure GoGameLevel(Level:Integer) ;
procedure UnloadGameResources() ;
function GetCurrentLevelCount():Integer ;
function FrameFuncGame():Boolean ;
procedure SetGameLevel(Level:Integer) ;
procedure GoGameAutoLevel() ;
//procedure PopupHitBox(AA:TAfterAction; x,y:Integer; color:Cardinal) ;
function GetActivePony():TGameObject ;
function GetBF():TBattleField ;

var
SkipStepInfo:Boolean ;
  SRsctDel:TSpriteRender ;
  sctDelAnim:IHGEAnimation ;
  SRbctDel:TSpriteRender ;
  bctDelAnim:IHGEAnimation ;
  sct_del_pos:TPointSingle ;
  effect_init_pos:TPointSingle ;

type
  TLoadThread = class(TThread)
  public
    pos:Integer ;
    maxpos:Integer ;
  protected
    procedure Execute() ; override ;
  end;

var loadpos:Integer  ;
var th:TLoadThread ;
var CritSect : TRTLCriticalSection;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, Effects,FFMenu, CommonProc,
  FFWinFail, HGESprite,
  simple_oper, KeyStrList,
  BFLoader, Terrain, ObjectMover, MapScript,
  PonyUnits, VictoryCond, FontHolder, MonsterAI, Constants,
  MonsterUnits, FFMessage, FFGameMenu, BFSaver, FFInfoStep,
  HitViewer, LeftPanel, CheatCodes, ScreenScroller, Editor,
  contnrs,
  IconPanel, Cursor, FFHelpPanel, MultiObjRender, FFMonsterInfo, FFMessageList,
  FFTerrainInfo, FFBattleTask, FogManager, AniManager, IniFiles, simple_files,
  PonyActionEx, Buildings, StepActionDamage, StepAction, CellFinder,
  FFConfirm, CellDict,
  PassivePropSpaceProtect, PassivePropEnemySlowdown, PassiveProp,
  StepActionRestore, StepActionHeal, FFChooseSol, TexturePainter,
  BuiltinMapFuncs, Config ;

var
  flag_fail:Boolean ;

  SRHex,SRHex_rightbordered,SRHexWay,SRHexDark,SRHexFog,SRHexMonsterZone,SRSpaceProtectZone,SRSlowDownZone,SRTowerZone,
    SRMagicLockZone,SRMagicStoleZone,SRPoisonZone,SRHexDamageZone:TSpriteRender ;
  SRPlashLeft:TSpriteRender ;
  SRFreezed,SRBurned,SRSleeped,SRForceShield,SRForceShieldNR,SRStun:TSpriteRender ;
  SRTargeted:TSpriteRender ;
  SRHealthInd:TSpriteRender ;
  SRAIStepIndBack:TSpriteRender ;
  SRAIStepInd:TSpriteRender ;
  SRAIBookAnim:TSpriteRender ;
  SRWoods,SRMountains:TSpriteRender ;
  SRTeleport:TSpriteRender ;
  TeleportAnim:IHGEAnimation ;
  SRCrystalRain:TSpriteRender ;
  CrystalRainAnim:IHGEAnimation ;
  SRSonicRainboom:TSpriteRender ;
  SonicRainboomAnim:IHGEAnimation ;
  SRSunBeam:TSpriteRender ;
  SunBeamAnim:IHGEAnimation ;
  SRSunBeamTail:TSpriteRender ;
  SRsctNew:TSpriteRender ;
  sctNewAnim:IHGEAnimation ;
  SRbctNew:TSpriteRender ;
  bctNewAnim:IHGEAnimation ;

  SRPortalActivation:TSpriteRender ;
  SREmptyClearing:TSpriteRender ;
  EmptyClearingAnim:IHGEAnimation ;

  SRRoadLR,SRRoadDiag,SRRoadRot1,SRRoadRot2,SRRoadCross1,SRRoadCross2,SRRoadX:TSpriteRender ;
  
  infoall:TStringList ;

  roundedterr:Boolean = true ;

  rain_count:Integer = 0 ;
  rain_array:array[0..31] of TPoint ;
  sonic_rainboom_pos:TPointSingle ;
  sct_new_pos:TPointSingle ;
    
  DelayedActionObject:TActionObject ;

  SRPoolObjZones:TSpriteRenderPool ;

  celldic:TCellDict ;

  oldsnapshot:string = '';

function CreateTerrainSprite(terr:TTerrain):IHGESprite ;
var spr:IHGESprite ;
    painter:TTexturePainter ;
    x,y:Integer ;
    filename,oldpath:string ;
begin
  filename:='terrains\terrain_'+terr.Name+'.png' ;
  if not FileExists(PathLoader+filename) then begin
    oldpath:=PathLoader ;
    SetPathForLoader(GetLevelFileName(CurrentGameCode,ActiveLevel)+'.data\images\') ;
    spr:=LoadAndCenteredSizedSprite(mHGE,filename) ;
    SetPathForLoader(oldpath) ;
  end
  else
    spr:=LoadAndCenteredSizedSprite(mHGE,filename) ;

  if ObjModule.PL.IsMonoTerrain and (not Terr.UseSubLayer) and (not (Terr.CharCode='@')) then begin
    painter:=TTexturePainter.Create(spr.GetTexture,False);
    for x := 0 to painter.Width-1 do
      for y := 0 to painter.Height-1 do
        if painter.Alpha[x,y]=$FF then
          painter.Pixels[x,y]:=terr.Color ;
    painter.Free ;
  end ;
  Result:=spr ;
end ;

function testXYOutScreen(X,Y:Integer):Boolean ;
begin
  Result:=(X<LP.getWidth()-CELL_WIDTH)or(Y<-CELL_HEIGHT)or
          (X>1024+CELL_WIDTH/2)or(Y>768+CELL_HEIGHT) ;
end;
function IsCellOutScreen(i:Integer):Boolean ;
begin
  Result:=testXYOutScreen(BF.GetCell(i).XC,BF.GetCell(i).YC) ;
end;
function IsMicroCellOutScreen(mc:TMicroCell):Boolean ;
begin
  Result:=testXYOutScreen(mc.XC,mc.YC) ;
end;

function GetActivePony():TGameObject ;
begin
  if BF.IsActiveCell then
    Result:=BF.getActiveObject()
  else
    Result:=nil ;
end ;

function GetBF():TBattleField ;
begin
  Result:=BF ;
end;

function IsControlPanelShowed():Boolean ;
begin
  // Раньше был запрет на панель при движении монстров и появления объектов
  Result:=True ;
end;

function GetCurrentLevelCount():Integer ;
begin
  Result:=GetLevelCountByGame(CurrentGameCode) ;
end;

procedure setGameLevel(Level:Integer) ;
begin
  ActiveLevel:=Level ;
end;

procedure LoadLevel(n:Integer) ;
var filename:string ;
begin
  SEPool.DelAllEffects ;

  SEPool.AddEffect(TSETransparentHarmonic.Create(SRTargeted,25,75,25,3000));

  filename:=GetLevelFileName(CurrentGameCode,n) ;

//  LoadTerrains(filename) ;
  InitGConfig(filename) ;
  ObjModule.setLevelFileName(filename) ;

  with TBFLoader.Create() do begin
    BF:=CreateBattleField(filename) ;
    MS:=GetMapScript() ;
    VC:=GetVictoryCond() ;
    Free ;
  end;

  BF.SetStaticShift(210,10);

  OM:=TObjectMover(BF.GetOM()) ;

  MAI:=TMonsterAI.Create(BF);

  mHGE.System_Log('Load level %d OK',[n]);

  HV:=THitViewer.Create() ;

  LP:=TLeftPanel.Create(BF) ;
  IP:=TIconPanel.Create() ;
  CSR:=TCursor.Create() ;

  flag_fail:=False ;

  GSkipMessage:=False ;
end;

function IsWin():Boolean ;
begin
  if BF.DefeatFlag then begin
    Result:=False ; Exit ;
  end ;
  
  if BF.VictoryFlag then Result:=True else begin
  Result:=VC.IsVictory(BF) ;
  if Result then begin
    BF.VictoryFlag:=True ;
    SetResultMsg('Число ходов: '+IntToStr(BF.GetCurrentStep+1)) ;
  end;
  end;
end;

function IsGameFail():Boolean ;
var i:Integer ;
begin
  Result:=False ;
  if BF.DefeatFlag then begin
    // ResultMsg уже установлен внутри BF
    Result:=True ;
    Exit ;
  end;

  for i := 0 to BF.CellCount - 1 do
    if not BF.GetCell(i).IsEmpty then
      if BF.GetCell(i)._Object is TPonyUnit then
        if (TPonyUnit(BF.GetCell(i)._Object).IsKilled())and
        (not BF.IsDeathAllow(TPonyUnit(BF.GetCell(i)._Object))) then begin
          SetResultMsg('Причина поражения: '+TPonyUnit(BF.GetCell(i)._Object).Name+
           ' без сознания.') ;
          Result:=True ;
          Exit ;
        end ;

end;

function tagTransformPony2Actions(tag:string):string ;
begin
  Result:='icon_'+tag ;
end;

const WATERTAGPOSTFIX='_inwatertagged' ;

function tagTransformPony2PonyWater(tag:string):string ;
begin
  Result:=tag+WATERTAGPOSTFIX ;
end;

procedure LoadGameResources(var CritSect : TRTLCriticalSection; var p:Integer) ;
var i:Integer ;
    Spr:IHGESprite ;
    dir,borderdir:Integer ;
    savepathloader,userimagedir:string ;
    
procedure IncP() ;
begin
  EnterCriticalSection(CritSect) ;
  Inc(p) ;
  LeaveCriticalSection(CritSect) ;
end ;

procedure LoadInternalAndUserSpritesByMask(pool:TSpriteRenderPool;mask:string; tagTransform:TfuncTagTransform=nil);
begin
  LoadFilesToSRPool(SRPoolObjects,mask,'units',tagTransform) ;
  if DirectoryExists(userimagedir+'units') then begin
    TAVHGEUtils.PathLoader:=userimagedir ;
    LoadFilesToSRPool(SRPoolObjects,mask,'units',tagTransform) ;
    TAVHGEUtils.PathLoader:=savepathloader ;
  end;
end ;

begin
  AM:=TAniManager.Create() ;

  SRHex:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell.png')) ;
  SRHex_rightbordered:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_rightbordered.png')) ;

  SRHexWay:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_way.png')) ;
  SRHexWay.transp:=50 ;  
  SRHexDark:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_dark.png')) ;
//  SRHexWay.transp:=50 ;
  SRHexFog:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_dark.png')) ;
  SRHexFog.transp:=33 ;

  SRHexMonsterZone:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_monsterzone.png')) ;
  SRHexMonsterZone.transp:=50 ;
  SRHexDamageZone:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_damagezone.png')) ;
  SRHexDamageZone.transp:=50 ;

  SRSpaceProtectZone:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_spaceprotectzone.png')) ;
  SRSpaceProtectZone.transp:=25 ;
  SRSlowDownZone:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_slowdownzone.png')) ;
  SRSlowDownZone.transp:=25 ;
  SRTowerZone:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_towerzone.png')) ;
  SRTowerZone.transp:=25 ;
  SRPoisonZone:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_poisonzone.png')) ;
  SRPoisonZone.transp:=25 ;
  SRMagicLockZone:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_magiclockzone.png')) ;
  SRMagicLockZone.transp:=25 ;
  SRMagicStoleZone:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'hexcell_magicstolezone.png')) ;
  SRMagicStoleZone.transp:=25 ;

  SRPlashLeft:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'plash_left.png')) ;

  SRTextBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'text_back.png')) ; ;

  SRMenuBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'menu_back.png')) ; ;
  SRChooseSolBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'choosesol_back.png')) ; ;

  SRButMiniClose:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'but_miniclose.png')) ; ;
  SRButMiniClose2:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'but_miniclose2.png')) ; ;

  BattleField.setCellParams(
    Round(SRHex.GetSprite.GetWidth),Round(SRHex.GetSprite.GetHeight)-4);

  IncP() ;

  SRPoolTerrs:=TSpriteRenderPool.Create ;
  for i := 0 to Terrains().Count - 1 do
    if Pos('Teleport',Terrains().GetTerr(i).Name)=0 then
    if Pos('FlameWall',Terrains().GetTerr(i).Name)=0 then
    SRPoolTerrs.AddRenderTagged(TSpriteRender.Create(
        CreateTerrainSprite(Terrains().GetTerr(i))),
        Terrains().GetTerr(i).Name);

  IncP() ;

  // Построение микротерриторий внутри карты
  for i := 0 to Terrains().Count - 1 do
   if not Terrains().GetTerr(i).UseSubLayer then
    for dir:=0 to 5 do begin
      Spr:=CreateTerrainSprite(Terrains().GetTerr(i)) ;
      MakeMicroTerr(Spr,dir) ;
      SRPoolTerrs.AddRenderTagged(TSpriteRender.Create(Spr),
        'microterr_'+Terrains().GetTerr(i).Name+'_'+IntToStr(dir)) ;
    end;
  // И микротерриторий на края карты
  for i := 0 to Terrains().Count - 1 do
   if not Terrains().GetTerr(i).UseSubLayer then
    for borderdir:=1 to 10 do begin
      Spr:=CreateTerrainSprite(Terrains().GetTerr(i)) ;
      MakeMicroTerrBorder(Spr,borderdir) ;
      SRPoolTerrs.AddRenderTagged(TSpriteRender.Create(Spr),
        'microterrborder_'+Terrains().GetTerr(i).Name+'_'+IntToStr(borderdir)) ;
    end;

  IncP() ;

  userimagedir:=GetLevelFileName(CurrentGameCode,ActiveLevel)+'.data\images\' ;
  savepathloader:=TAVHGEUtils.PathLoader ;

  SRPoolObjects:=TSpriteRenderPool.Create ;
  LoadInternalAndUserSpritesByMask(SRPoolObjects,'pony_*.png') ;
IncP() ;

  LoadInternalAndUserSpritesByMask(SRPoolObjects,'monster_*.png') ;
IncP() ;

  LoadFilesToSRPool(SRPoolObjects,'resource_*.png','units') ;
IncP() ;

  LoadInternalAndUserSpritesByMask(SRPoolObjects,'building_*.png') ;
IncP() ;

  LoadInternalAndUserSpritesByMask(SRPoolObjects,'neutral_*.png') ;

  SRPoolObjects.AddRenderTagged(
    AM.CreateSprite(PathLoader+'crystal_tower_little.png',9,9,0,70,70,70,35,35),
    'building_crystaltowersmall') ;
  SRPoolObjects.AddRenderTagged(
    AM.CreateSprite(PathLoader+'crystal_tower_big.png',9,9,0,100,100,100,50,50),
    'building_crystaltowerbig') ;

  SRPoolObjects.AddRenderTagged(
    AM.CreateSprite(PathLoader+'celestia_ray.png',8,20,0,0,110,100,55,50),
    'pony_celestia_ray') ;
  SRPoolObjects.AddRenderTagged(
    AM.CreateSprite(PathLoader+'nm_ray.png',8,20,0,0,110,100,55,50),
    'monster_nmoon_ray') ;
  SRPoolObjects.AddRenderTagged(
    AM.CreateSprite(PathLoader+'nm_ray.png',8,20,0,0,110,100,55,50),
    'neutral_nm_ray') ;
  SRPoolObjects.AddRenderTagged(
    AM.CreateSprite(PathLoader+'blue_ray.png',8,20,0,0,80,30,40,15),
    'neutral_blue_ray') ;
  SRPoolObjects.AddRenderTagged(
    AM.CreateSprite(PathLoader+'yellow_ray.png',8,20,0,0,80,30,40,15),
    'neutral_yellow_ray') ;
  SRPoolObjects.AddRenderTagged(
    AM.CreateSprite(PathLoader+'clash_ray.png',8,20,0,0,80,100,40,50),
    'neutral_clash_ray') ;

  SRPortalActivation:=
    AM.CreateSprite(PathLoader+'portal_activation.png',19,10,0,0,80,80,40,40) ;
  PortalActivationAnim:=AM.GetLastAnim() ;
  PortalActivationAnim.SetMode(HGEANIM_FWD or HGEANIM_NOLOOP);
  PortalActivationAnim.Stop() ;

  SREmptyClearing:=
    AM.CreateSprite(PathLoader+'empty_place_clearing.png',7,10,0,0,80,97,40,48) ;
  EmptyClearingAnim:=AM.GetLastAnim() ;
  EmptyClearingAnim.SetMode(HGEANIM_FWD or HGEANIM_NOLOOP);
  EmptyClearingAnim.Stop() ;

IncP() ;

  // Дублирование для водных текстур
  LoadInternalAndUserSpritesByMask(SRPoolObjects,'pony_*.png',tagTransformPony2PonyWater) ;
  LoadInternalAndUserSpritesByMask(SRPoolObjects,'monster_*.png',tagTransformPony2PonyWater) ;
  for i := 0 to SRPoolObjects.Count - 1 do
     if Pos(WATERTAGPOSTFIX,SRPoolObjects[i].Tag)<>0 then
        MakeGradientTranspByHalf(TSpriteRender(SRPoolObjects[i]).GetSprite()) ;

  SRPoolIcons:=TSpriteRenderPool.Create ;
  LoadFilesToSRPool(SRPoolIcons,'*_ico.png','icons') ;
  if DirectoryExists(userimagedir+'icons') then begin
    TAVHGEUtils.PathLoader:=userimagedir ;
    LoadFilesToSRPool(SRPoolIcons,'*_ico.png','icons') ;
    TAVHGEUtils.PathLoader:=savepathloader ;
  end;


IncP() ;

  SRPoolActionIcons:=TSpriteRenderPool.Create ;
  LoadFilesToSRPool(SRPoolActionIcons,'icon_*.png','actions') ;
  if DirectoryExists(userimagedir+'actions') then begin
    TAVHGEUtils.PathLoader:=userimagedir ;
    LoadFilesToSRPool(SRPoolActionIcons,'icon_*.png','actions') ;
    TAVHGEUtils.PathLoader:=savepathloader ;
  end;

  LoadInternalAndUserSpritesByMask(SRPoolActionIcons,'pony_*.png',tagTransformPony2Actions) ;
  for i := 0 to SRPoolActionIcons.Count - 1 do
    if Pos('icon_pony_',SRPoolActionIcons[i].Tag)=1 then
      SRPoolActionIcons[i].SetScaleBoth(70);

IncP() ;

  SRPoolObjects.AddRenderTagged(TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'units\empty_place.png')),'empty_place');

  SRFreezed:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'spell_freeze.png')) ;
  SRFreezed.transp:=50 ;

  SRSleeped:=AM.CreateSprite(PathLoader+'sleep_34.png',32,24,0,0,64,64,0,64) ;
  SRForceShield:=AM.CreateSprite(PathLoader+'forceshield.png',28,10,0,0,80,80) ;
  SRForceShieldNR:=AM.CreateSprite(PathLoader+'forceshieldnr.png',28,10,0,0,80,80) ;
  SRAIBookAnim:=AM.CreateSprite(PathLoader+'book.png',9,3,0,0,30,30,0,0) ;
  SRStun:=AM.CreateSprite(PathLoader+'stun.png',7,20,0,0,70,70, 30,55) ;
  SRBurned:=AM.CreateSprite(PathLoader+'spell_burned.png',15,20,0,0,100,100) ;

  SRTeleport:=AM.CreateSprite(PathLoader+'teleportation_9.png',9,9,0,0,200,200) ;
  TeleportAnim:=AM.GetLastAnim() ;
  TeleportAnim.Stop() ;

  SRPoolTerrs.AddRenderTagged(
    AM.CreateSprite(PathLoader+'Portal.png',7,10,0,0,50,75),'Teleport');
  SRPoolTerrs.AddRenderTagged(
    AM.CreateSprite(PathLoader+'Portal.png',7,10,0,0,50,75),'TeleportOpened');

  SRPoolTerrs.AddRenderTagged(
    AM.CreateSprite(PathLoader+'flame_wall_1.png',15,20,0,0,150,90),'FlameWall_1');

  SRPoolTerrs.AddRenderTagged(
    AM.CreateSprite(PathLoader+'flame_wall_2.png',15,20,0,0,100,150),'FlameWall_2');

  SRPoolTerrs.AddRenderTagged(
    AM.CreateSprite(PathLoader+'flame_wall_3.png',15,20,0,0,100,150),'FlameWall_3');

  SRCrystalRain:=AM.CreateSprite(PathLoader+'crystal_rain.png',25,20,0,0,128,550) ;
  CrystalRainAnim:=AM.GetLastAnim() ;
  CrystalRainAnim.SetMode(HGEANIM_FWD or HGEANIM_NOLOOP);
  CrystalRainAnim.Stop() ;

  SRSonicRainboom:=AM.CreateSprite(PathLoader+'sonic_rainboom.png',7,10,0,0,500,500) ;
  SonicRainboomAnim:=AM.GetLastAnim() ;
  SonicRainboomAnim.SetMode(HGEANIM_FWD or HGEANIM_NOLOOP);
  SonicRainboomAnim.Stop() ;

  SRSunBeam:=AM.CreateSprite(PathLoader+'sun_beam.png',8,20,0,0,100,500) ;
  SunBeamAnim:=AM.GetLastAnim() ;
  SunBeamAnim.SetMode(HGEANIM_FWD or HGEANIM_LOOP);
  SunBeamAnim.Stop() ;
  SRSunBeamTail:=AM.CreateSprite(PathLoader+'sun_beam.png',8,20,0,0,100,10) ;
  with AM.GetLastAnim() do begin
    SetMode(HGEANIM_FWD or HGEANIM_LOOP);
    Stop() ;
  end;
  SRSunBeamTail.scaley:=10000 ;

  SRsctNew:=AM.CreateSprite(PathLoader+'crystal_tower_little.png',24,17,0,0,70,70) ;
  sctNewAnim:=AM.GetLastAnim() ;
  sctNewAnim.SetMode(HGEANIM_FWD or HGEANIM_NOLOOP);
  sctNewAnim.Stop() ;

  SRsctDel:=AM.CreateSprite(PathLoader+'crystal_tower_little.png',17,17,0,140,70,70) ;
  sctDelAnim:=AM.GetLastAnim() ;
  sctDelAnim.SetMode(HGEANIM_FWD or HGEANIM_NOLOOP);
  sctDelAnim.Stop() ;

  SRbctNew:=AM.CreateSprite(PathLoader+'crystal_tower_big.png',24,17,0,0,100,100) ;
  bctNewAnim:=AM.GetLastAnim() ;
  bctNewAnim.SetMode(HGEANIM_FWD or HGEANIM_NOLOOP);
  bctNewAnim.Stop() ;

  SRbctDel:=AM.CreateSprite(PathLoader+'crystal_tower_big.png',17,17,0,200,100,100) ;
  bctDelAnim:=AM.GetLastAnim() ;
  bctDelAnim.SetMode(HGEANIM_FWD or HGEANIM_NOLOOP);
  bctDelAnim.Stop() ;

  SRTargeted:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'target.png')) ;

  SRHealthInd:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'indicator2.png')) ;
  SRAIStepIndBack:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'enemy_actions.png')) ;
  SRAIStepInd:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'enemy_actions_ind.png')) ;
  SRAIStepInd:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'enemy_actions_ind.png')) ;

  SRWoods:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'layer_woods.png')) ;
  SRMountains:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'layer_mountains.png')) ;

  SRRoadLR:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'road_l_r.png')) ;
  SRRoadDiag:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'road_diag.png')) ;
  SRRoadRot1:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'road_rot1.png')) ;
  SRRoadRot2:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'road_rot2.png')) ;
  SRRoadCross1:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'road_cross1.png')) ;
  SRRoadCross2:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'road_cross2.png')) ;
  SRRoadX:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'road_x.png')) ;

  SRUnderAttack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'ally_is_under_attack.png')) ;

  IncP() ;

  SRPoolObjZones:=TSpriteRenderPool.Create ;

  LoadEditorKeys(GetLevelFileName(CurrentGameCode,ActiveLevel)) ;
end ;

procedure UnloadGameResources() ;
begin
  SRPool.DelAllRenders ;
  SRPoolTerrs.Free ;
  OM.Free ;
  MAI.Free ;
  BF.Free ;
  SRPoolObjZones.Free ;
end;

procedure RenderZoneInfos() ;

function PosZoneY(i:Integer):Integer ;
begin
  Result:=90+140*i ;
end ;

function PosZoneYFnt(i:Integer):Integer ;
begin
  Result:=PosZoneY(i)-75 ;
end ;

var C:Cardinal ;

begin
  C:=fnt2.GetColor ;
  fnt.SetColor($FF404040);

  fnt2.Render(100,PosZoneYFnt(0),HGETEXT_CENTER,'Защита от Пустоты');
  SRSpaceProtectZone.RenderAt(100,PosZoneY(0)) ;

  fnt2.Render(100,PosZoneYFnt(1),HGETEXT_CENTER,'Покрытие башен');
  SRTowerZone.RenderAt(100,PosZoneY(1)) ;

  fnt2.Render(100,PosZoneYFnt(2),HGETEXT_CENTER,'Зона замедления');
  SRSlowDownZone.RenderAt(100,PosZoneY(2)) ;

  fnt2.Render(100,PosZoneYFnt(3),HGETEXT_CENTER,'Зона отравления');
  SRPoisonZone.RenderAt(100,PosZoneY(3)) ;

  fnt2.Render(100,PosZoneYFnt(4),HGETEXT_CENTER,'Зона без магии');
  SRMagicLockZone.RenderAt(100,PosZoneY(4)) ;

  fnt.SetColor(C);

end;

procedure ProcessCellClick(mx,my:Single) ;
var OverCell:TCell ;
    ListWay:TCellListNoOwn ;
    CellStart:TCell ;
    errmsg:string ;
    CurPony:TPonyUnit ;
    ListRain,ListBeam:TCellListNoOwn ;
    i:Integer ;
begin
  OverCell:=BF.GetCellByXY(Round(mx),Round(my)) ;
  if OverCell=nil then Exit ;

  // Варианты действий:
  // 1 - выполнение действия
  // 2 - выделение пони
  // 3 - запуск перемещения пони

   if LP.ActiveAction<>nil then
     ListWay:=LP.ActiveAction.BuildAllowCellList(BF.GetActiveCell)
   else
   if BF.IsActiveCell() then
     ListWay:=BF.CreateListCellsOnWayForPonyWalk(BF.GetActiveCell,OverCell,
        TPonyUnit(BF.GetActiveObject()).GetStepLeftWithEnergy())
   else
     ListWay:=TCellListNoOwn.Create ;

   // 1
   if LP.ActiveAction<>nil then
     if ListWay.IsObjectIn(OverCell) then begin
       CurPony:=TPonyUnit(BF.getActiveObject()) ;
       if LP.ActiveAction.Apply(BF,OverCell,errmsg) then begin
         if LP.ActiveAction.Code='CrystallRain' then begin
           DelayedActionObject:=TPonyActionEx(LP.ActiveAction).GetActionObject() ;
           ListRain:=LP.ActiveAction.BuildResultCellList(BF.GetActiveCell,OverCell) ;
           rain_count:=ListRain.Count ;
           effect_init_pos:=BF.GetShift() ;
           for i := 0 to ListRain.Count - 1 do begin
              rain_array[i].X:=ListRain[i].XC ;
              rain_array[i].Y:=ListRain[i].YC-
                Round(SRCrystalRain.GetSprite().GetHeight()/2)+CELL_HEIGHT div 2 ;
           end;
           CrystalRainAnim.Play ;
           ListRain.Free ;
         end;
         if LP.ActiveAction.Code='SonicRainbow' then begin
           DelayedActionObject:=TPonyActionEx(LP.ActiveAction).GetActionObject() ;
           effect_init_pos:=BF.GetShift() ;
           sonic_rainboom_pos.X:=OverCell.XC ;
           sonic_rainboom_pos.Y:=OverCell.YC ;
           SonicRainboomAnim.Play ;
         end;
         if LP.ActiveAction.Code='BuildCrystalTowerSmall' then begin
           DelayedActionObject:=TPonyActionEx(LP.ActiveAction).GetActionObject() ;
           effect_init_pos:=BF.GetShift() ;
           sct_new_pos.X:=OverCell.XC ;
           sct_new_pos.Y:=OverCell.YC ;
           sctNewAnim.Play ;
         end;
         if LP.ActiveAction.Code='BuildCrystalTowerBig' then begin
           DelayedActionObject:=TPonyActionEx(LP.ActiveAction).GetActionObject() ;
           effect_init_pos:=BF.GetShift() ;
           sct_new_pos.X:=OverCell.XC ;
           sct_new_pos.Y:=OverCell.YC ;
           bctNewAnim.Play ;
         end;
         if LP.ActiveAction.Code='SunBeam' then begin
           DelayedActionObject:=TPonyActionEx(LP.ActiveAction).GetActionObject() ;
           effect_init_pos:=BF.GetShift() ;
           ListBeam:=LP.ActiveAction.BuildResultCellList(BF.GetActiveCell,OverCell) ;
           ListBeam.SortByQDistanceTo(BF.GetActiveCell);
           SEPool.AddEffect(TSEMovementLinear.Create(SRSunBeam,
                 ListBeam[0].XC,ListBeam[0].YC-260+CELL_HEIGHT/2,
                 ListBeam[ListBeam.Count-1].XC,ListBeam[ListBeam.Count-1].YC-260+CELL_HEIGHT/2,1500));
           ListBeam.Free ;
           SunBeamAnim.Play ;
         end;

         LP.ActiveAction:=nil ;
         BF.clearPonyPos() ;
         CurPony.ApplyAction() ;
         Exit ;
       end
       else begin
         LP.setTemporaryMsg(errmsg,5);
         Exit ;
       end;
     end;


   // 2
   if not OverCell.isEmpty() then
     if OverCell._Object.CanRule then begin
       BF.setActiveCell(OverCell) ;
       LP.ActiveAction:=nil ;
       Exit ;
     end ;

   // 3      
   if LP.ActiveAction=nil then
     if BF.IsActiveCell() then
        if OverCell.isEmpty() then
          if ListWay.Count>0 then begin
             BF.SavePonyPos() ;
             CellStart:=BF.GetActiveCell() ;
             BF.clearActiveCell() ;
             OM.RunMovingProcess(CellStart,ListWay);
             Exit ;
          end ;

end;

procedure ProcessCellRightClick(mx,my:Single) ;
var OverCell:TCell ;
    ListWay:TCellListNoOwn ;
    CellStart:TCell ;
    errmsg:string ;
    CurPony:TPonyUnit ;
begin
  // Сброс текущего действия по правой кнопке
  if LP.ActiveAction<>nil then begin
    LP.ActiveAction:=nil ;
    Exit ;
  end;

  OverCell:=BF.GetCellByXY(Round(mx),Round(my)) ;
  if OverCell=nil then Exit ;

  if OverCell.IsMonster then
    GoMonsterInfo(TMonsterUnit(OverCell._Object))
  else
  if OverCell.IsEmpty then
    GoTerrainInfo(OverCell.GetRealTerr())

end;

procedure GoNextStep() ;
begin
    BF.ReadyForAfterStep:=True ;
    BF.NextStep() ;
    infoall:=BF.CreateStepInfo() ;
    BF.ClearStepInfo() ;
    MAI.BeginStep ;
    LP.ActiveAction:=nil ;
    {if not SkipStepInfo then begin
      showInfoAll(infoall) ;
      Exit ;
    end;}
end;

function FrameFuncGame():Boolean ;
var mx,my:Single ;
    dt:Single ;
    mapmovedx,mapmovedy:Integer ;
    i:Integer ;
    Script:TScriptRec ;
    multspeed:Single ;
    z:Boolean ;
    allowtransp:Boolean ;
begin
  try
  Result:=False ;

  dt:=mHGE.Timer_GetDelta() ;
  mHGE.Input_GetMousePos(mx,my);

  MS.ResetCachedResults() ;

  if (mHGE.Input_KeyDown(HGEK_ESCAPE)) or
     (LP.IsOverMenu(mx,my) and mHGE.Input_KeyDown(HGEK_LBUTTON)) then begin
    if LP.IsTemporaryMsg then LP.ClearTemporaryMsg else begin
      GoGameMenu() ;
      Exit ;
    end;
  end;

  if (mHGE.Input_KeyDown(HGEK_F1)) or
     (LP.IsOverHelp(mx,my) and mHGE.Input_KeyDown(HGEK_LBUTTON)) then begin
    GoHelpPanel() ;
    Exit ;
  end;

  if (LP.IsOverQuest(mx,my) and mHGE.Input_KeyDown(HGEK_LBUTTON)) then begin
    //setDialogMsg(BF.MapTaskView(),'ok_ico') ;
    FFBattleTask.GoBattleTask() ;
    Exit ;
  end;

  if (mHGE.Input_GetKeyState(HGEK_SHIFT)) then dt:=2*dt ;

  if (mHGE.Input_KeyDown(HGEK_C) and (not InEditMode())) or
     (LP.IsOverGridSwitch(mx,my) and mHGE.Input_KeyDown(HGEK_LBUTTON)) then
    PL.SetShowHex(not PL.IsShowHex) ;
   if (mHGE.Input_KeyDown(HGEK_V)and (not InEditMode())) then
    PL.SetShowHealthInd(not PL.IsShowHealthInd) ;


  if (mHGE.Input_KeyDown(HGEK_R)and (not InEditMode())) and (not OM.IsMovingProcess()) then begin
    if BF.isPonyPosSaved() then begin
      LP.ActiveAction:=nil ;
      BF.RestorePonyPos() ;
      LP.setTemporaryMsg('Отмена перемещения выполнена',5);
    end
    else
      LP.setTemporaryMsg('Нет сохраненных ходов или отмена невозможна',5);
  end;

  if (mHGE.Input_KeyDown(HGEK_F7)) then begin
    setMessageList(BF.GetMessageList()) ;
    Exit ;
  end;

  if (mHGE.Input_KeyDown(HGEK_F8)) then begin
    roundedterr:=not roundedterr ;
  end;
  
  ProcessCheatCodes() ;

  if not BF.IsOverMapMovingProcess then
    if IsScreenScrolled(mapmovedx,mapmovedy,multspeed) then
      BF.MoveOverMap(mapmovedx,mapmovedy,dt,multspeed);

  SEPool.Update(dt) ;

  LP.Update(mx,my,dt) ;

  // Притормаживаем действия, пока идет всплывание урона
  if (not HV.IsHitPopup()) then begin
    OM.Update(dt);
    BF.Update(dt);
    MAI.Update(dt);
    if (BF.ReadyForAfterStep and MAI.IsStepFinished) then begin
      BF.ReadyForAfterStep:=False ;
      BF.NextStep(AFTERSTEP) ;
    end ;
  end;

  if mHGE.Input_KeyDown(HGEK_F4) then switchEditMode() ;

  processEditor() ;

  if InEditMode() then Exit ;

  IP.Update(dt) ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) and
     (not OM.IsMovingProcess())and
     (not BF.IsOverMapMovingProcess()) and
     (not BF.IsTeleportProcessing()) and
     (not BF.IsExistsTranspObjs()) and
     (not sctNewAnim.IsPlaying) and
     (not bctNewAnim.IsPlaying) and     
     (MAI.IsStepFinished) then begin

    if (mx>200)and(not IP.IsOverPanel(mx,my))and(not LP.IsOverUserAction(mx,my))
       then ProcessCellClick(mx,my) ;

  if not MS.IsActualScript then
  if LP.IsOverFinishStep(mx,my) then begin
    if IP.IsNoStepActionsYet() then
      execConfirmMsg('Вы не переместили ни одну пони и не выполнили ни одного действия. '+
        ' Уверены, что хотите завершить ход?',
            FrameFuncGame,GoNextStep)
    else
      GoNextStep() ;
  end;

  if (MapFuncs_getUserActionInfo(BF)<>'')and(MAI.IsStepFinished)and(not MS.IsActualScript) then begin
    if LP.IsOverUserAction(mx,my) then
      MapFuncs_doUserAction(BF) ;    
  end;

  end; // end keydown


  if mHGE.Input_KeyDown(HGEK_RBUTTON) and
     (not OM.IsMovingProcess())and
     (not BF.IsOverMapMovingProcess()) and
     (not BF.IsTeleportProcessing()) and
     (not BF.IsExistsTranspObjs()) and
     (MAI.IsStepFinished) then begin

    if mx>200 then ProcessCellRightClick(mx,my) ;

  end; // end keydown

  if IsWin() then begin
//    PlaySound(SndWin) ;
   mHGE.System_Log('Win');
   MS.ResetCachedResults() ;

     if (not BF.IsOverMapMovingProcess())and
     (not BF.IsExistsTranspObjs())and // появления объектов
     (not BF.IsTeleportProcessing()) and
     (not OM.IsMovingProcess()) then begin // И движения любых объектов

  if not MS.IsActualScript then begin
    // Если еще есть актуальные скрипты, выполняем их
    UnloadGameResources() ;
    mHGE.System_Log('Resource unload');
    PL.SigLevelCompleted(CurrentGameCode,ActiveLevel);
    mHGE.System_Log('sig completed');
    GoWin() ;
    mHGE.System_Log('go win');
    Exit ; // Обязательно прервать процедуру
  end ;

     end;
  end;

  if IsGameFail() then begin
    mHGE.System_Log('Fail');
    if not HV.IsHitPopup() then begin

    if not flag_fail then begin
      flag_fail:=True ;
      setDialogMsg('Вы потерпели поражение!','ok_ico') ;
    end
    else begin
      UnloadGameResources() ;
      GoFail() ;
      Exit ; // Обязательно прервать процедуру
    end ;
    
    end;
  end;

  if (mHGE.Input_KeyDown(HGEK_G)and (not InEditMode())) then begin
    while (not MAI.IsStepFinished)and(not HV.IsHitPopup) do begin
      MAI.Update(dt);
      OM.Update(dt);
      BF.Update(dt);
    end;
  end;

  if (mHGE.Input_KeyDown(HGEK_SPACE)and (not InEditMode())) then begin
    if BF.IsActiveCell then
      BF.ImmediateRunTo(BF.GetActiveCell.XOnMap,BF.GetActiveCell.YOnMap);
  end ;

  allowtransp:=MS.IsActualScriptInTransp() ;

  // Запрет на запуск скриптов во время движения карты
  if (not BF.IsOverMapMovingProcess())and
     ((not BF.IsExistsTranspObjs()) or allowtransp )and // появления объектов
     (not OM.IsMovingProcess()) and // И движения любых объектов
     (not BF.IsTeleportProcessing()) and
     (not HV.IsHitPopup()) and // И всплывающих ударов
     (not BF.IsTimerProcessed()) and
     (MAI.IsStepFinished) then
  if MS.IsActualScript then begin
    Script:=MS.CreateActualScript() ;
    mHGE.System_Log('find script, classname='+Script.ClassName+'::'+Script.debugInfo());
    BF.clearPonyPos() ;
    Script.ExecEvent(BF);
    if Script.IsDialog then begin
      BF.GetMessageList().AddMessage(Script.DialogIcon,Script.DialogMsg);
      setDialogMsg(Script) ;
      nohidedialog:=MS.IsActualScriptIsDialog() and
        (MS.IsActualScriptGetMark()<>'1')  ;
    end;
    if Script.IsChooseSol then begin
      GoChooseSol() ;
    end;
    // Только если следующий скрипт НЕ диалог, или если это последний скрипт в группе
    if (not MS.IsActualScript()) then
        GSkipMessage:=False ;

  end;
  
  if BF.IsTeleportProcessing() then begin
    if not TeleportAnim.IsPlaying then begin
      TeleportAnim.SetFrame(0);
      TeleportAnim.Play ;
    end ;
  end
  else
     TeleportAnim.Stop ;

  if (DelayedActionObject<>nil) then begin
    z:=False ;
    z:=z or ((not SonicRainboomAnim.IsPlaying)and(DelayedActionObject.Code='SonicRainbow')) ;
    z:=z or ((not sctNewAnim.IsPlaying)and(DelayedActionObject.Code='BuildCrystalTowerSmall')) ;
    z:=z or ((not bctNewAnim.IsPlaying)and(DelayedActionObject.Code='BuildCrystalTowerBig')) ;
    z:=z or ((not CrystalRainAnim.IsPlaying)and(DelayedActionObject.Code='CrystallRain')) ;
    z:=z or ((not SEPool.IsEffectExist(TSEMovementLinear,SRSunBeam))and(DelayedActionObject.Code='SunBeam')) ;
    if z then begin
      DelayedActionObject.Apply() ;
      DelayedActionObject.Free ;
      DelayedActionObject:=nil ;
    end;
  end;

  AM.UpdateAll(dt);

  LP.setExtInfo(BF.getExtInfo());
  LP.setUserActionInfo(BF.getUserActionInfo());

  Result:=False ;
  except
    on E:Exception do begin
      mHGE.System_Log('Error in Frame Func: '+E.Message);
    end;
  end;
end;

function RenderFuncGame():Boolean ;
var mx,my:Single ;
    i,j:Integer ;
    OverCell:TCell ;
    SR,SRRoad:TSpriteRender ;
    ListMovable,ListWay:TCellListNoOwn ;
    bright:Integer ;
    MonsterStepList,TowerDamageList:TCellListNoOwn ;
    log:TStringList ;
    MOR:TMultiObjRender ;
    dir:Integer ;
    Terr:TTerrain ;
    ListMicroCell:TObjectList ;
    freezed,downed:Boolean ;
    sad:TStepActionDamage ;
    cellrender:TSpriteRender ;
    PPSP:TPassivePropSpaceProtect ;
    PPESD:TPassivePropEnemySlowdown ;
    SAR:TStepActionRestore ;
    SAH:TStepActionHeal ;
    dist:Integer ;
    ListOver:TCellListNoOwn ;
    cellrendercode:string ;
    roads:string ;
begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  log:=TStringList.Create ;
  try

  if oldsnapshot<>BF.GetTerrSnapshot() then begin
    mHGE.System_Log('update snapshot');
    for i := 0 to BF.CellCount - 1 do
      BF.GetCell(i).tmpCachedTerrain:=nil ;
    oldsnapshot:=BF.GetTerrSnapshot() ;
  end;

  sprBack.RenderStretch(0,0,SWindowOptions.Width,SWindowOptions.Height) ;

  SRPool.Render ;

  BF.FM.UpdateBattleField(BF) ;

  log.Add('1') ;

  // Слишком много переменных флагов
  OverCell:=nil ;
  if (not(showdialog or showmessagelist or showmenu or showchoosesol or showhelppanel or
  showmonsterinfo or showterraininfo or showinfostep or showbattletask or showconfirm)) then
    if not LP.IsOverPanel(mx,my) then
      OverCell:=BF.GetCellByXY(Round(mx),Round(my)) ;

  // Определение активного (выделяемого) объекта
  MonsterStepList:=nil ;
  TowerDamageList:=nil ;
  if OverCell<>nil then
    if (not OverCell.isEmpty()) and (OverCell.FogState=fsVisible) then begin
      CSR.SetObject() ;
      if OverCell._Object.CanRule then CSR.SetPonyObject()
      else
      if (OverCell._Object is TMonsterUnit)and
         (LP.ActiveAction=nil) then begin
        MonsterStepList:=BF.GetCellsOnDistNForPonyWalk(OverCell,
          TMonsterUnit(OverCell._Object).GetMaxStep()) ;
      end
      else
      if (OverCell._Object is TBuilding)and
         (LP.ActiveAction=nil) then begin
         // На время отключили
         {if OverCell._Object.getStepAction(TStepActionDamage,sad) then
            TowerDamageList:=GetCellFinder().GetCellsOnDistN(OverCell,
              TStepActionDamage(sad).Dist,[spIgnoreTerrain,spIncludeBusyCell]);
          }
      end
    end;

  log.Add('2') ;

  // Построение списка ячеек доступных для хода
  if BF.IsActiveCell() then begin

    if LP.ActiveAction<>nil then
      ListMovable:=LP.ActiveAction.BuildAllowCellList(BF.GetActiveCell)
    else
      ListMovable:=BF.GetCellsOnDistNForPonyWalk(BF.GetActiveCell,
        TPonyUnit(BF.GetActiveObject()).GetStepLeftWithEnergy()) ;
    //ListMovable:=nil ;
  end
  else
    ListMovable:=nil ;

  log.Add('3') ;

  // Построение списка текущего хода
  ListWay:=nil ;
  if ListMovable<>nil then
    if ListMovable.IsObjectIn(OverCell) then begin
      if LP.ActiveAction=nil then begin
        ListWay:=BF.CreateListCellsOnWayForPonyWalk(BF.GetActiveCell,OverCell,
          TPonyUnit(BF.GetActiveObject()).GetStepLeftWithEnergy()) ;
        CSR.SetWalk() ;
      end
      else begin
        ListWay:=LP.ActiveAction.BuildResultCellList(BF.getActiveCell,OverCell) ;
        CSR.SetSpell(LP.ActiveAction) ;
      end;
    end;

  log.Add('4') ;

  for i := 0 to BF.CellCount-1 do begin
    if IsCellOutScreen(i) then Continue ;
    
    // Расчет яркости слоя
    bright:=100 ;
    if MAI.IsStepFinished then begin
      if BF.GetCell(i)=OverCell then
        bright:=Alternate(PL.IsShowHex(),120,120)
      else begin
        if ListMovable<>nil then
          if ListMovable.IsObjectIn(BF.GetCell(i)) then
            bright:=Alternate(PL.IsShowHex(),120,120) ;
      end;

    end;

    // Подложка рельефа
    if BF.GetCell(i)._Terrain.UseSubLayer or BF.GetCell(i).IsSpace() then begin
      SR:=SRPoolTerrs.GetRenderByTag(BF.GetCell(i).GetMostTerrainAround().Name) ;
      SR.bright:=bright ;
      SR.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;
    end;

    // Основной рельеф
    if not (BF.GetCell(i).IsSpace()) then begin
      SR:=SRPoolTerrs.GetRenderByTag(BF.GetCell(i)._Terrain.Name) ;
    SR.bright:=bright ;

    // Дорога
    if BF.GetCell(i).tmpMapChar='W' then begin

      SRRoad:=nil ;
      roads:=BF.GetCell(i).getLinkedDirs() ;
      if (roads='0')or(roads='3')or(roads='03')or(roads='023')or(roads='035') then begin
        SRRoad:=SRRoadDiag ;        SRRoad.mirror:=[] ;
      end
      else
      if (roads='1')or(roads='4')or(roads='14')or(roads='124')or(roads='145') then begin
        SRRoad:=SRRoadDiag ;         SRRoad.mirror:=[mirrHorz] ;
      end
      else
      if (roads='02')or(roads='025') then begin
        SRRoad:=SRRoadRot1 ;        SRRoad.mirror:=[] ;
      end
      else
      if (roads='15')or(roads='125') then begin
        SRRoad:=SRRoadRot1 ;         SRRoad.mirror:=[mirrHorz] ;
      end
      else
      if (roads='24')or(roads='245') then begin
        SRRoad:=SRRoadRot1 ;         SRRoad.mirror:=[mirrVert] ;
      end
      else
      if (roads='35')or(roads='235') then begin
        SRRoad:=SRRoadRot1 ;         SRRoad.mirror:=[mirrVert,mirrHorz] ;
      end
      else
      if roads='04' then begin
        SRRoad:=SRRoadRot2 ;         SRRoad.mirror:=[] ;
      end
      else
      if roads='13' then begin
        SRRoad:=SRRoadRot2 ;         SRRoad.mirror:=[mirrHorz] ;
      end
      else
      if roads='024' then begin
        SRRoad:=SRRoadCross1 ;         SRRoad.mirror:=[] ;
      end
      else
      if roads='135' then begin
        SRRoad:=SRRoadCross1 ;         SRRoad.mirror:=[mirrHorz] ;
      end
      else
      if roads='034' then begin
        SRRoad:=SRRoadCross2 ;         SRRoad.mirror:=[] ;
      end
      else
      if roads='134' then begin
        SRRoad:=SRRoadCross2 ;         SRRoad.mirror:=[mirrHorz] ;
      end
      else
      if roads='014' then begin
        SRRoad:=SRRoadCross2 ;         SRRoad.mirror:=[mirrVert] ;
      end
      else
      if roads='013' then begin
        SRRoad:=SRRoadCross2 ;         SRRoad.mirror:=[mirrVert,mirrHorz] ;
      end
      else
      if roads='0134' then begin
        SRRoad:=SRRoadX ;         SRRoad.mirror:=[] ;
      end
      else
      SRRoad:=SRRoadLR ;

      if (BF.GetCell(i)._Terrain.Caption='Стена огня')or
         (BF.GetCell(i)._Terrain.Caption='Стационарный телепорт') then begin
        SRRoad.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC);
        SR.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;
      end
      else begin
        SR.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;
        SRRoad.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC);
      end;
    end
    else
      SR.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;

    end
    else begin
      SR:=SRPoolTerrs.GetRenderByTag('Space') ;
      SR.transp:=BF.GetCell(i)._Object.GetTransp() ;
      SR.bright:=bright ;
      SR.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;
    end;

    // Сглаживание рельефа
    if roundedterr then
    for dir := 0 to 5 do begin
      Terr:=BF.GetCellMicroTerrBetweenDirAndNext(i,dir) ;
      if Terr<>nil then begin
        SR:=SRPoolTerrs.GetRenderByTag('microterr_'+Terr.Name+'_'+IntToStr(dir)) ;
        if BF.GetCell(i).IsSpace() then
          SR.transp:=BF.GetCell(i)._Object.GetTransp()
        else
        if Terr.CharCode='@' then
          SR.transp:=BF.GetCell(i).GetMaxTranspFromSpaceAround()
        else
          SR.transp:=0 ;

        SR.bright:=100 ;
        SR.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;
      end ;
    end; 


  end;

  // Леса
    for i := 0 to BF.CellCount-1 do begin
      if IsCellOutScreen(i) then Continue ;

    // Расчет яркости слоя
    bright:=100 ;
    if MAI.IsStepFinished then begin
      if BF.GetCell(i)=OverCell then
        bright:=Alternate(PL.IsShowHex(),120,120)
      else begin
        if ListMovable<>nil then
          if ListMovable.IsObjectIn(BF.GetCell(i)) then
            bright:=Alternate(PL.IsShowHex(),120,120) ;
      end;

    end;

    end;

  if roundedterr {and (not PL.IsShowHex)} then begin
  ListMicroCell:=BF.CreateMicroCellList() ;
  for i := 0 to ListMicroCell.Count - 1 do begin
    if IsMicroCellOutScreen(TMicroCell(ListMicroCell[i])) then Continue ;

    SR:=SRPoolTerrs.GetRenderByTag('microterrborder_'+
      TMicroCell(ListMicroCell[i])._Terrain.Name+'_'+
      IntToStr(TMicroCell(ListMicroCell[i]).borderdir)) ;
    SR.bright:=100 ;
    SR.RenderAt(TMicroCell(ListMicroCell[i]).XC,TMicroCell(ListMicroCell[i]).YC) ;
  end;
  ListMicroCell.Free ;
  end;

  // Рисование сетки в конце
  if PL.IsShowHex then
    for i := 0 to BF.CellCount-1 do
      if (BF.GetCell(i).CellI=BF.MaxCellI) and (BF.GetCell(i).CellJ mod 2 = 1) then
        SRHex_rightbordered.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC)
      else
      if (BF.GetCell(i).CellI=BF.MaxCellI-1) and (BF.GetCell(i).CellJ mod 2 = 0) then
        SRHex_rightbordered.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC)
      else
        SRHex.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;

  for i := 0 to BF.CellCount-1 do
    if not IsCellOutScreen(i) then 
      // Объект
    if BF.GetCell(i).FogState=fsVisible then
    if not BF.GetCell(i).IsEmpty then begin
      SR:=SRPoolObjects.GetRenderByTag(BF.GetCell(i)._Object.SpriteTag) ;
      if SR=nil then mHGE.System_Log('nil render by tag: '+BF.GetCell(i)._Object.SpriteTag);

      if BF.GetCell(i)._Terrain.IsWater then
        if not BF.GetCell(i)._Object.IsFlyer then
          if not BF.GetCell(i)._Object.IsWaterUnit then
            if SRPoolObjects.GetRenderByTag(SR.Tag+WATERTAGPOSTFIX)<>nil then
              SR:=SRPoolObjects.GetRenderByTag(SR.Tag+WATERTAGPOSTFIX) ;

      SR.bright:=0 ;
      SR.transp:=BF.GetCell(i)._Object.GetTransp() ;
      if BF.GetCell(i).IsSpace() then SR.transp:=100 ;
      if BF.GetCell(i)._Object.IsHorzReverse then SR.mirror:=[mirrHorz] else
      SR.mirror:=[] ;

//      SR.color:=$8080FF ;

      freezed:=False ;
      if BF.GetCell(i)._Object is TMonsterUnit then
        if TMonsterUnit(BF.GetCell(i)._Object).IsFreezed() then freezed:=True ;
      if freezed then SR.color:=$000000FF else SR.color:=$00FFFFFF ; ;

      downed:=False ;
      if BF.GetCell(i)._Object is TMonsterUnit then
        if TMonsterUnit(BF.GetCell(i)._Object).IsDown() then downed:=True ;
      if downed then SR.SetScaleBoth(70) else SR.SetScaleBoth(100) ;

      if not BF.GetCell(i)._Object.IsHided() then
        SR.RenderAt(BF.GetCell(i).XwShift(),BF.GetCell(i).YwShift()) ;

      if BF.GetCell(i)._Object is TMonsterUnit then begin
        if TMonsterUnit(BF.GetCell(i)._Object).IsFreezed() then
          SRFreezed.RenderAt(BF.GetCell(i).XwShift(),BF.GetCell(i).YwShift()) ;
        if TMonsterUnit(BF.GetCell(i)._Object).IsSleeped() then
          SRSleeped.RenderAt(BF.GetCell(i).XwShift(),BF.GetCell(i).YwShift()) ;
        if TMonsterUnit(BF.GetCell(i)._Object).IsBurned() then
          SRBurned.RenderAt(BF.GetCell(i).XwShift(),BF.GetCell(i).YwShift()) ;
      end;

      if BF.GetCell(i)._Object is TPonyUnit then begin
        if TPonyUnit(BF.GetCell(i)._Object).IsTeleported then
          SRTeleport.RenderAt(BF.GetCell(i).XwShift(),BF.GetCell(i).YwShift());
        if TPonyUnit(BF.GetCell(i)._Object).IsShield then begin
          if TPonyUnit(BF.GetCell(i)._Object).IsShieldNR() then
            SRForceShieldNR.RenderAt(BF.GetCell(i).XwShift(),BF.GetCell(i).YwShift())
          else
            SRForceShield.RenderAt(BF.GetCell(i).XwShift(),BF.GetCell(i).YwShift());
        end;
        if TPonyUnit(BF.GetCell(i)._Object).IsStun() then
          SRStun.RenderAt(BF.GetCell(i).XwShift(),BF.GetCell(i).YwShift());
      end ;

      // Индикатор
      if PL.IsShowHealthInd then begin
      if BF.GetCell(i)._Object is TMonsterUnit then begin
        SRHealthInd.color:=Gradient($FF0000,$0000FF,
          TMonsterUnit(BF.GetCell(i)._Object).GetHealthPerc/100) ;
        SRHealthInd.scalex:=TMonsterUnit(BF.GetCell(i)._Object).GetHealthPerc ;
        SRHealthInd.RenderAt(BF.GetCell(i).XwShift()-20,BF.GetCell(i).YwShift()+40) ;
      end;
      if BF.GetCell(i)._Object is TPonyUnit then begin
        SRHealthInd.color:=Gradient($FF0000,$008000,
          TPonyUnit(BF.GetCell(i)._Object).GetHealthPerc/100) ;
        SRHealthInd.scalex:=TPonyUnit(BF.GetCell(i)._Object).GetHealthPerc ;
        SRHealthInd.RenderAt(BF.GetCell(i).XwShift()-20,BF.GetCell(i).YwShift()+40) ;
      end;
      end;
    end;


  // Ходы
   for i := 0 to BF.CellCount-1 do begin
   if IsCellOutScreen(i) then Continue ;
    // Расчет яркости слоя
    bright:=100 ;
    if MAI.IsStepFinished then begin
      if BF.GetCell(i)=OverCell then
        bright:=Alternate(PL.IsShowHex(),120,120)
      else begin
        if ListMovable<>nil then
          if ListMovable.IsObjectIn(BF.GetCell(i)) then
            bright:=Alternate(PL.IsShowHex(),120,120) ; 
      end;

    end;

   // Путь
    if MAI.IsStepFinished and
      (not OM.IsMovingProcess) and
      (not BF.IsExistsTranspObjs()) then begin
    if ListWay<>nil then
      if ListWay.IsObjectIn(BF.GetCell(i)) then
        SRHexWay.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;

    if MonsterStepList<>nil then
      if MonsterStepList.IsObjectIn(BF.GetCell(i)) then
        SRHexMonsterZone.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;
    if TowerDamageList<>nil then
      if TowerDamageList.IsObjectIn(BF.GetCell(i)) then
        SRHexDamageZone.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;

    end;

  end;

  if (mHGE.Input_GetKeyState(HGEK_ALT)) then begin

  if celldic=nil then
    celldic:=TCellDict.Create
  else
    celldic.Clear() ;
      
  // Новая модель вывода зон - миниатюрой самого объекта
  for i := 0 to BF.CellCount-1 do begin
    if BF.GetCell(i).IsEmpty then Continue ;
    cellrendercode:='' ;
    dist:=0 ;

    // Получение всех объектов, имеющих зоны действия
    if BF.GetCell(i).IsPonyUnit then begin
      if TPonyUnit(BF.GetCell(i)._Object).Code='flatter' then 
        dist:=3 ;
    end;
    if BF.GetCell(i).IsBuilding then begin
      if BF.GetCell(i)._Object.getPassiveProp(TPassivePropSpaceProtect,TPassiveProp(PPSP)) then 
        dist:=PPSP.ProtectDist ;
      if BF.GetCell(i)._Object.getPassiveProp(TPassivePropEnemySlowdown,TPassiveProp(PPESD)) then
        dist:=PPESD.SlowdownDist ;
      if BF.GetCell(i)._Object.getStepAction(TStepActionDamage,TStepAction(SAD)) then
        dist:=SAD.Dist ;
      if BF.GetCell(i)._Object.getStepAction(TStepActionHeal,TStepAction(SAH)) then
        dist:=SAH.Dist ;
      if BF.GetCell(i)._Object.getStepAction(TStepActionRestore,TStepAction(SAR)) then
        dist:=SAR.Dist ;
    end;
    if BF.GetCell(i).IsMonster then begin
      if TMonsterUnit(BF.GetCell(i)._Object).IsPoison then
        dist:=TMonsterUnit(BF.GetCell(i)._Object).PoisonDist ;
      if BF.GetCell(i)._Object is TMonsterTent then
        dist:=TMonsterTent(BF.GetCell(i)._Object).MagicLockDist ;
      if BF.GetCell(i)._Object is TMonsterTirek then
        dist:=TMonsterTirek(BF.GetCell(i)._Object).MagicStoleDist ;
    end ;

    if dist>0 then
      cellrendercode:=BF.GetCell(i)._Object.SpriteTag ;
    // Конец получения

    if cellrendercode<>'' then begin

      cellrender:=SRPoolObjZones.GetRenderByTag(cellrendercode) ;
      if cellrender=nil then begin
         cellrender:=TSpriteRender.Create(
           SRPoolObjects.GetRenderByTag(cellrendercode).GetSprite()) ;
         cellrender.transp:=15 ;
         cellrender.SetScaleBoth(33);
         SRPoolObjZones.AddRenderTagged(cellrender,cellrendercode);
      end;

      ListOver:=GetCellFinder().FastGetAllCellsOnRadius(BF.GetCell(i),dist) ;
      for j := 0 to ListOver.Count - 1 do
        if ListOver[j]<>BF.GetCell(i) then
          celldic.AddObject(ListOver[j],cellrender);
      ListOver.Free ;
    end;
    
  end ;

  for i := 0 to BF.CellCount-1 do begin
    if IsCellOutScreen(i) then Continue ;
    if celldic.GetObjectCount(BF.GetCell(i))=0 then Continue ;

    MOR:=TMultiObjRender.Create() ;
    for j := 0 to celldic.GetObjectCount(BF.GetCell(i))-1 do
      MOR.Add(TSpriteRender(celldic.GetObject(BF.GetCell(i),j)));
    MOR.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC,25) ;
    MOR.Free ;
  end;
  
  end;

  log.Add('5') ;

  for i := 0 to BF.CellCount-1 do
    if not IsCellOutScreen(i) then
    if not BF.GetCell(i).IsEmpty then
      if BF.GetCell(i)._Object.IsTargeted then
        SRTargeted.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;

  log.Add('6') ;

  for i := 0 to BF.CellCount-1 do
    if BF.GetCell(i).FogState=fsDark then
      SRHexDark.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC)
    else
      if BF.GetCell(i).FogState=fsFog then
        SRHexFog.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;

  for i := 0 to BF.CellCount-1 do begin
    if BF.GetCell(i).showEmptyClearing=1 then begin
      if not EmptyClearingAnim.IsPlaying then EmptyClearingAnim.Play ;
      BF.GetCell(i).showEmptyClearing:=2 ;
    end;
    if (BF.GetCell(i).showEmptyClearing=2) and (not EmptyClearingAnim.IsPlaying()) then
      BF.GetCell(i).showEmptyClearing:=0 ;

    if BF.GetCell(i).showEmptyClearing=2 then 
      SREmptyClearing.RenderAt(BF.GetCell(i).XC,BF.GetCell(i).YC) ;
  end;


  if CrystalRainAnim.IsPlaying then
    for i := 0 to rain_count-1 do
      SRCrystalRain.RenderAt(rain_array[i].X+(effect_init_pos.X-BF.GetShift().X),
        rain_array[i].Y+(effect_init_pos.Y-BF.GetShift().Y)) ;

  if SonicRainboomAnim.IsPlaying then
    SRSonicRainboom.RenderAt(sonic_rainboom_pos.X+(effect_init_pos.X-BF.GetShift().X),
      sonic_rainboom_pos.Y+(effect_init_pos.Y-BF.GetShift().Y)) ;

  if sctNewAnim.IsPlaying then
    SRsctNew.RenderAt(sct_new_pos.X+(effect_init_pos.X-BF.GetShift().X),
      sct_new_pos.Y+(effect_init_pos.Y-BF.GetShift().Y)) ;

  if sctDelAnim.IsPlaying then
    SRsctDel.RenderAt(sct_del_pos.X+(effect_init_pos.X-BF.GetShift().X),
      sct_del_pos.Y+(effect_init_pos.Y-BF.GetShift().Y)) ;

  if bctNewAnim.IsPlaying then
    SRbctNew.RenderAt(sct_new_pos.X+(effect_init_pos.X-BF.GetShift().X),
      sct_new_pos.Y+(effect_init_pos.Y-BF.GetShift().Y)) ;

  if bctDelAnim.IsPlaying then
    SRbctDel.RenderAt(sct_del_pos.X+(effect_init_pos.X-BF.GetShift().X),
      sct_del_pos.Y+(effect_init_pos.Y-BF.GetShift().Y)) ;

  if SEPool.IsEffectExist(TSEMovementLinear,SRSunBeam) then begin
    SRSunBeam.RenderAt(SRSunBeam.x+(effect_init_pos.X-BF.GetShift().X),
      SRSunBeam.y+(effect_init_pos.Y-BF.GetShift().Y)) ;
    SRSunBeamTail.RenderAt(SRSunBeam.x,SRSunBeam.y-750) ;
  end;

  if PortalActivationAnim.IsPlaying then
    for i := 0 to portalactivation_count - 1 do
      SRPortalActivation.RenderAt(portalactivation_pos[i].X+(effect_init_pos.X-BF.GetShift().X),
        portalactivation_pos[i].Y+(effect_init_pos.Y-BF.GetShift().Y)) ;

  HV.Render() ;

  log.Add('7') ;

  // Вывод панели
  if IsControlPanelShowed() then begin
    SRPlashLeft.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter);
    
    LP.Render(OverCell,mx,my) ;

    if InEditMode then
      if OverCell<>nil then
        fnt2.PrintF(310,30,
          HGETEXT_CENTER,'Редактор (%d,%d)%s(%s)',[OverCell.CellI,
          OverCell.CellJ,#13,Alternate(editorsetupmode=esmTerrains,'территории','объекты')]) ;

    log.Add('8') ;

    IP.Render() ;
  end;

  if ListMovable<>nil then ListMovable.Free ;
  if ListWay<>nil then ListWay.Free ;

  log.Add('9') ;

  if showdialog then RenderMessageDialog(
    SWindowOptions.GetXCenter) ;
  if showmessagelist then RenderMessageListDialog(
    SWindowOptions.GetXCenter+100) ;
  if showinfostep then RenderInfoStep() ;

  if showmenu then RenderGameMenu() ;
  if showchoosesol then RenderChooseSol() ;
  if showhelppanel then RenderHelpPanel() ;
  if showmonsterinfo then RenderMonsterInfo() ;
  if showterraininfo then RenderTerrainInfo() ;

  if showbattletask then RenderBattleTask() ;

  if showconfirm then
    FFConfirm.RenderConfirmDialog(SWindowOptions.GetXCenter) ; 

  if not MAI.IsStepFinished then begin
    SRAIStepIndBack.RenderAt(220,20);
    SRAIStepInd.scalex:=Round(100*MAI.StepProgress()) ;
    SRAIStepInd.RenderAt(220+2,20+2);
    SRAIBookAnim.RenderAt(220+2,20) ;
    fnt2.SetColor($FFFFFFFF);
    fnt2.Render(220+40,20+4,HGETEXT_LEFT,'Ход противника');
  end ;

  CSR.Render() ;

  except
    on E:Exception do begin
      mHGE.System_Log('Error in Render Func: '+E.Message);
      mHGE.System_Log(log.Text);
    end;
  end;

  log.Free ;
  mHGE.Gfx_EndScene;

end;



function FrameFuncIndicator():Boolean ;
var p:Integer ;
begin
  Result:=False ;
  Inc(LoadPos) ;
  EnterCriticalSection(CritSect) ;
  loadpos:=th.pos ;
  LeaveCriticalSection(CritSect) ;
  LoadingPonyAnim.Update(mHGE.Timer_GetDelta()) ;

  p:=loadpos-1 ;
  //if (p>=LoadingPonyProgress.GetFrames) then p:=LoadingPonyProgress.GetFrames-1 ;
  if (p<0) then p:=0 ;  
  LoadingPonyProgress.SetFrame(p) ;
  if loadpos=th.maxpos then begin
    // Перенести куда-нибудь
    //DeleteCriticalSection(CritSect);
    mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncGame);
  end;
end ;

function RenderFuncIndicator():Boolean ;
begin
  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  //fnt.SetColor($FFFFFFFF) ;
  //fnt.PrintF(100,100,HGETEXT_LEFT,'%d',[loadpos]) ;

  SRLoadingFrame.RenderAt(50,730) ;
  SRLoadingPony.RenderAt(50,730) ;
  SRLoadingProgress.RenderAt(50,730) ;

  SRLoadingText.RenderAt(200,730) ;

  mHGE.Gfx_EndScene;
end;

procedure TLoadThread.Execute ;
var filename:string ;
begin
  filename:=GetLevelFileName(CurrentGameCode,ActiveLevel) ;
  LoadTerrains(filename) ;
  LoadGameResources(CritSect,pos) ;
  LoadLevel(ActiveLevel) ;
  SkipStepInfo:=False ;
  EnterCriticalSection(CritSect) ;
  Inc(pos) ;
  LeaveCriticalSection(CritSect) ;
end;

procedure GoGameLevel(Level:Integer) ;
begin
  loadpos:=0 ;
  ActiveLevel:=Level ;
  InitializeCriticalSection(CritSect);
  th:=TLoadThread.Create(True);
  th.pos:=0 ;
  th.maxpos:=12 ;
  th.Resume() ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncIndicator);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncIndicator);
end;

procedure GoGameAutoLevel() ;
begin
  GoGameLevel(ActiveLevel) ;
end;

end.
