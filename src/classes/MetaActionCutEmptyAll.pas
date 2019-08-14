unit MetaActionCutEmptyAll;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionCutEmptyAll = class(TMetaAction)
  private
  public
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, MonsterUnits, ObjModule ;

{ TMetaActionCutEmptyAll }

function TMetaActionCutEmptyAll.Apply(Cell: TCell): Boolean;
var i:Integer ;
begin
  Result:=False ;
  if not Cell.IsSpace() then Exit ;

  for i:=0 to BF.CellCount-1 do
    if BF.GetCell(i).IsSpace() then begin
      BF.GetCell(i).ClearObject() ;
      BF.GetCell(i).ShowEmptyClearing:=1 ;
    end;
  Result:=True ;
end;

function TMetaActionCutEmptyAll.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsSpace() then begin
    Result:=False ;
    errmsg:='Нет Пустоты для очистки' ;
  end
  else
    Result:=True ;
end;

initialization

  RegisterMetaAction(TMetaActionCutEmptyAll) ;

end.
