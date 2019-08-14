unit ScenePlayer ;

interface
uses Windows, SpriteEffects, HGESprite, Classes, SysUtils, contnrs, HGEFont ;

type
  TSceneIcon = class
  public
    id:string ;
    SR:TSpriteRender ;
    Color:Cardinal ;
    Visible:Boolean ;
  end ;

  TSceneText = class
  public
    icon_id:string ;
    str:string ;
    delay:Integer ;
    Action:string ;
    ActionParam:string ;
  end ;

  TScenePlayer = class
  private
    sprBack:IHGESprite ;
    ListIcons:TObjectList ;
    ListScenes:TObjectList ;
    ListStatic:TObjectList ;
    ListStaticNames:TStringList ;
    TextPos:TPoint ;
    TextWidth:Single ;
    Fnt:IHGEFont ;
    TekScenePoz:Integer ;
    tpass:Single ;
    SRIconBack:TSpriteRender ;
    SRIconTalk:TSpriteRender ;
    function GetIcon(i:Integer):TSceneIcon ;
    function GetIconByID(id:string):TSceneIcon ;
    function TekScene():TSceneText ;
  public
    constructor CreateFromFile(FileName:string) ;
    procedure StartPlay ;
    function IsFinished():Boolean ;
    function IsStaticVisible(partname:string):Boolean ;
    function IsStaticExist(partname:string):Boolean ;
    procedure Update(dt:Single) ;
    procedure GoNextScene() ;
    procedure Render() ;
  end ;

implementation
uses TAVHGEUtils, CommonClasses ;

function TScenePlayer.GetIcon(i:Integer):TSceneIcon ;
begin  Result:=TSceneIcon(ListIcons[i]) ; end ;

function TScenePlayer.GetIconByID(id: string): TSceneIcon;
var i:Integer ;
begin
  Result:=nil ;
  for i := 0 to ListIcons.Count - 1 do
    if GetIcon(i).id=id then Result:=GetIcon(i) ;
end;

constructor TScenePlayer.CreateFromFile(FileName:string) ;
var i:Integer ;
    SI:TSceneIcon ;
    ST:TSceneText ;
begin
  ListIcons:=TObjectList.Create ;
  ListScenes:=TObjectList.Create ;
  ListStatic:=TObjectList.Create ;
  ListStaticNames:=TStringList.Create ;

  SRIconTalk:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,'icon_talk.png'));

  with TIniFileEx.Create(FileName) do begin
    if ReadString('Main','Background','')<>'' then
      sprBack:=LoadSizedSprite(mHGE,ReadString('Main','Background',''))
    else
      sprBack:=nil ;

    if ReadString('Main','Icon_Background','')<>'' then
      SRIconBack:=TSpriteRender.Create
        (LoadAndCenteredSizedSprite(mHGE,ReadString('Main','Icon_Background','')))
    else
      SRIconBack:=nil ;

    TextPos:=ReadPoint('Main','TextPos') ;
    TextWidth:=ReadInteger('Main','TextWidth',600) ;
    Fnt:=THGEFont.Create(ReadString('Main','Font','System.fnt'));

    i:=1 ;
    while (ReadString('Static',Format('Static%d_file',[i]),'')<>'') do begin
      ListStatic.Add(TSpriteRender.Create(
        LoadAndCenteredSizedSprite(mHGE,
        ReadString('Static',Format('Static%d_file',[i]),'')),
        ReadInteger('Static',Format('Static%d_X',[i]),0),
        ReadInteger('Static',Format('Static%d_Y',[i]),0))) ;
      ListStaticNames.Add(ReadString('Static',Format('Static%d_file',[i]),'')) ;
      mHGE.System_Log(Format('load static %d',[i]));
      Inc(i) ;
    end ;

    i:=1 ;
    while (ReadString('Icons',Format('Icon%d_id',[i]),'')<>'') do begin
      SI:=TSceneIcon.Create() ;
      SI.id:=ReadString('Icons',Format('Icon%d_id',[i]),'') ;
      SI.SR:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
        'icons\'+ReadString('Icons',Format('Icon%d_file',[i]),'')),
        ReadInteger('Icons',Format('Icon%d_X',[i]),0),
        ReadInteger('Icons',Format('Icon%d_Y',[i]),0)) ;
      SI.Color:=ReadColor('Icons',Format('Icon%d_Color',[i])) ;
      SI.Visible:=ReadBool('Icons',Format('Icon%d_Visible',[i]),True) ;
      ListIcons.Add(SI) ;
      Inc(i) ;
    end ;

    i:=1 ;
    while (ReadString('Texts',Format('Text%d_icon',[i]),'')<>'') do begin
      ST:=TSceneText.Create() ;
      ST.icon_id:=ReadString('Texts',Format('Text%d_icon',[i]),'') ;
      ST.str:=StringReplace(ReadString('Texts',Format('Text%d_str',[i]),''),'\n',#13,[rfReplaceAll]) ;
      ST.delay:=ReadInteger('Texts',Format('Text%d_delay',[i]),1000) ;
      ST.action:=ReadString('Texts',Format('Text%d_action',[i]),'') ;
      ST.actionparam:=ReadString('Texts',Format('Text%d_actionparam',[i]),'') ;
      ListScenes.Add(ST) ;
      Inc(i) ;
    end ;

    Free ;
  end ;
end ;

procedure TScenePlayer.Update(dt:Single) ;
begin
  tpass:=tpass-dt ;
  if tpass<=0 then GoNextScene() ;
end ;

procedure TScenePlayer.GoNextScene() ;
var i:Integer ;
begin
  Inc(TekScenePoz) ;

  if not IsFinished then begin
    tpass:=TekScene.delay/1000 ;
    if TekScene.str<>'' then tpass:=100 ;
    
    if TekScene.Action='showicon' then begin
      with TStringList.Create() do begin
        CommaText:=TekScene.ActionParam ;
        for i := 0 to Count - 1 do
          GetIconByID(Strings[i]).Visible:=True ;
        Free ;
      end;
    end
    else
    if TekScene.Action='hideicon' then begin
      with TStringList.Create() do begin
        CommaText:=TekScene.ActionParam ;
        for i := 0 to Count - 1 do
          GetIconByID(Strings[i]).Visible:=False ;
        Free ;
      end;
    end
    else
    if TekScene.Action='changeback' then begin
      sprBack:=LoadSizedSprite(mHGE,TekScene.ActionParam) ;
    end
    else
    if TekScene.Action='hidestatic' then begin
      TSpriteRender(ListStatic[StrToInt(TekScene.ActionParam)]).transp:=100 ;
    end;



  end;
end ;

procedure TScenePlayer.Render() ;
var i:Integer ;
begin
  if sprBack<>nil then

  //sprBack.Render(0,0) ;
  sprBack.RenderStretch(0,0,WO.Width,WO.Height);

  for i:=0 to ListIcons.Count-1 do begin
    if not GetIcon(i).Visible then Continue ;

    if SRIconBack<>nil then SRIconBack.RenderAt(GetIcon(i).SR.x,GetIcon(i).SR.y);

    GetIcon(i).SR.Render ;

    if not IsFinished then
      if (GetIcon(i).id=TekScene.icon_id)and(TekScene.str<>'') then
        SRIconTalk.RenderAt(GetIcon(i).SR.x,GetIcon(i).SR.y);
  end;

  for i:=0 to ListStatic.Count-1 do 
    TSpriteRender(ListStatic[i]).Render ;

  if not IsFinished then begin
    fnt.SetColor(GetIconByID(TekScene.icon_id).Color);
    if Trim(TekScene.str)<>'' then
      fnt.PrintFB(TextPos.X-TextWidth/2,TextPos.Y,TextWidth,1000,
        HGETEXT_CENTER,TekScene.str,[]) ;
  end;
end ;

procedure TScenePlayer.StartPlay ;
begin
  TekScenePoz:=-1 ;
  GoNextScene() ;
end ;

function TScenePlayer.TekScene: TSceneText;
begin
  Result:=TSceneText(ListScenes[TekScenePoz]) ;
end;

function TScenePlayer.IsFinished():Boolean ;
begin
  Result:=TekScenePoz>=ListScenes.Count ;
end ;

function TScenePlayer.IsStaticVisible(partname: string): Boolean;
var i:Integer ;
begin
  Result:=False ;
  for i := 0 to ListStaticNames.Count - 1 do
    if Pos(partname,ListStaticNames[i])<>0 then
      if TSpriteRender(ListStatic[i]).transp<100 then begin
        Result:=True ;
        Exit ;
      end;
end;

function TScenePlayer.IsStaticExist(partname:string):Boolean ;
var i:Integer ;
begin
  Result:=False ;
  for i := 0 to ListStaticNames.Count - 1 do
    if Pos(partname,ListStaticNames[i])<>0 then begin
      Result:=True ;
      Exit ;
    end;
end;

end.
