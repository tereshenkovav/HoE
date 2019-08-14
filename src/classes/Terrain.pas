unit Terrain ;

interface
uses AutoCreatedSubList ;

type
  TTerrain = class
  private
    FCharCode:char ;
    FStepNeed:Integer ;
    FCaption:string ;
    FName:string ;
    FExtraDefence:Integer ;
    FUseSubLayer:Boolean ;
    FColor:Cardinal ;
    FAllowBuild:Boolean ;
    FIsWater:Boolean ;
    FOnlyFlyers:Boolean ;
    FInfo:string ;
  public
    constructor Create() ;
    function intGetStepNeed():Integer ;
    function GetExtraDefence():Integer ;
    property Caption:string read FCaption ;
    property Name:string read FName ;
    property UseSubLayer:Boolean read FUseSubLayer ;
    property CharCode:char read FCharCode ;
    property Color:Cardinal read FColor ;
    property AllowBuild:Boolean read FAllowBuild;
    property IsWater:Boolean read FIsWater ;
    property OnlyFlyers:Boolean read FOnlyFlyers ;
    property Info:string read FInfo ;
  end ;

  TTerrainList = class(TACObjectList)
  private
    procedure Add(T:TTerrain) ;
  public
    function GetByCodeChar(ch:char):TTerrain ;
    function GetByName(AName:string):TTerrain ;
    function Count():Integer ;
    function GetTerr(i:Integer):TTerrain ;
    procedure Clear() ;
  end;

procedure LoadTerrains(MapFile:string) ;
function Terrains():TTerrainList ;

implementation
uses IniFiles, Classes, SysUtils, CommonClasses, CommonProc, simple_files ;

const
  DEFAULT_STEPNEED = 1 ;
  DEFAULT_EXTRADEFENCE = 0 ;

var
  GTerrList:TTerrainList ;

procedure AddTerrainsFile(filename:string) ;
var T:TTerrain ;
    List:TStringList ;
    i:Integer ;
begin
  if not FileExists(filename) then Exit ;

  with TIniFileEx.Create(filename) do begin
    List:=TStringList.Create ;
    ReadSections(List) ;
    for i := 0 to List.Count - 1 do begin
      if List[i][1]='-' then Continue ;

      T:=TTerrain.Create() ;
      T.FCharCode:=ReadString(List[i],'Char',#32)[1] ;
      T.FName:=List[i] ;
      T.FCaption:=ReadString(List[i],'Caption','') ;
      T.FStepNeed:=ReadInteger(List[i],'StepNeed',DEFAULT_STEPNEED) ;
      if T.FStepNeed<=0 then T.FStepNeed:=DEFAULT_STEPNEED ;
      T.FExtraDefence:=ReadInteger(List[i],'Speed',DEFAULT_EXTRADEFENCE) ;
      T.FUseSubLayer:=ReadBool(List[i],'UseSubLayer',false) ;
      T.FColor:=ReadColor(List[i],'Color') ;
      T.FAllowBuild:=ReadBool(List[i],'AllowBuild',false) ;
      T.FIsWater:=ReadBool(List[i],'IsWater',false) ;
      T.FOnlyFlyers:=ReadBool(List[i],'OnlyFlyers',false) ;
      T.FInfo:=ReadString(List[i],'Info','') ;

      GTerrList.Add(T);
    end;
    List.Free ;
    Free ;
  end;
end;

procedure AddEmptyTerrain();
var T:TTerrain ;
begin
  T:=TTerrain.Create() ;
  T.FCharCode:='@' ;
  T.FName:='Space' ;
  T.FCaption:='Space' ;
  T.FStepNeed:=10 ;
  T.FExtraDefence:=DEFAULT_EXTRADEFENCE ;
  T.FUseSubLayer:=False ;
  T.FColor:=ColorStr2Int('000000') ;
  T.FAllowBuild:=false ;
  GTerrList.Add(T);
end;

procedure LoadTerrains(MapFile:string) ;
begin
  if GTerrList=nil then
    GTerrList:=TTerrainList.Create
  else
    GTerrList.Clear() ;

  AddTerrainsFile(AppPath+'\..\configs\terrains.ini') ;
  AddEmptyTerrain() ;  
  AddTerrainsFile(MapFile+'.data\configs\terrains.ini') ;
end;

function Terrains():TTerrainList ;
var T:TTerrain ;
    List:TStringList ;
    i:Integer ;
begin
  if GTerrList=nil then begin
    GTerrList:=TTerrainList.Create ;
    AddTerrainsFile(AppPath+'\..\configs\terrains.ini') ;
    AddEmptyTerrain() ;
  end;
  Result:=GTerrList ;
end;

{ TTerrain }

constructor TTerrain.Create;
begin
  FStepNeed:=DEFAULT_STEPNEED ;
  FExtraDefence:=DEFAULT_EXTRADEFENCE ;
  FCaption:='Unknkown' ;
  FUseSubLayer:=False ;
end;

function TTerrain.GetExtraDefence: Integer;
begin  Result:=FExtraDefence ; end;

function TTerrain.intGetStepNeed: Integer;
begin  Result:=FStepNeed ; end;

{ TTerrainList }

procedure TTerrainList.Add(T: TTerrain);
begin
  List.Add(T) ;
end;

procedure TTerrainList.Clear;
begin
  List.Clear() ;
end;

function TTerrainList.Count: Integer;
begin  Result:=List.Count ; end;

function TTerrainList.GetByCodeChar(ch: char): TTerrain;
var i:Integer ;
begin
  Result:=nil ;
  for i := 0 to List.Count - 1 do
    if GetTerr(i).CharCode=ch then begin
      Result:=GetTerr(i) ;
      Break ;
    end;
end;

function TTerrainList.GetByName(AName: string): TTerrain;
var i:Integer ;
begin
  Result:=nil ;
  for i := 0 to List.Count - 1 do
    if GetTerr(i).Name=AName then begin
      Result:=GetTerr(i) ;
      Break ;
    end;
end;

function TTerrainList.GetTerr(i: Integer): TTerrain;
begin
  Result:=TTerrain(List[i]) ;
end;

end.