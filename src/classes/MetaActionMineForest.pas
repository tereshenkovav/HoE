unit MetaActionMineForest;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionMineForest = class(TMetaAction)
  private
    MineValue:Integer ;
  public
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
    constructor Create(Params: TStringList); override ;
  end;

implementation
uses ObjModule, NeutralUnits, GameObject, SysUtils, Terrain ;

{ TMetaActionMineForest }

function TMetaActionMineForest.Apply(Cell: TCell): Boolean;
begin
  Result:=False ;
  if Cell._Terrain.Name='Forest' then begin
    Result:=True ;
    BF.IncWood(MineValue) ;
    Cell._Terrain:=Terrains.GetByName('Land') ;
  end ;
end;

function TMetaActionMineForest.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  Result:=False ;
  if Cell._Terrain.Name='Forest' then
    Result:=True
  else
    errmsg:='Нет леса для добычи!' ;
end;

constructor TMetaActionMineForest.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  MineValue:=StrToInt(Params.Values['MineValue']) ;
end;

initialization

  RegisterMetaAction(TMetaActionMineForest) ;

end.
