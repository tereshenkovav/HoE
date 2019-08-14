unit StringListSmart ;

{

   Класс представляет собой расширение стандартного TStringList со
   со следующими ключевыми возможностями.

    1) Позволяет эффективно расщеплять строку, заданную как набор
  пар "параметр=значение" на строки, аналогично тому, как это делает
  класс TStringList через CommaText. Данное расширение позволяет это 
  делать без обрамление параметров с пробелами и запятыми кавычками. 
  Например, следующая строка будет обработана корректно:

    abc= Привет, медвед!, xyz=Еще строка

  Ограничения:
  
    Имена параметров могу состоять только из малых английских букв и знака
  подчеркивания.

    2) Безопасное взятие строк по номерам,
  даже если число строк меньше указанного.

    3) Установка списка разрешенных имен и взятие значений строк только
  при условии, что имя входит в список разрешенных

    4) procedure UnSort() - выполняет случайную сортировку списка

    5) procedure AddIfNoExist(s:string) - добавляет строку, если IndexOf=-1
}

{$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface
uses Classes ;

type
  TdsOption = (dsCaseIns) ;
  TdsOptions = set of TdsOption ;
  
  { TStringListSmart }

  TStringListSmart = class(TStringList)
  private
    ListValids:TStringList ;
    function GetSafeString(i:Integer):string ;
    function IsValid(const Name:string):Boolean ;
    function GetValidValue(Name: string): string;
    procedure SetValidValue(Name: string; const AValue: string);
  public
    constructor Create ;
    constructor CreateFromFile(const FileName:string) ;
    constructor CreateFromComma(const Comma:string) ;
    constructor CreateAsClone(ListSrc:TStringList) ;
    destructor Destroy ; override ;
    procedure UnSort() ;
    function AddIfNoExist(s:string):Integer ;
    function AddNameOrdered(Name,Value:string):Integer ;
    function FastIndexOfName(Name:string):Integer ;
    procedure AddValidNames(const Valids:array of string) ;
    procedure SetCommaTextSmart(const s:string) ;
    function DelStringIfExist(const s:string; Options:TdsOptions=[]):Boolean ;
    function IndexOfCaseIns(const s:string):Integer ;
    procedure TrimAllLines() ;
    procedure DelEmptyLines() ;
    function GetRandomString():string ;
    procedure AddFmt(const fmt:string; const vars:array of const) ;
    function HasIntersectWith(List:TStringList):Boolean ;
    function CreatePackedWithWrapper(wrapleft,wrapright,sep:string):string ;
    procedure MergeWithNames(List:TStringList) ;
    property SafeStrings[i:Integer]:string read GetSafeString ; default ;
    property ValidValues[Name:string]:string read GetValidValue write SetValidValue ;
  end ;

  TStringListSafe = class(TStringListSmart) ; // Для совместимости 

// Создает как разницу между первым и вторым списком (есть в первом, нет во втором)
function CreateSLSAsDiff(List1,List2:TStringList):TStringListSmart ;
// Создает как сумму первого и второго (без повторов)
function CreateSLSAsSum(List1,List2:TStringList):TStringListSmart ;

implementation
uses RegExpr, SysUtils, StringObject ;

function CreateSLSAsDiff(List1,List2:TStringList):TStringListSmart ;
var i:Integer ;
begin
  Result:=TStringListSmart.Create ;
  for i:=0 to List1.Count-1 do
    if List2.IndexOf(List1[1])=-1 then
      Result.Add(List1[i]) ;
end ;

function CreateSLSAsSum(List1,List2:TStringList):TStringListSmart ;
var i:Integer ;
begin
  Result:=TStringListSmart.Create ;
  for i:=0 to List1.Count-1 do
    if Result.IndexOf(List1[1])=-1 then Result.Add(List1[i]) ;
  for i:=0 to List2.Count-1 do
    if Result.IndexOf(List2[1])=-1 then Result.Add(List2[i]) ;
end ;

constructor TStringListSmart.Create;
begin
  ListValids:=TStringList.Create ;
end;

constructor TStringListSmart.CreateFromFile(const FileName:string) ;
begin
  inherited Create() ;
  if FileExists(FileName) then LoadFromFile(FileName) ;
end ;

constructor TStringListSmart.CreateFromComma(const Comma:string) ;
begin
  inherited Create() ;
  CommaText:=Comma ;
end ;

constructor TStringListSmart.CreateAsClone(ListSrc:TStringList) ;
begin
  inherited Create() ;
  Text:=ListSrc.Text ;
end ;

destructor TStringListSmart.Destroy;
begin
  ListValids.Free ;
  inherited Destroy;
end;

function TStringListSmart.IsValid(const Name: string): Boolean;
begin
  Result:=(ListValids.IndexOf(AnsiLowerCase(Name))<>-1) ;
end;

procedure TStringListSmart.MergeWithNames(List: TStringList);
var i:Integer ;
begin
  for i := 0 to List.Count - 1 do
    if IndexOfName(List.Names[i])<>-1 then
      Values[List.Names[i]]:=List.ValueFromIndex[i]
    else
      Add(List[i]) ;
end;

function TStringListSmart.GetValidValue(Name: string): string;
begin
  if IsValid(Name) then Result:=Values[AnsiLowerCase(Name)]
    else raise Exception.CreateFmt(
      'Ошибка ValidValue: имя %s не указано в списке разрешенных',[Name]) ;
end;

procedure TStringListSmart.SetValidValue(Name: string; const AValue: string);
begin
  if IsValid(Name) then Values[AnsiLowerCase(Name)]:=AValue
    else raise Exception.CreateFmt(
      'Ошибка ValidValue: имя %s не указано в списке разрешенных',[Name]) ;
end;

procedure TStringListSmart.AddValidNames(const Valids: array of string);
var i:Integer ;
begin
  for i:=0 to High(Valids) do
    if not IsValid(Valids[i]) then
      ListValids.Add(Valids[i]) ;
end;

function TStringListSmart.GetSafeString(i:Integer):string ;
begin  
  if i>=Count then Result:='' else Result:=Strings[i] ;
end ;

procedure TStringListSmart.SetCommaTextSmart(const s:string) ;
var R:TRegExpr ;
    str:string ;
    z:Boolean ;
begin
  Clear ;
  R:=TRegExpr.Create ;
  R.Expression:='([\w_]+)\x20*?\=\x20*?(.*?)\x20*?((\,\x20*?[\w_]+)|$)' ;
  
  str:=s ;

  repeat
    z:=False ;
    if R.Exec(str) then begin
      Add(Trim(R.Match[1])+'='+Trim(R.Match[2])) ;
      str:=Copy(str,R.MatchPos[2]+R.MatchLen[2]+1,Length(str)) ;
      z:=True ;
    end ; 
  until not z ; 

  R.Free ;
end ;

procedure TStringListSmart.UnSort() ;
var List:TStringList ;
    cnt,i,j:Integer ;
begin
  Randomize() ;
  List:=TStringList.Create ;
  cnt:=Count ;
  for i:=0 to cnt-1 do begin
    j:=Round(Random(Count)) ;
    List.Add(Strings[j]) ;
    Delete(j) ;
  end ;
  for i:=0 to List.Count-1 do
    Add(List[i]) ;
  List.Free ;
end ;

function TStringListSmart.AddIfNoExist(s:string):Integer ;
begin
  Result:=IndexOf(s) ;
  if Result=-1 then Result:=Add(s) ;
end ;

function TStringListSmart.DelStringIfExist(const s: string;
  Options: TdsOptions): Boolean;
var i:Integer ;
begin
  if dsCaseIns in Options then begin
    for i:=0 to Count-1 do
      if AnsiLowerCase(Strings[i])=AnsiLowerCase(s) then begin
        Delete(i) ; Break ;
      end ;
  end
  else begin
    if IndexOf(s)<>-1 then Delete(IndexOf(s)) ;
  end ;
end;

function TStringListSmart.IndexOfCaseIns(const s: string): Integer;
var i:Integer ;
begin
  Result:=-1 ;
  for i:=0 to Count-1 do
    if AnsiLowerCase(Strings[i])=AnsiLowerCase(s) then begin
      Result:=i ;Break ;
    end ;  
end;

function TStringListSmart.AddNameOrdered(Name,Value:string):Integer ;
var a,b:Integer ;
begin
  if Count=0 then begin
    Result:=0 ;
    Add(Name+'='+Value) ; Exit ;
  end ;
  
  if Names[0]>Name then begin
    Result:=0 ;
    Insert(0,Name+'='+Value) ;
  end
  else
  if Names[Count-1]<Name then begin
    Result:=Count ;
    Insert(Count,Name+'='+Value) ;
  end
  else begin

  a:=0 ;
  b:=Count-1 ;
  repeat
    Result:=(a+b) div 2 ;
    if Names[Result]=Name then Break else
    if Names[Result]<Name then a:=Result else b:=Result ;
  until abs(a-b)<=1 ; 
  if Names[Result]=Name then begin Result:=-1 ; Exit ; end ;
  if (Names[Result]<Name) then Insert(Result+1,Name+'='+Value) else
  if (Names[Result]>Name) then Insert(Result,Name+'='+Value) ;
 
  end ;
end ;

function TStringListSmart.FastIndexOfName(Name:string):Integer ;
var a,b:Integer ;
begin
  if Count=0 then Result:=-1 else 
  if Name<Names[0] then Result:=-1 else
  if Name>Names[Count-1] then Result:=-1 else
  if Name=Names[0] then Result:=0 else
  if Name=Names[Count-1] then Result:=Count-1 else begin
  a:=0 ;
  b:=Count-1 ;
  repeat
    Result:=(a+b) div 2 ;
    if Names[Result]=Name then Exit else
    if Names[Result]<Name then a:=Result else b:=Result ;
  until abs(a-b)<=1 ;
  Result:=-1 ;
  end ;
end ;

procedure TStringListSmart.TrimAllLines() ;
var i:Integer ;
begin
  for i:=0 to Count-1 do Strings[i]:=Trim(Strings[i]) ;
end ;

procedure TStringListSmart.DelEmptyLines() ;
var i:Integer ;
begin
  while i<Count do
    if Trim(Strings[i])='' then Delete(i) else Inc(i) ;
end ;

procedure TStringListSmart.AddFmt(const fmt: string;
  const vars: array of const);
begin
  Add(Format(fmt,vars)) ;
end;

function TStringListSmart.HasIntersectWith(List:TStringList):Boolean ;
//var s1,s2:string ;
var i,j:Integer ;
begin
  Result:=False ;
  for i:=0 to Count-1 do
    for j:=0 to List.Count-1 do
      if Strings[i]=List[j] then begin
        Result:=True ; Exit ;
      end ;

{  for s1 in Self do
    for s2 in List do
      if s1=s2 then begin
        Result:=True ; Exit ;
      end ;}
end ;

function TStringListSmart.CreatePackedWithWrapper(wrapleft,wrapright,sep:string):string ;
var i:Integer ;
    str:TStringObject ;
begin
  str:=NewStrObj() ;
  for i:=0 to Count-1 do
    str.AddWithSep(wrapleft+Strings[i]+wrapright,sep) ;
  Result:=str.s ;
  str.Free ;
end ;

function TStringListSmart.GetRandomString():string ;
begin
  if Count=0 then raise Exception.Create('Cant get random string from empty list') ;
  Result:=Strings[Round(Random(Count))] ;
end ;

end.
