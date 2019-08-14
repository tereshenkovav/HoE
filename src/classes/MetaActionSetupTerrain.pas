unit MetaActionSetupTerrain;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionSetupTerrain = class(TMetaAction)
  private
    TerrName:string ;
    Limit:Integer ;
  public
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
    constructor Create(Params: TStringList); override ;
  end;

implementation
uses ObjModule, simple_oper, SysUtils, Terrain ;

{ TMetaActionSetupTerrain }

function TMetaActionSetupTerrain.Apply(Cell: TCell): Boolean;
var NewTerrName:string ;
begin
  Result:=True ;
  if TerrName='FlameWall' then begin
    NewTerrName:='FlameWall_1' ;
    if Cell.GetLinkByDir(0)<>nil then
      if Pos('FlameWall',Cell.GetLinkByDir(0)._Terrain.Name)=1 then begin
        NewTerrName:='FlameWall_3' ;
        Cell.GetLinkByDir(0)._Terrain:=Terrains.GetByName(NewTerrName) ;
      end;
    if Cell.GetLinkByDir(3)<>nil then
      if Pos('FlameWall',Cell.GetLinkByDir(3)._Terrain.Name)=1 then begin
        NewTerrName:='FlameWall_3' ;
        Cell.GetLinkByDir(3)._Terrain:=Terrains.GetByName(NewTerrName) ;
      end;
    if Cell.GetLinkByDir(1)<>nil then
      if Pos('FlameWall',Cell.GetLinkByDir(1)._Terrain.Name)=1 then begin
        NewTerrName:='FlameWall_2' ;
        Cell.GetLinkByDir(1)._Terrain:=Terrains.GetByName(NewTerrName) ;
      end;
    if Cell.GetLinkByDir(4)<>nil then
      if Pos('FlameWall',Cell.GetLinkByDir(4)._Terrain.Name)=1 then begin
        NewTerrName:='FlameWall_2' ;
        Cell.GetLinkByDir(4)._Terrain:=Terrains.GetByName(NewTerrName) ;
      end;
  end
  else
    NewTerrName:=TerrName ;

  Cell._Terrain:=Terrains.GetByName(NewTerrName) ;
end;

function TMetaActionSetupTerrain.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
var i,cnt:Integer ;
begin
  if TerrName='FlameWall' then
    if Cell.IsPonyUnit() or Cell.IsBuilding() then begin
      errmsg:='Нельзя ставить стену огня на пони или здания!' ;
      Result:=False ;
      Exit ;
    end;

  if (Cell._Terrain.Name=TerrName)and(TerrName<>'FlameWall') then begin
    errmsg:='Уже установлено!' ;
    Result:=False ;
  end
  else
  if Limit<High(Limit) then begin
    cnt:=0 ;
    for i := 0 to BF.CellCount-1 do
      if BF.GetCell(i)._Terrain.Name=TerrName then Inc(cnt) ;
    if cnt>=Limit then begin
      errmsg:=Format('Уже установлено %d штуки!',[cnt]) ;
      Result:=False ;
    end
    else
      Result:=True ;
  end
  else
    Result:=True
end;

constructor TMetaActionSetupTerrain.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  TerrName:=Params.Values['TerrName'] ;
  Limit:=StrToIntWt0(Params.Values['Limit']) ;
  if Limit=0 then Limit:=High(Limit) ;
end;

initialization

  RegisterMetaAction(TMetaActionSetupTerrain) ;

end.
