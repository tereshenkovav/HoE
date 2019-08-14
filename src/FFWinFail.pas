unit FFWinFail;

interface

procedure GoWin ;
procedure GoFail ;

implementation
uses ObjModule, TAVHGEUtils, HGE, HGEFont, simple_oper, FFMenu, FFGame,
  CommonProc, PersistentFlags, FFConfirm ;

type
  TWinFailMode = (mWin,mFail) ;

function FrameFuncWinOrFail():Boolean ;
var mx,my:Single ;
    nextn:Integer ;
begin
  Result:=False ;
  
  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    Result:=True ;
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    if SRButMenu.IsMouseOver(mx,my) then GoMenu() ;
    if SRButReplay.IsMouseOver(mx,my) then
      GoAutoGame(ActiveLevel) ;
    if SRButNext.IsMouseOver(mx,my) and (SRButNext.transp<100) then begin
      if ActiveLevel=-1 then
        GoAutoGame(1)
      else begin
        if (CurrentGameCode='company3')and(ActiveLevel=10) then begin
          nextn:=StrToIntWt0(GetPersistentFlags().GetVar('epilog_n')) ;
          if nextn=0 then nextn:=1 ;
          GoAutoGame(nextn) ;
        end
        else
          GoAutoGame(ActiveLevel+1) ;
      end;
    end;
  end;

end ;

function intRenderFunc(Mode:TWinFailMode):Boolean ;
var mx,my:Single ;
    str:string ;
begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.RenderStretch(0,0,SWindowOptions.Width,SWindowOptions.Height) ;

  if Mode=mWin then begin
    SRWin.RenderAt(0,0)
//    if ActiveLevel<GetCurrentLevelCount then
//      SRWin.RenderAt(300,250)
//    else
//      SRFinalWin.RenderAt(150,150)
  end
  else
    SRFail.RenderAt(0,0) ;

  SRTextBack.RenderAt(512,550);

  SRButMenu.RenderAsButton(350,680,mx,my,100,150) ;
  SRButReplay.RenderAsButton(510,680,mx,my,100,150) ;

  if Mode=mWin then
    if (ActiveLevel+1<=GetLevelCountByGame(CurrentGameCode))
       and (not(
       ((CurrentGameCode='company3')and(ActiveLevel>=11)))) then
      SRButNext.RenderAsButton(670,680,mx,my,100,150) ;

  fnt2.SetColor($FFFFFFFF);
  fnt2.PrintF(512,500,HGETEXT_CENTER,GetResultMsg(),[]) ;

 { if Mode=mWin then begin
    if ActiveLevel<GetCurrentLevelCount then
      str:=Texts.Values[CurrentGameCode+'_WINTEXT']
    else
      str:=Texts.Values[CurrentGameCode+'_FINALWINTEXT'] ;
  end
  else
    str:=Texts.Values[CurrentGameCode+'_FAILTEXT'] ;

  fnt2.PrintF(SWindowOptions.GetXCenter(),100,HGETEXT_CENTER,str,[]) ;
 }

  if showconfirm then
    RenderConfirmDialog(SWindowOptions.GetXCenter) ;

  sprMouse.Render(mx,my) ;

  mHGE.Gfx_EndScene;
end;

function RenderFuncWin():Boolean ;
begin
  intRenderFunc(mWin) ;
end;

procedure GoWin() ;
begin
  setFuncsNoRun(mHGE,FrameFuncWinOrFail,RenderFuncWin);
end;

function RenderFuncFail():Boolean ;
begin
  intRenderFunc(mFail) ;
end;

procedure GoFail() ;
begin
  setFuncsNoRun(mHGE,FrameFuncWinOrFail,RenderFuncFail);
end;

end.
