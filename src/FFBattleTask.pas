unit FFBattleTask;

interface

function FrameFuncBattleTask():Boolean ;
procedure RenderBattleTask() ;
procedure GoBattleTask() ;

var
  showbattletask:Boolean ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, FFGame, FFMenu,
 SpriteEffects, SysUtils, simple_oper, BattleField, BattleTask ;

procedure GoBattleTask() ;
begin
  showbattletask:=True ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncBattleTask);
end;


procedure RenderBattleTask() ;
var mx,my:Single ;
    sc:Single ;
    str:string ;
    i,p:Integer ;
begin
  mHGE.Input_GetMousePos(mx,my);

  SRDlgBack.RenderAt(0,0) ;
  SRBattleTaskBack.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;

  sc:=fnt2.GetScale() ;
  fnt2.SetScale(0.9);
  p:=110 ;
  for i := 0 to GetBF().GetBattleTask().Count-1 do begin
    if GetBF().GetBattleTask().GetType(i)=bttFail then fnt2.SetColor($FFd50014) else
    if GetBF().GetBattleTask().GetType(i)=bttComp then fnt2.SetColor($FFb5b5b5) else
    if not GetBF().GetBattleTask().IsReq(i) then fnt2.SetColor($FF25e56d) else
    fnt2.SetColor($FFdbd40f) ;

    fnt2.PrintFB(SWindowOptions.GetXCenter-210,p,
      450,1000,
      HGETEXT_LEFT,GetBF().GetBattleTask().GetTask(i),[]) ;
    p:=p+fnt2.GetTotalHeight()+20 ;  
  end;

  fnt2.SetScale(sc);

  SRButOk.RenderAsButton(SWindowOptions.GetXCenter,700,mx,my,100,150);

end;

function FrameFuncBattleTask():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    showbattletask:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin

    if SRButOk.IsMouseOver(mx,my) then begin
      showbattletask:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    end ;

    if not showbattletask then Exit ;

  end ;
end ;

end.
