unit CellFinder ;

interface
uses BattleField, GameObject, contnrs ;

type
  TProcOnWay = procedure(CellTek:TCell) of object ;

  TSearchMode = (smWideSearch,smWaySearch) ;
  TBreakOnThrow = (DoBreakOnThrow,NoBreakOnThrow) ;

  TDirThrowParams = (dtpToMonster,dtpToSpace,dtpBoth,dtpNone) ;

  TCellFinder = class
  private
    GList:TCellListNoOwn ;
    GListWay:TCellListNoOwn ;
    GListWayTmp:TCellListNoOwn ;
    TargetCell:TCell ;
    WalkedObject:TGameObject ;
    callcnt:Integer ;
    procedure ExecRecurseWay(Cell:TCell; dist:Integer;
      Params:TSearchParams; procOnWay:TProcOnWay) ;
    procedure CopyWayIfNeed(CellTek:TCell) ;
    procedure intAddAllLinked(List:TCellListNoOwn; circle:TCellListNoOwn; dist:Integer) ;
    procedure ExecWave(Wave:TObjectList; Params: TSearchParams);
  public
    function GetCellsOnDistN(CellStart: TCell;
      dist: Integer; Params:TSearchParams=[]): TCellListNoOwn;
    function CreateListCellsOnWay(CellStart,CellFinish: TCell;
      maxdist:Integer; Params:TSearchParams=[]): TCellListNoOwn;
    function CreateListCellsRadials(CellStart:TCell;
      dist:Integer; Params:TDirThrowParams; BreakOnThrow:TBreakOnThrow):TCellListNoOwn ;
    function CalcDirFromToCell(CellFrom,CellTo:TCell):Integer ;
    function FastGetAllCellsOnRadius(CellStart:TCell; maxdist:Integer):TCellListNoOwn ;
  end ;

function GetCellFinder():TCellFinder ;

implementation
uses CellBuilder, TAVHGEUtils, StepRules, PonyUnits, ObjModule ;

var
  GCellFinder:TCellFinder ;

function GetCellFinder():TCellFinder ;
begin
  if GCellFinder=nil then GCellFinder:=TCellFinder.Create ;
  Result:=GCellFinder ;
end ;

function tmpStarBearLimitWay(Cell:TCell;GO:TGameObject):Boolean ;
var FlatterCell:TCell ;
begin
  Result:=False ;
  if not(GO is TPonyUnit) then Exit ;
  if TPonyUnit(GO).Code<>'bear' then Exit ;

  if not BF.GetObjectCell('flatter',FlatterCell) then Exit ;

  if Cell.CalcCDistanceTo(FlatterCell)>3 then Result:=True ;
end;


type
  TWCell = class
  public
    Cell:TCell ;
    w:Integer ;
    constructor Create(ACell:TCell; Aw:Integer) ;
    procedure setW(Aw:Integer) ;
  end;

constructor TWCell.Create(ACell:TCell; Aw:Integer) ;
begin
  setW(Aw) ;
  Cell:=ACell ;
end;

procedure TCellFinder.ExecWave(Wave:TObjectList; Params: TSearchParams);
var i,j,k:Integer ;
    d:Integer ;
    WCell:TWCell ;
    NewWave:TObjectList ;
    find:Boolean ;
begin
  NewWave:=TObjectList.Create ;

  for i := 0 to Wave.Count - 1 do begin
    WCell:=TWCell(Wave[i]) ;
    if WCell.w=0 then Continue ;

    for j:=0 to WCell.Cell.GetLinkCount()-1 do begin
      if GList.IsObjectIn(WCell.Cell.GetLinked(j)) then Continue ;

      if not(WCell.Cell.GetLinked(j).IsEmpty or (spIncludeBusyCell in Params)) then Continue ;

      if Assigned(WalkedObject) and (not(spIgnoreTerrain in Params)) then begin
        if not TStepRules.IsPassed(WCell.Cell.GetLinked(j)._Terrain,WalkedObject) then Continue ;
        if tmpStarBearLimitWay(WCell.Cell.GetLinked(j),WalkedObject) then Continue ;
      end;

      if spIgnoreTerrain in Params then
        d:=1
      else begin
        if Assigned(WalkedObject) then begin
          d:=TStepRules.GetStepNeed(WCell.Cell.GetLinked(j)._Terrain,WalkedObject) ;
          if not WalkedObject.IsFlyer then
            if WCell.Cell.GetLinked(j).IsSlowdownCell() then d:=6 ;
        end
        else
          d:=1 ;
      end;

      find:=False ;
      for k := 0 to NewWave.Count - 1 do
        if WCell.Cell.GetLinked(j)=TWCell(NewWave[k]).Cell then begin
          if TWCell(NewWave[k]).w<WCell.w-d then
            TWCell(NewWave[k]).setW(WCell.w-d) ;
          find:=True ;
          Break ;
        end;
      if not find then
        NewWave.Add(TWCell.Create(WCell.Cell.GetLinked(j),WCell.w-d)) ;

    end;
  end;

  for i := 0 to NewWave.Count - 1 do
    GList.Add(TWCell(NewWave[i]).Cell) ;

  if NewWave.Count>0 then ExecWave(NewWave,params) ;

  NewWave.Free ;
end;

procedure TCellFinder.ExecRecurseWay(Cell: TCell; dist: Integer;
  Params: TSearchParams; procOnWay: TProcOnWay);
var i:Integer ;
    d:Integer ;
    z:Boolean ;
begin
  Inc(callcnt) ;
  GListWayTmp.Add(Cell) ;
  for i:=0 to Cell.GetLinkCount()-1 do begin
    if (GListWay.Count<=GList.Count)and(GListWay.Count>0) then Continue ;

    if not(Cell.GetLinked(i).IsEmpty or (spIncludeBusyCell in Params)) then Continue ;

    if Assigned(WalkedObject) and (not(spIgnoreTerrain in Params)) then begin
      if not TStepRules.IsPassed(Cell.GetLinked(i)._Terrain,WalkedObject) then Continue ;
      if tmpStarBearLimitWay(Cell.GetLinked(i),WalkedObject) then Continue ;
    end;

      z:=GList.IsObjectIn(Cell.GetLinked(i));
      if not z then begin
        GList.Add(Cell.GetLinked(i)) ;
        if Assigned(procOnWay) then procOnWay(Cell.getLinked(i)) ;

        if spIgnoreTerrain in Params then
          d:=1
        else begin
        if Assigned(WalkedObject) then begin
          d:=TStepRules.GetStepNeed(Cell.GetLinked(i)._Terrain,WalkedObject) ;
          if not WalkedObject.IsFlyer then
            if Cell.GetLinked(i).IsSlowdownCell() then d:=6 ;
        end
        else
          d:=1 ;
        end;

        if dist>d then
          if not GListWayTmp.IsObjectIn(Cell.GetLinked(i)) then
            ExecRecurseWay(Cell.GetLinked(i),dist-d,params,procOnWay) ;

        GList.Delete(Cell.GetLinked(i));
      end ;
  end;
  GListWayTmp.Delete(Cell);
end;

function TCellFinder.FastGetAllCellsOnRadius(CellStart: TCell;
  maxdist: Integer): TCellListNoOwn;
var ListWay:TCellListNoOwn ;
    circle:TCellListNoOwn ;
begin
  ListWay:=TCellListNoOwn.Create() ;
  ListWay.Add(CellStart) ;
  circle:=TCellListNoOwn.Create() ;
  circle.Add(CellStart) ;
  intAddAllLinked(ListWay,circle,maxdist) ;
  circle.Free ;
  Result:=ListWay ;
end;

function TCellFinder.GetCellsOnDistN(CellStart: TCell;
  dist: Integer; Params:TSearchParams=[]): TCellListNoOwn;
var Wave:TObjectList ;
begin
  Wave:=TObjectList.Create() ;
  Wave.Add(TWCell.Create(CellStart,dist)) ;
  GList:=TCellListNoOwn.Create() ;
  GList.Add(CellStart) ;
  WalkedObject:=CellStart._Object ;
  ExecWave(Wave,Params) ;

  Result:=GList ;

  Wave.Free ;
end;

procedure TCellFinder.intAddAllLinked(List: TCellListNoOwn; circle:TCellListNoOwn;
  dist:Integer);
var i,j:Integer ;
    tmp:TCellListNoOwn ;
begin
  if dist=0 then Exit ;

  tmp:=TCellListNoOwn.Create ;

  for j := 0 to circle.Count - 1 do
    for i := 0 to circle[j].GetLinkCount - 1 do
      if not List.IsObjectIn(circle[j].GetLinked(i)) then begin
        List.AddIfNoExist(circle[j].GetLinked(i)) ;
        tmp.Add(circle[j].GetLinked(i)) ;
      end;

  intAddAllLinked(List,tmp,dist-1) ;

  tmp.Free ;
end;

// Код забран в TCellBuilder
function TCellFinder.CalcDirFromToCell(CellFrom, CellTo: TCell): Integer;
begin
  Result:=TCellBuilder.calcDirection(CellFrom,CellTo) ;
end;

procedure TCellFinder.CopyWayIfNeed(CellTek: TCell);
begin
  if CellTek=TargetCell then
    if (GListWay.Count>GList.Count)or(GListWay.Count=0) then begin
      GListWay.Clear ;
      GListWay.AddNoExistFrom(GList) ;
    end ;
end;

function TCellFinder.CreateListCellsRadials(CellStart: TCell; dist: Integer;
  Params: TDirThrowParams; BreakOnThrow:TBreakOnThrow): TCellListNoOwn;
var i,dir:Integer ;
    TekCell,Cell:TCell ;
    z:Boolean ;
begin
  Result:=TCellListNoOwn.Create() ;

  for dir := 0 to 5 do begin
    TekCell:=CellStart ;
    for i := 1 to dist do begin
      Cell:=TekCell.GetLinkByDir(dir) ;
      if Cell=nil then Break ;

      case Params of
        dtpToMonster: z:=Cell.IsMonster() ;
        dtpToSpace: z:=Cell.IsSpace() ;
        dtpBoth: z:=Cell.IsSpace() or Cell.IsMonster ;
        else z:=False ;
      end ;

      if Params<>dtpNone then
        if not(Cell.IsEmpty() or z) then Break ;

      Result.Add(Cell) ;
      if z and (BreakOnThrow=DoBreakOnThrow) then Break ;

      TekCell:=Cell ;
    end;
  end ;
end;

function TCellFinder.CreateListCellsOnWay(CellStart,CellFinish: TCell;
  maxdist:Integer; Params:TSearchParams=[]): TCellListNoOwn;
begin
  callcnt:=0 ;
  WalkedObject:=CellStart._Object ;
  GListWayTmp:=TCellListNoOwn.Create ;
  GList:=TCellListNoOwn.Create() ;
  GListWay:=TCellListNoOwn.Create ;

  TargetCell:=CellFinish ;
  if maxdist>0 then ExecRecurseWay(CellStart,maxdist,params,CopyWayIfNeed) ;

  Result:=GListWay ;
  GList.Free ;
  GListWayTmp.Free ;
  //mHGE.System_Log('callcnt: %d',[callcnt]);
end;

procedure TWCell.setW(Aw: Integer);
begin
  w:=Aw ;
  if w<0 then w:=0 ;  
end;

end.