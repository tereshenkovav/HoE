unit FFChooseSol;

interface

function FrameFuncChooseSol():Boolean ;
procedure RenderChooseSol() ;
procedure GoChooseSol() ;

var
  showchoosesol:Boolean ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, FFGame, FFMenu,
 SpriteEffects, FFBattleTask, FFStartMenu ;

var SRBut:TSpriteRender ;
const SOL_COUNT=3 ;

procedure goChooseSol() ;
begin
  if SRBut=nil then
    SRBut:=TSpriteRender.Create(
      LoadAndCenteredSizedSprite(mHGE,'but_choosesol.png'));

  showchoosesol:=True ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncChooseSol);
end;

function GetPos(i,cnt:Integer):Integer ;
var space:Integer ;
begin
  space:=Round((SRChooseSolBack.GetSprite.GetHeight-cnt*SRBut.GetSprite.GetHeight)/(cnt+1)) ;
  Result:=Round(SWindowOptions.GetYCenter()-SRChooseSolBack.GetSprite.GetHeight/2+
     space*(i+1)+SRBut.GetSprite.GetHeight*(i+0.5)) ;
end;

procedure RenderChooseSol() ;
var mx,my:Single ;
    i:Integer ;
const strs:array[0..SOL_COUNT-1] of string =
  ('Использовать заклинание очистки',
   'Принять предложение Дискорда',
   'Принять предложение Мрака') ;
begin
  mHGE.Input_GetMousePos(mx,my);

  SRChooseSolBack.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;

  fnt2.SetScale(0.90);
  for i := 0 to SOL_COUNT-1 do begin
    SRBut.RenderAsButton(SWindowOptions.GetXCenter,GetPos(i,SOL_COUNT),mx,my,100,150) ;
    fnt2.Render(SWindowOptions.GetXCenter,GetPos(i,SOL_COUNT)-10,HGETEXT_CENTER,strs[i]);
  end;
end;

function FrameFuncChooseSol():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin

    SRBut.SetXY(SWindowOptions.GetXCenter,GetPos(0,SOL_COUNT));
    if SRBut.IsMouseOver(mx,my) then begin
      showchoosesol:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
      BF.SetFlag('spellsol');
    end ;

    SRBut.SetXY(SWindowOptions.GetXCenter,GetPos(1,SOL_COUNT));
    if SRBut.IsMouseOver(mx,my) then begin
      showchoosesol:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
      BF.SetFlag('fusesol');
    end ;

    SRBut.SetXY(SWindowOptions.GetXCenter,GetPos(2,SOL_COUNT));
    if SRBut.IsMouseOver(mx,my) then begin
      showchoosesol:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
      BF.SetFlag('splitsol');
    end ;

    if not showchoosesol then Exit ;

  end ;
end ;

end.
