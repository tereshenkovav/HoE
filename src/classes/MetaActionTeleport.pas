unit MetaActionTeleport;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionTeleport = class(TMetaAction)
  private
    ImmediateTeleport:Boolean ;
  public
    constructor Create(Params:TStringList) ; override ; 
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, ObjModule, PonyUnits ;

{ TMetaActionTeleport }

function TMetaActionTeleport.Apply(Cell: TCell): Boolean;
var damage:Integer ;
    iskilled:Boolean ;
begin
  Result:=False ;
  if not Cell.IsEmpty() then Exit ;

  if ImmediateTeleport then begin
    BF.GetActiveCell().TransactObject(Cell) ;
    BF.setActiveCell(Cell) ;
  end
  else
    TPonyUnit(BF.GetActiveCell()._Object).RunTeleportaion(Cell) ;

  Result:=True ;
end;

function TMetaActionTeleport.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsEmpty then begin
    Result:=False ;
    errmsg:='Ячейка занята' ;
  end
  else
    Result:=True ;
end;

constructor TMetaActionTeleport.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  ImmediateTeleport:=Params.Values['ImmediateTeleport']='true' ;
end;

initialization

  RegisterMetaAction(TMetaActionTeleport) ;

end.
