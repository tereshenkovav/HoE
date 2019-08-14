unit FFGameMenu ;

interface

function FrameFuncGameMenu():Boolean ;
procedure RenderGameMenu() ;
procedure GoGameMenu() ;

var
  showmenu:Boolean ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, FFGame, FFMenu,
 SpriteEffects, FFBattleTask, FFStartMenu ;

var SRBut:TSpriteRender ;

procedure goGameMenu() ;
begin
  if SRBut=nil then
    SRBut:=TSpriteRender.Create(
      LoadAndCenteredSizedSprite(mHGE,'but_menu.png'));

  showmenu:=True ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGameMenu);
end;

function GetPos(i:Integer):Integer ;
begin
  Result:=334+i*33 ;
end;

procedure RenderGameMenu() ;
var mx,my:Single ;
    i:Integer ;
const strs:array[0..3] of string = ('Закрыть','Задание','Заново','Выход') ;
begin
  mHGE.Input_GetMousePos(mx,my);

  SRMenuBack.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;

  fnt2.SetScale(0.90);
  for i := 0 to 3 do begin
    SRBut.RenderAsButton(SWindowOptions.GetXCenter,GetPos(i),mx,my,100,150) ;
    fnt2.Render(SWindowOptions.GetXCenter,GetPos(i)-10,HGETEXT_CENTER,strs[i]);
  end;
end;

function FrameFuncGameMenu():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    showmenu:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin

    SRBut.SetXY(SWindowOptions.GetXCenter,GetPos(0));
    if SRBut.IsMouseOver(mx,my) then begin
      showmenu:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    end ;

    SRBut.SetXY(SWindowOptions.GetXCenter,GetPos(1));
    if SRBut.IsMouseOver(mx,my) then begin
      showmenu:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
      FFBattleTask.GoBattleTask() ;
    end ;

    SRBut.SetXY(SWindowOptions.GetXCenter,GetPos(2));
    if SRBut.IsMouseOver(mx,my) then begin
      showmenu:=False ;
      //UnloadGameResources() ;
      FFGame.GoGameAutoLevel ;
      //mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    end ;

    SRBut.SetXY(SWindowOptions.GetXCenter,GetPos(3));
    if SRBut.IsMouseOver(mx,my) then begin
      showmenu:=False ;
      UnloadGameResources() ;
      if CurrentGameCode='systest' then GoStartMenu() else GoMenu() ;
    end ;

    if not showmenu then Exit ;

  end ;
end ;

end.
