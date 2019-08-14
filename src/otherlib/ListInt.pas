unit ListInt;

{$IFDEF FPC}  {$MODE Delphi}{$H+} {$ENDIF}

{
     Примечание:
     Класс в его текущей реализации (с наследованием от
   TStringList и использованием строк для хранения чисел)
   очень медленный. Не рекомендуется использовать для
   критичных по времени алгоритмов. 

   01.04.2010 (не шутка :-))
     - Добавлены функции
     function GetRandomItem():Integer ;
     function CreateRandomList(SelCount:Integer):TListInt ;

   04.02.2009
     - function CreateIntersectWith(LI:TListInt):TListInt ;

   18.02.2008
     - Добавлен метод Sort
     - Добавлен метод IsEmpty
     
   04.09.2007
     - Добавлена процедура Invert, включающая элемент
     если его нет, и убирающая, если есть.
}

interface
uses Classes ;

type

  { TListInt }

  TListInt = class(TStringList)
  private
    function GetItems(i: Integer): Integer;
    procedure SetItems(i: Integer; const Value: Integer);
    function GetPackedInts: string;
    procedure SetPackedInts(const Value: string);
  public
    function CreateNewByPosAndSize(const pos,size:Integer):TListInt ;
    function Add(const A:Integer):Integer ;
    function AddIfNoExist(const A:Integer):Integer ;
    procedure AddFrom(LIsrc:TListInt) ;
    procedure AddInterval(start,finish:Integer) ;
    function Delete(const A:Integer): Boolean ;
    procedure Invert(const A:Integer) ;
    function IsElemIn(const A:Integer): Boolean ;
    function PackedWithSep(const sep:char):string ;
    procedure Sort(const IsAsc:Boolean=True) ; 
    function IsEmpty: Boolean ;
    function CreateIntersectWith(LI:TListInt):TListInt ;
    procedure DelList(LI:TListInt) ;
    function GetRandomItem():Integer ;
    function CreateRandomList(SelCount:Integer):TListInt ;
    constructor Create ; overload ;
    constructor Create(const APackedInts:string) ; overload ;
    function CreateClone():TListInt ;
    procedure DeleteFirst() ; 
    property PackedInts:string read GetPackedInts write SetPackedInts ;
    property Items[i:Integer]:Integer read GetItems write SetItems ; default ;
  end ;

  TLIHelper = class
  private
  public
    class function Max(LI:TListInt):Integer ;
    class function Min(LI:TListInt):Integer ;
    class function Avg(LI:TListInt):Single ;
    class procedure AddInt(LI:TListInt; a:Integer) ;
  end ;

implementation
uses SysUtils, simple_oper ;

{ TListInt }

function TListInt.Add(const A: Integer): Integer;
begin
  Result:=inherited Add(IntToStr(A)) ;
end;

procedure TListInt.AddInterval(start,finish:Integer) ;
var i:Integer ;
begin
  for i:=start to finish do Add(i) ;  
end ;

function TListInt.AddIfNoExist(const A:Integer):Integer ;
begin
  if IsElemIn(A) then Result:=-1 else Result:=Add(A) ;
end ;

function TListInt.Delete(const A: Integer): Boolean;
begin
  Result:=True ;
  if IndexOf(IntToStr(A))<>-1 then
    inherited Delete(IndexOf(IntToStr(A)))
  else
    Result:=False ;  
end;

procedure TListInt.DeleteFirst;
begin
  inherited Delete(0) ;
end;

function TListInt.GetItems(i: Integer): Integer;
begin
  Result:=StrToInt(Strings[i]) ;
end;

procedure TListInt.SetItems(i: Integer; const Value: Integer);
begin
  Strings[i]:=IntToStr(Value) ;
end;

function TListInt.GetPackedInts: string;
begin
  Result:=CommaText ;
end;
 
procedure TListInt.SetPackedInts(const Value: string);
begin
  CommaText:=Value ;
end;

procedure TListInt.Sort(const IsAsc:Boolean=True) ;
var i,j:Integer ;    
    m_i:Integer ;
    t:Integer ;
begin
  if Count<=1 then Exit ;

  for j:=0 to Count-1 do begin
    m_i:=j ;
    //Writeln(j,' ',Count) ;
    for i:=j to Count-1 do
      if IsAsc then begin
        if Items[m_i]>Items[i] then m_i:=i ;
      end
      else begin
         if Items[m_i]<Items[i] then m_i:=i ;
      end ;
      t:=Items[j] ; Items[j]:=Items[m_i] ; Items[m_i]:=t ;
  end ;      
end ;
 
function TListInt.IsElemIn(const A: Integer): Boolean;
begin
  Result:=(IndexOf(IntToStr(A))<>-1) ;
end;

function TListInt.IsEmpty: Boolean ;
begin  Result:=(Count=0) ; end ;

function TListInt.CreateIntersectWith(LI: TListInt): TListInt;
var i:Integer ;
begin
  Result:=TListInt.Create ;
  for i:=0 to Count-1 do
    if LI.IsElemIn(Items[i]) and (not Result.IsElemIn(Items[i])) then
      Result.Add(Items[i]) ;
end;

procedure TListInt.DelList(LI:TListInt) ;
var i:Integer ;
begin
  for i:=0 to LI.Count-1 do Delete(LI[i]) ;
end ;

function TListInt.GetRandomItem():Integer ;
begin
  Result:=Items[Round(Random(Count))] ;
end ;

{
   Текущая реализация алгоритма очень медленная и подразумевает, что все
   элементы в списке уникальны
}

function TListInt.CreateRandomList(SelCount:Integer):TListInt ;
var i,j,newselcount:Integer ;
begin
  if SelCount>Count then newselcount:=Count else newselcount:=SelCount ;
  Result:=TListInt.Create ;
  for i := 0 to newselcount - 1 do begin
    repeat  j:=GetRandomItem() ; until not Result.IsElemIn(j) ;
    Result.Add(j) ;
  end;
end ;

constructor TListInt.Create;
begin
  inherited Create ;
end;

constructor TListInt.Create(const APackedInts: string);
begin
  Create ;
  PackedInts:=APackedInts ;
end;

function TListInt.CreateNewByPosAndSize(const pos, size: Integer): TListInt;
var i:Integer ;
begin
  Result:=TListInt.Create ;
  i := (pos-1)*size ;
  while (i<Count)and(i<pos*size) do begin
    Result.Add(Items[i]) ; Inc(i) ;
  end;
end;

function TListInt.PackedWithSep(const sep: char): string;
var i:Integer ;
begin
  Result:='' ;
  for i:=0 to Count-1 do
    Result:=Result+Alternate(Result<>'',sep,'')+Strings[i] ;
end;

procedure TListInt.Invert(const A: Integer);
begin
  if IsElemIn(A) then Delete(A) else Add(A) ;
end;

function TListInt.CreateClone():TListInt ;
begin
  Result:=TListInt.Create(Self.PackedInts) ;
end ;

class function TLIHelper.Max(LI:TListInt):Integer ;
var i:Integer ;
begin
  Result:=Low(Integer) ;
  for i:=0 to LI.Count-1 do
    if Result<LI[i] then Result:=LI[i] ;
end ;

class function TLIHelper.Min(LI:TListInt):Integer ;
var i:Integer ;
begin
  Result:=High(Integer) ;
  for i:=0 to LI.Count-1 do
    if Result>LI[i] then Result:=LI[i] ;
end ;

class function TLIHelper.Avg(LI:TListInt):Single ;
var i:Integer ;
    sum:Cardinal ;
begin
  Result:=0 ;
  sum:=0 ;
  for i:=0 to LI.Count-1 do Inc(sum,LI[i]) ;
  Result:=sum/LI.Count ;
end ;

class procedure TLIHelper.AddInt(LI:TListInt; a:Integer) ;
var i:Integer ;
begin
  for i:=0 to LI.Count-1 do LI[i]:=LI[i]+a ;
end ;

procedure TListInt.AddFrom(LIsrc: TListInt);
var i:Integer ;
begin
  for i:=0 to LIsrc.Count-1 do Add(LIsrc[i]) ;
end;

end.
