unit MetaActionSleep;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionSleep = class(TMetaAction)
  private
    SleepTime:Integer ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, MonsterUnits ;

{ TMetaActionSleep }

function TMetaActionSleep.Apply(Cell: TCell): Boolean;
begin
  if Cell.IsMonster then begin
    TMonsterUnit(Cell._Object).Sleep(SleepTime) ;
    Result:=True ;
  end
  else
    Result:=False ;
end;

function TMetaActionSleep.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsMonster then begin
    Result:=False ;
    errmsg:='Нет врагов для усыпления' ;
  end
  else
    Result:=True ;

end;

constructor TMetaActionSleep.Create(Params: TStringList);
begin
  inherited Create(Params);
  SleepTime:=StrToIntWt0(Params.Values['SleepTime']) ;
end;

initialization

  RegisterMetaAction(TMetaActionSleep) ;

end.
