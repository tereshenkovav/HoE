unit StepRules;

interface
uses Terrain, GameObject ;

type
  TStepRules = class
  public
    class function GetStepNeed(Terr:TTerrain; GO:TGameObject):Integer ;
    class function IsPassed(Terr:TTerrain; GO:TGameObject):Boolean ;
  end;

implementation
uses PonyUnits, MonsterUnits ;

{ TStepRules }

class function TStepRules.GetStepNeed(Terr: TTerrain; GO: TGameObject): Integer;
begin
  Result:=Terr.intGetStepNeed ;
  if GO.IsFlyer then Result:=1 else
  if GO.IsWaterUnit then begin
    if Terr.IsWater then Result:=1 else Result:=4 ;
  end;
end;

class function TStepRules.IsPassed(Terr: TTerrain; GO: TGameObject): Boolean;
begin
  Result:=True ;
  // ���������� ����
  if (GO is TPonyUnit)and(not GO.IsFlyer) then begin
    // ���������� ���� - �� ����� ������ �� ����
    if (not GO.IsWaterUnit)and(Terr.OnlyFlyers) then Result:=False ;
    // ������� ���� - �� ����� ������ �� ����
    if (GO.IsWaterUnit)and(not Terr.IsWater) then Result:=False ;
    // ������ ������� ����� �����
    if Pos('FlameWall',Terr.Name)=1 then Result:=False ;    
  end ;
  // ���� ��� ����� � ��������� �����
  if (GO is TMonsterUnit) then
    if ((TMonsterUnit(GO).Code='shark')or(TMonsterUnit(GO).Code='pirateship'))
    and(not Terr.IsWater) then Result:=False ;
end;

end.
