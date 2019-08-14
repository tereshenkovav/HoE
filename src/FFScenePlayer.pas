unit FFScenePlayer;

interface

type
  TProcAfterScene = procedure ;

procedure DoPlayScenes(scenefiles:array of string;
  proc:TProcAfterScene) ;

implementation
uses ScenePlayer, Classes, SpriteEffects, ObjModule, HGE,
  TAVHGEUtils, simple_files, simple_oper, FFStartMenu, Variants,
  FFMenu ;

var
  SP:TScenePlayer ;
  SRSceneReplay:TSpriteRender ;
  SRSceneNext:TSpriteRender ;
  SRSceneSkip:TSpriteRender ;
  ListScenes:TStringList ;
  scene_n:Integer ;

  procAfterScene:TProcAfterScene ;

procedure UnloadSceneResources() ;
begin
  SRSceneReplay.Free ;
  SRSceneNext.Free ;
  SRSceneSkip.Free ;
  SP.Free ;
end;

procedure LoadAndPlayTekScene() ;
begin
  SP:=TScenePlayer.CreateFromFile(AppPath+'\..\scenes\'+ListScenes[scene_n]+'.ini');
  SP.StartPlay ;
end;

function FrameFuncScenePlayer():Boolean ;
var mx,my:Single ;
    i:Integer ;
    dt:Single ;
begin
  Result:=False ;

  dt:=mHGE.Timer_GetDelta() ;

  mHGE.Input_GetMousePos(mx,my);

  if (mHGE.Input_KeyDown(HGEK_ESCAPE))or

      (( mHGE.Input_KeyDown(HGEK_LBUTTON) or mHGE.Input_KeyDown(HGEK_SPACE)or
          mHGE.Input_KeyDown(HGEK_ENTER) ) and
       (not SP.IsStaticExist('text_back')) and SP.IsFinished ) then begin
    UnloadSceneResources() ;
    procAfterScene() ;
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    if (SRSceneNext.IsMouseOver(mx,my))or(SRSceneSkip.IsMouseOver(mx,my)) then begin
      if scene_n=ListScenes.Count-1 then begin
        UnloadSceneResources() ;
        procAfterScene() ;
        Exit ;
      end
      else begin
        Inc(scene_n) ;
        LoadAndPlayTekScene() ;
      end;
    end
    else
    if SRSceneReplay.IsMouseOver(mx,my) then
      LoadAndPlayTekScene()
    else
      SP.GoNextScene ;
  end;

  if mHGE.Input_KeyDown(HGEK_SPACE)or
     mHGE.Input_KeyDown(HGEK_ENTER) then begin
    SP.GoNextScene ;
  end ;

  SP.Update(dt) ;

end;

function RenderFuncScenePlayer():Boolean ;
var mx,my:Single ;
    i:Integer ;
begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  SP.Render ;

  if SP.IsStaticExist('text_back') then begin
  if SP.IsFinished then begin
    SRSceneReplay.RenderAsButton(510,680,mx,my,100,150);
    if (@procAfterScene<>@FFMenu.GoMenu) then SRSceneNext.RenderAsButton(670,680,mx,my,100,150);
  end
  else begin
    if not SP.IsStaticVisible('starttext') then
      SRSceneSkip.RenderAsButton(670,680,mx,my,100,150) ;
  end;
  end;

  sprMouse.Render(mx,my);

  mHGE.Gfx_EndScene;
end;

procedure DoPlayScenes(scenefiles:array of string;
  proc:TProcAfterScene) ;
var i:Integer ;
begin
  procAfterScene:=proc ;

  SRSceneReplay:=TSpriteRender.Create(LoadSizedSprite(mHGE,'but_scene_replay.png')) ;
  SRSceneNext:=TSpriteRender.Create(LoadSizedSprite(mHGE,'but_scene_next.png'));
  SRSceneSkip:=TSpriteRender.Create(LoadSizedSprite(mHGE,'but_scene_skip.png'));
  
  ListScenes:=TStringList.Create ;
  for i := 0 to Length(scenefiles) - 1 do
    ListScenes.Add(scenefiles[i]) ;

  scene_n:=0 ;
  LoadAndPlayTekScene() ;

  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncScenePlayer);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncScenePlayer);

end;

end.
