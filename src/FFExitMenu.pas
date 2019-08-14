unit FFExitMenu;

interface

function procConfirmExit():Boolean ;

implementation

uses
  {DirectXGraphics, D3DX81mo,} TAVHGEUtils, HGE, SpriteEffects, ObjModule, HGEFont ;

//[!] Тута жирное дублирование кода с FFConfirm
var //SRScreenBack:TSpriteRender ;
    pframe,prender:THGECallback ;
    isatexitmenu:Boolean = False ;

    SRDialogIcon:TSpriteRender = nil ;
    SRButYes:TSpriteRender = nil ;
    SRButNo:TSpriteRender = nil ;

function FrameFuncExitMenu():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    isatexitmenu:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,pframe);
    mHGE.System_SetState(HGE_RENDERFUNC,prender);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    if SRButYes.IsMouseOver(mx,my) then begin
      Result:=True ;
      Exit ;
    end ;
    if SRButNo.IsMouseOver(mx,my) then begin
      isatexitmenu:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,pframe);
      mHGE.System_SetState(HGE_RENDERFUNC,prender);
      Exit ;
    end ;
  end ;

end ;

function RenderFuncExitMenu():Boolean ;
var mx,my:Single ;
    HIB:Single ;
    XC:Single ;
begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  //SRScreenBack.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;

  XC:=SWindowOptions.GetXCenter ;
  HIB:=SRIconBack.GetSprite.GetWidth ;

  SRConfirmBack.RenderAt(XC,SWindowOptions.GetYCenter) ;
  fnt2.SetColor($FFFFFFFF);
  fnt2.SetScale(0.90);
  fnt2.PrintFB(XC-SRTextBack.GetSprite.GetWidth/2+HIB+40+8,
    SWindowOptions.GetYCenter-153/2+20,
    651-HIB-75-16,1000,
    HGETEXT_CENTER,'%s',['Выйти из программы?']);
  fnt2.SetScale(1);

  SRDialogIcon.RenderAt(
    XC-651/2+83,SWindowOptions.GetYCenter-33);

  SRButYes.RenderAsButton(XC-164,SWindowOptions.GetYCenter+54,mx,my,100,150) ;
  SRButNo.RenderAsButton(XC-50,SWindowOptions.GetYCenter+54,mx,my,100,150) ;
  fnt2.PrintFB(XC-174,SWindowOptions.GetYCenter+42,
    100,100,HGETEXT_LEFT,'%s',['Да']);
  fnt2.PrintFB(XC-60,SWindowOptions.GetYCenter+42,
    100,100,HGETEXT_LEFT,'%s',['Нет']);

  sprMouse.Render(mx,my) ;

  mHGE.Gfx_EndScene;

end ;

function procConfirmExit():Boolean ;
//var Surf: IDirect3DSurface8;
begin
  Result:=False ;

  if isatexitmenu then Exit ;

  isatexitmenu:=True ;

  if SRDialogIcon=nil then
    SRDialogIcon:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icons\ok_ico.png'));
  if SRButYes=nil then
    SRButYes:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,'but_yes.png'));
  if SRButNo=nil then
    SRButNo:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,'but_no.png'));

  {
  mHGE.GetDevice().GetBackBuffer(0,D3DBACKBUFFER_TYPE_MONO,Surf);
  D3DXSaveSurfaceToFile(PChar('tmp.bmp'),D3DXIFF_BMP,Surf,nil,nil);
  SRScreenBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,'..\bin\tmp.bmp')) ;
  SRScreenBack.color:=$FF404040 ;
  }

  pframe:=mHGE.System_GetState(HGE_FRAMEFUNC);
  prender:=mHGE.System_GetState(HGE_RENDERFUNC);
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncExitMenu);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncExitMenu);
end;

end.
