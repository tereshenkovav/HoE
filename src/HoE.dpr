program HoE;

{$APPTYPE GUI}

{$R *.res}

uses
  Windows,
  SysUtils,
  Classes,
  HGE,
  HGEFont,
  TAVHGEUtils,
  SpriteEffects,
  WindowOptions,
  simple_files,
  BuiltinMapFuncs in 'BuiltinMapFuncs.pas',
  CheatCodes in 'CheatCodes.pas',
  CommonClasses in 'CommonClasses.pas',
  CommonProc in 'CommonProc.pas',
  Constants in 'Constants.pas',
  Editor in 'Editor.pas',
  FFBattleTask in 'FFBattleTask.pas',
  FFChooseSol in 'FFChooseSol.pas',
  FFConfirm in 'FFConfirm.pas',
  FFExitMenu in 'FFExitMenu.pas',
  FFGame in 'FFGame.pas',
  FFGameMenu in 'FFGameMenu.pas',
  FFHelpPanel in 'FFHelpPanel.pas',
  FFInfoStep in 'FFInfoStep.pas',
  FFIntro in 'FFIntro.pas',
  FFMenu in 'FFMenu.pas',
  FFMessage in 'FFMessage.pas',
  FFMessageList in 'FFMessageList.pas',
  FFMonsterInfo in 'FFMonsterInfo.pas',
  FFScenePlayer in 'FFScenePlayer.pas',
  FFStartMenu in 'FFStartMenu.pas',
  FFTerrainInfo in 'FFTerrainInfo.pas',
  FFWinFail in 'FFWinFail.pas',
  HardLevels in 'HardLevels.pas',
  HitViewer in 'HitViewer.pas',
  LeftPanel in 'LeftPanel.pas',
  ObjModule in 'ObjModule.pas',
  PersistentFlags in 'PersistentFlags.pas',
  Player in 'Player.pas',
  ScenePlayer in 'ScenePlayer.pas',
  ScreenScroller in 'ScreenScroller.pas',
  AniManager in 'classes\AniManager.pas',
  BattleField in 'classes\BattleField.pas',
  BattleTask in 'classes\BattleTask.pas',
  BFLoader in 'classes\BFLoader.pas',
  BFSaver in 'classes\BFSaver.pas',
  Buildings in 'classes\Buildings.pas',
  CellBuilder in 'classes\CellBuilder.pas',
  CellDict in 'classes\CellDict.pas',
  CellFinder in 'classes\CellFinder.pas',
  CommonResource in 'classes\CommonResource.pas',
  Config in 'classes\Config.pas',
  Cursor in 'classes\Cursor.pas',
  DialogHistory in 'classes\DialogHistory.pas',
  EmptyManager in 'classes\EmptyManager.pas',
  EmptyPlace in 'classes\EmptyPlace.pas',
  FogManager in 'classes\FogManager.pas',
  FoodResource in 'classes\FoodResource.pas',
  GameObject in 'classes\GameObject.pas',
  IconPanel in 'classes\IconPanel.pas',
  LocalProc in 'classes\LocalProc.pas',
  MapScript in 'classes\MapScript.pas',
  MessageList in 'classes\MessageList.pas',
  MetaAction in 'classes\MetaAction.pas',
  MetaActionBuild in 'classes\MetaActionBuild.pas',
  MetaActionBurn in 'classes\MetaActionBurn.pas',
  MetaActionConsume in 'classes\MetaActionConsume.pas',
  MetaActionConsumePonyForce in 'classes\MetaActionConsumePonyForce.pas',
  MetaActionCutEmptyAll in 'classes\MetaActionCutEmptyAll.pas',
  MetaActionCutEmptySector in 'classes\MetaActionCutEmptySector.pas',
  MetaActionDamage in 'classes\MetaActionDamage.pas',
  MetaActionDownEnemy in 'classes\MetaActionDownEnemy.pas',
  MetaActionDownload in 'classes\MetaActionDownload.pas',
  MetaActionEnemyTransform in 'classes\MetaActionEnemyTransform.pas',
  MetaActionFreeze in 'classes\MetaActionFreeze.pas',
  MetaActionFuse in 'classes\MetaActionFuse.pas',
  MetaActionHarvest in 'classes\MetaActionHarvest.pas',
  MetaActionHeal in 'classes\MetaActionHeal.pas',
  MetaActionMakeLand in 'classes\MetaActionMakeLand.pas',
  MetaActionManageAction in 'classes\MetaActionManageAction.pas',
  MetaActionMineForest in 'classes\MetaActionMineForest.pas',
  MetaActionMineStone in 'classes\MetaActionMineStone.pas',
  MetaActionRepair in 'classes\MetaActionRepair.pas',
  MetaActionRestore in 'classes\MetaActionRestore.pas',
  MetaActionSetFlag in 'classes\MetaActionSetFlag.pas',
  MetaActionSetPonyParam in 'classes\MetaActionSetPonyParam.pas',
  MetaActionSetShield in 'classes\MetaActionSetShield.pas',
  MetaActionSetupTerrain in 'classes\MetaActionSetupTerrain.pas',
  MetaActionSleep in 'classes\MetaActionSleep.pas',
  MetaActionSummone in 'classes\MetaActionSummone.pas',
  MetaActionTeleport in 'classes\MetaActionTeleport.pas',
  MetaActionTransform in 'classes\MetaActionTransform.pas',
  MetaActionUpload in 'classes\MetaActionUpload.pas',
  MetaActionWings in 'classes\MetaActionWings.pas',
  MiniMap in 'classes\MiniMap.pas',
  MonsterAI in 'classes\MonsterAI.pas',
  MonsterUnits in 'classes\MonsterUnits.pas',
  MultiObjRender in 'classes\MultiObjRender.pas',
  NeutralUnits in 'classes\NeutralUnits.pas',
  ObjectMover in 'classes\ObjectMover.pas',
  PassiveProp in 'classes\PassiveProp.pas',
  PassivePropEnemySlowdown in 'classes\PassivePropEnemySlowdown.pas',
  PassivePropIDDQD in 'classes\PassivePropIDDQD.pas',
  PassivePropNoTarget in 'classes\PassivePropNoTarget.pas',
  PassivePropSpaceProtect in 'classes\PassivePropSpaceProtect.pas',
  PonyAction in 'classes\PonyAction.pas',
  PonyActionAttackLong in 'classes\PonyActionAttackLong.pas',
  PonyActionAttackNear in 'classes\PonyActionAttackNear.pas',
  PonyActionEx in 'classes\PonyActionEx.pas',
  PonyUnits in 'classes\PonyUnits.pas',
  StaticText in 'classes\StaticText.pas',
  StepAction in 'classes\StepAction.pas',
  StepActionCreateRes in 'classes\StepActionCreateRes.pas',
  StepActionDamage in 'classes\StepActionDamage.pas',
  StepActionDestroy in 'classes\StepActionDestroy.pas',
  StepActionHeal in 'classes\StepActionHeal.pas',
  StepActionProduce in 'classes\StepActionProduce.pas',
  StepActionRestore in 'classes\StepActionRestore.pas',
  StepRules in 'classes\StepRules.pas',
  StoneResource in 'classes\StoneResource.pas',
  Terrain in 'classes\Terrain.pas',
  VictoryCond in 'classes\VictoryCond.pas';

var i,j:Integer ;
begin
  Randomize() ;

  mHGE := HGECreate(HGE_VERSION);
  TAVHGEUtils.mHGE:=mHGE ;
  TAVHGEUtils.PathLoader:='..\images\' ;

  SWindowOptions:=TWindowOptionsNoMash.Create(1024,768,False) ;

  SetGlobalWindowOptions(SWindowOptions) ;
  SpriteEffects.SetWindowOptions(SWindowOptions) ;

  mHGE.System_SetState(HGE_USESOUND,False) ;
  mHGE.System_SetState(HGE_LOGFILE,'PonyHex.log');
  mHGE.System_SetState(HGE_TITLE,'Герои Эквестрии');
  mHGE.System_SetState(HGE_ICON,'MAINICON');

  mHGE.System_SetState(HGE_WINDOWED,not SWindowOptions.FullScreen);
  mHGE.System_SetState(HGE_SCREENWIDTH,SWindowOptions.Width);
  mHGE.System_SetState(HGE_SCREENHEIGHT,SWindowOptions.Height);
  mHGE.System_SetState(HGE_SCREENBPP,32);
  mHGE.System_SetState(HGE_FPS,HGEFPS_VSYNC);
  mHGE.System_SetState(HGE_EXITFUNC,procConfirmExit) ;

  if not mHGE.System_Initiate() then begin
    MessageBox(0,PChar(mHGE.System_GetErrorMessage),'Error',MB_OK or MB_ICONERROR or MB_SYSTEMMODAL);
    mHGE.System_Shutdown;
    mHGE := nil;
    Exit ;
  end ;

    SEPool:=TSpriteEffectPool.Create ;
    SRPool:=TSpriteRenderPool.Create ;

    fnt:=THGEFont.Create('..\fonts\fontsys.fnt');
    fnt2:=THGEFont.Create('..\fonts\Nubers.fnt');

    Texts:=TStringList.Create ;
    Texts.Values['HELPINFO']:=TxtFile2String(AppPath+'\..\configs\help') ;
    Texts.Values['MAIN_ABOUT']:=TxtFile2String(AppPath+'\..\configs\about') ;
    for i := 0 to Texts.Count - 1 do begin
      Texts.ValueFromIndex[i]:=StringReplace(Texts.ValueFromIndex[i],#10,'',[rfReplaceAll]) ;
      Texts.ValueFromIndex[i]:=StringReplace(Texts.ValueFromIndex[i],'\n',#13,[rfReplaceAll]) ;
    end;


    // Common player
    PL:=TPlayer.CreateFromDefaultFile() ;

  // Load game

  sprMouse:=LoadSizedSprite(mHGE,'cursorSys.png') ;
  sprMouseActive:=LoadSizedSprite(mHGE,'cursorActive.png') ;

  sprMouseWalk:=LoadSizedSprite(mHGE,'cursorWalk.png') ;
  sprMouseLook:=LoadSizedSprite(mHGE,'cursorLook.png') ;
  sprMouseLookActive:=LoadSizedSprite(mHGE,'cursorLookActive.png') ;
  sprMouseSpell:=LoadSizedSprite(mHGE,'cursorSpell.png') ;
  sprBack:=LoadSizedSprite(mHGE,'back.png') ;

  LoadStartMenuResources() ;
  //GoStartMenu() ;
  GoIntro() ;
  initScreenScroller() ;
  mHGE.System_Start ;
  UnloadStartMenuResources() ;

  SRPool.Free ;
  SEPool.Free ;

  PL.Free ;

  mHGE.System_Shutdown;
  mHGE := nil;

end.

