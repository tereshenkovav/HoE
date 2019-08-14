unit FFMonsterInfo;

interface
uses MonsterUnits ;

function FrameFuncMonsterInfo():Boolean ;
procedure RenderMonsterInfo() ;
procedure GoMonsterInfo(M:TMonsterUnit) ;

var
  showmonsterinfo:Boolean ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, FFGame, FFMenu,
 SpriteEffects, SysUtils ;

var _M:TMonsterUnit ;

procedure GoMonsterInfo(M:TMonsterUnit) ;
begin
  _M:=M ;
  showmonsterinfo:=True ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncMonsterInfo);
end;


procedure RenderMonsterInfo() ;
var mx,my:Single ;
    SR:TSpriteRender ;
    sc:Single ;
    str:string ;
    p:Integer ;
begin
  mHGE.Input_GetMousePos(mx,my);

  SRDlgBack.RenderAt(0,0) ;
  SRAboutBack.RenderAt(SWindowOptions.GetXCenter,420) ;

  SR:=SRPoolObjects.GetRenderByTag(_M.SpriteTag) ;
  if SR<>nil then
    SR.RenderAt(SWindowOptions.GetXCenter,250);

  fnt2.SetColor($FF491305);
  fnt2.PrintF(SWindowOptions.GetXCenter,300,HGETEXT_CENTER,_M.Name,[]);

  fnt2.SetColor($FF601010);
  sc:=fnt2.GetScale() ;
  fnt2.SetScale(0.9);
  fnt2.PrintF(SWindowOptions.GetXCenter-230,340,HGETEXT_LEFT,'Запас здоровья: %d',[_M.GetMaxHealth]);
  fnt2.PrintF(SWindowOptions.GetXCenter-230,365,HGETEXT_LEFT,'Дальность хода: %d',[_M.GetMaxStep]);
  fnt2.PrintF(SWindowOptions.GetXCenter-230,390,HGETEXT_LEFT,'Атака обычная: %d-%d',
    [_M.GetAttackValue.GetMin,_M.GetAttackValue.GetMax]);

  p:=415 ;

  if _M.IsSplashAttack then begin
    str:=Format('%d-%d, радиус %d',[_M.GetSplashAttackValue.GetMin,
      _M.GetSplashAttackValue.GetMax,_M.SplashAttackRadius()]) ;
    fnt2.PrintF(SWindowOptions.GetXCenter-230,p,HGETEXT_LEFT,'Атака по площади: %s',
      [str]);
    Inc(p,25) ;
  end ;

  if _M.IsPoison then begin
    str:=Format('%d-%d, радиус %d',[_M.PoisonAttackValue.GetMin,
      _M.PoisonAttackValue.GetMax,_M.PoisonDist()]) ;
    fnt2.PrintF(SWindowOptions.GetXCenter-230,p,HGETEXT_LEFT,'Урон вокруг: %s',
      [str]);
    Inc(p,25) ;
  end ;

  if _M.IsStun() then begin
    fnt2.PrintF(SWindowOptions.GetXCenter-230,p,HGETEXT_LEFT,'Оглушение пони на 1 ход',
      []);
    Inc(p,25) ;
  end ;

  fnt2.PrintFB(SWindowOptions.GetXCenter-230,500,480,1000,HGETEXT_LEFT,_M.Descr,[]);


  fnt2.SetScale(sc);

  SRButOk.RenderAsButton(SWindowOptions.GetXCenter,620,mx,my,100,150);

end;

function FrameFuncMonsterInfo():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    showmonsterinfo:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin

    if SRButOk.IsMouseOver(mx,my) then begin
      showmonsterinfo:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    end ;

    if not showmonsterinfo then Exit ;

  end ;
end ;

end.
