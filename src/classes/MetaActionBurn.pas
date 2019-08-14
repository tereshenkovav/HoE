unit MetaActionBurn;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionBurn = class(TMetaAction)
  private
  public
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, MonsterUnits, ObjModule ;

{ MetaActionBurn }

function TMetaActionBurn.Apply(Cell: TCell): Boolean;
begin
  Result:=False ;
  if not Cell.IsMonster() then Exit ;

  TMonsterUnit(Cell._Object).Burn() ;

  Result:=True ;
end;

function TMetaActionBurn.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsMonster then begin
    Result:=False ;
    errmsg:='Нет врагов для поджигания' ;
  end
  else
    Result:=True ;
end;

initialization

  RegisterMetaAction(TMetaActionBurn) ;

end.
