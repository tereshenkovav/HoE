unit MetaActionManageAction;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionManageAction = class(TMetaAction)
  private
    MType:string ;
    Action:string ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses GameObject, ObjModule, PonyAction ;

{ TMetaActionManageAction }

function TMetaActionManageAction.Apply(Cell: TCell): Boolean;
begin
  Result:=False ;

  TPonyActionPermits(BF.GetPAP).setPermit(MType,Action) ;

  Result:=True ;
end;

function TMetaActionManageAction.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  // Сделано для того, чтобы не учитывалось в разрешении на остальные действия
  Result:=False ;
end;

constructor TMetaActionManageAction.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  MType:=Params.Values['Type'] ;
  Action:=Params.Values['Action'] ;
end;

initialization

  RegisterMetaAction(TMetaActionManageAction) ;

end.
