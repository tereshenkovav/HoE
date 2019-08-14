unit MetaActionFreeze;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionFreeze = class(TMetaAction)
  private
    FreezeTime:Integer ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, MonsterUnits ;

{ TMetaActionFreeze }

function TMetaActionFreeze.Apply(Cell: TCell): Boolean;
begin
  if Cell.IsMonster then begin
    TMonsterUnit(Cell._Object).Freeze(FreezeTime) ;
    Result:=True ;
  end
  else
    Result:=False ;
end;

function TMetaActionFreeze.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsMonster then begin
    Result:=False ;
    errmsg:='Нет врагов для заморозки' ;
  end
  else
    Result:=True ;

end;

constructor TMetaActionFreeze.Create(Params: TStringList);
begin
  inherited Create(Params);
  FreezeTime:=StrToIntWt0(Params.Values['FreezeTime']) ;
end;

initialization

  RegisterMetaAction(TMetaActionFreeze) ;

end.
