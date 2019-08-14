unit FFInfoStep ;

interface
uses Classes ;

function FrameFuncInfoStep():Boolean ;
procedure RenderInfoStep() ;
procedure showInfoAll(infolist:TStringList) ; overload ;

var
  showinfostep:Boolean ;

const
  POS_CB_X=240 ;
  POS_CB_Y=580 ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, FFGame, simple_oper,
  SysUtils ;

var
  _infolist:TStringList ;
  active_text:string ;

procedure showInfoAll(infolist:TStringList) ; overload ;
begin
  showinfostep:=True ;
  _infolist:=infolist ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncInfoStep);
end;

function GetIconPosX(i:Integer):Integer ;
begin
  Result:=260+102*i ;
end ;

function GetIconPosY(i:Integer):Integer ;
begin
  Result:=310 ;
end ;

procedure RenderInfoStep() ;
var mx,my:Single ;
    i:Integer ;
begin
  mHGE.Input_GetMousePos(mx,my);


    SRDlgBack.RenderAt(0,0) ;
    SRAboutBack.scalex:=140 ;
    SRAboutBack.RenderAt(SWindowOptions.GetXCenter,420) ;
    fnt2.SetColor($FF491305);
    fnt2.PrintF(SWindowOptions.GetXCenter,200,HGETEXT_CENTER,
      'Итоги хода%sНаведите курсор на пони для информации',[#13]);
    SRAboutBack.scalex:=100 ;

  for i := 0 to _infolist.Count - 1 do begin
    SRIconBack.RenderAsButton(GetIconPosX(i),GetIconPosY(i),mx,my,100,150) ;
    SRPoolIcons.GetRenderByTag(_infolist.Names[i]+'_ico').RenderAt(
      GetIconPosX(i),GetIconPosY(i));

  end ;

    fnt2.PrintF(250,380,HGETEXT_LEFT,active_text,[]);

    if FFGame.SkipStepInfo then
      SRcbOn.RenderAsButton(POS_CB_X,POS_CB_Y,mx,my,100,150)
    else
      SRcbOff.RenderAsButton(POS_CB_X,POS_CB_Y,mx,my,100,150) ;

    fnt2.PrintF(280,570,HGETEXT_LEFT,'Не показывать это окно',[#13]);

    SRButOk.RenderAsButton(SWindowOptions.GetXCenter,620,mx,my,100,150);

end;

function FrameFuncInfoStep():Boolean ;
var mx,my:Single ;
    dt:Single ;
    i:Integer ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    showinfostep:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    if SRButOk.IsMouseOver(mx,my) then begin
      showinfostep:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
      Exit ;
    end ;
    SRcbOn.SetXY(POS_CB_X,POS_CB_Y);
    if SRcbOn.IsMouseOver(mx,my) then FFGame.SkipStepInfo:=
      not FFGame.SkipStepInfo ;
  end ;

  active_text:='' ;
  for i := 0 to _infolist.Count - 1 do begin
    SRIconBack.SetXY(GetIconPosX(i),GetIconPosY(i)) ;
    if SRIconBack.IsMouseOver(mx,my) then
      active_text:=StringReplace(
        HexToStr(_infolist.ValueFromIndex[i]),#13#10,#13,[rfReplaceAll]) ;
  end;

end ;

end.
