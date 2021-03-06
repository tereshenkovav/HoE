unit TAVStrUtils;

{
   ������� ���������:

     2010.01.14
       - function MyAnsiLowerCase(const s:string):string ;

     2009.09.25
       - function MyUTF8toCP1251(s:string):string ;

     2009.09.20
       - function GetPhoneFromStr(s:string):string ;
       - function StripExceptDigits(s:string):string ;

     2008.10.11
       - ��������� ������� SmartCompareStrings

     2008.06.25
       - ��������� ������� RemoveAllSpaces

     2008.06.24
       - ��������� ������� RemoveRepeatSpaces

     2008.03.31
       - ��������� ������� LetterE2EO 


}

{$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface
uses Classes ;

type
  TSmartCompareParams = (scpCaseIns,scpIgnoreSpaces,scpByWords) ;
  TSetSmartCompareParams = set of TSmartCompareParams ;
  TSmartCompareResult = (scrEqual,scrNoEqual) ;

function RemoveRepeatSpaces(const s:string):string ;
function RemoveAllSpaces(const s:string):string ;
function intCharLess32ToSpace(s:string):string ;
function LetterEO2E(s:string):string ;
function SmartCompareStrings(const s1,s2:string; 
  const SmartCompareParams:TSetSmartCompareParams):TSmartCompareResult ;
function GetPhoneFromStr(s:string):string ;
function StripExceptDigits(s:string):string ;
function MyUTF8toCP1251_old(s:string):string ;
{$ifdef fpc}
function MyUTF8toCP1251(s:string; var isok:Boolean):string ;
function MyCP1251toUTF8(s:string; var isok:Boolean):string ;
{$endif}
function MyUnicodeToUTF8(s:string):string ;

function MyAnsiLowerCase(const s:string):string ;
function MyAnsiUpperCase(const s:string):string ;
function CreateStringListBySep(const s,sep:string):TStringList ;
function StripExceptChars(s,chars:string):string ;
function StripCharsLess32(s:string):string ;
function StripChars(s,chars:string):string ;
function ReversString(str:string):string ;
function ReversePos(substr,str:string):Integer ;
function IsStrInCommaList(str,commastr:string):Boolean ;
function IsAnyFromCommaListInStr(str,commastr:string):Boolean ;
function StripCommaListFromStr(str,commastr:string):string ;
function ExtractStrFromStrWithGarbage(const src:string; extract:string; 
  garbchars:string; replacestr:string=''):string ;
function RemoveRepeatChars(src:string; chars:string):string ;


{
  ������� ������ ������ �� ������. ��������, ('quickbasic','basic')='quick'
}
function RemoveStrFromStr(str,strdel:string):string ;

{
  ��������� ����� � ������ ����������
    1) �������� perm_d ����
    2) �������� perm_d ����
    3) �������������� ������� 2*perm_d ����
    4) ������ perm_d ���� �� ������
}
function IsStringEqualWithPermutate(s1,s2:string; perm_d:Integer):Boolean ;

{
   ������� �������� N ������ �������� �� ������, � ������ ����.
}
function GetFirstNCharsByWord(str:string; N:Integer; 
  splitchars:string=' .,;:'):string ;

// ������� ��������� ����������� �� ������ ������ ����
function TruncStrByFirstSlog(str:string):string ;

function FirstCharUp(s:string):string ;

// ��������� � ������ ���������
function IsEqualWithFinalChars(s,sword:string):Boolean ;

// �������� ������ A �� AA (���-���), O - �� � �.�.  ������� ��� ����������� ������
function InjectRusEngSequences(s:string):string ;

function StripCharsFromEdges(str:string; chars:string):string ;

function genUnicCodeByStr(str:string; chars_for_code:string; codelen:Integer):string ;

function GenRndIntStr(n:Integer):string ;

function ReplaceCharLess32ByXCode(str:string):string ;

{ // future
function String2Rows(str:string; maxlen:Integer; sep:string):string ;
}

const 
  CHAR32=chr(32) ;
  CHARSRUSUPPER='�����Ũ��������������������������' ;
  CHARSRUSLOWER='��������������������������������' ;
  DIGITS='0123456789' ;

var
  CHARSENGLOWER:string ; 
  CHARSENGUPPER:string ; 

implementation
uses {$ifdef unix}iconvenc,{$endif} SysUtils, simple_regex, simple_oper ;

var
  CHARLESS32:string = '' ;

function intCharLess32ToSpace(s:string):string ;
var i:Integer ;
    r:string ;
begin
  r:=s ;
  for i:=1 to length(r) do
    if ord(r[i])<32 then r[i]:=CHAR32 ;
  Result:=r ;
end ;

function LetterEO2E(s:string):string ;
begin
  Result:=s ;
  Result:=StringReplace(Result,'�','�',[rfReplaceAll]) ;
  Result:=StringReplace(Result,'�','�',[rfReplaceAll]) ;
end ;

function RemoveRepeatSpaces(const s:string):string ;
var last_c:char ;
    i:Integer ;
begin
  Result:='' ;
  last_c:=chr(0) ;
  for i:=1 to Length(s) do
    if (last_c=CHAR32)and(s[i]=CHAR32) then
      Continue
    else begin
      Result:=Result+s[i] ;
      last_c:=s[i] ;
    end ; 
end ;

function RemoveAllSpaces(const s:string):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=1 to Length(s) do
    if s[i]<>CHAR32 then Result:=Result+s[i] ;
end ;

function SmartCompareStrings(const s1,s2:string; 
  const SmartCompareParams:TSetSmartCompareParams):TSmartCompareResult ;
begin
end ;

function GetPhoneFromStr(s:string):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=1 to Length(s) do
    if s[i] in ['0','1','2','3','4','5','6','7','8','9'] then Result:=Result+s[i] ;
  if (Length(Result)=11) then Result[1]:='8' ;
  if (Length(Result)<>11) then Result:='' ;
end ;

function StripExceptDigits(s:string):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=1 to Length(s) do 
    if (ord(s[i])>=48)and(ord(s[i])<=57) then
      Result:=Result+s[i] ;
end ;

function StripCharsLess32(s:string):string ;
var i:Integer ;
begin
  if CHARLESS32='' then 
    for i:=0 to 31 do CHARLESS32:=CHARLESS32+chr(i) ;
  Result:=StripChars(s,CHARLESS32) ;
end ;

// ������ �������, �� ������ ��������
function MyUTF8toCP1251_old(s:string):string ;
var i:Integer ;
    b:byte ;
begin
{
��� 208
������ ���� + 48

��� 209
������ ���� + 112
}

  Result:='' ;
  i:=1 ;
  while i<=Length(s) do begin
    b:=ord(s[i]) ;
    if (b>127) then begin Result:=Result+chr((b + 48) * 64 + ord(s[i+1]) + 48); Inc(i) ; end else
      Result:=Result+s[i] ;
    Inc(i) ;
  end ;

end ;

{$ifdef fpc}
function MyUTF8toCP1251(s:string; var isok:Boolean):string ;
begin
  {$ifdef unix}
  isok:=(Iconvert(s,Result,'UTF-8','CP1251')=0);
  {$else}
  Result:=UTF8ToAnsi(s) ;
  isok:=True ;
  {$endif} ;
end ;

function MyCP1251toUTF8(s:string; var isok:Boolean):string ;
begin
  {$ifdef unix}
  isok:=(Iconvert(s,Result,'CP1251','UTF-8')=0);
  {$else}
  Result:=AnsiToUTF8(s) ;
  isok:=True ;
  {$endif} ;
end ;
{$endif}

function MyAnsiLowerCase(const s:string):string ;
var r:string ;
    i:Integer ;
begin
  r:='' ;        
  for i:=1 to Length(s) do begin
    if ord(s[i])=255 then r:=r+chr(255) else
    if ord(s[i])=223 then r:=r+chr(255) else
    if ord(s[i])=247 then r:=r+chr(247) else
    if ord(s[i])=215 then r:=r+chr(247) else
    if ord(s[i])=184 then r:=r+chr(184) else
    if ord(s[i])=168 then r:=r+chr(184) else
    r:=r+AnsiLowerCase(s[i]) ;
  end ;
  Result:=r ;
end ;

function MyAnsiUpperCase(const s:string):string ;
var r:string ; 
    i:Integer ;
begin
  r:='' ;    
  for i:=1 to Length(s) do begin
    if ord(s[i])=255 then r:=r+chr(223) else
    if ord(s[i])=223 then r:=r+chr(223) else
    if ord(s[i])=247 then r:=r+chr(215) else
    if ord(s[i])=215 then r:=r+chr(215) else
    if ord(s[i])=184 then r:=r+chr(168) else
    if ord(s[i])=168 then r:=r+chr(168) else
    r:=r+AnsiUpperCase(s[i]) ;
  end ;
  Result:=r ;
end ;

function CreateStringListBySep(const s,sep:string):TStringList ;
var str:string ;
    i:Integer ;
begin
  Result:=TStringList.Create() ;
  str:='' ;
  i:=1 ;
  while i<=Length(s) do begin
    if Copy(s,i,Length(sep))=sep then begin 
      Result.Add(Trim(str)) ;
      str:='' ; 
      Inc(i,Length(sep)-1) ;
    end
    else
      str:=str+s[i] ;
    Inc(i) ;
  end ;
  if str<>'' then Result.Add(Trim(str)) ;
end ;

function StripExceptChars(s,chars:string):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=1 to Length(s) do 
    if Pos(s[i],chars)>0 then Result:=Result+s[i] ;
end ;

function StripChars(s,chars:string):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=1 to Length(s) do 
    if Pos(s[i],chars)=0 then Result:=Result+s[i] ;
end ;

function IsStringEqualWithPermutate(s1,s2:string; perm_d:Integer):Boolean ;
var str1,str2:string ;

  function PermVar1(t1,t2:string):Boolean ;
  var i,j,x:Integer ;
  begin
    j:=1 ;
    for i:=1 to Length(t1)-1 do begin
      if t1[i]<>t2[j] then Inc(x) else Inc(j) ;
    end ;
    if x=1 then begin Result:=True ; Exit ; end ;
  end ;

  function PermVar2(t1,t2:string):Boolean ;
  var i,j,x:Integer ;
      List:TStringList ;
  begin 
    List:=TStringList.Create ;
    x:=0 ;
    for i:=1 to Length(t1) do 
      if t1[i]<>t2[i] then begin
        if List.IndexOf(t2[i]+t1[i])=-1 then begin
          List.Add(t1[i]+t2[i]) ; Inc(x) ;
        end
        else
          List.Delete(List.IndexOf(t2[i]+t1[i])) ;
      end ;
    Result:=(List.Count=0)and(x=1) ;
    List.Free ;
  end ;

  function PermVar3(t1,t2:string):Boolean ;
  var i,j,x:Integer ;
  begin 
    x:=0 ;
    for i:=1 to Length(t1) do 
      if t1[i]<>t2[i] then Inc(x) ;
    Result:=(x=1) ;
  end ;

begin
  Result:=False ;
  str1:=MyAnsiLowerCase(Trim(s1)) ; str2:=MyAnsiLowerCase(Trim(s2)) ;
  if (str1=str2) then begin  Result:=True ; Exit ; end ;

//  1) �������� � �������� perm_d ����
  if Length(str1)=Length(str2)+1 then
    if PermVar1(str1,str2) then begin Result:=True ; Exit ; end ;
  if Length(str2)=Length(str1)+1 then
    if PermVar1(str2,str1) then begin Result:=True ; Exit ; end ;

  if Length(str1)=Length(str2) then begin
//  3) �������������� ������� 2*perm_d ����
    if PermVar2(str1,str2) then begin Result:=True ; Exit ; end ;

//  4) ������ perm_d ���� �� ������
    if PermVar3(str1,str2) then begin Result:=True ; Exit ; end ;
  end ;
 
end ;

function ReversString(str:string):string ;
var i,n:Integer ;
    c:char ;
begin
  Result:=str ;
  n:=Length(str) ;
  for i:=1 to n div 2 do begin
    c:=Result[i] ; Result[i]:=Result[n-i+1] ; Result[n-i+1]:=c ;
  end ;
end ;

function RemoveStrFromStr(str,strdel:string):string ;
var p:Integer ;
begin
  p:=Pos(strdel,str) ;
  if p=0 then Result:=str else
  Result:=Copy(str,1,p-1)+Copy(str,p+Length(strdel),Length(str)) ;
end ;

function ReversePos(substr,str:string):Integer ;
var i:Integer ;
begin
  Result:=0 ;
  for i:=Length(str) downto 1 do
    if Copy(str,i,Length(substr))=substr then begin
      Result:=Length(str)-i-Length(substr)+2 ; Break ;
    end ;
//  i:=Pos(substr,str) ;
//  if i=0 then Result:=0 else Result:=Length(str)-i-Length(substr)+2 ;
end ;

function IsStrInCommaList(str,commastr:string):Boolean ;
begin
  with TStringList.Create() do begin
    CommaText:=commastr ;
    Result:=(IndexOf(str)<>-1) ;
    Free ;
  end;
end;

function IsAnyFromCommaListInStr(str,commastr:string):Boolean ;
var i:Integer ;
begin
  Result:=False ;
  with TStringList.Create() do begin
    CommaText:=commastr ;
    for i:=0 to Count-1 do 
      if Pos(Strings[i],str)<>0 then begin  Result:=True ; Break ; end ;
    Free ;
  end;
end ;

function StripCommaListFromStr(str,commastr:string):string ;
var i:Integer ;
begin
  Result:=str ;
  with TStringList.Create() do begin
    CommaText:=commastr ;
    for i:=0 to Count-1 do
      Result:=StringReplace(Result,Strings[i],'',[rfReplaceAll]) ;
    Free ;
  end;
end ;

function GetFirstNCharsByWord(str:string; N:Integer; 
  splitchars:string=' .,;:'):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=1 to Length(str) do 
    if (Length(Result)>=N)and(Pos(str[i],splitchars)>0) then Break 
    else Result:=Result+str[i] ;
end ;

function TruncStrByFirstSlog(str:string):string ;
var arr_words:array[0..255] of string ;
    arr_finc:array[0..255] of char ;
    i,wordcnt:Integer ;
    tekw:string ;
    notrunc:Boolean ;
const SPLITCHARS=' .,;:-()' ;
      CHARGLAS='�����������' ;

function PackWord(sword:string; issetdot:Boolean; out noturnc:Boolean):string ;
var tmp:string ;
    i,cntglas:Integer ;
begin
  if Pos(AnsiLowerCase(sword[1]),CHARGLAS)>0 then cntglas:=2 else cntglas:=1 ;

  tmp:=sword+#32 ;
  for i:=1 to Length(tmp)-1 do
    if (Pos(AnsiLowerCase(sword[i]),CHARGLAS)>0)and(Pos(AnsiLowerCase(sword[i+1]),CHARGLAS)=0) then begin
      dec(cntglas) ; if (cntglas=0) then Break ;
    end ;

  Result:=Copy(Trim(tmp),1,i+1) ;
  if issetdot then Result:=Result+'.' ;

  notrunc:=(Length(Result)>=Length(sword)) ;
  if notrunc then Result:=sword ;
 
end ;

begin
  tekw:='' ;
  wordcnt:=0 ;
  for i:=1 to Length(str) do
    if Pos(str[i],SPLITCHARS)<>0 then begin
      if tekw<>'' then begin
        arr_words[wordcnt]:=tekw ;
        arr_finc[wordcnt]:=str[i] ;
        tekw:='' ;
        Inc(wordcnt) ;
      end
    end
    else 
      tekw:=tekw+str[i] ;

  if tekw<>'' then begin
    arr_words[wordcnt]:=tekw ;
    arr_finc[wordcnt]:=#0 ;
    Inc(wordcnt) ;
  end ;

  Result:='' ;
  for i:=0 to wordcnt-1 do begin
    Result:=Result+PackWord(arr_words[i],arr_finc[i] in [#32,#0],notrunc) ;
    if not (arr_finc[i] in [#32,#0]) then Result:=Result+arr_finc[i] 
    else if notrunc and (arr_finc[i]<>#0) then Result:=Result+#32 ;
  end ;
end ;

function FirstCharUp(s:string):string ;
begin
  if Trim(s)<>'' then
    Result:=AnsiUpperCase(Trim(s)[1])+AnsiLowerCase(Copy(Trim(s),2,Length(s))) 
  else
    Result:='' ;
end ;

procedure FillCharsEng() ;
var c:char ;
begin
  for c:='a' to 'z' do CHARSENGLOWER:=CHARSENGLOWER+c ;
  for c:='A' to 'Z' do CHARSENGUPPER:=CHARSENGUPPER+c ;
end ;

// ������ ����� - �����������, ������ - �������� ��� ������ �������
// ������� ����� ���������� � �� ��������� ������� � ����������
// (������ - �������, ������ - �������)
function IsEqualWithFinalChars(s,sword:string):Boolean ;
const SPLITCHARS=' .,;:-()' ;
      CHARGLAS='�����������' ; // �������� ������ � ������� ���� (���� - ����)
var lowers,lowersw:string ;
    i:Integer ;
    s1,s2:string ;
begin
  lowers:=AnsiLowerCase(s) ;
  lowersw:=AnsiLowerCase(sword) ;
  // ������� ��� ������� ����������� �����
  //if Pos(lowersw[Length[lowersw]],CHARGLAS)>0 then begin // �� ����� ������� - �������
  // ���� ������ ����� - ����������� ��� ������� � �����
  s1:='' ;
  for i:=Length(lowers) downto 1 do 
    if Pos(lowers[i],CHARGLAS)=0 then begin
      s1:=Copy(lowers,1,i) ; Break ;
    end ;
  s2:='' ;
  for i:=Length(lowersw) downto 1 do 
    if Pos(lowersw[i],CHARGLAS)=0 then begin
      s2:=Copy(lowersw,1,i) ; Break ;
    end ;
  Result:=(s1=s2) ;
end ;

function ExtractStrFromStrWithGarbage(const src:string; extract:string; 
  garbchars:string; replacestr:string=''):string ;
var arr:array of Integer ;
    str1,str2:string ;
    i,j:Integer ;
    p:Integer ;
begin
  str2:=StripChars(extract,garbchars) ;
  // � ������ FPC 2.2.0 ����� ���� +1, �� ����� ���������� ������ ������
  SetLength(arr,Length(src)+2) ;

  str1:='' ;
  j:=1 ;
  for i:=1 to Length(src) do
    if Pos(src[i],garbchars)=0 then begin
      arr[j]:=i ;
      str1:=str1+src[i] ;
      Inc(j) ;
    end ;
  arr[j]:=Length(src)+1 ; // ���� ����, ��� ����� ���������� � � �����

  p:=Pos(str2,str1) ;
//  Writeln('pos=',p) ;
  if p=0 then Result:=src else
  Result:=Copy(src,1,arr[p-1])+replacestr+Copy(src,arr[p+Length(str2)],Length(src)) ;

end ;

function RemoveRepeatChars(src:string; chars:string):string ;
var str:string ;
    last_c:char ;
    i:Integer ;
begin
  Result:='' ;
  if length(src)=0 then Exit ;
  last_c:=src[1] ;
  Result:=Result+src[1] ;
  for i:=2 to Length(src) do begin
    if (Pos(src[i],chars)=0)or(last_c<>src[i]) then
      Result:=Result+src[i] ;
    last_c:=src[i] ;
  end ;
end ;

function InjectRusEngSequences(s:string):string ;

const 
  RUS_ENG_SEQ=
    '�=A,�=a,�=B,�=E,�=e,�=K,�=k,�=M,�=H,�=O,�=o,�=P,�=C,�=c,�=T,�=X,�=x' ;

begin
  Result:=s ;
  {$IFDEF TURBO_DELPHI}
  with TStringList.Create() do begin
    CommaText:=RUS_ENG_SEQ ;
    while Count>0 do begin
      Result:=StringReplace(Result,Names[0],
       '['+Names[0]+ValueFromIndex[0]+']',[rfReplaceAll]) ;
      Delete(0) ;
    end ;
    Free ;
  end ;
  {$ENDIF}
end ;

function StripCharsFromEdges(str:string; chars:string):string ;
var si,fi,i:Integer ;
begin
  si:=Length(str) ;
  fi:=1 ;
  for i := 1 to Length(str) do
    if Pos(str[i],chars)=0 then begin
      si:=i ; Break ;
    end;
  for i := Length(str) downto 1 do
    if Pos(str[i],chars)=0 then begin
      fi:=i ; Break ;
    end;
  if si<=fi then Result:=Copy(str,si,fi-si+1) else Result:='' ;
end;

function genUnicCodeByStr(str:string; chars_for_code:string; codelen:Integer):string ;
var i,j,k:Integer ;
begin
  Result:=StringOfChar(#32,codelen) ;
  for i:=1 to codelen do begin
    k:=0 ;
    for j:=1 to Length(str) do
      Inc(k,(k+ord(str[j])) mod (i+1)) ;
    Result[i]:=chars_for_code[(k mod Length(chars_for_code))+1]  ;
  end ;
end ;

function GenRndIntStr(n:Integer):string ;
var i:Integer ;
begin
  Result:=StringOfChar(#32,n) ;
  for i:=1 to n do
    Result[i]:=IntToStr(Round(Random(10)))[1] ;
end ;

function ReplaceCharLess32ByXCode(str:string):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=1 to Length(str) do
    if ord(str[i])<32 then Result:=Result+Format('\x%.2d',[ord(str[i])]) else
                           Result:=Result+str[i] ;
end ;

{
function String2Rows(str:string; maxlen:Integer; sep:string):string ;
var i,k:Integer ;
    s:string ;
begin
  Result:='' ;
  k:=1 ;
  while 
  for i:=1 to Length(str) do begin
    
    

end ;
}

{.$ifdef fpc}
function MyUnicodeToUTF8(s:string):string ;
var str,strn,str2:string ;
    i:Integer ;
    PW:PWideChar ;
    P:PAnsiChar ;
begin
  Result:='' ;

  str:=s ;
  strn:='' ;
  i:=1 ;
  while i<=Length(str) do 
    if LowerCase(Copy(str,i,2))='\u' then begin
      str2:=HexToStr(UpperCase(Copy(str,i+4,2)))+
            HexToStr(UpperCase(Copy(str,i+2,2))) ;

      P:=PAnsiChar(#32#32) ;
      PW:=PWideChar(str2) ;
      UnicodeToUtf8(P,PW,5) ;

      //strn:=strn+P ;

      Inc(i,6) ;
    end
    else begin
      strn:=strn+str[i] ;
      Inc(i) ;
    end ;
  
  Result:=strn; 
end;

{.$endif}

initialization

FillCharsEng() ;

end.

