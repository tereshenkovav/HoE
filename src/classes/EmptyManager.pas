unit EmptyManager ;

interface
uses BattleField, KeyIntList ;

type
  TEmptyManager = class
  private
    ListDirVer:TKeyIntList ;
    _BF:TBattleField ;
    ListProtectedCells:TCellListNoOwn ;
    procedure SetEmptyToCells(List:TCellListNoOwn; out IsDefeat:Boolean) ;
    procedure DoProcessEmptyCell(Cell:TCell; ListNew:TCellListNoOwn) ;
  public
    constructor Create(BF:TBattleField) ;
    destructor Destroy ; override ;
    procedure NextStep(out IsDefeat:Boolean) ;
    function GetDirVer(dir:Integer):Integer ;
    procedure SetDirVer(dir:Integer; ver:Integer) ;
  end ;

const
  DEFAULT_ANYDIR_VER=30 ;
  
implementation
uses Classes, SysUtils, Buildings, EmptyPlace, PonyUnits, CommonProc,
  GameObject, NeutralUnits, MonsterUnits, ObjModule, Player ;

constructor TEmptyManager.Create(BF:TBattleField) ;
var i:Integer ;
begin
  ListDirVer:=TKeyIntList.Create ;
  for i := 0 to 5 do
    ListDirVer.Value[i]:=DEFAULT_ANYDIR_VER ;

  _BF:=BF ;
end ;

destructor TEmptyManager.Destroy;
begin
  ListDirVer.Free ;
  inherited Destroy ;
end;

procedure TEmptyManager.DoProcessEmptyCell(Cell: TCell;
  ListNew: TCellListNoOwn);
var dir:Integer ;
    fix:Single ;
begin
  // В казуальном режиме и ниже, Пустота на 40% медленнее
  fix:=1 ;
  if PL.GetHardLevel()<=hlCasual then fix:=0.60 ;
  // Механизм движения пустоты - данная реализация, полностью случайна
  for dir := 0 to 5 do
    if Cell.GetLinkByDir(dir)<>nil then
      if not Cell.GetLinkByDir(dir).IsSpace() then
        if Random(100)<Round(fix*GetDirVer(dir)) then
          if not ListProtectedCells.IsObjectIn(Cell.GetLinkByDir(dir)) then
            ListNew.AddIfNoExist(Cell.GetLinkByDir(dir)) ;
end;

function TEmptyManager.GetDirVer(dir: Integer): Integer;
begin
  Result:=ListDirVer.Value[dir] ;
end;

procedure TEmptyManager.NextStep(out IsDefeat:Boolean) ;
var i:Integer ;
    ListNewEmpty:TCellListNoOwn ;
begin
  IsDefeat:=False ;

  ListProtectedCells:=_BF.CreateProtectedCellList() ;

  // Основной код размножения пустоты
  Randomize ;
  ListNewEmpty:=TCellListNoOwn.Create;
  for i := 0 to _BF.CellCount - 1 do
    if not _BF.GetCell(i).IsEmpty then
      if _BF.GetCell(i)._Object is TEmptyPlace then
        DoProcessEmptyCell(_BF.GetCell(i),ListNewEmpty) ;

  SetEmptyToCells(ListNewEmpty,IsDefeat) ;

  ListNewEmpty.Free ;
  ListProtectedCells.Free ;
end ;

procedure TEmptyManager.SetDirVer(dir, ver: Integer);
begin
  ListDirVer.Value[dir]:=ver ;
end;

procedure TEmptyManager.SetEmptyToCells(List: TCellListNoOwn; out IsDefeat:Boolean);
var i:Integer ;
begin
  for i := 0 to List.Count - 1 do begin
    if not List[i].IsEmpty then begin
      if List[i]._Object is TPonyUnit then begin
        if not TPonyUnit(List[i]._Object).DeathAllow then begin
          SetResultMsg('Причина поражения: '+TPonyUnit(List[i]._Object).Name+
             ' зависла в Пустоте.') ;
          IsDefeat:=True ;
        end ;
      end;
      if List[i]._Object is TNeutralUnit then begin
        if TNeutralUnit(List[i]._Object).IsMustSurvive() then begin
          SetResultMsg('Причина поражения: '+TNeutralUnit(List[i]._Object).Name+
           ' завис в Пустоте.') ;
          IsDefeat:=True ;
        end;
      end;
      if List[i]._Object is TBuilding then begin
        if TBuilding(List[i]._Object).IsMustSurvive() then begin
          SetResultMsg('Причина поражения: '+TBuilding(List[i]._Object).Name+
           ' завис в Пустоте.') ;
          IsDefeat:=True ;
        end;
      end;
      if List[i]._Object is TMonsterUnit then begin
        if TMonsterUnit(List[i]._Object).IsMustSurvive() then begin
          SetResultMsg('Причина поражения: '+TMonsterUnit(List[i]._Object).Name+
           ' завис в Пустоте.') ;
          IsDefeat:=True ;
        end;
      end;

    end;

    if _BF.getActiveCell=List[i] then
      _BF.clearActiveCell() ;

    List[i].ClearObject;
    _BF.AddGameObject(TEmptyPlace.Create(GetEmptyParams),List[i]) ;
  end;

end;

end.