unit Player;

interface
uses KeyStrList, IniFiles ;

type
  THardLevel = (hlImmortal, hlNovice, hlCasual, hlStandart) ;

  TPlayer = class
  private
    MaxLevelAvals:TKeyStrList ;
    FIsFirstRun:Boolean ;
    FTwailikorn:Boolean ;
    FFastKeyboard:Boolean ;
    FFastMouse:Boolean ;
    FShowHex:Boolean ;
    FShowHealthInd:Boolean ;
    FNoShowAlertLowRes:Boolean ;
    DemoCompletedMask:Integer ;
    FLastCompany:string ;
    FHardLevel:THardLevel ;
    FMonoTerrain:Boolean ;
    function createIniFile():TIniFile ;
  public
    function IsLevelAval(GameCode:string; LevelN:Integer):Boolean ;
    function GetCompletedCount(GameCode:string):Integer ;
    procedure SetTwailikorn(ATwailikorn:Boolean) ;
    procedure SigLevelCompleted(GameCode:string; LevelN:Integer) ;
    procedure SetFastMouse(AFastMouse:Boolean) ;
    procedure SetFastKeyboard(AFastKeyboard:Boolean) ;
    procedure SetShowHex(AShowHex:Boolean) ;
    procedure SetShowHealthInd(AShowHealthInd:Boolean) ;
    procedure SetNoShowAlertLowRes(ANoShowAlertLowRes:Boolean) ;
    procedure SetLastCompany(ALastCompany:string) ;
    procedure SetHardLevel(AHardLevel:THardLevel) ;
    procedure SetMonoTerrain(AMonoTerrain:Boolean) ;
    function IsFirstRun():Boolean ;
    function IsTwailikorn():Boolean ;
    function IsFastKeyboard():Boolean ;
    function IsFastMouse():Boolean ;
    function IsShowHex():Boolean ;
    function IsShowHealthInd():Boolean ;
    function IsNoShowAlertLowRes():Boolean ;
    function IsPassedDemoCompany():Boolean ;
    function IsMonoTerrain():Boolean ;
    function GetLastCompany():string ;
    function GetHardLevel():THardLevel ;
    procedure SetRunOk() ;
    constructor CreateFromDefaultFile() ;
  end;

implementation
uses Classes, simple_files, PersistentFlags ;

{ TPlayer }

constructor TPlayer.CreateFromDefaultFile();
var List:TStringList ;
    i:Integer ;
begin
  MaxLevelAvals:=TKeyStrList.Create ;

  List:=TStringList.Create ;
  with createIniFile() do begin
    ReadSections(List) ;
    for i := 0 to List.Count - 1 do
      MaxLevelAvals.Value[List[i]]:=ReadInteger(List[i],'MaxLevelAval',1);
    FIsFirstRun:=not ReadBool('Main','FirstRunOk',False) ;
    FTwailikorn:=ReadBool('Main','Twailikorn',False) ;
    FFastMouse:=ReadBool('Main','FastMouse',False) ;
    FFastKeyboard:=ReadBool('Main','FastKeyboard',False) ;
    FShowHex:=ReadBool('Main','ShowHex',True) ;
    FShowHealthInd:=ReadBool('Main','ShowHealthInd',False) ;
    FNoShowAlertLowRes:=ReadBool('Main','NoShowAlertLowRes',False) ;
    DemoCompletedMask:=ReadInteger('DemoCompany','DemoCompletedMask',0) ;
    FLastCompany:=ReadString('Main','LastCompany','company1') ;
    FMonoTerrain:=ReadBool('Main','MonoTerrain',False) ;
    FHardLevel:=THardLevel(ReadInteger('Main','HardLevel',ord(hlCasual))) ;
    Free ;
  end;
  List.Free ;
end;

function TPlayer.createIniFile: TIniFile;
begin
  Result:=TIniFile.Create(AppDataPath()+'\player.ini') ;
end;

function TPlayer.GetCompletedCount(GameCode: string): Integer;
begin
  Result:=MaxLevelAvals.Value[GameCode]-1 ;
  if Result<0 then Result:=0 ;  
end;

function TPlayer.GetHardLevel: THardLevel;
begin
  Result:=FHardLevel ;
end;

function TPlayer.GetLastCompany: string;
begin
  Result:=FLastCompany ;
end;

function TPlayer.IsFastKeyboard: Boolean;
begin
  Result:=FFastKeyboard ;
end;

function TPlayer.IsFastMouse: Boolean;
begin
  Result:=FFastMouse ;
end;

function TPlayer.IsFirstRun: Boolean;
begin
  Result:=FIsFirstRun ;
end;

function TPlayer.IsLevelAval(GameCode:string; LevelN: Integer): Boolean;
var MLevel:Integer ;
begin
  if (GameCode='hardcompany')or(GameCode='usermaps') then begin
    Result:=True ; Exit ;
  end ;

  MLevel:=MaxLevelAvals.Value[GameCode] ;
  if MLevel=0 then MLevel:=1 ;
  if (GameCode='company3')and(LevelN>10) then begin
    if LevelN=11 then Result:=GetPersistentFlags().IsFlag('final_clear') else
    if LevelN=12 then Result:=GetPersistentFlags().IsFlag('final_fuse') else
    if LevelN=13 then Result:=GetPersistentFlags().IsFlag('final_split') else
    Result:=False ;        
  end
  else
    Result:=LevelN<=MLevel ;
end;

function TPlayer.IsMonoTerrain: Boolean;
begin
  Result:=FMonoTerrain ;
end;

function TPlayer.IsPassedDemoCompany: Boolean;
begin
  Result:=(DemoCompletedMask=4+2+1) ;
end;

function TPlayer.IsNoShowAlertLowRes: Boolean;
begin
  Result:=FNoShowAlertLowRes ;
end;

function TPlayer.IsShowHealthInd: Boolean;
begin
  REsult:=FShowHealthInd ;
end;

function TPlayer.IsShowHex: Boolean;
begin
  Result:=FShowHex ;
end;

function TPlayer.IsTwailikorn: Boolean;
begin
  Result:=FTwailikorn ;
end;

procedure TPlayer.SetLastCompany(ALastCompany: string);
begin
  FLastCompany:=ALastCompany ;
  with createIniFile() do begin
    WriteString('Main','LastCompany',ALastCompany) ;
    Free ;
  end;
end;

procedure TPlayer.SetMonoTerrain(AMonoTerrain: Boolean);
begin
  FMonoTerrain:=AMonoTerrain ;
  with createIniFile() do begin
    WriteBool('Main','MonoTerrain',AMonoTerrain) ;
    Free ;
  end;
end;

procedure TPlayer.SetFastKeyboard(AFastKeyboard: Boolean);
begin
  FFastKeyboard:=AFastKeyboard ;
  with createIniFile() do begin
    WriteBool('Main','FastKeyboard',AFastKeyboard) ;
    Free ;
  end;
end;

procedure TPlayer.SetFastMouse(AFastMouse: Boolean);
begin
  FFastMouse:=AFastMouse ;
  with createIniFile() do begin
    WriteBool('Main','FastMouse',AFastMouse) ;
    Free ;
  end;
end;

procedure TPlayer.SetHardLevel(AHardLevel: THardLevel);
begin
  FHardLevel:=AHardLevel ;
  with createIniFile() do begin
    WriteInteger('Main','HardLevel',ord(AHardLevel)) ;
    Free ;
  end;
end;

procedure TPlayer.SetNoShowAlertLowRes(ANoShowAlertLowRes: Boolean);
begin
  FNoShowAlertLowRes:=ANoShowAlertLowRes ;
  with createIniFile() do begin
    WriteBool('Main','NoShowAlertLowRes',ANoShowAlertLowRes) ;
    Free ;
  end;
end;

procedure TPlayer.SetRunOk;
begin
  with createIniFile() do begin
    WriteBool('Main','FirstRunOk',True) ;
    Free ;
  end;
end;

procedure TPlayer.SetShowHealthInd(AShowHealthInd: Boolean);
begin
  FShowHealthInd:=AShowHealthInd ;
  with createIniFile() do begin
    WriteBool('Main','ShowHealthInd',AShowHealthInd) ;
    Free ;
  end;
end;

procedure TPlayer.SetShowHex(AShowHex: Boolean);
begin
  FShowHex:=AShowHex ;
  with createIniFile() do begin
    WriteBool('Main','ShowHex',AShowHex) ;
    Free ;
  end;
end;

procedure TPlayer.SetTwailikorn(ATwailikorn: Boolean);
begin
  FTwailikorn:=ATwailikorn ;
  with createIniFile() do begin
    WriteBool('Main','Twailikorn',ATwailikorn) ;
    Free ;
  end;
end;

procedure TPlayer.SigLevelCompleted(GameCode:string; LevelN: Integer);
begin
  if MaxLevelAvals.Value[GameCode]<LevelN+1 then begin
    MaxLevelAvals.Value[GameCode]:=LevelN+1 ;

    // Жесткий патч для второй кампании - чтобы открыть карту за бонусной
    if (GameCode='company2')and(LevelN=12) then
      MaxLevelAvals.Value[GameCode]:=LevelN+2 ;
    // Жесткий патч для третьей кампании - чтобы открыть карту за бонусной
    if (GameCode='company3')and(LevelN=4) then
      MaxLevelAvals.Value[GameCode]:=LevelN+2 ;

    with createIniFile() do begin
      WriteInteger(GameCode,'MaxLevelAval',MaxLevelAvals.Value[GameCode]);
      Free ;
    end;
  end;

  if GameCode='democompany' then begin
    DemoCompletedMask:=DemoCompletedMask or (1 shl (LevelN-1)) ;
    with createIniFile() do begin
      WriteInteger('democompany','DemoCompletedMask',DemoCompletedMask);
      Free ;
    end;
  end;

end;

end.
