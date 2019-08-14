unit MetaActionSetShield;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionSetShield = class(TMetaAction)
  private
    ShieldTime:Integer ;
    ShieldValue:Integer ;
    ShieldTag:string ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, PonyUnits ;

{ TMetaActionSetShield }

function TMetaActionSetShield.Apply(Cell: TCell): Boolean;
begin
  if Cell.IsPonyUnit then begin
    TPonyUnit(Cell._Object).SetShield(ShieldTime,ShieldValue,ShieldTag) ;
    Result:=True ;
  end
  else
    Result:=False ;
end;

function TMetaActionSetShield.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsPonyUnit then begin
    Result:=False ;
    errmsg:='Нет пони для установки щита' ;
  end
  else
    Result:=True ;

end;

constructor TMetaActionSetShield.Create(Params: TStringList);
begin
  inherited Create(Params);
  ShieldTime:=StrToIntWt0(Params.Values['ShieldTime']) ;
  ShieldValue:=StrToIntWt0(Params.Values['ShieldValue']) ;
  ShieldTag:=Params.Values['ShieldTag'] ;    
end;

initialization

  RegisterMetaAction(TMetaActionSetShield) ;

end.
