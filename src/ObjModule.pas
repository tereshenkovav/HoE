unit ObjModule;

interface
uses HGE, WindowOptions, SpriteEffects, HGESprite, HGEFont,
  Player, Classes, HitViewer, BattleField, ObjectMover, MapScript,
  VictoryCond,MonsterAI, LeftPanel, IconPanel, Cursor, AniManager, HGEAnim,
  CommonClasses ;

var
  mHGE:IHGE ;
  SWindowOptions:TWindowOptions ;
  SRPool:TSpriteRenderPool ;
  SEPool:TSpriteEffectPool ;

  AM:TAniManager ;

   SRAboutBack,SROptBack,SRTitresBack,SRDlgBack,SRBattleTaskBack:TSpriteRender ;
   SRButOk:TSpriteRender ;
   SRcbOn,SRcbOff:TSpriteRender ;
   SRrbOn,SRrbOff:TSpriteRender ;

   sprMouse,sprMouseActive,sprBack,sprWater:IHGESprite ;
   sprMouseWalk,sprMouseLook,sprMouseLookActive,sprMouseSpell:IHGESprite ;

   SRWin,SRFail,SRFinalWin:TSpriteRender ;
   SRButMenu,SRButReplay,SRButNext:TSpriteRender ;
   SRButBack:TSpriteRender ;

   SR_BackStudy,SR_BackCampain,SR_BackLegends:TSpriteRender ;
   SR_Campain1,SR_Campain2,SR_Campain3:TSpriteRender ;

   SR_Campain,SR_Study,SR_Legends,SR_UserMaps,
   SR_ExitGame,SR_Titres,SR_Settings:TSpriteRender ;
   SR_BackLegendDescription:TSpriteRender ;

   SR_Pointer:TSpriteRender ;

   SRTextBack,SRMsgBack,SRConfirmBack,SRMessageListBack,SRIconBack,SRButMiniClose,
     SRButMiniClose2,SRMenuBack,SRChooseSolBack:TSpriteRender ;
   SRButUp,SRButDown:TSpriteRender ;

   SRPoolTerrs,SRPoolObjects,SRPoolIcons,SRPoolActionIcons:TSpriteRenderPool ;

   SRLoadingFrame,SRLoadingText,SRLoadingPony,SRLoadingProgress:TSpriteRender ;
   LoadingPonyAnim,LoadingPonyProgress:IHGEAnimation ;

   SRUnderAttack:TSpriteRender ;

   fnt,fnt2:IHGEFont ;

   Texts:TStringList ;

   ActiveLevel:Integer ;

   CurrentGameCode:string ;
   
   PL:TPlayer ;

   HV:THitViewer ;

  BF:TBattleField ;
  LP:TLeftPanel ;
  IP:TIconPanel ;
  CSR:TCursor ;
  OM:TObjectMover ;
  MS:TMapScript ;
  VC:TVictoryCond ;
  MAI:TMonsterAI ;

  PortalActivationAnim:IHGEAnimation ;
  portalactivation_pos:array[0..31] of TPointSingle ;
  portalactivation_count:Integer = 0 ;

var LevelFileName:string ;
  
const
   COMPANY_1 = 'company1' ;
   COMPANY_2 = 'company2' ;
   COMPANY_3 = 'company3' ;
   DEMO_COMPANY = 'democompany' ;
   HARD_COMPANY = 'hardcompany' ;
   FUN_COMPANY = 'funcompany' ;
   SYM_ENERGY = #05 ;
   SYM_STONE = #04 ;
   SYM_FOOD = #01 ;
   SYM_HEALTH = #02 ;
   SYM_STEP = #03 ;

function getCB(Von:Boolean):TSpriteRender ;
function getRB(Von:Boolean):TSpriteRender ;
procedure setLevelFileName(FileName:string) ;

implementation

function getCB(Von:Boolean):TSpriteRender ;
begin
  if Von then Result:=SRcbOn else Result:=SRcbOff ;
end;

function getRB(Von:Boolean):TSpriteRender ;
begin
  if Von then Result:=SRrbOn else Result:=SRrbOff ;
end;

procedure setLevelFileName(FileName:string) ;
begin
  LevelFileName:=FileName ;
end;

end.
