unit MetaActionEnemyTransform;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionEnemyTransform = class(TMetaAction)
  private
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses GameObject, ObjModule, MonsterUnits ;

{ TMetaActionEnemyTransform }

function TMetaActionEnemyTransform.Apply(Cell: TCell): Boolean;
var GO:TGameObject ;
begin
  Result:=False ;

  if Cell.IsEmpty then Exit ;
  if not (Cell._Object is TMonsterUnit) then Exit ;
  
  Cell.ClearObject() ;

  GO:=GetGOFactory(BF).CreateGameObject('Monster',SavedParams) ;
  if GO=nil then Exit ;

  Result:=True ;
  BF.AddGameObject(GO,Cell) ;
  mHGE.System_Log('objects with cname=%s and params "%s" added ok',
     ['Monster',SavedParams.CommaText]);

end;

function TMetaActionEnemyTransform.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  Result:=False ;
  if not Cell.IsEmpty then
    if Cell._Object is TMonsterUnit then Result:=True ;
end;

constructor TMetaActionEnemyTransform.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  SavedParams.Delete(SavedParams.IndexOfName('Code'));
  SavedParams.Add('Code='+SavedParams.Values['MonsterCode']) ;
end;

initialization

  RegisterMetaAction(TMetaActionEnemyTransform) ;

end.
