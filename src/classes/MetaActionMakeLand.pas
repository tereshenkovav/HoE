unit MetaActionMakeLand;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionMakeLand = class(TMetaAction)
  private
  public
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
    constructor Create(Params: TStringList); override ;
  end;

implementation
uses ObjModule, NeutralUnits, GameObject, SysUtils, Terrain ;

{ TMetaActionMakeLand }

function TMetaActionMakeLand.Apply(Cell: TCell): Boolean;
begin
  Result:=False ;
  if (Cell._Terrain.Name='Forest')or
     (Cell._Terrain.Name='Mountain')or
     (Cell._Terrain.Name='Water')or
     (Cell._Terrain.Name='LowWater')
  then begin
    Result:=True ;
    Cell._Terrain:=Terrains.GetByName('Land') ;
  end ;
end;

function TMetaActionMakeLand.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  Result:=False ;
  if (Cell._Terrain.Name='Forest')or
     (Cell._Terrain.Name='Mountain')or
     (Cell._Terrain.Name='Water')or
     (Cell._Terrain.Name='LowWater') then
    Result:=True
  else
    errmsg:='В этом месте уже луг!' ;
end;

constructor TMetaActionMakeLand.Create(Params: TStringList);
begin
  inherited Create(Params) ;
end;

initialization

  RegisterMetaAction(TMetaActionMakeLand) ;

end.
