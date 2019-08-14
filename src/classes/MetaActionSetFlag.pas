unit MetaActionSetFlag;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionSetFlag = class(TMetaAction)
  private
    FlagName:string ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses GameObject, ObjModule ;

{ TMetaActionSetFlag }

function TMetaActionSetFlag.Apply(Cell: TCell): Boolean;
begin
  Result:=False ;

  BF.SetFlag(FlagName) ;

  Result:=True ;
end;

function TMetaActionSetFlag.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  // Сделано для того, чтобы не учитывалось в разрешении на остальные действия
  Result:=False ;
end;

constructor TMetaActionSetFlag.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  FlagName:=Params.Values['Flag'] ;
end;

initialization

  RegisterMetaAction(TMetaActionSetFlag) ;

end.
