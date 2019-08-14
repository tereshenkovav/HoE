unit CellDict;

interface
uses BattleField, contnrs;

const SZ=200 ;
type
  TCellDict = class
  private
    map:array[0..SZ,0..SZ] of TObjectList ;
  public
    cnt:Integer ;
    procedure AddObject(Cell:TCell; Obj:TObject) ;
    function GetObjectCount(Cell:TCell):Integer ;
    function GetObject(Cell:TCell; i:Integer):TObject ;
    procedure Clear() ;
    constructor Create ;
    destructor Destroy ; override ;
  end;

implementation
uses SysUtils ;

{ TCellDict }

procedure TCellDict.Clear;
var i,j:Integer ;
begin
  for i := 0 to SZ-1 do
    for j := 0 to SZ-1 do
      if Assigned(map[i,j]) then TObjectList(map[i,j]).Clear() ;
  cnt:=0 ;
end;

constructor TCellDict.Create;
begin
  cnt:=0 ;
end;

destructor TCellDict.Destroy;
var i,j:Integer ;
begin
  for i := 0 to SZ-1 do
    for j := 0 to SZ-1 do
      if Assigned(map[i,j]) then map[i,j].Free ;
  inherited Destroy ;
end;

procedure TCellDict.AddObject(Cell: TCell; Obj: TObject);
var List:TObjectList ;
begin
  Inc(cnt) ;
  if not Assigned(map[Cell.CellI,Cell.CellJ]) then begin
    List:=TObjectList.Create(False) ;
    List.Add(obj) ;
    map[Cell.CellI,Cell.CellJ]:=List ;
  end
  else begin
    if TObjectList(map[Cell.CellI,Cell.CellJ]).IndexOf(obj)=-1 then
      TObjectList(map[Cell.CellI,Cell.CellJ]).Add(obj) ;
  end;
end;

function TCellDict.GetObject(Cell: TCell; i: Integer): TObject;
begin
  if not Assigned(map[Cell.CellI,Cell.CellJ]) then Result:=nil else
  if i>=TObjectList(map[Cell.CellI,Cell.CellJ]).Count then Result:=nil else
  Result:=TObjectList(map[Cell.CellI,Cell.CellJ])[i] ;
end;

function TCellDict.GetObjectCount(Cell: TCell): Integer;
var idx:Integer ;
begin
  if not Assigned(map[Cell.CellI,Cell.CellJ]) then Result:=0 else
  Result:=TObjectList(map[Cell.CellI,Cell.CellJ]).Count ;
end;

end.
