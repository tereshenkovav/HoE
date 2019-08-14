unit FogManager;

interface

type
  TFogState = (fsVisible,fsFog,fsDark) ;

  TFogManagerAbstract = class
  public
    class procedure DoInitBattleField(BF:TObject) ; virtual ; abstract ;
    class procedure UpdateBattleField(BF:TObject) ; virtual ; abstract ;
  end;

  TFogManagerClass = class of TFogManagerAbstract ;

  TFogManagerNoFog = class(TFogManagerAbstract)
  public
    class procedure DoInitBattleField(BF:TObject) ; override ;
    class procedure UpdateBattleField(BF:TObject) ; override ;
  end;

  TFogManagerStd = class(TFogManagerAbstract)
  public
    class procedure DoInitBattleField(BF:TObject) ; override ;
    class procedure UpdateBattleField(BF:TObject) ; override ;
  end;

  TFogManagerNight = class(TFogManagerAbstract)
  public
    class procedure DoInitBattleField(BF:TObject) ; override ;
    class procedure UpdateBattleField(BF:TObject) ; override ;
  end;

implementation
uses BattleField, Buildings ;

{ TFogManagerNoFog }

class procedure TFogManagerNoFog.DoInitBattleField(BF:TObject) ;
var BFc:TBattleField ;
    i:Integer ;
begin
  BFc:=TBattleField(BF) ;
  for i := 0 to BFC.CellCount - 1 do
    BFC.GetCell(i).FogState:=fsVisible ;
end;

class procedure TFogManagerNoFog.UpdateBattleField(BF: TObject);
begin
  // Empty release
end;

{ TFogManagerStd }

class procedure TFogManagerStd.DoInitBattleField(BF:TObject) ;
var BFc:TBattleField ;
    i:Integer ;
begin
  BFc:=TBattleField(BF) ;
  for i := 0 to BFC.CellCount - 1 do
    BFC.GetCell(i).FogState:=fsDark ;
end;

class procedure TFogManagerStd.UpdateBattleField(BF: TObject);
var i,j:Integer ;
    ListOver:TCellListNoOwn ;
    BFc:TBattleField ;
begin
  BFc:=TBattleField(BF) ;

  for i := 0 to BFC.CellCount - 1 do
    if BFC.GetCell(i).FogState=fsVisible then BFC.GetCell(i).FogState:=fsFog ;

  for i := 0 to BFC.CellCount - 1 do
    if not BFC.GetCell(i).IsEmpty then
      if BFC.GetCell(i).IsPonyUnit() or (BFC.GetCell(i)._Object is TBuilding) then begin
        ListOver:=BFC.GetCellsOnDistN(BFc.GetCell(i),
          5,[spIncludeBusyCell,spIgnoreTerrain]) ;
        ListOver.Add(BFC.GetCell(i)) ;
        for j := 0 to ListOver.Count - 1 do
          ListOver[j].FogState:=fsVisible ;
        ListOver.Free ;
      end;
end;

{ TFogManagerNight }

class procedure TFogManagerNight.DoInitBattleField(BF:TObject) ;
var BFc:TBattleField ;
    i:Integer ;
begin
  BFc:=TBattleField(BF) ;
  for i := 0 to BFC.CellCount - 1 do
    BFC.GetCell(i).FogState:=fsFog ;
end;

class procedure TFogManagerNight.UpdateBattleField(BF: TObject);
var i,j:Integer ;
    ListOver:TCellListNoOwn ;
    BFc:TBattleField ;
begin
  BFc:=TBattleField(BF) ;

  for i := 0 to BFC.CellCount - 1 do
    if BFC.GetCell(i).FogState=fsVisible then BFC.GetCell(i).FogState:=fsFog ;

  for i := 0 to BFC.CellCount - 1 do
    if not BFC.GetCell(i).IsEmpty then
      if BFC.GetCell(i).IsPonyUnit() or (BFC.GetCell(i)._Object is TBuilding) then begin
        ListOver:=BFC.GetCellsOnDistN(BFc.GetCell(i),
          5,[spIncludeBusyCell,spIgnoreTerrain]) ;
        ListOver.Add(BFC.GetCell(i)) ;
        for j := 0 to ListOver.Count - 1 do
          ListOver[j].FogState:=fsVisible ;
        ListOver.Free ;
      end;
end;

end.
