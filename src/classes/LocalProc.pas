unit LocalProc;

interface
uses BattleField ;

type
  TLocalProc = class
  public
    str:string ;
  published
    procedure heal_all(BF:TBattleField) ;
    procedure force_all(BF:TBattleField) ;
    procedure damage_all(BF:TBattleField) ;
    procedure startPortalAnim(BF:TBattleField) ;
  end;

implementation
uses PonyUnits, MonsterUnits, HitViewer, ObjModule, TAVHGEUtils, FFGame,
  simple_oper, Classes, TAVStrUtils ;

{ TLocalProc }

procedure TLocalProc.damage_all(BF: TBattleField);
var i:Integer ;
    MU:TMonsterUnit ;
    damage:Integer ;
    iskilled:Boolean ;
begin
  mHGE.System_Log('damage_all');
  for i := 0 to BF.CellCount-1 do
    if not BF.GetCell(i).IsEmpty then
      if BF.GetCell(i)._Object is TMonsterUnit then begin
        MU:=TMonsterUnit(BF.GetCell(i)._Object) ;
        mHGE.System_Log('damage: '+MU.Code);
        damage:=MU.GetMaxHealth div 2 ;
        if damage>0 then begin
          MU.DecHealth(damage,iskilled) ;
          HV.AddNewHit(BF.GetCell(i),hsGood,-damage) ;
          if iskilled then BF.GetCell(i).ClearObject ;
        end;
      end;
end;

procedure TLocalProc.force_all(BF: TBattleField);
var i:Integer ;
    PU:TPonyUnit ;
    energy:Integer ;
begin
  mHGE.System_Log('force_all');
  for i := 0 to BF.CellCount-1 do
    if not BF.GetCell(i).IsEmpty then
      if BF.GetCell(i)._Object is TPonyUnit then begin
        PU:=TPonyUnit(BF.GetCell(i)._Object) ;
        mHGE.System_Log('force: '+PU.Code);
        energy:=PU.GetMaxEnergy-PU.GetEnergy ;
        if energy>0 then begin
          PU.IncEnergy(energy) ;
          HV.addNewHit(BF.GetCell(i),hsEnergy,energy) ;
        end;
      end;
end;

procedure TLocalProc.heal_all(BF: TBattleField);
var i:Integer ;
    PU:TPonyUnit ;
    heal:Integer ;
begin
  mHGE.System_Log('heal_all');
  for i := 0 to BF.CellCount-1 do
    if not BF.GetCell(i).IsEmpty then
      if BF.GetCell(i)._Object is TPonyUnit then begin
        PU:=TPonyUnit(BF.GetCell(i)._Object) ;
        mHGE.System_Log('heal: '+PU.Code);
        heal:=PU.GetMaxHealth-PU.GetHealth ;
        if heal>0 then begin
          PU.IncHealth(heal) ;
          HV.addNewHit(BF.GetCell(i),hsGood,heal) ;
        end;
      end;
end;

procedure TLocalProc.startPortalAnim(BF: TBattleField);
var List:TStringList ;
    i:Integer ;
begin
  FFGame.effect_init_pos:=BF.GetShift() ;

  List:=CreateStringListBySep(str,'@') ;
  portalactivation_count:=List.Count div 2 ;
  for i := 0 to portalactivation_count - 1 do
    with BF.GetCellByIJ(StrToIntWt0(List[2*i]),StrToIntWt0(List[2*i+1])) do begin
      portalactivation_pos[i].X:=XC ;
      portalactivation_pos[i].Y:=YC ;
    end;

  List.Free ;

  PortalActivationAnim.Play() ;
end;

end.
