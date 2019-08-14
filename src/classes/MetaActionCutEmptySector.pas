unit MetaActionCutEmptySector;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionCutEmpty = class(TMetaAction)
  private
  public
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, MonsterUnits, ObjModule, EmptyPlace ;

{ TMetaActionCutEmpty }

function TMetaActionCutEmpty.Apply(Cell: TCell): Boolean;
begin
  Result:=False ;
  if not Cell.IsSpace() then Exit ;
  if TEmptyPlace(Cell._Object).Fixed then Exit ;  

  Cell.ClearObject() ;
  Cell.ShowEmptyClearing:=1 ;
  Result:=True ;
end;

function TMetaActionCutEmpty.CanApplyToCell(Cell: TCell;
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

  RegisterMetaAction(TMetaActionCutEmpty) ;

end.
