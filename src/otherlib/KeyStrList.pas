unit KeyStrList ;

{$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface
uses Classes, SysUtils, KeyAbstractList ;

type

  { TKeyStrList }

  TKeyStrList = class(TKeyAbstractList)
  private
    function GetKey(i: Integer): string ;
    function GetValue(key: string): Integer;
    function GetValueFromIndex(i: Integer): Integer;
    procedure SetValue(key: string; const AValue: Integer);
  public
    function Add(AKey:string; AValue:Integer):Integer ;
    procedure Inc(AKey:string; AInc:Integer=1) ;
    procedure SaveToFile(filename:string) ;
    procedure SortByValue(Desc:Boolean=False) ;
    property Key[i:Integer]:string read GetKey ;
    property ValueFromIndex[i:Integer]:Integer read GetValueFromIndex ;
    property Value[key:string]:Integer read GetValue write SetValue ; default ;
  end ;

  { TKey2IntList }
{
  TKey2IntList = class(TKeyAbstractList)
  private
    function GetValue(key1,key2: Integer): Integer;
    procedure SetValue(key1,key2: Integer; const AValue: Integer);
  public
    function Add(AKey1,AKey2,AValue:Integer):Integer ;
    property Value[key1,key2:Integer]:Integer read GetValue write SetValue ;
  end ;
}
implementation
uses simple_oper ;

function funcSortByValueDesc(List:TStringList; i1,i2:Integer):Integer ;
var n1,n2:Integer ;
begin
  n1:=StrToIntWt0(List.ValueFromIndex[i1]) ;
  n2:=StrToIntWt0(List.ValueFromIndex[i2]) ;
  if n1<n2 then Result:=1 else
  if n1>n2 then Result:=-1 else
  Result:=0 ;
end;

function funcSortByValueAsc(List:TStringList; i1,i2:Integer):Integer ;
begin
  Result:=-funcSortByValueDesc(List,i1,i2) ;
end;

{ TKeyStrList }

function TKeyStrList.GetKey(i: Integer): string ;
begin  Result:=(List.Names[i]); end;

function TKeyStrList.GetValue(key: string): Integer;
begin  Result:=StrToIntWt0(List.Values[key]); end;

function TKeyStrList.GetValueFromIndex(i: Integer): Integer;
begin  Result:=StrToIntWt0(List.Values[List.Names[i]]); end;

procedure TKeyStrList.SaveToFile(filename: string);
begin
  List.SaveToFile(filename);
end;

procedure TKeyStrList.SetValue(key: string; const AValue: Integer);
begin  List.Values[(key)]:=IntToStrWt0(AValue) ; end;

procedure TKeyStrList.SortByValue(Desc: Boolean=False);
begin
  {$ifdef fpc}
  if Desc then
    List.CustomSort(@funcSortByValueDesc)
  else
    List.CustomSort(@funcSortByValueAsc);
  {$else}
  if Desc then
    List.CustomSort(funcSortByValueDesc)
  else
    List.CustomSort(funcSortByValueAsc);
  {$endif}
end;

function TKeyStrList.Add(AKey:string; AValue: Integer): Integer;
begin  List.Add(Format('%s=%d',[(AKey),AValue])) ; end;

procedure TKeyStrList.Inc(AKey:string; AInc:Integer=1) ;
begin  Value[AKey]:=Value[(AKey)]+AInc ; end;

{ TKey2IntList }

{
function TKey2IntList.GetValue(key1,key2: Integer): Integer;
begin
  Result:=StrToIntWt0(List.Values[Format('%d_%d',[key1,key2])]) ;
end ;

procedure TKey2IntList.SetValue(key1,key2: Integer; const AValue: Integer);
begin
  List.Values[Format('%d_%d',[key1,key2])]:=IntToStrWt0(AValue) ;
end ;

function TKey2IntList.Add(AKey1,AKey2,AValue:Integer):Integer ;
begin
  Value[AKey1,AKey2]:=AValue ;
end ;
}
end.
