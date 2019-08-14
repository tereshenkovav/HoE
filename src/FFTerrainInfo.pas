unit FFTerrainInfo;

interface
uses Terrain ;

function FrameFuncTerrainInfo():Boolean ;
procedure RenderTerrainInfo() ;
procedure GoTerrainInfo(T:TTerrain) ;

var
  showterraininfo:Boolean ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, FFGame, FFMenu,
 SpriteEffects, SysUtils, simple_oper, BattleField ;

var _T:TTerrain ;

procedure GoTerrainInfo(T:TTerrain) ;
begin
  _T:=T ;
  showterraininfo:=True ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncTerrainInfo);
end;


procedure RenderTerrainInfo() ;
var mx,my:Single ;
    SR:TSpriteRender ;
    sc:Single ;
    str:string ;
    p:Integer ;
begin
  mHGE.Input_GetMousePos(mx,my);

  SRDlgBack.RenderAt(0,0) ;
  SRAboutBack.RenderAt(SWindowOptions.GetXCenter,420) ;

  SR:=SRPoolTerrs.GetRenderByTag(_T.Name) ;
  if SR<>nil then begin
    SR.RenderAt(SWindowOptions.GetXCenter,250);
    SR.RenderAt(SWindowOptions.GetXCenter+CELL_WIDTH/2,250+CELL_HEIGHT*4/5);
    SR.RenderAt(SWindowOptions.GetXCenter-CELL_WIDTH/2,250+CELL_HEIGHT*4/5);
  end;

  fnt2.SetColor($FF491305);
  fnt2.PrintF(SWindowOptions.GetXCenter,400,HGETEXT_CENTER,_T.Caption,[]);

  fnt2.SetColor($FF601010);
  sc:=fnt2.GetScale() ;
  fnt2.SetScale(0.9);
  if _T.OnlyFlyers then
  fnt2.PrintF(SWindowOptions.GetXCenter-230,440,HGETEXT_LEFT,'Непроходима для бескрылых!',[])
  else
  if _T.intGetStepNeed>1 then
    fnt2.PrintF(SWindowOptions.GetXCenter-230,440,HGETEXT_LEFT,'Падение скорости: %d раза',
      [_T.intGetStepNeed()]);
  fnt2.PrintF(SWindowOptions.GetXCenter-230,465,HGETEXT_LEFT,'Разрешены здания: %s',
    [Alternate(_T.AllowBuild,'да','нет')]);

  fnt2.PrintFB(SWindowOptions.GetXCenter-230,520,480,1000,HGETEXT_LEFT,_T.Info,[]);

  fnt2.SetScale(sc);

  SRButOk.RenderAsButton(SWindowOptions.GetXCenter,620,mx,my,100,150);

end;

function FrameFuncTerrainInfo():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    showterraininfo:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin

    if SRButOk.IsMouseOver(mx,my) then begin
      showterraininfo:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    end ;

    if not showterraininfo then Exit ;

  end ;
end ;

end.
