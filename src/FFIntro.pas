unit FFIntro;

interface

procedure GoIntro() ;

implementation
uses TAVHGEUtils, SpriteEffects, Effects, ObjModule, HGE, FFStartMenu ;

var SRIntro:TSpriteRender ;
    tleft:Single ;

function FrameFuncIntro():Boolean ;
var mx,my:Single ;
    i:Integer ;
    dt:Single ;
begin
  Result:=False ;

  dt:=mHGE.Timer_GetDelta ;

  if mHGE.Input_KeyDown(HGEK_ESCAPE)or
     mHGE.Input_KeyDown(HGEK_SPACE) or
     mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    GoStartMenu() ;
    Exit ;
  end ;

  SEPool.Update(dt) ;

  tleft:=tleft-dt ;
  if tleft<=0 then begin
    GoStartMenu() ;
    Exit ;
  end;

end ;

function RenderFuncIntro():Boolean ;
begin
  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  SRIntro.Render ;

  mHGE.Gfx_EndScene;
end;

procedure GoIntro() ;
begin
  if SRIntro=nil then
    SRIntro:=TSpriteRender.Create(LoadSizedSprite(mHGE,'intro.png'),0,0);

  SRIntro.transp:=100 ;
  SEPool.DelAllEffects ;
  SEPool.AddEffect(TSETransparentLinear.Create(SRIntro,100,0,2000));

  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncIntro);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncIntro);

  tleft:=6 ;
end;

end.
