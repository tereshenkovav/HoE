unit MetaActionWings;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionWings = class(TMetaAction)
  private
    WingTime:Integer ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, PonyUnits ;

{ TMetaActionWings }

function TMetaActionWings.Apply(Cell: TCell): Boolean;
begin
  if Cell.IsEmpty then Exit ;

  if Cell._Object is TPonyUnit then begin
    TPonyUnit(Cell._Object).SetWings(WingTime) ;
    Result:=True ;
  end
  else
    Result:=False ;
end;

function TMetaActionWings.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if Cell.IsEmpty then begin
    Result:=False ;
    errmsg:='Нет пони для выдачи крыльев!' ;
  end
  else
  if not(Cell._Object is TPonyUnit) then begin
    Result:=False ;
    errmsg:='Нет пони для выдачи крыльев!' ;
  end
  else
  if TPonyUnit(Cell._Object).IsFlyer then begin
    Result:=False ;
    errmsg:='Пони не нуждается в крыльях!' ;
  end
  else
    Result:=True ;
end;

constructor TMetaActionWings.Create(Params: TStringList);
begin
  inherited Create(Params);
  WingTime:=StrToIntWt0(Params.Values['WingTime']) ;
end;

initialization

  RegisterMetaAction(TMetaActionWings) ;

end.
