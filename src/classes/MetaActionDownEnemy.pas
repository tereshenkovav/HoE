unit MetaActionDownEnemy;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionDownEnemy = class(TMetaAction)
  private
    DownTime:Integer ;
    Divide:Integer ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, MonsterUnits ;

{ TMetaActionSleep }

function TMetaActionDownEnemy.Apply(Cell: TCell): Boolean;
begin
  if Cell.IsMonster then begin
    TMonsterUnit(Cell._Object).DoDown(DownTime,Divide) ;
    Result:=True ;
  end
  else
    Result:=False ;
end;

function TMetaActionDownEnemy.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsMonster then begin
    Result:=False ;
    errmsg:='Нет врагов для поражения' ;
  end
  else
    Result:=True ;

end;

constructor TMetaActionDownEnemy.Create(Params: TStringList);
begin
  inherited Create(Params);
  DownTime:=StrToIntWt0(Params.Values['DownTime']) ;
  Divide:=StrToIntWt0(Params.Values['Divide']) ;  
end;

initialization

  RegisterMetaAction(TMetaActionDownEnemy) ;

end.
