unit BuiltinMapFuncs;

{
   Этот модуль содержит функции, которое по-хорошему, должны
   быть реализованы через скрипты, но по ряду причин, их
   пришлось закодировать в Паскале.
   При желании, этот модуль удаляется, и компилятор покажет все места,
   где было задействовано жесткое кодирование игровых сценариев.
}

interface
uses Classes, SysUtils, BattleField, Buildings ;

// Форматирование информации по карте
function MapFuncs_formatExtInfo(BF:TBattleField; params:TStringList):string ;
// Жестко закодированная механика телепортации
procedure MapFuncs_processBuildingTeleport(BF:TBattleField; TeleportCell:TCell) ;

function MapFuncs_getUserActionInfo(BF:TBattleField):string ;
function MapFuncs_doUserAction(BF:TBattleField):Boolean ;

implementation
uses NeutralUnits, MonsterUnits, CellFinder, PonyUnits ;

function MapFuncs_formatExtInfo(BF:TBattleField; params:TStringList):string ;
var modeltype:string ;
    x:Integer ;
    cell:TCell ;
begin
  modeltype:=params[0] ;
  Result:='Ошибка: неизвестная модель информации!!!' ;
  if modeltype='mapcastle' then begin
    x:=StrToInt(params[2])-BF.getObjCountByClass(TNeutralUnit) ;
    if x>0 then Result:=Format(params[1],[x]) else Result:='' ;
  end;
  if modeltype='mapships' then begin
    x:=StrToInt(params[2])-BF.GetWood() ;
    if x>0 then Result:=Format(params[1],[x]) else Result:='' ;
  end ;
  if modeltype='maptirek' then begin
    x:=BF.getObjCountByTag(params[2]) ;
    Result:=Format(params[1],[x]);
  end ;
  if modeltype='mapastral' then begin
    x:=StrToInt(params[2])-BF.getObjCountByCode('AstralBomb') ;
    if (x=0) then Result:=params[3] else Result:=Format(params[1],[x]);
  end;
  if modeltype='mappirates' then begin
    x:=StrToInt(params[2])-BF.GetScriptVar('gold') ;
    Result:=Format(params[1],[x]);
  end;
  if modeltype='mapnmoon' then begin
    if not BF.GetObjectCell('nmoon_ray',cell) then Result:='' else begin
      x:=TMonsterUnit(cell._Object).GetHealth-StrToInt(params[2]) ;
      if x<=0 then begin x:=0 ; BF.SetFlag('nmoon_crushed'); end ;
      Result:=Format(params[1],[x]);
    end;
  end;
end ;

procedure MapFuncs_processBuildingTeleport(BF:TBattleField; TeleportCell:TCell) ;
var i,j:Integer ;
    DstCell,NewActiveCell:TCell ;
    RList:TCellListNoOwn ;
begin
  if not TeleportCell.IsPonyUnit then Exit ;

  if TPonyUnit(TeleportCell._Object).IsTeleported then Exit ;
  
  // Поиск портала второго
  DstCell:=nil ;
  for j := 0 to BF.CellCount-1 do
    if BF.GetCell(j)<>TeleportCell then
      if BF.GetCell(j)._Terrain=TeleportCell._Terrain then
        DstCell:=TBattleField(BF).GetCell(j) ;

  // Перемещение
  if DstCell<>nil then begin
    RList:=GetCellFinder().GetCellsOnDistN(DstCell,2,[spIgnoreTerrain]) ;
    RList.Delete(DstCell) ;
    NewActiveCell:=RList[Round(Random(RList.Count))] ;

    TPonyUnit(TeleportCell._Object).RunTeleportaion(NewActiveCell) ;

    RList.Free ;
  end;

end ;

function MapFuncs_getUserActionInfo(BF:TBattleField):string ;
begin
  Result:='' ;
  if Pos('company1_level10',BF.MapFile)<>0 then begin
    if (BF.GetStone()>=60) then Result:='Отправить 60 камня' ;
  end ;
end;

function MapFuncs_doUserAction(BF:TBattleField):Boolean ;
begin
  if Pos('company1_level10',BF.MapFile)<>0 then begin
    if BF.GetStone()>=60 then BF.SetFlag('stoneusersend');
  end ;
end;

end.
