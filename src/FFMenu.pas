unit FFMenu;

interface

procedure GoMenu() ;
function FrameFuncMenu():Boolean ;

implementation
uses
   FFGame,
   TAVHGEUtils, HGE, HGEFont, ObjModule, Classes, SysUtils, simple_oper,
   FFStartMenu, CommonProc, FontHolder, StaticText,
   SpriteEffects, FFConfirm, PersistentFlags, Player ;

var
  FRLevel:array[-1..32] of TFontRender ;
  SRLegend:array[0..32] of TSpriteRender ;
  SRCusual,SRNovice:TSpriteRender ;

  TekSelectedLevel:Integer ;

procedure GoSelectedLevel() ;
begin
  GetPersistentFlags().SetFlag(CurrentGameCode+'_started');
  GoAutoGame(TekSelectedLevel) ;
end;

function FrameFuncMenu():Boolean ;
var mx,my:Single ;
    i:Integer ;
    z:Boolean ;
begin

  Result:=False ;
  
  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    UnloadGameResourcesCommon() ;
    GoStartMenu() ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin

    if DemoLevelExist(CurrentGameCode) then
      if FRLevel[-1].IsMouseOver(mx,my) then begin
          GoAutoGame(-1) ;
          Exit ;
        end ;

    for i := 1 to GetCurrentLevelCount() do
      if PL.IsLevelAval(CurrentGameCode,i) then begin
        if CurrentGameCode='hardcompany' then
          z:=SRLegend[i].IsMouseOver(mx,my)
        else
          z:=FRLevel[i].IsMouseOver(mx,my) ;

        if z then begin
          TekSelectedLevel:=i ;

          if (CurrentGameCode='company2')and(not PL.IsLevelAval('company1',13))and
           (not GetPersistentFlags().IsFlag(CurrentGameCode+'_started')) then begin
            execConfirmMsg('Вторая кампания является сюжетным продолжением первой.'+
            ' Уверены, что хотите начать со второй кампании?',
            FrameFuncMenu,GoSelectedLevel) ;
          end
          else
          if (CurrentGameCode='company3')and(not PL.IsLevelAval('company2',16)) and
           (not GetPersistentFlags().IsFlag(CurrentGameCode+'_started')) then begin
            execConfirmMsg('Третья кампания является сюжетным продолжением первой и второй.'+
            ' Уверены, что хотите начать с третьей кампании?',
            FrameFuncMenu,GoSelectedLevel) ;
          end
          else
            GoSelectedLevel() ;

          Exit ;
        end ;
      end;

    if SRButBack.IsMouseOver(mx,my) then begin
      UnloadGameResourcesCommon() ;
      GoStartMenu() ;
    end ;

    if Pos('company',CurrentGameCode)=1 then begin

    if SR_Campain1.IsMouseOver(mx,my) then begin
      CurrentGameCode:='company1' ;
      PL.SetLastCompany(CurrentGameCode);
      GoMenu() ;
      Exit ;
    end;

    if SR_Campain2.IsMouseOver(mx,my) then begin
      CurrentGameCode:='company2' ;
      PL.SetLastCompany(CurrentGameCode);
      GoMenu() ;
      Exit ;
    end;

    if SR_Campain3.IsMouseOver(mx,my) then begin
      CurrentGameCode:='company3' ;
      PL.SetLastCompany(CurrentGameCode);
      GoMenu() ;
      Exit ;
    end;

    end;
    
  end;

end;

function RenderFuncMenu():Boolean ;
var mx,my:Single ;
    i:Integer ;

function PosLeft(i:Integer):Integer ;
begin
  if CurrentGameCode='democompany' then
    Result:=620
  else
  if CurrentGameCode='usermaps' then
    Result:=100
  else  
  if CurrentGameCode='hardcompany' then begin
    if i=7 then i:=8 ;
    Result:=50+((i-1) mod 2)*220
  end
  else
    Result:=580 ;
end ;

function PosTop(i:Integer):Integer ;
begin
  if (CurrentGameCode='democompany') then
    Result:=190+(i-1)*70
  else
  if CurrentGameCode='hardcompany' then
    Result:=50+((i-1) div 2)*140 + Alternate(i>4,50,0)
  else  
  if CurrentGameCode='usermaps' then
    Result:=100+(i-1)*30 
  else
    Result:=100+(i-1)*40 ;
end ;

begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.RenderStretch(0,0,SWindowOptions.Width,SWindowOptions.Height) ;

  if CurrentGameCode='democompany' then begin
  SR_BackStudy.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;
  SR_Study.RenderAt(250,200);
  end
  else
  if CurrentGameCode='usermaps' then begin
    SR_BackLegends.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;
    for i := 1 to GetCurrentLevelCount() do begin
        if FRLevel[i]=nil then Continue ;
        
        FRLevel[i].RenderAt(PosLeft(i),PosTop(i)-10) ;
        if FRLevel[i].IsMouseOver(mx,my) then begin
          SR_BackLegendDescription.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;
          fnt2.SetColor($FFFFFFFF) ;
          fnt2.PrintF(SWindowOptions.GetXCenter+220,140,
            HGETEXT_CENTER,'%s',[AnsiUpperCase(GetLevelInfoByCodeAndN(CurrentGameCode,i).LevelName)]);
          fnt2.PrintFB(SWindowOptions.GetXCenter+20,180,
            440,1000,
            HGETEXT_LEFT,'%s',[GetLevelInfoByCodeAndN(CurrentGameCode,i).LevelDescr]);
          break ;
        end;
      end;
  end
  else
  if CurrentGameCode='hardcompany' then begin
    SR_BackLegends.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;
    for i := 1 to GetCurrentLevelCount() do
      if PL.IsLevelAval(CurrentGameCode,i) then begin
        SRLegend[i].SetXY(PosLeft(i),PosTop(i)-10) ;
        if SRLegend[i].IsMouseOver(mx,my) then begin
          SR_BackLegendDescription.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;
          fnt2.SetColor($FFFFFFFF) ;
          fnt2.PrintF(SWindowOptions.GetXCenter+220,140,
            HGETEXT_CENTER,'%s',[AnsiUpperCase(GetLevelInfoByCodeAndN(CurrentGameCode,i).LevelName)]);
          fnt2.PrintFB(SWindowOptions.GetXCenter+20,180,
            440,1000,
            HGETEXT_LEFT,'%s',[GetLevelInfoByCodeAndN(CurrentGameCode,i).LevelDescr]);
          break ;
        end;
      end;
  end
  else begin
  SR_BackCampain.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;
  SR_Campain1.RenderAsButton(200,70,mx,my,100,120);
  SR_Campain2.RenderAsButton(200,270,mx,my,100,120);
  SR_Campain3.RenderAsButton(200,470,mx,my,100,120);
  end;

  fnt2.SetColor($FF491305) ;

  if DemoLevelExist(CurrentGameCode) then begin
    FRLevel[-1].RenderAt(PosLeft(0),PosTop(0)-10) ;
    if FRLevel[-1].IsMouseOver(mx,my) then
      SR_Pointer.RenderAt(PosLeft(0)-40,PosTop(0)-12) ;
  end ;

  for i:=1 to GetCurrentLevelCount do 
    if PL.IsLevelAval(CurrentGameCode,i) then begin
      if CurrentGameCode='hardcompany' then begin
        SRLegend[i].RenderAsButton(PosLeft(i),PosTop(i)-10,mx,my,100,150) ;
      end
      else begin
        if FRLevel[i]<>nil then begin
          FRLevel[i].RenderAt(PosLeft(i),PosTop(i)-10) ;
          if FRLevel[i].IsMouseOver(mx,my) then
            SR_Pointer.RenderAt(PosLeft(i)-40,PosTop(i)-12) ;
        end;
      end;
    end;

  if CurrentGameCode='democompany' then
    SRButBack.RenderAsButton(180,620,mx,my,100,200)
  else
  if (CurrentGameCode='hardcompany')or(CurrentGameCode='usermaps') then
    SRButBack.RenderAsButton(170,670,mx,my,100,200)
  else
    SRButBack.RenderAsButton(180,680,mx,my,100,200) ;

  if Pos('company',CurrentGameCode)=1 then begin
    if PL.GetHardLevel()=hlCasual then SRCusual.RenderAt(390,27) else
    if PL.GetHardLevel()<=hlNovice then SRNovice.RenderAt(390,27);
  end;

  if showconfirm then
    RenderConfirmDialog(SWindowOptions.GetXCenter) ;
    
  sprMouse.Render(mx,my) ;
  
  {
  if UserNoSound then begin
    SRNoSound.bright:=Alternate(SRNoSound.IsMouseOver(mx,my),200,100) ;
    SRNoSound.RenderAt(30,30)
  end
  else begin
    SRSound.bright:=Alternate(SRSound.IsMouseOver(mx,my),200,100) ;
    SRSound.RenderAt(30,30);
  end ;
  }
  mHGE.Gfx_EndScene;
end;


procedure GoMenu() ;
var i,k:Integer ;
    numstr:string ;
begin
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncMenu);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncMenu);

  if SRCusual=nil then
    SRCusual:=TSpriteRender.Create(LoadSizedSprite(mHGE,'casual_mark.png'));
  if SRNovice=nil then
    SRNovice:=TSpriteRender.Create(LoadSizedSprite(mHGE,'novice_mark.png'));

  if CurrentGameCode='hardcompany' then begin
  for i := 1 to GetCurrentLevelCount() do
    if PL.IsLevelAval(CurrentGameCode,i) then begin
      SRLegend[i]:=TSpriteRender.Create(LoadSizedSprite(mHGE,
       Format('icon_Legend%d.png',[i])));
    end
  end
  else begin
  if DemoLevelExist(CurrentGameCode) then begin
    FRLevel[-1]:=TFontRender.Create(TFontHolder.Create(fnt2,
        TStaticText.Create(Format(
          Alternate(CurrentGameCode='company1','демокарта: %s','флэшбек: %s'),
        [GetLevelInfoByCodeAndN(CurrentGameCode,-1).LevelName]))),0,0);
    FRLevel[-1].color:=$491305 ;
    FRLevel[-1].RightBottom.X:=350 ;
  end;

  k:=1 ;
  for i := 1 to GetCurrentLevelCount() do
    if PL.IsLevelAval(CurrentGameCode,i) then begin
      if GetLevelInfoByCodeAndN(CurrentGameCode,i).IsNoNumber or
         (CurrentGameCode='usermaps') then numstr:='' else numstr:=IntToStr(i)+'. ' ;

      FRLevel[i]:=TFontRender.Create(TFontHolder.Create(fnt2,
        TStaticText.Create(Format('%s%s',
        [numstr,GetLevelInfoByCodeAndN(CurrentGameCode,i).LevelName]))),0,0);
      FRLevel[i].color:=$491305 ;
      FRLevel[i].RightBottom.X:=350 ;
      Inc(k) ;
    end;
    FRLevel[i]:=nil ;
  end;
   
end;


end.
