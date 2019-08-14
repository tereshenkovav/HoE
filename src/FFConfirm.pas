unit FFConfirm;

interface
uses MapScript ;

type
  TFrameFunc = function():Boolean ;
  TYesProc = procedure() ;

function FrameFuncConfirm():Boolean ;
procedure RenderConfirmDialog(XC:Integer) ;
procedure execConfirmMsg(DialogStr:string; backfunc:TFrameFunc; yesproc:TYesProc) ;

var
  showconfirm:Boolean ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, SpriteEffects ;

var
  GDialogMsg:string ;
  SRDialogIcon:TSpriteRender = nil ;
  SRButYes:TSpriteRender = nil ;
  SRButNo:TSpriteRender = nil ;

  storedbackfunc:TFrameFunc ;
  storedyesproc:TYesProc ;

procedure execConfirmMsg(DialogStr:string; backfunc:TFrameFunc; yesproc:TYesProc) ; overload ;
begin
  showconfirm:=True ;
  storedbackfunc:=backfunc ;
  storedyesproc:=yesproc ;

  GDialogMsg:=DialogStr ;
  if SRDialogIcon=nil then
    SRDialogIcon:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icons\ok_ico.png'));
  if SRButYes=nil then
    SRButYes:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,'but_yes.png'));
  if SRButNo=nil then
    SRButNo:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,'but_no.png'));

  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncConfirm);
end;

procedure RenderConfirmDialog(XC:Integer) ;
var mx,my:Single ;
    HIB:Single ;
begin
  mHGE.Input_GetMousePos(mx,my);

  HIB:=SRIconBack.GetSprite.GetWidth ;

  SRConfirmBack.RenderAt(XC,SWindowOptions.GetYCenter) ;
  fnt2.SetColor($FFFFFFFF);
  fnt2.SetScale(0.90);
  if GDialogMsg<>'' then

  fnt2.PrintFB(XC-SRTextBack.GetSprite.GetWidth/2+HIB+40+8,
    SWindowOptions.GetYCenter-153/2+20,
    651-HIB-75-16,1000,
    HGETEXT_CENTER,'%s',[GDialogMsg]);
  fnt2.SetScale(1);

  SRDialogIcon.RenderAt(
    XC-651/2+83,SWindowOptions.GetYCenter-33);

  SRButYes.RenderAsButton(XC-164,SWindowOptions.GetYCenter+54,mx,my,100,150) ;
  SRButNo.RenderAsButton(XC-50,SWindowOptions.GetYCenter+54,mx,my,100,150) ;
  fnt2.PrintFB(XC-174,SWindowOptions.GetYCenter+42,
    100,100,HGETEXT_LEFT,'%s',['Да']);
  fnt2.PrintFB(XC-60,SWindowOptions.GetYCenter+42,
    100,100,HGETEXT_LEFT,'%s',['Нет']);

end;

function FrameFuncConfirm():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    showconfirm:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,storedbackfunc);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_ENTER) then begin
    showconfirm:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,storedbackfunc);
    storedyesproc() ;
    Exit ;
  end ;
  
  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    if SRButYes.IsMouseOver(mx,my) then begin
      showconfirm:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,storedbackfunc);
      storedyesproc() ;
      Exit ;
    end ;
    if SRButNo.IsMouseOver(mx,my) then begin
      showconfirm:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,storedbackfunc);
      Exit ;
    end ;
  end ;
end ;

end.
