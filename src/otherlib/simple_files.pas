unit simple_files ;

{$ifdef fpc}{$mode objfpc}{$H+}{$endif}

{$ifdef win32}
  {$define winany}
{$else}
  {$ifdef wince}{$define winany}{$endif}
{$endif}

{

   29.06.2009
     - �������� � ������� OnlyPath ��� ��������� �����, 
     ���������� ��� ������ � IIS
   
   21.11.2007
     - ��������� ��������� Linux

   22.09.2007
     - ��������� ������� String2TxtFile
     - ��������� ������� TxtFile2String
   

}



interface

//  ��������� �� ����� ����� � ��������� ���� ��� �����
function OnlyFile (PathAndFile:string):string ;

//  ��������� �� ����� ����� � ��������� ���� � �����
function OnlyPath (PathAndFile:string):string ;

// ��������� �� ����� ����� ������ ��� �����
function NameWithoutExt (filename:string):string ;

// ��������� �� ����� ����� ������ ����������
function NameOnlyExt (filename:string):string ;

//  ���������� ���� � ����������. ��������, "C:\MyProgs\Prog1"
function AppPath:string ;

//  ������� ���������� ������ ���� � �����, ������� ���� � ����������,
//  ���� � ������������� ������. ���, ���� ���� ��� ��� "C:\MyPr\1.txt",
//  �� ������ ��� ���������. � ���� ��� ��� "1.txt", ��� "base\1.txt",
//  �� ������ ��� AppPath+'\'+filename 
function FileNameToAbsolut(filename:string):string ;

//  ������� �������� ��� FileNameToAbsolut, ����� ������, �����
//  �������� ���������� � ����� (192.168.0.1) 
//  ��� UNC-����� (\\host\resource)
//  ������� ��� ��������� ����� � ����� IB/FB/YA
function IBBaseNameToAbsolut(filename:string):string ;

// �������� - ���������� �� ����
function IsFileNameAbsolut(filename:string):Boolean ;

// �������� �� ������ ������� � ����� [34,42,46,47,58,60,62,63,92,124,152]
// ����������� ��� ���������� ������ � �������� ����� � �� ������
// ��������� ��� Win98 (FAT12). ������������ ���������. 
function ConvertNameToDir(name:string):string ;


function GetEnvString(name:string):string ;

{$ifdef winany}
function GetTMPPath:string ;
{$endif}

procedure String2TxtFile(const FileName:string;s:string) ;

function TxtFile2String(const FileName:string):string ;

function BinaryFile2String(const FileName:string):string ;

function String2BinaryFile(const FileName:string; s:string):string ;

function AddExtIfNoSet(filename,ext:string):string ;

{$IFDEF WIN32}
procedure RemoveDirAndContent(path: string);
function FileSizeByName(fileName : wideString) : Int64;
{$ENDIF}

implementation
uses {$ifdef winany} Windows {$else} BaseUnix {$endif} , SysUtils, Classes,
  simple_const ;

{$ifdef win32}
function FileSizeByName(fileName : wideString) : Int64;
var sr : TSearchRec;
begin
  if FindFirst(fileName, faAnyFile, sr ) = 0 then
    Result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
  else
    Result := -1;
  FindClose(sr) ;
end;
{$endif}

function OnlyFile (PathAndFile:string):string ;
var n,Poz,Max:word ;
begin
   Max:=length(PathAndFile) ;
   Poz:=1 ; // �� ������, ���� PathAndFile �� �������� ����
   for n:=1 to Max do
     if PathAndFile[n]=PATH_SEP then Poz:=n+1 ;

   OnlyFile:=copy(PathAndFile,Poz,Max-Poz+1) ;
end ;

function OnlyPath (PathAndFile:string):string ;
var n,Poz,Max:word ;

  function IsPathStart(s:string):Boolean ;
  begin
    Result:=(s[2]=':')and(s[3]=PATH_SEP)and
      (ord(AnsiUpperCase(s[1])[1])>=65)and(ord(AnsiUpperCase(s[1])[1])<=90) ;
  end ;

begin
   Max:=length(PathAndFile) ;
   Poz:=1 ; // �� ������, ���� PathAndFile �� �������� ����
   for n:=1 to Max do
     if PathAndFile[n]=PATH_SEP then Poz:=n+1 ;

   Result:=copy(PathAndFile,1,Poz-1) ;

   {.$ifdef fpc}{.$ifdef winany}
   // �������������� ��������� ��� �������� ��������� �������� ��� ������ � IIS
{   for n:=1 to Length(Result)-2 do
     if IsPathStart(Copy(Result,n,3)) then begin
       Result:=Copy(Result,n,Length(Result)) ;
       Exit ;
     end ;
}   {.$endif}{.$endif}
end ;

function NameWithoutExt (filename:string):string ;
var i:integer ;
begin
  // �� ��������� - ���� ����
  NameWithoutExt:=filename ;
  for i:=length(filename) downto 1 do
    if filename[i]='.' then // ���� �������
      begin
        NameWithoutExt:=Copy(filename,1,i-1) ;
        break ;
      end ;
end ;

function NameOnlyExt (filename:string):string ;
var i:integer ;
begin
  // �� ��������� - ������
  NameOnlyExt:='' ;
  for i:=length(filename) downto 1 do 
    if filename[i]='.' then // ���� �������
      begin
        NameOnlyExt:=Copy(filename,i+1,length(filename)-i+1) ;
        break ;
      end ;
end ;

function AppPath:string ;
var s:string ;
begin
  s:=OnlyPath(ParamStr(0)) ;
  Result:=Copy(s,1,length(s)-1) ;
end ;

function AddExtIfNoSet(filename,ext:string):string ;
begin
  if NameOnlyExt(filename)=ext then Result:=filename else
  Result:=filename+'.'+ext ;
end;

function FileNameToAbsolut(filename:string):string ;
begin
  if IsFileNameAbsolut(filename) then
    Result:=filename
  else
    Result:=AppPath+PATH_SEP+filename ;
end ;

function IBBaseNameToAbsolut(filename:string):string ;
var a:char ;
begin
  FileName:=Trim(filename) ;
  a:=FileName[1] ;
  //  ���� ���������� � �����, �.�. IP ��� UNC-����� (\\host\resource)
  if ((Ord(a)>=48)and(Ord(a)<=57))or(Copy(FileName,1,2)='\\') then
    Result:=FileName
  else
    Result:=FileNameToAbsolut (FileName) ;  
end ;

function IsFileNameAbsolut(filename:string):Boolean ;
begin
  Result:=(FileName[2]=':') ;
  {$ifdef fpc}{$ifdef linux}
  Result:=(FileName[1]=PATH_SEP) ;
  {$endif}{$endif}
end ;

function ConvertNameToDir(name:string):string ;
var Incorrect:set of byte ;
    i:Integer ;
    s:string ;
begin
  Incorrect:=[34,42,46,47,58,60,62,63,92,124,152] ;   
  for i:=1 to length(name) do
    if not(ord(name[i]) in Incorrect) then s:=s+name[i] ;
  Result:=s ;
end ;

function GetEnvString(name:string):string ;
var p:PChar ;
begin
  {$IFDEF FPC}
    {$ifdef Unix}
    Result:=fpGetEnv(Name)
    {$ELSE}
    Result:=GetEnvironmentVariable (name) ;
    {$ENDIF}
  {$ELSE}
  {$IFDEF TURBO_DELPHI}
  Result:=GetEnvironmentVariable(name) ;
  {$ELSE}
  p:=StrAlloc (32867) ;
  GetEnvironmentVariable (Pchar(name),p,32867) ;
  Result:=p ;
  StrDispose(p) ;
  p:=nil ;
  {$ENDIF}
  {$ENDIF}
end ;

{$ifdef winany}
function GetTMPPath:string ;
begin
  Result:=Trim(GetEnvString('TEMP')) ;
  if Result='' then Result:=Trim(GetEnvString('TMP')) ;
  if Result='' then Result:=AppPath ;
end ;

{$endif}

procedure String2TxtFile(const FileName:string;s:string) ;
begin
  with TStringList.Create do begin
    Text:=s ;
    SaveToFile(FileName) ;
    Free ;
  end ;
end ;

function TxtFile2String(const FileName:string):string ;
begin
  if not FileExists(FileName) then Result:='' else
  with TStringList.Create do begin
    LoadFromFile(FileName) ;
    Result:=Text ;
    Free ;
  end ;
end ;

{$IFDEF WIN32}
procedure RemoveDirAndContent(path: string);
var sr: TSearchRec;
begin
  if FindFirst(path + '\*.*', faAnyFile, sr) = 0 then
    repeat
      if sr.Attr and faDirectory = 0 then 
        DeleteFile(path+'\'+sr.name)
      else begin
        if Pos('.', sr.name)<=0 then RemoveDirAndContent(path+'\'+sr.name);
      end;
    until FindNext(sr) <> 0;
  FindClose(sr);
  RemoveDirectory(PChar(path));
end;
{$ENDIF}

function BinaryFile2String(const FileName:string):string ;
var f:file ;
    c:char ;
begin
  Result:='' ;
  AssignFile(f,FileName) ;
  Reset(f,1) ;
  while not eof(f) do begin
    BlockRead(f,c,1) ;
    Result:=Result+c ;
  end ;
  CloseFile(f) ;
end ;

function String2BinaryFile(const FileName:string; s:string):string ;
var f:file ;
    i:Integer ;
begin
  Result:='' ;
  AssignFile(f,FileName) ;
  ReWrite(f,1) ;
  for i:=1 to Length(s) do
    BlockWrite(f,s[i],1) ;
  CloseFile(f) ;
end ;

end.
