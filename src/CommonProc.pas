unit CommonProc;

interface
uses Classes, HGESprite ;

type
  TLevelInfo = class
  public
    LevelName:string ;
    LevelDescr:string ;
    IsNoNumber:Boolean ;
    IsNoMap:Boolean ;
  end;

procedure LoadGameResourcesCommon(code:string) ;
procedure UnLoadGameResourcesCommon() ;
function GetGameCodesList():TStringList ;
function GetLevelCountByGame(Code:string):Integer ;
function DemoLevelExist(Code:string):Boolean ;
function GetLevelFileName(Code:string; LevelN:Integer):string ;
procedure GoAutoGame(Level:Integer) ;
function GetLevelInfoByCodeAndN(Code:string; LevelN:Integer):TLevelInfo ;
function ConvertLongString(str:string):string ;
function ColorStr2Int(str:string):Cardinal ;
function Gradient (c1,c2:Cardinal;pos:real):Cardinal ;

procedure SetResultMsg(str:string) ;
procedure AddToResultMsh(str:string) ;
function GetResultMsg():string ;

procedure MakeMicroTerr(Spr:IHGESprite; dir:Integer) ;
procedure MakeMicroTerrBorder(Spr:IHGESprite; borderdir:Integer) ;

function UseFollowingCamera():Boolean ;

procedure MakeGradientTranspByHalf(Spr:IHGESprite) ;

function IsLowResolution():Boolean ;

implementation
uses SysUtils, ObjModule, TAVHGEUtils, SpriteEffects,
  FFGame, simple_oper, FFScenePlayer, simple_files,
  TexturePainter, Windows, BFLoader, AniManager, FFMenu, FFConfirm,
  HGE, Player, UnitFileSys ;

var GCList:TStringList ;
    LCList:TStringList ;
    //LNList:TStringList ;
    //LDList:TStringList ;
    LInfoList:TStringList ;

    ResultMsg:string ;

function Gradient (c1,c2:Cardinal;pos:real):Cardinal ;
var r1,g1,b1,r2,g2,b2,older:byte ;
    rw,gw,bw:word ;
begin
  asm
     mov eax,c1
     mov r1,al
     shr eax,8
     mov g1,al
     shr eax,8
     mov b1,al
     shr eax,8
     mov older,al

     mov eax,c2
     mov r2,al
     shr eax,8
     mov g2,al
     shr eax,8
     mov b2,al
  end ;

  rw:=r1+round((r2-r1)*pos) ;
  gw:=g1+round((g2-g1)*pos) ;
  bw:=b1+round((b2-b1)*pos) ;

  if rw>255 then r1:=255 else r1:=rw ;
  if gw>255 then g1:=255 else g1:=gw ;
  if bw>255 then b1:=255 else b1:=bw ;
   
  asm
    mov eax,0
    mov al,older
    shl eax,8
    mov al,b1
    shl eax,8
    mov al,g1
    shl eax,8
    mov al,r1
    mov @Result,eax
  end ;

end ;

function ColorStr2Int(str:string):Cardinal ;
var s:string ;
begin
  s:=HexToStr(str) ;

  if Length(s)=3 then
    Result:=$FF000000+(ord(s[1]) shl 16) + (ord(s[2]) shl 8) + ord(s[3])
  else
    Result:=(ord(s[1]) shl 32)+(ord(s[2]) shl 16) + (ord(s[3]) shl 8) + ord(s[4]) ;
end;

procedure SetResultMsg(str:string) ;
begin
  ResultMsg:=str ;
end;

procedure AddToResultMsh(str:string) ;
begin
  ResultMsg:=ResultMsg+#13+str ;
end;

function GetResultMsg():string ;
begin
  Result:=ResultMsg ;
end;

function ConvertLongString(str:string):string ;
begin
  Result:=StringReplace(str,'\n',#13,[rfReplaceAll]) ;
end;

function GetLevelFileName(Code:string; LevelN:Integer):string ;
var files:TStringList ;
    isok:Boolean ;
begin
  if Code='usermaps' then begin
    files:=CreateFilesList('..\usermaps','*',isok) ;
    if LevelN>files.Count then
      Result:='..\usermaps\8fsdg7fsf76c7zsa'
    else
      Result:='..\usermaps\'+files[LevelN-1] ;
    files.Free ;
  end
  else begin
    if LevelN<>-1 then
      Result:=Format('..\maps\'+Code+'_level%d',[LevelN])
    else
      Result:='..\maps\'+Code+'_demolevel'
  end ;
end ;

procedure NoProc() ;
begin

end;

var OkLevelN:Integer ;

procedure OkLevel() ;
begin
  PL.SetHardLevel(hlNovice);
  GoAutoGame(OkLevelN) ;
end ;

procedure GoAutoGame(Level:Integer) ;
var proc:TProcAfterScene ;
begin
  if (ObjModule.PL.GetHardLevel()=hlImmortal) and not(
     (CurrentGameCode='democompany') or
     ((CurrentGameCode='company1') and (Level<=7))
     ) then begin
       OkLevelN:=Level ;
       execConfirmMsg('Режим бессмертия доступен только на учебных картах '+
        'и первых семи картах первой кампании. Отключить режим бессмертия?',
        mHGE.System_GetState(HGE_FRAMEFUNC) ,OkLevel) ;
       Exit ;
     end;

  if GetLevelInfoByCodeAndN(CurrentGameCode,Level).IsNoMap then
    proc:=FFMenu.GoMenu
  else
    proc:=FFGame.GoGameAutoLevel ;

//  if CurrentGameCode=COMPANY_1 then begin
    //GoGameLevel(Level) ;
    FFGame.SetGameLevel(Level) ; //GoGameLevel(Level) ;

    if CurrentGameCode='usermaps' then begin
      proc() ;
      Exit ;
    end ;   

    if Level=-1 then
    FFScenePlayer.DoPlayScenes([CurrentGameCode+
      '_demolevel'],proc)
    else
    FFScenePlayer.DoPlayScenes([CurrentGameCode+
      '_scene'+IntToStr(Level)],proc);
    //proc() ;
//  end ;
end;

function DemoLevelExist(Code:string):Boolean ;
begin
  if Code='usermaps' then Result:=False else
  Result:=FileExists(GetLevelFileName(Code,-1))
end;

function GetLevelCountByGame(Code:string):Integer ;
var idx,R:Integer ;
begin
  if LCList=nil then LCList:=TStringList.Create ;

  if LCList.IndexOfName(Code)=-1 then begin
    R:=0 ;
    while FileExists(GetLevelFileName(Code,R+1)) do Inc(R) ;
    idx:=LCList.Add(Format('%s=%d',[Code,R])) ;
   // mHGE.System_Log('levelcount='+IntToStr(R));
  end ;
  Result:=StrToIntWt0(LCList.Values[Code]) ;
end;

function CreateLevelInfo(filename:string):TLevelInfo ;
var bfl:TBFLoader ;
begin
  Result:=TLevelInfo.Create() ;
  Result.LevelName:='Unknown' ;
  Result.LevelDescr:='Unknown' ;
  Result.IsNoNumber:=False ;
  Result.IsNoMap:=False ;

  if FileExists(filename) then begin
    with TStringList.Create() do begin
      LoadFromFile(filename) ;
      if Count>0 then Result.LevelName:=Strings[0] else Result.LevelName:='' ;
      Free ;
    end ;
    bfl:=TBFLoader.Create ;
    bfl.CreateMapDescription(filename,Result.LevelDescr,Result.IsNoNumber,Result.IsNoMap) ;
    bfl.Free ;
  end ;
end;

function GetLevelInfoByCodeAndN(Code:string; LevelN:Integer):TLevelInfo ;
var name:string ;
    idx:Integer ;
begin
  if LInfoList=nil then LInfoList:=TStringList.Create ;

  name:=Format('%s_%d',[Code,Leveln]) ;
  idx:=LInfoList.IndexOf(name) ;
  if idx=-1 then
    idx:=LInfoList.AddObject(name,CreateLevelInfo(GetLevelFileName(Code,LevelN))) ;
  Result:=TLevelInfo(LInfoList.Objects[idx]) ;
end;

function GetGameCodesList():TStringList ;
begin
  if GCList=nil then begin
    GCList:=TStringList.Create ;
    GCList.Add(COMPANY_1) ;
    GCList.Add(COMPANY_2) ;
    GCList.Add(COMPANY_3) ;
    GCList.Add(DEMO_COMPANY) ;
    GCList.Add(HARD_COMPANY) ;
    GCList.Add(FUN_COMPANY) ;

  end;
  Result:=GCList ;
end;

procedure LoadGameResourcesCommon(code:string) ;
var i:Integer ;
begin
  SRWin:=TSpriteRender.Create(LoadSizedSprite(mHGE,'victory.png'));
  SRFinalWin:=TSpriteRender.Create(LoadSizedSprite(mHGE,'victory.png'));
  SRFail:=TSpriteRender.Create(LoadSizedSprite(mHGE,'defeat.png'));

  SRMessageListBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,'messagelist_back.png')); ;

//  SndWin:=LoadSound('win.mp3') ;
//  SndWin.SetVolume(0.5);

  SRButBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
     'icon_Return.png')) ;

  SRButMenu:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    Format('but_break.png',[code])));
  SRButReplay:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    Format('but_replay.png',[code])));
  SRButNext:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    Format('but_next.png',[code])));

  SRButUp:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    Format('but_up.png',[code])));
  SRButDown:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    Format('but_down.png',[code])));

  SR_BackStudy:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'background_Study.png'));
  SR_BackCampain:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'background_BookOfCampaing.png'));
  SR_BackLegends:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'background_Legends.png'));
  SR_Pointer:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'Pointer.png'));

  SR_Campain1:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'Icon_Campaing1.png'));
  SR_Campain2:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'Icon_Campaing2.png'));
  SR_Campain3:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'Icon_Campaing3.png'));

  SR_BackLegendDescription:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'Back_LegendDescription.png'));

  SRLoadingFrame:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'loading_frame.png'));
  SRLoadingText:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'loading_text.png'));
  SRLoadingPony:=TAniManager.OnlyCreateSprite(PathLoader+'loading_pony.png',8,8,0,0,30,30,-1,-1,LoadingPonyAnim) ;
  SRLoadingProgress:=TAniManager.OnlyCreateSprite(PathLoader+'loading_progress.png',11,11,0,0,46,46,-1,-1,LoadingPonyProgress) ;
  
end ;

procedure UnLoadGameResourcesCommon() ;
var i:Integer ;
begin
  SRWin.Free ;
  SRFail.Free ;
  SRFinalWin.Free ;
  SRButBack.Free ;
//  SndWin.Free ;
  SRButMenu.Free ;
  SRButReplay.Free ;
  SRButNext.Free ;
end;

procedure MakeMicroTerr(Spr:IHGESprite; dir:Integer) ;
var x,y:Integer ;

function f5(y_:Integer):Integer ;
begin
  Result:=20-Round((2/3)*y_) ;
end ;

function f1(y_,w_:Integer):Integer ;
begin
  Result:=w_-20+Round((2/3)*y_) ;
end ;

function f2(y_,w_,h_:Integer):Integer ;
begin
  Result:=20+Round(h_+5)-Round((2/3)*(y_)) ;
end ;

function f4(y_,w_,h_:Integer):Integer ;
begin
  Result:=w_-20-Round(h_+5)+Round((2/3)*(y_)) ;
end ;

begin

  with TTexturePainter.Create(Spr.GetTexture,False) do begin
    if dir=0 then
      for y := 4 to Height-1 do
        for x := 0 to Width-1 do
          Alpha[x,y]:=$00 ;
    if dir=1 then
      for y := 0 to Height-1 do
        for x := 0 to f1(y,Width) do
          if x<Width then
            Alpha[x,y]:=$00 ;
    if dir=2 then
      for y := 0 to Height-1 do
        for x := 0 to f2(y,Width,Height) do
          if x<Width then
            Alpha[x,y]:=$00 ;
    if dir=3 then
      for y := 0 to Height-6 do
        for x := 0 to Width-1 do
          Alpha[x,y]:=$00 ;
    if dir=4 then
      for y := 0 to Height-1 do
        for x := f4(y,Width,Height) to Width-1 do
          if x>=0 then
            Alpha[x,y]:=$00 ;
    if dir=5 then
      for y := 0 to Height-1 do
        for x := f5(y) to Width-1 do
          if x>=0 then
            Alpha[x,y]:=$00 ;
   
    Free ;
  end;
  
end;

procedure MakeMicroTerrBorder(Spr:IHGESprite; borderdir:Integer) ;
var x,y:Integer ;

function yby12(x1,y1,x2,y2:Integer; x:Integer):Integer ;
var a:Single ;
begin
  a:=(y1-y2)/(x1-x2) ;
  Result:=Round((y1-x1*a)+a*x) ;
end ;

function ylefttop(x:Integer):Integer ;
begin
  Result:=yby12(0,20,39,26,x) ;
  if x>20 then Dec(Result,(x-20) div 3) ;
end ;

function yleftbot(x:Integer):Integer ;
begin
  Result:=yby12(0,76,39,70,x) ;
  if x>20 then Inc(Result,(x-20) div 3) ;
end ;

function yrighttop(x:Integer):Integer ;
begin
  Result:=yby12(79,20,39,26,x) ;
  if x<60 then Dec(Result,(60-x) div 3) ;
end ;

function yrightbot(x:Integer):Integer ;
begin
  Result:=yby12(79,76,39,70,x) ;
  if x<60 then Inc(Result,(60-x) div 3) ;
end ;

begin
  
  with TTexturePainter.Create(Spr.GetTexture,False) do begin
    if borderdir=1 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y<77)or(x>(Width div 2+(Height-y) div 4)) then Alpha[x,y]:=$00 ;
    if borderdir=2 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y<77)or(x<=(Width div 2+(Height-y) div 4)) then Alpha[x,y]:=$00 ;

    if borderdir=3 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y>yrighttop(x))or(x<Width div 2) then Alpha[x,y]:=$00 ;
    if borderdir=4 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y<=yrighttop(x))or(y>=yrightbot(x))or(x<Width div 2) then Alpha[x,y]:=$00 ;
    if borderdir=5 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y<yrightbot(x))or(x<Width div 2) then Alpha[x,y]:=$00 ;

    if borderdir=6 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y>20)or(x>Width div 2 + y div 4) then Alpha[x,y]:=$00 ;
    if borderdir=7 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y>20)or(x<=Width div 2 + y div 4) then Alpha[x,y]:=$00 ;

    if borderdir=8 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y>ylefttop(x))or(x>=Width div 2) then Alpha[x,y]:=$00 ;
    if borderdir=9 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y<=ylefttop(x))or(y>=yleftbot(x))or(x>=Width div 2) then Alpha[x,y]:=$00 ;
    if borderdir=10 then
      for y := 0 to Height-1 do
        for x := 0 to Width-1 do
          if (y<yleftbot(x))or(x>=Width div 2) then Alpha[x,y]:=$00 ;

    Free ;
  end;

end;

procedure MakeGradientTranspByHalf(Spr:IHGESprite) ;
var x,y,h0:Integer ;
    a:Integer ;
begin
try

  with TTexturePainter.Create(Spr.GetTexture,False) do begin
    h0:=Height div 2 ;
    for y := 0 to Height-1 do
      for x := 0 to Width-1 do
        if (y>=h0) then
          if Alpha[x,y]>$20 then begin
            a:=Round($80*(1-2*(y-h0)/h0)) ;
            if a<$00 then a:=$00 ;
            Alpha[x,y]:=a ;
          end;
    Free ;
  end ;
  
except
  on E:Exception do
    MessageBox(0,Pchar(E.Message),Pchar('Ошибка!'),MB_OK) ;
end;
end;

function UseFollowingCamera():Boolean ;
begin
  Result:=False ;
end;

function IsLowResolution():Boolean ;
var screen_rect:TRect;
begin
  if GetWindowRect(GetDesktopWindow(),&screen_rect) then
    Result:=(screen_rect.Right<SWindowOptions.Width)or
      (screen_rect.Bottom<SWindowOptions.Height+50) 
  else
    Result:=False ;
end ;

end.
