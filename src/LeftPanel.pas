unit LeftPanel;

interface
uses BattleField, PonyAction, SpriteEffects, HGESprite, MiniMap ;

{.$DEFINE NOMINIMAP}

type
  TLeftPanel = class
  private
    _BF:TBattleField ;
    SRSubLayer:TSpriteRender ;
    SRButMenu:TSpriteRender ;
    SRButQuestMenu:TSpriteRender ;
    SRButHelpMenu:TSpriteRender ;
    SRButGridSwitch:TSpriteRender ;
    SRButSkip:TSpriteRender ;
    SRButUserAction:TSpriteRender ;
    SRButAction:TSpriteRender ;
    SRActionSelected:TSpriteRender ;
    SRActionNotAval:TSpriteRender ;
    SRErrBack:TSpriteRender ;
    SRInfoBack:TSpriteRender ;
    SRTop:TSpriteRender ;
    SRBody:TSpriteRender ;
    SRBot:TSpriteRender ;
    TempMsg:string ;
    TempDelay:Single ;
    SprMap:IHGESprite ;
    MinFPS:Double ;
    extinfo:string ;
    useractioninfo:string ;
    ShiftVert,ShiftHorz:Integer ;
  public
    MM:TMiniMap ;
    ActiveAction:TPonyAction ;
    constructor Create(BF:TBattleField) ;
    procedure Render(OverCell:TCell; mx,my:Single) ;
    function IsOverMenu(mx,my:Single):Boolean ;
    function IsOverHelp(mx, my: Single): Boolean;
    function IsOverQuest(mx, my: Single): Boolean;
    function IsOverGridSwitch(mx, my: Single): Boolean;
    function IsOverPanel(mx,my:Single):Boolean ;
    function IsOverFinishStep(mx,my:Single):Boolean ;
    function IsOverUserAction(mx,my:Single):Boolean ;
    function GetOverAction(mx,my:Single;
      out OverAction:TPonyAction):Boolean ;
    procedure setTemporaryMsg(msg:string; delay:Integer) ;
    procedure ClearTemporaryMsg() ;
    function IsTemporaryMsg():Boolean ;
    procedure Update(mx,my:Single; dt:Single) ;
    function getWidth():Integer ;
    procedure setExtInfo(str:string) ;
    procedure setUserActionInfo(str:string) ;
  end;

implementation
uses GameObject, ObjModule, HGEFont, PonyUnits, TAVHGEUtils, HGE, SysUtils,
  FogManager, FFMessage, Editor ;

const
  POS_MENU=22 ;
  POS_FINISHSTEP=735 ;
  POS_MINIMAP_X=7 ;
  POS_MINIMAP_Y=39 ;
  MINIMAP_SIZE=188 ;
  MIDX=101 ;
  
function getButActionY(i:Integer):Integer ;
begin
  Result:=454+i*55 ;
end;

function getButActionX(i:Integer):Integer ;
begin
  Result:=44+(i-1)*58 ;
end;

{ TLeftPanel }

procedure TLeftPanel.setExtInfo(str: string);
begin
  extinfo:=str ;
end;

procedure TLeftPanel.setTemporaryMsg(msg:string; delay:Integer) ;
begin
  TempMsg:=msg ;
  TempDelay:=delay ;
end;

procedure TLeftPanel.setUserActionInfo(str: string);
begin
  useractioninfo:=str ;
end;

procedure TLeftPanel.Update(mx,my:Single; dt: Single);
var mapx,mapy:Single ;
    clickx,clicky:Integer ;
    Cell:TCell ;
    OverAction:TPonyAction ;
    errmsg:string ;
begin
  if IsTemporaryMsg then TempDelay:=TempDelay-dt ;

  {$IFNDEF NOMINIMAP}
  _BF.UpdateMiniMap(MM);

  if (mHGE.Input_KeyDown(HGEK_TAB)) and (not InEditMode()) then
    MM.NoLandscape:=not MM.NoLandscape ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin

    mapx:=mx-POS_MINIMAP_X-ShiftHorz ;
    mapy:=my-POS_MINIMAP_Y-ShiftVert ;
    if (mapx>=0)and(mapx<=MINIMAP_SIZE)and
       (mapy>=0)and(mapy<=MINIMAP_SIZE) then begin
      mHGE.System_Log('mapx=%d mapy=%d',[Round(mapx),Round(mapy)]) ;
      MM.GetXYByClickPos(mapx,mapy,clickx,clicky) ;

      mHGE.System_Log('clickx=%d clicky=%d',[Round(clickx),Round(clicky)]) ;
      _BF.ImmediateRunTo(clickx,clicky);
    end ;
  end ;
  {$ENDIF}

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    ClearTemporaryMsg() ;
    if LP.GetOverAction(mx,my,OverAction) then begin
      if ActiveAction=OverAction then
         ActiveAction:=nil
      else begin
         if OverAction.CanApply(BF,errmsg) then
           ActiveAction:=OverAction
         else
           LP.setTemporaryMsg(errmsg,3) ;
       end;
    end ;
  end;

end;

procedure TLeftPanel.ClearTemporaryMsg;
begin
  TempDelay:=0 ;
end;

constructor TLeftPanel.Create(BF: TBattleField);
begin
  _BF:=BF ;
  SprMap:=LoadSizedSprite(mHGE,'map_alpha.png') ;
  SRButMenu:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'but_gamemenu.png')) ;
  SRButQuestMenu:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'but_questmenu.png')) ;
  SRButHelpMenu:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'but_helpmenu.png')) ;
  SRButGridSwitch:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'but_gridswitch.png')) ;

  SRSubLayer:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'plashleft_sublayer.png')) ;

  SRButSkip:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'but_skipstep.png')) ;
  SRButUserAction:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'but_skipstep.png')) ;

  SRButAction:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'button_spell.png')) ;
  SRActionSelected:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'icon_selected.png')) ;
  SRActionNotAval:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'button_spellnotaval.png')) ;

  SRErrBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'error_back.png')) ;
  SRInfoBack:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'info_back.png')) ;

  SRTop:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'bb_top.png')) ; ;
  SRBody:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'bb_body.png')) ; ;
  SRBot:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'bb_bot.png')) ; ;

  MM:=_BF.CreateMiniMap() ;
end;

function TLeftPanel.GetOverAction(mx, my: Single;
  out OverAction: TPonyAction): Boolean;
var i,g,p:Integer ;
    ListActions:TPonyActionList ;
begin
  OverAction:=nil ;
  Result:=False ;
  if not BF.IsActiveCell() then Exit ;

  ListActions:=TPonyUnit(_BF.GetActiveObject()).GetPermittedActionList(
      TPonyActionPermits(_BF.GetPAP));

  for g := 1 to 3 do begin
    p:=0 ;
    for i := 0 to ListActions.Count - 1 do
      if ListActions.GetAction(i).Order=g then begin
      SRButAction.SetXY(getButActionX(g),getButActionY(p));
      if SRButAction.IsMouseOver(mx,my) then begin
        OverAction:=ListActions.GetAction(i) ;
        Result:=True ;
        Break ;
      end ;
      Inc(p) ;
    end;
  end;
end;

function TLeftPanel.getWidth: Integer;
begin
  Result:=Round(SRSubLayer.GetSprite.GetWidth) ;
end;

function TLeftPanel.IsOverFinishStep(mx, my: Single): Boolean;
begin
  Result:=SRButSkip.IsMouseOver(mx,my) ;
end;

function TLeftPanel.IsOverUserAction(mx, my: Single): Boolean;
begin
  if useractioninfo='' then Result:=False else  
  Result:=SRButUserAction.IsMouseOver(mx,my) ;
end;

function TLeftPanel.IsOverMenu(mx, my: Single): Boolean;
begin
  Result:=SRButMenu.IsMouseOver(mx,my) ;
end;

function TLeftPanel.IsOverHelp(mx, my: Single): Boolean;
begin
  Result:=SRButHelpMenu.IsMouseOver(mx,my) ;
end;

function TLeftPanel.IsOverQuest(mx, my: Single): Boolean;
begin
  Result:=SRButQuestMenu.IsMouseOver(mx,my) ;
end;

function TLeftPanel.IsOverGridSwitch(mx, my: Single): Boolean;
begin
  Result:=SRButGridSwitch.IsMouseOver(mx,my) ;
end;

function TLeftPanel.IsOverPanel(mx, my: Single): Boolean;
begin
  Result:=mx<SRSubLayer.GetSprite.GetWidth ;
end;

function TLeftPanel.IsTemporaryMsg: Boolean;
begin
  Result:=(TempDelay>0) ;
end;

procedure TLeftPanel.Render(OverCell: TCell; mx,my:Single);
var ObjInformed:TGameObject ;
    ListActions:TPonyActionList ;
    i,g,p:Integer ;
    str:string ;
    ShiftX,ShiftY:Single ;
    SR:TSpriteRender ;
    msg:string ;
    fps:Double ;
    OverAction:TPonyAction ;
    th,th2:Integer ;
    v:Integer ;
    
function colorbyv(v:Integer):Cardinal ;
begin
  if v<0 then Result:=$FFff7272 else
  if v>0 then Result:=$FF36ff00 else
  Result:=$FFD0D0D0 ;
end ;

function signbyv(v:Integer):string ;
begin
  if v>0 then Result:='+' else
  Result:='' ;
end ;

begin
  SRSubLayer.RenderAt(MIDX,215) ;
  // Получение объекта для отображения информации
  ObjInformed:=nil ;
  if _BF.IsActiveCell then ObjInformed:=_BF.GetActiveCell._Object ;
  if OverCell<>nil then
    if (not OverCell.IsEmpty())and(OverCell.FogState=fsVisible) then
      ObjInformed:=OverCell._Object ;

  fnt2.SetColor($FFFFFFFF);
  fnt2.SetScale(0.75);

  // Кнопки
  SRButMenu.RenderAsButton(53,POS_MENU,mx,my,100,150) ;
  SRButQuestMenu.RenderAsButton(117,POS_MENU,mx,my,100,150) ;
  SRButHelpMenu.RenderAsButton(149,POS_MENU,mx,my,100,150) ;
  SRButGridSwitch.RenderAsButton(181,POS_MENU,mx,my,100,150) ;

  if MAI.IsStepFinished and (not MS.IsActualScript) then begin
    SRButSkip.RenderAsButton(101,746,mx,my,100,150) ;
    // Информация о ходе
    fnt2.SetScale(0.85) ;
    fnt2.SetColor($FFFFFFFF);
    fnt2.PrintF(100,736,HGETEXT_CENTER,'Завершить ход № %d',[_BF.GetCurrentStep+1]);
  end;


  // Ресурсы
  fnt2.SetScale(1) ;
  fnt2.SetColor($FFFFFFFF);
  fnt2.PrintF(35,232,HGETEXT_LEFT,'%d',[_BF.getFood()]);
  fnt2.PrintF(130,232,HGETEXT_LEFT,'%d',[_BF.GetStone()]);

  fnt2.SetScale(0.7) ;
  v:=_BF.GetFoodIncAtMoment() ;
  fnt2.SetColor(colorbyv(v));
  fnt2.PrintF(77,228,HGETEXT_LEFT,'%s%d',[signbyv(v),v]);

  v:=_BF.GetStoneIncAtMoment() ;
  fnt2.SetColor(colorbyv(v));
  fnt2.PrintF(170,228,HGETEXT_LEFT,'%s%d',[signbyv(v),v]);

  fnt2.SetScale(0.75) ;
  fnt2.SetColor($FFFFFFFF);


  {$IFNDEF NOMINIMAP}
  ShiftX:=_BF.GetShift().X ;
  ShiftY:=_BF.GetShift().Y ;
  MM.FillTexture256(SprMap.GetTexture(),MINIMAP_SIZE,MINIMAP_SIZE,
    ShiftX,ShiftY,ShiftVert,ShiftHorz);
  SprMap.Render(POS_MINIMAP_X+ShiftHorz,POS_MINIMAP_Y+ShiftVert) ;
  {$ENDIF}

  // Вывод информации о рельефе
  if OverCell<>nil then
    fnt2.PrintF(MIDX,272,HGETEXT_CENTER,'%s',[OverCell._Terrain.Caption]);

  // Вывод информации об объекте выделенном или активном
  if ObjInformed<>nil then begin
    fnt2.PrintF(MIDX,297,HGETEXT_CENTER,'%s',[
      StringReplace(ObjInformed.Name,'\n',#13,[rfReplaceAll])]);
    fnt2.PrintF(MIDX,312,HGETEXT_CENTER,'%s',[ObjInformed.Info]);
  end ;

  if IsTemporaryMsg then begin
    SRErrBack.RenderAt(SWindowOptions.GetXCenter+SRSubLayer.GetSprite.GetWidth / 2,737) ;
    fnt2.SetColor($FFFFFFFF);
    fnt2.PrintF(SWindowOptions.GetXCenter+SRSubLayer.GetSprite.GetWidth / 2,
      727,HGETEXT_CENTER,'%s',[TempMsg]) ;
    fnt2.SetColor($FFFFFFFF);
  end;

  if (extinfo<>'')and(MAI.IsStepFinished) then begin
    SRInfoBack.RenderAt(203,7) ;
    fnt2.SetColor($FFFFFFFF);
    fnt2.PrintFB(204,10,122,1000,HGETEXT_CENTER,'%s',[extinfo]) ;
    fnt2.SetColor($FFFFFFFF);
  end;

  if (useractioninfo<>'')and(MAI.IsStepFinished)and(not MS.IsActualScript) then begin
    SRButUserAction.RenderAsButton(297,746,mx,my,100,150) ;
    fnt2.SetScale(0.85) ;
    fnt2.SetColor($FFFFFFFF);
    fnt2.PrintF(297,736,HGETEXT_CENTER,'%s',[useractioninfo]);  
  end;

  if _BF.IsActiveCell() and
     (MAI.IsStepFinished) and
     (not OM.IsMovingProcess) and
     (not BF.IsExistsTranspObjs())and
     (not FFMessage.showdialog) then begin

     ListActions:=TPonyUnit(_BF.GetActiveObject()).GetPermittedActionList
       (TPonyActionPermits(_BF.GetPAP)) ;
     OverAction:=nil ;  
     for g := 1 to 3 do begin
       p:=0 ;
     for i := 0 to ListActions.Count - 1 do
       if ListActions.getAction(i).Order=g then begin
        SRButAction.RenderAsButton(getButActionX(g),getButActionY(p),mx,my,100,150);
        if SRButAction.IsMouseOver(mx,my) then OverAction:=ListActions.getAction(i) ;
        
        SR:=SRPoolActionIcons.GetRenderByTag('icon_'+ListActions.getAction(i).Icon(_BF.GetActiveObject())) ;
        if SR<>nil then SR.RenderAt(getButActionX(g),getButActionY(p))
        else
          fnt2.PrintF(getButActionX(g),getButActionY(p)-10,HGETEXT_CENTER,'%s',
          [ListActions.getAction(i).Icon(_BF.GetActiveObject())]);

        if not ListActions.getAction(i).CanApply(BF,msg) then
           SRActionNotAval.RenderAt(getButActionX(g),getButActionY(p)) ;

        if ActiveAction=ListActions.getAction(i) then
          SRActionSelected.RenderAt(getButActionX(g),getButActionY(p)) ;
        Inc(p) ;  
     end;
     end;

     //if ListActions.Count>0 then
     //for i := ListActions.Count to 12-1 do
     //   SRButAction.RenderAsButton(getButActionX(i),getButActionY(i),mx,my,100,150);

     if ListActions.Locked then begin
       fnt2.PrintF(MIDX,getButActionY(0)-10,HGETEXT_CENTER,'%s',
         ['Действия заблокированы!']);
     end ;
     if ListActions.Stuned then begin
       fnt2.PrintF(MIDX,getButActionY(0)-10,HGETEXT_CENTER,'%s',
         ['Действия недоступны!']);
     end ;

     if (OverAction<>nil) then begin

       str:=StringReplace(OverAction.SubInfo,'\n',#13,[rfReplaceAll]) ;
       fnt2.SetColor($00000000) ;
       th:=0 ;
       if Trim(str)<>'' then begin
         fnt2.PrintFB(205+8,500,270,1000,HGETEXT_LEFT,'%s',[str]) ;
         th:=fnt2.GetTotalHeight() ;
       end ;

       fnt2.PrintFB(205+8,500,270,1000,HGETEXT_LEFT,'%s',[OverAction.Info()]) ;
       th2:=fnt2.GetTotalHeight() ;

       SRTop.RenderAt(205,422);
       SRBody.scaley:=Round(100*((th+th2+40)/23)) ;
       SRBody.RenderAt(205,430);
//       SRBot.RenderAt(205,430+23*14);
       SRBot.RenderAt(205,430+SRBody.GetSprite.GetHeight()*SRBody.scaley/100);

       fnt2.SetColor($FFFEE910);
       fnt2.PrintF(205+145,430,HGETEXT_CENTER,'%s',[OverAction.Caption()]) ;
       fnt2.SetColor($FFFFFFFF);
       fnt2.PrintF(205+8,458,HGETEXT_LEFT,'%s',[OverAction.Info()]) ;
       fnt2.SetColor($FFFFFFFF);
       str:=StringReplace(OverAction.SubInfo,'\n',#13,[rfReplaceAll]) ;
       if Trim(str)<>'' then
         fnt2.PrintFB(205+8,458+th2+10,270,1000,HGETEXT_LEFT,'%s',[str]) ;

       fnt2.SetColor($FFFFFFFF);
     end;

  end;


  fnt2.SetScale(1);

    // FPS
  fps:=mHGE.Timer_GetFPS ;
  if (MinFPS=0)or(MinFPS>fps) then MinFPS:=fps ;
  fnt2.PrintF(1010,735,HGETEXT_RIGHT,'FPS:%.2d, min:%.2d',[Round(fps),Round(MinFPS)]);


end;

end.
