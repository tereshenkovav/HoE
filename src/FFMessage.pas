unit FFMessage ;

interface
uses MapScript ;

function FrameFuncMessage():Boolean ;
procedure RenderMessageDialog(XC:Integer) ;
procedure setDialogMsg(fromScript:TScriptRec) ; overload ;
procedure setDialogMsg(DialogStr,DialogIcon:string) ; overload ;

var
  showdialog:Boolean ;
  nohidedialog:Boolean ;
  GSkipMessage:Boolean ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, FFGame, DialogHistory ;

var
  GDialogMsg:string ;
  GDialogIcon:string ;
  GAllowSkip:Boolean ;

procedure setDialogMsg(DialogStr,DialogIcon:string) ; overload ;
begin
  if GSkipMessage then Exit ;
  
  showdialog:=True ;
  GDialogMsg:=DialogStr ;
  GDialogIcon:=DialogIcon ;

  GAllowSkip:=True ;
  if not GetDialogHistory().IsDialogExist(BF.MapFile,GDialogIcon,GDialogMsg) then begin
    GetDialogHistory().AddDialogHistory(BF.MapFile,GDialogIcon,GDialogMsg) ;
    GAllowSkip:=False ;
  end;  

  // Правило смены иконок - в идеале, должно идти внешней настройкой
  if GDialogIcon='rarity_ico' then
    if BF.getObjCountByCode('nrarity')>0 then
      GDialogIcon:='nrarity_ico' ;

  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncMessage);
end;

procedure setDialogMsg(fromScript:TScriptRec) ; overload ;
begin
  setDialogMsg(fromScript.DialogMsg,fromScript.DialogIcon) ;
end;

procedure RenderMessageDialog(XC:Integer) ;
var mx,my:Single ;
    HIB:Single ;
begin
  mHGE.Input_GetMousePos(mx,my);

  HIB:=SRIconBack.GetSprite.GetWidth ;

  SRMsgBack.RenderAt(203,557) ;
  fnt2.SetColor($FFFFFFFF);
  fnt2.SetScale(0.90);
  if GDialogMsg<>'' then

  fnt2.PrintFB(209,643,800,1000,HGETEXT_CENTER,'%s',[GDialogMsg]);
  fnt2.SetScale(1);

  //SRIconBack.RenderAt(XC-SRTextBack.GetSprite.GetWidth/2+75,
  //  SWindowOptions.GetYCenter);

  if SRPoolIcons.GetRenderByTag(GDialogIcon)<>nil then
    SRPoolIcons.GetRenderByTag(GDialogIcon).RenderAt(244,600);

  SRButMiniClose.RenderAsButton(956,623,mx,my,100,150) ;
  if GAllowSkip then
    SRButMiniClose2.RenderAsButton(992,623,mx,my,100,150) ;

end;

function FrameFuncMessage():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE)or
     mHGE.Input_KeyDown(HGEK_ENTER)or
     mHGE.Input_KeyDown(HGEK_SPACE) then begin
    showdialog:=nohidedialog ;
    mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    if SRButMiniClose2.IsMouseOver(mx,my) then begin
      GSkipMessage:=True ;
      showdialog:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
      Exit ;
    end;

    if ((mx>=240)and(my>640))or
      SRButMiniClose.IsMouseOver(mx,my) then {SRMsgBack.IsMouseOver(mx,my)} begin
      showdialog:=nohidedialog ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
      Exit ;
    end ;
  end ;
end ;

end.
