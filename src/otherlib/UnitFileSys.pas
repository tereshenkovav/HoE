unit UnitFileSys;

{$IFDEF FPC}
 {$mode delphi}
{$ENDIF}


interface

uses Classes,Windows ;

procedure GetFilesList (List,Attr:TStringList; Path,Mask:string; var AllOk:boolean) ;
function CreateFilesList (Path,Mask:string; var AllOk:boolean):TStringList ;
function CreateDirsList (Path,Mask:string; var AllOk:boolean):TStringList ;
procedure GetDirsList (List,Attr:TStringList; Path,Mask:string; var AllOk:boolean) ;
function pchartostr (p:PChar):string ;
function TestAttr (Attribute,Tip:Cardinal):boolean ;

implementation

function CreateFilesList (Path,Mask:string; var AllOk:boolean):TStringList ;
var ListAttr:TStringList ;
begin
  ListAttr:=TStringList.Create() ;
  Result:=TStringList.Create ;
  GetFilesList(Result,ListAttr,Path,Mask,AllOk) ;
  ListAttr.Free ;
end ;

function CreateDirsList (Path,Mask:string; var AllOk:boolean):TStringList ;
var ListAttr:TStringList ;
begin
  ListAttr:=TStringList.Create() ;
  Result:=TStringList.Create ;
  GetDirsList(Result,ListAttr,Path,Mask,AllOk) ;
  ListAttr.Free ;
end ;

procedure GetFilesList (List,Attr:TStringList; Path,Mask:string; var AllOk:boolean) ;
var handle:THandle ;
    FindData:WIN32_FIND_DATA ;
    i:byte ;
    s,stroka:string ;
    Success:LongBool ;
    FilesOver:boolean ;
begin
  List.Clear ;
  if Attr<>nil then Attr.Clear ;

  handle:=FindFirstFile (PChar(Path+'\'+Mask),FindData) ;
  if handle=INVALID_HANDLE_VALUE then
   begin
    AllOk:=FALSE ;
    exit ;
   end
   else
    AllOk:=TRUE ;

  if not(TestAttr(FindData.dwFileAttributes,FILE_ATTRIBUTE_DIRECTORY)) then
   begin
    List.Add (pchartostr(FindData.cFileName)) ;
    str (FindData.dwFileAttributes,s) ;
    if Attr<>nil then Attr.Add (s) ;
   end ;

  FilesOver:=False ;
  while not(FilesOver) do
  begin
    Success:=FindNextFile (handle,FindData) ;
    if Success then
     begin
       if not(TestAttr(FindData.dwFileAttributes,FILE_ATTRIBUTE_DIRECTORY)) then
        begin
         List.Add (pchartostr(FindData.cFileName)) ;
         str (FindData.dwFileAttributes,s) ;
         if Attr<>nil then Attr.Add (s) ;
        end ;
     end
     else
      if GetLastError=ERROR_NO_MORE_FILES then FilesOver:=TRUE ;
  end ;

//  FindClose(handle) ;

end ;

procedure GetDirsList (List,Attr:TStringList; Path,Mask:string; var AllOk:boolean) ;
var handle:THandle ;
    FindData:WIN32_FIND_DATA ;
    i:byte ;
    s,stroka:string ;
    Success:LongBool ;
    FilesOver:boolean ;
begin
  List.Clear ;
  Attr.Clear ;

  handle:=FindFirstFile (pchar(Path+'\'+Mask),FindData) ;
  if handle=INVALID_HANDLE_VALUE then
   begin
    AllOk:=FALSE ;
    exit ;
   end
   else
    AllOk:=TRUE ;

  if TestAttr(FindData.dwFileAttributes,FILE_ATTRIBUTE_DIRECTORY) then
   begin
    List.Add (pchartostr(FindData.cFileName)) ;
    str (FindData.dwFileAttributes,s) ;
    Attr.Add (s) ;
   end ;

  FilesOver:=False ;
  while not(FilesOver) do
  begin
    Success:=FindNextFile (handle,FindData) ;
    if Success then
     begin
      if TestAttr(FindData.dwFileAttributes,FILE_ATTRIBUTE_DIRECTORY) then
       begin
        List.Add (pchartostr(FindData.cFileName)) ;
        str (FindData.dwFileAttributes,s) ;
        Attr.Add (s) ;
       end ; 
     end
     else
      if GetLastError=ERROR_NO_MORE_FILES then FilesOver:=TRUE ;
  end ;

  FindClose(handle) ;

end ;

function pchartostr (p:PChar):string ;
var stroka:string ;
    i:byte ;
begin
  i:=0 ;
  stroka:='' ;
  while p[i]<>chr(0) do begin stroka:=stroka+p[i] ; inc(i) ; end ;
  pchartostr:=stroka ;
end ;

function TestAttr (Attribute,Tip:Cardinal):boolean ;
begin
  TestAttr:=(Tip=(Attribute and Tip)) ;
end ;
end.
