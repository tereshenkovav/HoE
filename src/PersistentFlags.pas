unit PersistentFlags;

interface
uses AutoCreatedSubList ;

type
  TPersistentFlags = class(TACStringList)
  private
    function getStoreFile():string ;
  public
    constructor Create() ;
    procedure SetFlag(FlagName:string) ;
    function IsFlag(FlagName:string):Boolean ;
    procedure SetVar(VarName:string; VarValue:string) ;
    function GetVar(VarName:string):string ;    
  end;

function GetPersistentFlags():TPersistentFlags ;

implementation
uses simple_files, IniFiles, SysUtils, Classes ;

var
  PF:TPersistentFlags = nil ;

function GetPersistentFlags():TPersistentFlags ;
var List:TStringList ;
    i:Integer ;
begin
  if PF=nil then begin
    PF:=TPersistentFlags.Create() ;
    {
    List:=TStringList.Create ;
    with TIniFile.Create(AppPath+'\player.ini') do begin
      ReadSection('PersistentFlags',List) ;
      for i := 0 to List.Count - 1 do
        PF.List.Add(List[i]) ;
      ReadSection('PersistentVars',List) ;
      for i := 0 to List.Count - 1 do
        PF.List.Add(List[i]) ;
      Free ;
    end;
    List.Free ;
    }
  end;
  Result:=PF ;
end;

{ TPersistentFlags }

constructor TPersistentFlags.Create();
begin
  inherited Create() ;
  if FileExists(getStoreFile()) then List.LoadFromFile(getStoreFile()) ;
end;

function TPersistentFlags.getStoreFile: string;
begin
  Result:=AppDataPath()+'\flags.store' ;
end;

function TPersistentFlags.GetVar(VarName: string): string;
begin
  Result:=List.Values[AnsiLowerCase(VarName)] ;
end;

function TPersistentFlags.IsFlag(FlagName: string): Boolean;
begin
  Result:=List.IndexOf(AnsiLowerCase(FlagName))<>-1 ;
end;

procedure TPersistentFlags.SetFlag(FlagName: string);
var i:Integer ;
begin
  if List.IndexOf(FlagName)=-1 then List.Add(FlagName) ;
 { with TIniFile.Create(AppPath+'\player.ini') do begin
    EraseSection('PersistentFlags') ;
    for i := 0 to List.Count - 1 do
      if Pos('=',List[i])=-1 then
        WriteString('PersistentFlags',List[i],'1') ;
    Free ;
  end;
  }
  List.SaveToFile(getStoreFile()) ;
end;

procedure TPersistentFlags.SetVar(VarName, VarValue: string);
var i:Integer ;
begin
  if List.IndexOfName(VarName)=-1 then
    List.Add(VarName+'='+VarValue)
  else
    List.Values[VarName]:=VarValue ;
  {with TIniFile.Create(AppPath+'\player.ini') do begin
    EraseSection('PersistentVars') ;
    for i := 0 to List.Count - 1 do
      if Pos('=',List[i])<>-1 then
        WriteString('PersistentVars',List.Names[i],List.ValueFromIndex[i]) ;
    Free ;
  end;
  }
  List.SaveToFile(getStoreFile()) ;
end;

end.
