unit Config ;

interface
uses Classes, AutoCreatedSubList ;

type
  TConfig = class(TACStringList)
  private
    ActiveClass:string ;
    procedure AppendFromFile(FileName:string) ;
  public
    function AsInteger(Name:string):Integer ;
    function AsBoolean(Name:string):Boolean ;
    function AsPercent(Name:string):Single ;
    function AsString(Name:string):string ; overload ;
    function AsString(Name:string; Default:string):string ; overload ; 
  end ;

function GConfig(Caller:TObject):TConfig ; overload ;
function GConfig(ClassName:string):TConfig ; overload ;
procedure InitGConfig(MapFile:string) ;

implementation
uses simple_oper, simple_files, IniFiles, SysUtils ;

var
  FConfig:TConfig ;

function GConfig(Caller:TObject):TConfig ;
begin
  Result:=GConfig(Caller.ClassName) ;
end ;

function GConfig(ClassName:string):TConfig ;
begin
  FConfig.ActiveClass:=ClassName ;
  Result:=FConfig ;
end ;

procedure InitGConfig(MapFile:string) ;
begin
  if FConfig<>nil then FConfig.Free ;

  FConfig:=TConfig.Create ;
  FConfig.AppendFromFile(AppPath+'\..\configs\constants.ini') ;
  if DirectoryExists(MapFile+'.data') then
    FConfig.AppendFromFile(MapFile+'.data\configs\constants.ini') ;
end;

procedure TConfig.AppendFromFile(FileName:string) ;
var Ini:TIniFile ;
    Sects,Values:TStringList ;
    i,j:Integer ;
begin
  Sects:=TStringList.Create ;
  Ini:=TIniFile.Create(FileName) ;
  Ini.ReadSections(Sects) ;
  for i:=0 to Sects.Count-1 do begin
    Values:=TStringList.Create ;
    Ini.ReadSection(Sects[i],Values) ;
    for j := 0 to Values.Count - 1 do
      List.Values[Sects[i]+'@'+Values[j]]:=Ini.ReadString(Sects[i],Values[j],'') ;
    Values.Free ;
  end ;
  Ini.Free ;
  Sects.Free ;
end ;

function TConfig.AsInteger(Name:string):Integer ;
begin
  Result:=StrToIntWt0(AsString(Name)) ;
end ;

function TConfig.AsBoolean(Name:string):Boolean ;
begin
  Result:=(AsString(Name)='true')or(AsString(Name)='1') ;
end ;

function TConfig.AsPercent(Name: string): Single;
begin
  Result:=AsInteger(Name)/100 ;
end;

function TConfig.AsString(Name:string):string ;
var PName:string ;
begin
  PName:=ActiveClass+'@'+Name ;
  //if List.IndexOfName(PName)=-1 then
  //  raise Exception.Create('Не найден параметр конфига: '+PName) ;

  Result:=List.Values[PName] ;
end ;

function TConfig.AsString(Name:string; Default:string):string ;
var PName:string ;
begin
  PName:=ActiveClass+'@'+Name ;
  if List.IndexOfName(PName)=-1 then
    Result:=Default
  else
    Result:=List.Values[PName] ;
end ;

end.