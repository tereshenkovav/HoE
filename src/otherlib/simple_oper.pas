unit simple_oper ;

{
   История изменений:

     19.05.07
       - Добавлена функция
      function Alternate (b:Boolean;c1,c2:TClass) : TClass ; overload ;

     16.02.08
       - Добавлена функция 
      function nl2br(s:string):string ; 
   
     13.09.07
       - Добавлена функция
      function StringToChar(s:string):Char ;

     19.05.07
       - Добавлена функция
      function Alternate (b:Boolean;o1,o2:TObject) : TObject ; overload ;

     24.10.07
       - Добавлены функции
      procedure IfLessThenAss(var x:Integer;const n:Integer) ;
      procedure IfGreatThenAss(var x:Integer;const n:Integer) ;
      function CopyFromToEnd(s:string; pos: Integer) : string ;
}

{$IFDEF FPC} {$MODE DELPHI} {$ENDIF}

interface

//  Возвращает строку, содержащую '0', если она пуста,
//    иначе - без изменений
function RetNolIfEmpty(s:string):string ;

// Функция преобразует булеан в строку
//  True -> 'True'
//  False -> 'False'
function BoolToStr(b:Boolean):string ;

// Функция преобразует булеан в русскую строку
//  True -> 'Да'
//  False -> 'Нет'
function BoolToStrRus(b:Boolean):string ;

// Функция преобразует строку в булеан
//  'True' -> True
//  'False' -> False
//  Регистр входа игнорирется, т.е., сработает и 'TRUE' и  'True'
function StrToBool(s:string):Boolean ;

// Функция преобразует булеан в число
//  True -> 1
//  False -> 0
function BoolToInt(b:Boolean):Integer ;

// Функция преобразует число в булеан
//  1 -> True
//  0 -> False
function IntToBool(i:Integer):Boolean ;

// Конвертирует Int в Str с учетом нуля. Т.е., вернет '', если 0
function IntToStrWt0(a:Integer):string ;

// Конвертирует Str в Int с учетом нуля. Т.е., вернет 0, если ''
function StrToIntWt0(s:string):Integer ;

function IntToStrSigned(a:Integer):string ;

// Арабские числв - в римскую запись
//  (только от 1 до 12. Оставлена для совместимости)
function ArabToRoma(num:Integer):string ;

// Арабские числв - в римскую запись
//  Наиболее правильная версия
function IntToRoman(num: Cardinal): String;

// Расставляет символы chr(13) между символами строки -
//   для вертикального написания слов (а-ля Матрица)
function RotateString(s:string):string ;

// Добавляет к каждой найденной кавычке (chr(34)) еще одну.
//   Для подготовки запросов
// Оставлена для совместимости
function PrepStringForSQL (s:string):string ;

// Возвращает истину, если параметр пустая строка или Null
function IsEmptyOrNull(v:Variant):Boolean ;

// Аналогично операции a?x:y в Си
function Alternate (b:Boolean;s1,s2:string) : string ; overload ;
function Alternate (b:Boolean;a1,a2:Integer) : Integer ; overload ;
function Alternate (b:Boolean;d1,d2:Double) : Double ; overload ;
function Alternate (b:Boolean;b1,b2:Boolean) : Boolean ; overload ;
function Alternate (b:Boolean;o1,o2:TObject) : TObject ; overload ;
function Alternate (b:Boolean;c1,c2:TClass) : TClass ; overload ;

// Возращает параметр ifnull, если v=Null, иначе возвращает сам v
function VarToInt (v:Variant;ifnull:Integer):Integer ;

// Копирование строки от pos1 до pos2
function CopyFromTo(s:string; pos1, pos2: Integer) : string ;

// Копирование строки от pos до конца
function CopyFromToEnd(s:string; pos: Integer) : string ;

// Преобразование шестнадцатиричной строки в ее обычный вид
function HexToStr(const s:string):string ;
// Преобразование строки в шестнадцатиричный вид
function StrToHex(const s:string):string ;

// Возвращает знак числа (-1,0,-1) ;
function MySign(const ANum:Real):Integer ;

// Возвращает строку '\x20', если входная - пробелы,
//   иначе - без изменений
function SpaceToCode(const astr:string):string ;

// Преобразует строку в букву,
// беря первую букву или chr(32), если строка пуста
function StringToChar(s:string):Char ;

// Если n<x, то x:=n 
procedure IfLessThenAss(var x:Integer;const n:Integer) ;

// Если n>x, то x:=n
procedure IfGreatThenAss(var x:Integer;const n:Integer) ;

// Заменяет \x13\x10 на <br>
function nl2br(s:string):string ;

function GetStrFromPacked(s,str:string):string ;
function ReplaceStrInPacked(s,str,newvalue:string):string ;
function GetIntFromPacked(s,str:string):Integer ;

function Ansi2UtfCharCodes(s:string):string ;

function HTML2RE(const html:string):string ;

function Int2Chrs(a:Longint):string ;
function Chrs2Int(cs:string):Longint ;

function GetSplitPart1(s:string; sep:string):string ;
function GetSplitPart1orAll(s:string; sep:string):string ;
function GetSplitPart2(s:string; sep:string):string ;

procedure SwapVar(var a,b:Integer) ;

function AlternateExI(conds:array of Boolean; res: array of integer):Integer ;
function AlternateExS(conds:array of Boolean; res: array of string):string ;

function GreatLessEqualTo101(const s1,s2:string):Integer ; overload ;
function GreatLessEqualTo101(const n1,n2:Integer):Integer ; overload ;
function GreatLessEqualTo101(const d1,d2:TDateTime):Integer ; overload ;

function GetRndIntFromTo(const fromi,toi:Integer):Integer ;

function RndBool():Boolean ;

function RoundTo(n:Integer; divider:Integer):Integer ;

function FloatToStrWithDot(f:Real):string ;

function IfNoEmpty(s:string; def:string):string ;

function CreateRandomSeq(seqset:string; seqlen:Integer):string ;

function ValueByBxB(b1,b2:Boolean; v11,v10,v01,v00:Integer):Integer ;

function CreateGUIDStr():string ;

implementation
uses SysUtils, Classes ,Variants  ;

function RetNolIfEmpty(s:string):string ;
begin
  if Trim(s)='' then Result:='0' else Result:=s ;
end ;

function BoolToStr(b:Boolean):string ;
begin
  if b then Result:='True' else Result:='False' ;
end ;

function BoolToStrRus(b:Boolean):string ;
begin
  if b then Result:='Да' else Result:='Нет' ;
end ;

function BoolToInt(b:Boolean):Integer ;
begin
  if b then Result:=1 else Result:=0 ;
end ;

function IntToBool(i:Integer):Boolean ;
begin
  Result:=(i=1) ;
end ;

function StrToBool(s:string):Boolean ;
begin
  if AnsiUpperCase(Trim(s))='TRUE' then Result:=True else Result:=False ;
end ;

function IntToStrWt0(a:Integer):string ;
begin
  if a=0 then Result:='' else Result:=IntToStr(a) ;
end ;

function StrToIntWt0(s:string):Integer ;
begin
  if Trim(s)='' then Result:=0 else Result:=StrToInt(s) ;
end ;

function IntToStrSigned(a:Integer):string ;
begin
  Result:=IntToStr(a) ;
  if a>0 then Result:='+' + Result ;
end ;
{
  1    I
  5    V
  10   X
  50   L
  100  C
  500  D
  1000 M

}
function ArabToRoma(num:Integer):string ;
begin
  case num of
   0: Result:='' ;
   1: Result:='I' ;
   2: Result:='II' ;
   3: Result:='III' ;
   4: Result:='IV' ;
   5: Result:='V' ;
   6: Result:='VI' ;
   7: Result:='VII' ;
   8: Result:='VIII' ;
   9: Result:='IX' ;
   10: Result:='X' ;
   11: Result:='XI' ;
   12: Result:='XII' ;
  end ;
end ;

function RotateString(s:string):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=1 to length(s) do begin
    Result:=Result+s[i] ;
    if i<length(s) then Result:=Result+chr(13) ;
  end ;
end ;

function PrepStringForSQL (s:string):string ;
var i:Integer ;
    res:string ;
begin
  for i:=1 to length(s) do begin
    res:=res+s[i] ;
    if s[i]='"' then res:=res+'"' ;
  end ;
  Result:=res ;
end ;

function IntToRoman(num: Cardinal): String;
const
  Nvals = 13;
  vals: array [1..Nvals] of word = (1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000);
  roms: array [1..Nvals] of string[2] = ('I', 'IV', 'V', 'IX', 'X', 'XL', 'L', 'XC', 'C', 'CD', 'D', 'CM', 'M');
var
  b: 1..Nvals;
begin
  result := '';
  b := Nvals;
  while num > 0 do
  begin
    while vals[b] > num do
      dec(b);
    dec (num, vals[b]);
    result := result + roms[b]
  end;
end;

function IsEmptyOrNull(v:Variant):Boolean ;
begin
  if v=Null then
    Result:=True
  else
    Result:=(Trim(string(v))='') ;
end ;

function Alternate (b:Boolean;s1,s2:string) : string ;
begin
  if b then Result:=s1 else Result:=s2 ;
end ;

function Alternate (b:Boolean;a1,a2:Integer) : Integer ;
begin
  if b then Result:=a1 else Result:=a2 ;
end ;

function Alternate (b:Boolean;d1,d2:Double) : Double ;
begin
  if b then Result:=d1 else Result:=d2 ;
end ;

function Alternate (b:Boolean;b1,b2:Boolean) : Boolean ;
begin
  if b then Result:=b1 else Result:=b2 ;
end ;

function Alternate (b:Boolean;o1,o2:TObject) : TObject ; overload ;
begin
  if b then Result:=o1 else Result:=o2 ;
end ;

function Alternate (b:Boolean;c1,c2:TClass) : TClass ; overload ;
begin
  if b then Result:=c1 else Result:=c2 ;
end ;

function VarToInt (v:Variant;ifnull:Integer):Integer ;
begin
  if v=Null then Result:=ifnull else Result:=v ;
end ;

function CopyFromTo(s:string; pos1, pos2: Integer) : string ;
begin
  Result:=Copy(s,pos1,pos2-pos1+1) ;
end ;

function CopyFromToEnd(s:string; pos: Integer) : string ;
begin
  Result:=CopyFromTo(s,pos,Length(s)) ;
end ;

function HexToStr(const s:string):string ;
var k,mk:integer ;
    h1,h2,b:byte ;
    s1:string ;
begin
  mk:=(length(s) div 2)  ;
  s1:=StringOfChar(#32,mk) ;
  for k:=1 to mk do begin
    h1:=ord(s[k*2-1]) ;
    h2:=ord(s[k*2]) ;
    if h1 < 58 then dec(h1,48) else dec(h1,55) ;
    if h2 < 58 then dec(h2,48) else dec(h2,55) ;
    b:=(h1 shl 4)+h2 ;
    s1[k]:=chr(b) ;
  end ;
  Result:=s1 ;
end ;

function StrToHex(const s:string):string ;
var k,mk:integer ;
    h1,h2,b:byte ;
    s1:string ;
begin
  mk:=length(s)  ;
  s1:=StringOfChar(#32,mk shl 1) ;
  for k:=1 to mk do begin
    b:=ord(s[k]) ;
    h1:=b div 16 ;
    h2:=b mod 16 ;
    if h1 < 10 then s1[2*k-1]:=chr(h1+48) else s1[2*k-1]:=chr(h1+55) ;
    if h2 < 10 then s1[2*k]:=chr(h2+48) else s1[2*k]:=chr(h2+55) ;
  end ;
  Result:=s1 ;
end ;

function MySign(const ANum:Real):Integer ;
begin
  if ANum>0 then Result:=1 else
    if ANum<0 then Result:=-1 else
      if ANum=0 then Result:=0 ;
end ;

function SpaceToCode(const astr:string):string ;
begin
  Result:=Alternate(Trim(astr)='','\x20',astr) ;
end ;

function StringToChar(s:string):Char ;
begin
  if length(s)>0 then Result:=s[1] else Result:=chr(32) ;
end ;

procedure IfLessThenAss(var x:Integer;const n:Integer) ;
begin
  if n<x then x:=n ; 
end ;

procedure IfGreatThenAss(var x:Integer;const n:Integer) ;
begin
  if n>x then x:=n ;
end ;

function nl2br(s:string):string ; 
begin
  Result:=StringReplace(s,chr(13)+chr(10),'<br>',[rfReplaceAll]) ;
  Result:=StringReplace(Result,chr(13),'<br>',[rfReplaceAll]) ;  
  Result:=StringReplace(Result,chr(10),'<br>',[rfReplaceAll]) ;    
end ;

function GetStrFromPacked(s,str:string):string ;
begin
  with TStringList.Create do begin
    CommaText:=s ;  Result:=Values[str] ;  Free ;
  end;
end ;

function ReplaceStrInPacked(s,str,newvalue:string):string ;
begin
  with TStringList.Create do begin
    CommaText:=s ;  Values[str]:=newvalue ;  Result:=CommaText ;  Free ;
  end;
end ;

function GetIntFromPacked(s,str:string):Integer ;
begin
  Result:=StrToIntWt0(GetStrFromPacked(s,str)) ;
end ;

function Ansi2UtfCharCodes(s:string):string ;
var i:Integer ;
    c:Word ;
begin
  Result:='' ;
  for i:=1 to Length(s) do begin
    if Result<>'' then Result:=Result+',' ;
    c:=ord(s[i]) ;
    // Если идут русские символы, то добавляем число, полученное опытным
    // путем - оно должно преобразовывать asc в unicode
    if c>127 then Inc(c,848) ;
    Result:=Result+IntToStr(c) ;
  end ;
end ;

function HTML2RE(const html: string): string;
begin
  Result:=html ;
  Result:=StringReplace(Result,'<','\<',[rfReplaceAll]) ;
  Result:=StringReplace(Result,'>','\>',[rfReplaceAll]) ;
  Result:=StringReplace(Result,'/','\/',[rfReplaceAll]) ;
end;

function Int2Chrs(a:Longint):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=3 downto 0 do
    Result:=Result+chr((a shr (i*8))and($FF)) ;
end ;

function Chrs2Int(cs:string):Longint ;
var i:Integer ;
begin
  Result:=0 ;
  for i:=3 downto 0 do
    Result:=Result+(ord(cs[4-i]) shl (i*8)) ;
end ;

function GetSplitPart1(s:string; sep:string):string ;
begin  Result:=Copy(s,1,Pos(sep,s)-1) ; end ;

function GetSplitPart1orAll(s:string; sep:string):string ;
begin
  if Pos(sep,s)<>0 then Result:=GetSplitPart1(s,sep) else Result:=s ;
end ;

function GetSplitPart2(s:string; sep:string):string ;
begin
  if Pos(sep,s)<>0 then Result:=Copy(s,Pos(sep,s)+Length(sep),Length(s)) else Result:='' ;
end ;

procedure SwapVar(var a,b:Integer) ;
var t:Integer ;
begin  t:=a ; a:=b ; b:=t ; end ;

function AlternateExI(conds:array of Boolean; res: array of integer):Integer ;
var i:Integer ;
begin
  for i:=0 to High(conds) do
    if conds[i] then begin Result:=res[i] ; Exit ; end ;
  Result:=res[High(conds)+1] ;
end ;

function AlternateExS(conds:array of Boolean; res: array of string):string ;
var i:Integer ;
begin
  for i:=0 to High(conds) do
    if conds[i] then begin Result:=res[i] ; Exit ; end ;
  Result:=res[High(conds)+1] ;
end ;

function GreatLessEqualTo101(const s1,s2:string):Integer ; 
begin
  if s1>s2 then Result:=1 else
  if s1<s2 then Result:=-1 else Result:=0 ;
end ;

function GreatLessEqualTo101(const n1,n2:Integer):Integer ;
begin
  if n1>n2 then Result:=1 else
  if n1<n2 then Result:=-1 else Result:=0 ;
end ;                               

function GreatLessEqualTo101(const d1,d2:TDateTime):Integer ;
begin
  if d1>d2 then Result:=1 else
  if d1<d2 then Result:=-1 else Result:=0 ;
end ;

function GetRndIntFromTo(const fromi,toi:Integer):Integer ;
begin
  Result:=fromi+Round(Random(toi-fromi+1)) ;
end ;

function RndBool():Boolean ;
begin
  Result:=(Random(2)>0.5) ;
end ;

function RoundTo(n:Integer; divider:Integer):Integer ;
begin
  if n mod divider = 0 then Result:=n else 
  if (n mod divider) > (divider div 2) then Result:=divider*(n div divider + 1) else
  Result:=divider*(n div divider) ;
end ;

function FloatToStrWithDot(f:Real):string ;
begin
  Result:=StringReplace(FloatToStr(f),',','.',[]) ;
end;

function IfNoEmpty(s:string; def:string):string ;
begin
  if Trim(s)='' then Result:=def else Result:=s ;  
end;

function CreateRandomSeq(seqset:string; seqlen:Integer):string ;
var i:Integer ;
begin
  Randomize ;
  Result:=StringOfChar(#32,seqlen) ;
  for i:=1 to seqlen do 
    Result[i]:=seqset[Round(Random(Length(seqset)))+1] ;
end ;

{.$IFDEF TURBO_DELPHI}
function CreateGUIDStr():string ;
var G:TGUID ;
begin
  CreateGUID(G) ;
  Result:=GUIDToString(G) ;
//  ReleaseGUID(G) ;
end ;
{.$ENDIF}

function ValueByBxB(b1,b2:Boolean; v11,v10,v01,v00:Integer):Integer ;
begin
  if b1 then begin
    if b2 then Result:=v11 else Result:=v10 ;
  end
  else begin
    if b2 then Result:=v01 else Result:=v00 ;
  end ;
end ;

end.

