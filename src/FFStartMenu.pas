unit FFStartMenu;

interface

procedure GoStartMenu() ;
procedure LoadStartMenuResources() ;
procedure UnLoadStartMenuResources() ;

implementation
uses
   FFGame,
   TAVHGEUtils, HGE, HGEFont, ObjModule, Classes, SysUtils, simple_oper,
   SpriteEffects,
   CommonProc, FFMenu, FFScenePlayer, FFIntro, FFConfirm,
     PersistentFlags, Player ;

var //arr_SRIcons:array[0..32] of TSpriteRender ;
    //SRAbout,SRExit,SRIntro,SROpt:TSpriteRender;

    SR_TextCampain,SR_TextStudy,SR_TextLegends,SR_TextUserMaps,
    SR_TextExitGame,SR_TextTitres,SR_TextSettings:TSpriteRender ;

    SR_Logo:TSpriteRender ;

    IsDialog:Boolean = False ;
    IsOpt:Boolean = False ;
    IsAlertRes:Boolean ;

    ActiveCursor:Boolean ;

function getCBPosX(i:Integer):Integer ;
begin
  Result:=220 ;
end ;

function getCBPosY(i:Integer):Integer ;
begin
  Result:=160+60*i ;
end ;

procedure GoCompany() ;
begin
  GetPersistentFlags().SetFlag('company_without_learn_confirmed') ;
  CurrentGameCode:=PL.GetLastCompany() ;
  LoadGameResourcesCommon(CurrentGameCode) ;
  GoMenu() ;
end;

procedure GoHardCompany() ;
begin
  GetPersistentFlags().SetFlag('hardcompany_without_learn_confirmed') ;
  CurrentGameCode:='hardcompany' ;
  LoadGameResourcesCommon(CurrentGameCode) ;
  GoMenu() ;
end;          

function FrameFuncStartMenu():Boolean ;
var mx,my:Single ;
    i:Integer ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    if IsDialog then
      IsDialog:=False
    else
    if IsOpt then
      IsOpt:=False
    else
    if IsAlertRes then
      IsAlertRes:=False
    else
    begin
      Result:=True ;
      Exit ;
    end;
  end ;

  if mHGE.Input_KeyDown(HGEK_F5) and mHGE.Input_GetKeyState(HGEK_SHIFT)
    and mHGE.Input_GetKeyState(HGEK_CTRL) then begin
      CurrentGameCode:='usermaps' ;
      LoadGameResourcesCommon(CurrentGameCode) ;
      GoMenu() ;
      Exit ;
    end;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    if not(IsDialog or IsOpt or IsAlertRes) then begin
      if SR_Campain.IsMouseOver(mx,my) then begin
        if (not PL.IsPassedDemoCompany())and
           (not GetPersistentFlags().IsFlag('company_without_learn_confirmed')) then
          execConfirmMsg('Вы не прошли обучение. Уверены, что хотите играть в кампанию?',
            FrameFuncStartMenu,GoCompany)
        else
          GoCompany() ;
      end;
      if SR_Study.IsMouseOver(mx,my) then begin
        CurrentGameCode:='democompany' ;
        LoadGameResourcesCommon(CurrentGameCode) ;
        GoMenu() ;
      end;
      if SR_Legends.IsMouseOver(mx,my) then begin
        if (not PL.IsPassedDemoCompany())and
           (not GetPersistentFlags().IsFlag('hardcompany_without_learn_confirmed')) then
          execConfirmMsg('Вы не прошли обучение. Уверены, что хотите играть в Легенды (набор карт повышенной сложности)?',
            FrameFuncStartMenu,GoHardCompany)
        else
          GoHardCompany() ;
      end;
      if SR_UserMaps.IsMouseOver(mx,my) then begin
        CurrentGameCode:='usermaps' ;
        LoadGameResourcesCommon(CurrentGameCode) ;
        GoMenu() ;
      end;
    end;
    
    if IsDialog or IsOpt or IsAlertRes then begin
      if SRButOk.IsMouseOver(mx,my) then begin
        IsDialog:=False ;
        IsOpt:=False ;
        IsAlertRes:=False ;
      end;

      if IsOpt then begin
        SRrbOn.SetXY(getCBPosX(0),getCBPosY(0));
        if SRrbOn.IsMouseOver(mx,my) then PL.SetHardLevel(hlImmortal);

        SRrbOn.SetXY(getCBPosX(1),getCBPosY(1));
        if SRrbOn.IsMouseOver(mx,my) then PL.SetHardLevel(hlNovice);

        SRrbOn.SetXY(getCBPosX(2),getCBPosY(2));
        if SRrbOn.IsMouseOver(mx,my) then PL.SetHardLevel(hlCasual);

        SRrbOn.SetXY(getCBPosX(3),getCBPosY(3));
        if SRrbOn.IsMouseOver(mx,my) then PL.SetHardLevel(hlStandart);

        SRcbOn.SetXY(getCBPosX(4),getCBPosY(4));
        if SRcbOn.IsMouseOver(mx,my) then PL.SetTwailikorn(not PL.IsTwailikorn);

        SRcbOn.SetXY(getCBPosX(5),getCBPosY(5));
        if SRcbOn.IsMouseOver(mx,my) then PL.SetFastKeyboard(not PL.IsFastKeyboard);

        SRcbOn.SetXY(getCBPosX(6),getCBPosY(6));
        if SRcbOn.IsMouseOver(mx,my) then PL.SetFastMouse(not PL.IsFastMouse);

        SRcbOn.SetXY(getCBPosX(7),getCBPosY(7));
        if SRcbOn.IsMouseOver(mx,my) then PL.SetMonoTerrain(not PL.IsMonoTerrain);

      end;

      if IsAlertRes then begin
        SRcbOn.SetXY(getCBPosX(3),getCBPosY(3));
        if SRcbOn.IsMouseOver(mx,my) then PL.SetNoShowAlertLowRes(not PL.IsNoShowAlertLowRes);
      end ;

    end
    else begin
    if SR_ExitGame.IsMouseOver(mx,my) then begin
      Result:=True ;
      Exit ;
    end ;

    if SR_Titres.IsMouseOver(mx,my) then
      IsDialog:=True ;

    if SR_Settings.IsMouseOver(mx,my) then
      IsOpt:=True ;
    
    {if SRSound.IsMouseOver(mx,my) or SRNoSound.IsMouseOver(mx,my) then begin
      UserNoSound:=not UserNoSound ;
      SaveSoundOpt() ;
    end;}
    end;

  end;

end;

function RenderFuncStartMenu():Boolean ;
var mx,my:Single ;
    i:Integer ;
const
  POS_TEXT_Y=500 ;
begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  ActiveCursor:=False ;
  if not (IsOpt or IsDialog or showconfirm) then
  ActiveCursor:=SR_Study.IsMouseOver(mx,my) or
    SR_Campain.IsMouseOver(mx,my) or
    SR_Legends.IsMouseOver(mx,my) or
    SR_UserMaps.IsMouseOver(mx,my) or
    SR_ExitGame.IsMouseOver(mx,my) or
    SR_Titres.IsMouseOver(mx,my) or
    SR_Settings.IsMouseOver(mx,my) ;

  sprBack.RenderStretch(0,0,SWindowOptions.Width,SWindowOptions.Height) ;

  SR_Logo.RenderAt(SWindowOptions.GetXCenter,100) ;

  fnt2.SetColor($FF404040) ;

  SR_Study.RenderAsButton(160,300,mx,my,100,120);
  SR_Campain.RenderAsButton(380,300,mx,my,100,140);
  SR_Legends.RenderAsButton(620,300,mx,my,100,140);
  SR_UserMaps.RenderAsButton(840,300,mx,my,100,140);

  SR_Settings.RenderAsButton(400,650,mx,my,100,140);
  SR_Titres.RenderAsButton(512,650,mx,my,100,120);
  SR_ExitGame.RenderAsButton(612,650,mx,my,100,140);

  if not (IsOpt or IsDialog or showconfirm) then begin
  if SR_Study.IsMouseOver(mx,my) then
    SR_TextStudy.RenderAt(SWindowOptions.GetXCenter,POS_TEXT_Y);
  if SR_Campain.IsMouseOver(mx,my) then
    SR_TextCampain.RenderAt(SWindowOptions.GetXCenter,POS_TEXT_Y);
  if SR_Legends.IsMouseOver(mx,my) then
    SR_TextLegends.RenderAt(SWindowOptions.GetXCenter,POS_TEXT_Y);
  if SR_UserMaps.IsMouseOver(mx,my) then
    SR_TextUserMaps.RenderAt(SWindowOptions.GetXCenter,POS_TEXT_Y);
  if SR_Settings.IsMouseOver(mx,my) then
    SR_TextSettings.RenderAt(SWindowOptions.GetXCenter,POS_TEXT_Y);
  if SR_Titres.IsMouseOver(mx,my) then
    SR_TextTitres.RenderAt(SWindowOptions.GetXCenter,POS_TEXT_Y);
  if SR_ExitGame.IsMouseOver(mx,my) then
    SR_TextExitGame.RenderAt(SWindowOptions.GetXCenter,POS_TEXT_Y);
  end ;


{
  for i := 0 to GetGameCodesList.Count - 1 do begin
    arr_SRIcons[i].SetScaleBoth(120*(100/arr_SRIcons[i].GetSprite.GetWidth));
    arr_SRIcons[i].RenderAsButton(PosLeft(i),PosTop(i),mx,my,100,120) ;

        fnt2.PrintF(PosLeft(i),PosTop(i)+80,HGETEXT_CENTER,
          '%d/%d',[PL.GetCompletedCount(GetGameCodesList[i]),
            GetLevelCountByGame(GetGameCodesList[i])]);
  end;
}

{  if UserNoSound then begin
    SRNoSound.bright:=Alternate(SRNoSound.IsMouseOver(mx,my),200,100) ;
    SRNoSound.RenderAt(30,30)
  end
  else begin
    SRSound.bright:=Alternate(SRSound.IsMouseOver(mx,my),200,100) ;
    SRSound.RenderAt(30,30);
  end ;
}
  if IsDialog then begin
    SRDlgBack.RenderAt(0,0) ;
    SRTitresBack.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;
    fnt2.SetColor($FFFFFFFF);
    fnt2.SetScale(0.9);
    fnt2.PrintF(SWindowOptions.GetXCenter,30,HGETEXT_CENTER,
      Texts.Values['MAIN_ABOUT'],[]);
    fnt2.SetScale(1);
    SRButOk.RenderAsButton(SWindowOptions.GetXCenter+2,749,mx,my,100,150);
  end;

  if IsOpt then begin
    SRDlgBack.RenderAt(0,0) ;
    SROptBack.RenderAt(SWindowOptions.GetXCenter,SWindowOptions.GetYCenter) ;
    fnt2.SetColor($FF491305);
    fnt2.PrintF(SWindowOptions.GetXCenter,80,HGETEXT_CENTER,
      'НАСТРОЙКИ',[]);

    getRB(PL.GetHardLevel()=hlImmortal).RenderAsButton(getCBPosX(0),getCBPosY(0),
      mx,my,100,150) ;
    fnt2.PrintF(getCBposX(0)+30,getCBPosY(0)-20,HGETEXT_LEFT,
      'Режим бессмертия (режим новичка плюс%sавтоматический силовой щит при сильном ранении пони)',[#13]);

    getRB(PL.GetHardLevel()=hlNovice).RenderAsButton(getCBPosX(1),getCBPosY(1),
      mx,my,100,150) ;
    fnt2.PrintF(getCBposX(1)+30,getCBPosY(1)-20,HGETEXT_LEFT,
      'Режим новичка (-33%% урона и здоровья врагов,%s-20%% на расход сил действий, +1 к дальности хода всех пони)',[#13]);

    getRB(PL.GetHardLevel()=hlCasual).RenderAsButton(getCBPosX(2),getCBPosY(2),
      mx,my,100,150) ;
    fnt2.PrintF(getCBposX(2)+30,getCBPosY(2)-20,HGETEXT_LEFT,
      'Казуальный режим (-33%% урона и здоровья врагов)%s[рекомендуется для типового прохождения]',[#13]);

    getRB(PL.GetHardLevel()=hlStandart).RenderAsButton(getCBPosX(3),getCBPosY(3),
      mx,my,100,150) ;
    fnt2.PrintF(getCBposX(3)+30,getCBPosY(3)-20,HGETEXT_LEFT,
      'Стандартная сложность%s[рекомендуется для опытных игроков]',[#13]);

    getCB(PL.IsTwailikorn).RenderAsButton(getCBPosX(4),getCBPosY(4),
      mx,my,100,150) ;
    fnt2.PrintF(getCBposX(4)+30,getCBPosY(4)-20,HGETEXT_LEFT,
      'Твайлайт как аликорн%s(+33%% к скорости и способность полета)',[#13]);

    getCB(PL.IsFastKeyboard).RenderAsButton(getCBPosX(5),getCBPosY(5),
      mx,my,100,150) ;
    fnt2.PrintF(getCBposX(5)+30,getCBPosY(5),HGETEXT_LEFT,
      'Быстрая прокрутка карты клавишами (+50%%)',[]);

    getCB(PL.IsFastMouse).RenderAsButton(getCBPosX(6),getCBPosY(6),
      mx,my,100,150) ;
    fnt2.PrintF(getCBposX(6)+30,getCBPosY(6),HGETEXT_LEFT,
      'Быстрая прокрутка карты мышью (+50%%)',[]);

    getCB(PL.IsMonoTerrain).RenderAsButton(getCBPosX(7),getCBPosY(7),
      mx,my,100,150) ;
    fnt2.PrintF(getCBposX(7)+30,getCBPosY(7),HGETEXT_LEFT,
      'Однотонные текстуры рельефа',[]);

    SRButOk.RenderAsButton(SWindowOptions.GetXCenter,680,mx,my,100,150);
  end;

  if IsAlertRes then begin
    SRDlgBack.RenderAt(0,0) ;
    SRAboutBack.RenderAt(SWindowOptions.GetXCenter,420) ;
    fnt2.SetColor($FF491305);
    fnt2.PrintF(SWindowOptions.GetXCenter,200,HGETEXT_CENTER,
      'ПРЕДУПРЕЖДЕНИЕ!',[]);

    fnt2.PrintF(300,300,HGETEXT_LEFT,
      'Ваше экранное разрешение меньше, чем нужно%s'+
      'для отображения всего игрового окна.%s'+
      'Рекомендуем перейти в полноэкранный режим,%s'+
      'нажав клавиши Alt и Enter одновременно.',[#13,#13,#13]);

    getCB(PL.IsNoShowAlertLowRes).RenderAsButton(getCBPosX(3),getCBPosY(3),
      mx,my,100,150) ;
    fnt2.PrintF(getCBposX(3)+30,getCBPosY(3)-20,HGETEXT_LEFT,
      'Не выводить больше это предупреждение',[]);

    SRButOk.RenderAsButton(SWindowOptions.GetXCenter,620,mx,my,100,150);
  end;

  if showconfirm then
    RenderConfirmDialog(SWindowOptions.GetXCenter) ;
  

  if ActiveCursor then
    sprMouseActive.Render(mx,my)
  else
    sprMouse.Render(mx,my) ;

  mHGE.Gfx_EndScene;
end;


procedure LoadStartMenuResources() ;
var i:Integer ;
begin
  SR_Campain:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_campaing.png'));
  SR_Legends:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_legends.png'));
  SR_UserMaps:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_usermaps.png'));
  SR_Study:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_study.png'));
  SR_Titres:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_titres.png'));
  SR_Settings:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_settings.png'));
  SR_ExitGame:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_exitgame.png'));

  SR_TextCampain:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_Textcampaing.png'));
  SR_TextLegends:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_Textlegends.png'));
  SR_TextUserMaps:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_TextUserMaps.png'));
  SR_TextStudy:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_Textstudy.png'));
  SR_TextTitres:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_Texttitres.png'));
  SR_TextSettings:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_Textsettings.png'));
  SR_TextExitGame:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'icon_Textexit.png'));

  SRDlgBack:=TSpriteRender.Create
      (LoadSizedSprite(mHGE,'dialog_back.png'));
  SROptBack:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'messagelist_back.png'));
  SRAboutBack:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'about_back.png'));
  SRTitresBack:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'titres_back.png'));
  SRBattleTaskBack:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'qj_window.png'));
  SRButOk:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'but_ok.png'));

  SR_Logo:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'logo.png'));

  SRcbOn:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'checkbox_on.png'));
  SRcbOff:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'checkbox_off.png'));

  SRrbOn:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'radiobtn_on.png'));
  SRrbOff:=TSpriteRender.Create
      (LoadAndCenteredSizedSprite(mHGE,'radiobtn_off.png'));

  SRMsgBack:=TSpriteRender.Create(LoadSizedSprite(mHGE,'message_back.png')); ;
  SRConfirmBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,'confirm_back.png')); ;
  SRIconBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'icon_back.png')) ; ;
  SRTextBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,'text_back.png')); ;

end;

procedure UnLoadStartMenuResources() ;
var i:Integer ;
begin
  SR_Campain.Free ;
  SR_Study.Free ;
  SR_Legends.Free ;
  SR_UserMaps.Free ;
  SR_Settings.Free ;
  SR_Titres.Free ;
  SR_ExitGame.Free ;
  SRDlgBack.Free ;
  SROptBack.Free ;
  SRAboutBack.Free ;
  SRButOk.Free ;

  SR_Logo.Free ;

end;

procedure GoStartMenu() ;
begin
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncStartMenu);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncStartMenu);

  // тест разрешения
  if not PL.IsNoShowAlertLowRes then
    if CommonProc.IsLowResolution() then
      IsAlertRes:=True ;
end;


end.
