unit FFHelpPanel ;

interface

function FrameFuncHelpPanel():Boolean ;
procedure RenderHelpPanel() ;
procedure GoHelpPanel() ;

var
  showhelppanel:Boolean ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, FFGame, FFMenu,
 SpriteEffects ;

procedure GoHelpPanel() ;
begin
  showhelppanel:=True ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncHelpPanel);
end;


procedure RenderHelpPanel() ;
var mx,my:Single ;
begin
  mHGE.Input_GetMousePos(mx,my);

    SRDlgBack.RenderAt(0,0) ;
    SRAboutBack.RenderAt(SWindowOptions.GetXCenter,420) ;
    fnt2.SetColor($FF491305);
    fnt2.PrintF(SWindowOptions.GetXCenter,200,HGETEXT_CENTER,
      '”œ–¿¬À≈Õ»≈',[]);

    fnt2.PrintF(SWindowOptions.GetXCenter-235,240,HGETEXT_LEFT,
      Texts.Values['HELPINFO'],[]);
    SRButOk.RenderAsButton(SWindowOptions.GetXCenter,620,mx,my,100,150);

end;

function FrameFuncHelpPanel():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    showhelppanel:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin

    if SRButOk.IsMouseOver(mx,my) then begin
      showhelppanel:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    end ;

    if not showhelppanel then Exit ;

  end ;
end ;

end.
