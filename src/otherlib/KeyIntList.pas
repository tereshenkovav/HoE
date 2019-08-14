unit KeyIntList ;

{$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface
uses Classes, SysUtils, KeyAbstractList ;

type

  TKILSortMode = (ksmAsc,ksmDesc) ;

  { TKeyIntList }

  TKeyIntList = class(TKeyAbstractList)
  private
    function GetKey(i: Integer): Integer;
    function GetValue(key: Integer): Integer;
    function GetValueFromIndex(i: Integer): Integer;
    procedure SetValue(key: Integer; const AValue: Integer);
  public
    function Add(AKey,AValue:Integer):Integer ;
    procedure Inc(AKey:Integer; AInc:Integer=1) ;
    function GetPacked():string ;
    procedure Delete(Key:Integer) ;
    procedure SetPacked(packedstr:string) ;
    procedure DoSortByValue(sortmode:TKILSortMode) ;
    procedure DoSortByKey(sortmode:TKILSortMode) ;
    property Key[i:Integer]:Integer read GetKey ;
    property ValueFromIndex[i:Integer]:Integer read GetValueFromIndex ;
    property Value[key:Integer]:Integer read GetValue write SetValue ; default ;
  end ;

  { TKey2IntList }

  TKey2IntList = class(TKeyAbstractList)
  private
    function GetValue(key1,key2: Integer): Integer;
    procedure SetValue(key1,key2: Integer; const AValue: Integer);
  public
    function GetPacked():string ;
    function Add(AKey1,AKey2,AValue:Integer):Integer ;
    function Inc(AKey1,AKey2:Integer; AInc:Integer=1):Integer ;
    property Value[key1,key2:Integer]:Integer read GetValue write SetValue ; default ;
  end ;

implementation
uses simple_oper, StringObject, TAVStrUtils ;

{ TKeyIntList }

function TKeyIntList.GetKey(i: Integer): Integer;
begin  Result:=StrToIntWt0(List.Names[i]); end;

function TKeyIntList.GetValue(key: Integer): Integer;
begin  Result:=StrToIntWt0(List.Values[IntToStr(key)]); end;

function TKeyIntList.GetValueFromIndex(i: Integer): Integer;
begin  Result:=StrToIntWt0(List.Values[List.Names[i]]); end;

procedure TKeyIntList.SetValue(key: Integer; const AValue: Integer);
begin  List.Values[IntToStr(key)]:=IntToStrWt0(AValue) ; end;

function TKeyIntList.Add(AKey, AValue: Integer): Integer;
begin  List.Add(Format('%d=%d',[AKey,AValue])) ; end;

procedure TKeyIntList.Inc(AKey:Integer; AInc:Integer=1) ;
begin  Value[AKey]:=Value[AKey]+AInc ; end;

procedure TKeyIntList.Delete(Key:Integer) ;
begin  
  if List.IndexOfName(IntToStr(Key))<>-1 then List.Delete(List.IndexOfName(IntToStr(Key))) ;
end ;

function TKeyIntList.GetPacked():string ;
var i:Integer ;
    str:TStringObject ;
begin
  str:=NewStrObj() ;
  for i:=0 to Count-1 do
    str.AddWithSep(Format('%d=%d',[Key[i],ValueFromIndex[i]]),',') ;
  Result:=str.s ;
  str.Free ;
end ;

procedure TKeyIntList.SetPacked(packedstr:string) ;
var i:Integer ;
    tmp:TStringList ;
begin
  Clear ;
  tmp:=CreateStringListBySep(packedstr,',') ;
  for i:=0 to tmp.Count-1 do
    Add(StrToInt(tmp.Names[i]),StrToInt(tmp.Values[tmp.Names[i]])) ;
  tmp.Free ;
end ;

function CustomSortByValueAsc(List:TStringList; i1,i2:Integer):Integer ;
begin
  Result:=StrToIntWt0(List.Values[List.Names[i1]])-StrToIntWt0(List.Values[List.Names[i2]]) ;
end ;

function CustomSortByValueDesc(List:TStringList; i1,i2:Integer):Integer ;
begin
  Result:=-(StrToIntWt0(List.Values[List.Names[i1]])-StrToIntWt0(List.Values[List.Names[i2]])) ;
end ;

function CustomSortByNameAsc(List:TStringList; i1,i2:Integer):Integer ;
begin
  Result:=StrToIntWt0(List.Names[i1])-StrToIntWt0(List.Names[i2]) ;
end ;

function CustomSortByNameDesc(List:TStringList; i1,i2:Integer):Integer ;
begin
  Result:=-(StrToIntWt0(List.Names[i1])-StrToIntWt0(List.Names[i2])) ;
end ;

procedure TKeyIntList.DoSortByValue(sortmode:TKILSortMode) ;
begin
  case sortmode of
    ksmAsc: List.CustomSort(@CustomSortByValueAsc) ;
    ksmDesc: List.CustomSort(@CustomSortByValueDesc) ;
  end ;
end ;

procedure TKeyIntList.DoSortByKey(sortmode:TKILSortMode) ;
begin
  case sortmode of
    ksmAsc: List.CustomSort(@CustomSortByNameAsc) ;
    ksmDesc: List.CustomSort(@CustomSortByNameDesc) ;
  end ;
end ;


{ TKey2IntList }

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

function TKey2IntList.Inc(AKey1,AKey2:Integer; AInc:Integer=1):Integer ;
begin
  Value[AKey1,AKey2]:=Value[AKey1,AKey2]+AInc ;
end ;

function TKey2IntList.GetPacked: string;
var i:Integer ;
    str:TStringObject ;
begin
  str:=NewStrObj() ;
  for i:=0 to List.Count-1 do
    str.AddWithSep(List[i],',') ;
  Result:=str.s ;
  str.Free ;
end;

end.
