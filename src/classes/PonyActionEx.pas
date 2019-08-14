unit PonyActionEx;

interface
uses PonyAction, Classes, BattleField, MetaAction, contnrs, GameObject,
  AutoCreatedSubList ;

type
  TActionItem = record
    ma:TMetaAction ;
    cell:TCell ;
  end;

  TActionObject = class
  private
    items:array[0..32] of TActionItem ;
    poz:Integer ;
  public
    Code:string ;
    constructor Create(ACode:string) ;
    procedure AddItem(Ama:TMetaAction; Acell:TCell) ;
    procedure Apply() ;
  end;

  TPonyActionEx = class(TPonyAction)
  private
    FCode:string ;
    FCaption:string ;
    FSubInfo:string ;
    Energy:Integer ;
    Stone:Integer ;
    Food:Integer ;
    Wood:Integer ;
    AllowCellsParams:string ;
    DestCellsParams:string ;
    ListMActions:TObjectList ;
    OneTryAction:Boolean ;
    ActionObject:TActionObject ;
  public
    function Caption():string ; override ;
    function Info():string ; override ;
    function SubInfo():string ; override ;
    function Code():string ; override ;
    function Icon(Pony:TGameObject):string ; override ;

    constructor Create(Params:TStringList) ; override ;
    destructor Destroy ; override ;

    function OnlyForFreeStore(out place:Integer):Boolean ;
    function OnlyForBusyStore(out place:Integer):Boolean ;
    function BuildAllowCellList(CellStart:TCell):TCellListNoOwn ; override ;
    function BuildResultCellList(CellStart,CellSel: TCell): TCellListNoOwn; override ;
    function Apply(BF:TBattleField; Cell:TCell; var errmsg:string):Boolean ; override ;
    function CanApply(BF:TBattleField; var errmsg:string):Boolean ; override ;

    function GetActionObject():TActionObject ;
  end ;

function CreatePonyActionExFromMainIni(Code:string):TPonyActionEx ;

implementation
uses IniFiles, CellBuilder, simple_const, PonyUnits, SysUtils, simple_oper,
  MetaActionTeleport, StringObject, MetaActionManageAction,
  MetaActionDownload, MetaActionUpload, ObjModule, MetaActionSetFlag,
  MetaActionConsumePonyForce, MetaActionSetupTerrain, HardLevels ;

function CreatePonyActionExFromMainIni(Code:string):TPonyActionEx ;
var Ini:TIniFile ;
    Params:TStringList ;
    p:Integer ;
    str:string ;
begin
  Result:=TPonyActionEx.Create(nil);

  Ini:=TIniFile.Create('..\configs\actions.ini') ;
  if not Ini.SectionExists(Code) and
    FileExists(LevelFileName+'.data\configs\actions.ini') then begin
    Ini.Free ;
    Ini:=TIniFile.Create(LevelFileName+'.data\configs\actions.ini') ;
  end;


  Result.FCaption:=Ini.ReadString(Code,'Caption','Не задан') ;
  Result.FSubInfo:=Ini.ReadString(Code,'SubInfo','') ;
  Result.FCode:=Code ;
  Result.Energy:=Ini.ReadInteger(Code,'Energy',0) ;
  SetNoviceEnergy(Result.Energy) ;
  Result.Stone:=Ini.ReadInteger(Code,'Stone',0) ;
  Result.Food:=Ini.ReadInteger(Code,'Food',0) ;
  Result.Wood:=Ini.ReadInteger(Code,'Wood',0) ;
  Result.AllowCellsParams:=Ini.ReadString(Code,'AllowCells','linked') ;
  Result.DestCellsParams:=Ini.ReadString(Code,'DestCells','point') ;
  Result.OneTryAction:=Ini.ReadString(Code,'OneTryAction','false')='true' ;

  p:=0 ;
  while True do begin
    str:=Ini.ReadString(Code,'MetaAction'+IntToStrWt0(p),'') ;
    if str='' then Break ;

    Params:=TStringList.Create ;
    Params.CommaText:=str ;
    Result.ListMActions.Add(MetaAction.CreateMetaAction(Params)) ;
    Params.Free ;
    
    Inc(p) ;
  end;

  Ini.Free ;
end;

{ TPonyActionEx }

function TPonyActionEx.Apply(BF:TBattleField; Cell: TCell; var errmsg:string): Boolean;
var List:TCellListNoOwn ;
    _errmsg:string ;
    i,j:Integer ;
    z:Boolean ;
    isdelayed:Boolean ;
label skip ;    
begin
  List:=BuildResultCellList(BF.GetActiveCell,Cell) ;

  // Патч для заклинаний, использующий телепорт
  // Смысл в том, что для телепорта, нужно, чтобы можно было применить
  // именно в ТУ ячейку, куда выбрано - а не хотя бы в одну, как в других
  // заклинаниях
  Result:=True ;
  for j := 0 to ListMActions.Count - 1 do
    if ListMActions[j] is TMetaActionTeleport then begin
      Result:=TMetaAction(ListMActions[j]).CanApplyToCell(Cell,_errmsg) ;
      if not Result then errmsg:=_errmsg ;
    end;

  if Result then begin

  Result:=False ;
  for i := 0 to List.Count - 1 do begin
    for j := 0 to ListMActions.Count - 1 do begin
      z:=TMetaAction(ListMActions[j]).CanApplyToCell(List[i],_errmsg) ;
      // Поправка для принудительного сброса недопустимого действия поглощения сил
      if (TMetaAction(ListMActions[j]) is TMetaActionConsumePonyForce) or
         (TMetaAction(ListMActions[j]) is TMetaActionSetupTerrain) then
        if not z then begin
          Result:=False ;
          errmsg:=_errmsg;
          goto skip ;
        end ;

      Result:=Result or z ;
      if not z then errmsg:=_errmsg ;
    end;
  end;

skip:

  if Result then begin

    TPonyUnit(BF.GetActiveObject()).DecEnergy(Energy) ;
    BF.DecStone(Stone) ;
    BF.DecFood(Food) ;
    BF.DecWood(Wood) ;

    if OneTryAction then
      TPonyActionPermits(BF.GetPAP).setPermit('deny',Code()) ;

    // Временно делаем УЖЕ ТРИ  заклинание отложенным
    isdelayed:=(Code='CrystallRain')or(Code='SonicRainbow')or(Code='SunBeam')or
      (Code='BuildCrystalTowerSmall')or(Code='BuildCrystalTowerBig') ;
    if isdelayed then ActionObject:=TActionObject.Create(Code) ;
    
    for i := 0 to List.Count - 1 do
      for j := 0 to ListMActions.Count - 1 do
        if TMetaAction(ListMActions[j]).CanApplyToCell(List[i],errmsg)
          // И всегда разрешаем установить разрешения
          or (ListMActions[j] is TMetaActionManageAction)
          // И всегда разрешаем установить флаги
          or (ListMActions[j] is TMetaActionSetFlag) then begin
          // Поправка касается ТОЛЬКО заклинания телепортации
          if ListMActions[j] is TMetaActionTeleport then z:=List[i]=Cell else z:=True ;
          if z then begin
            if (isdelayed)and(not(ListMActions[j] is TMetaActionTeleport)) then
               ActionObject.AddItem(TMetaAction(ListMActions[j]),List[i])
            else
              TMetaAction(ListMActions[j]).Apply(List[i]) ;
          end;
        end;
  end ;

  end;
  List.Free ;
end;

function TPonyActionEx.BuildAllowCellList(CellStart: TCell): TCellListNoOwn;
begin
  Result:=TCellBuilder.BuildCellListFromCenter(CellStart,AllowCellsParams) ;
end;

function TPonyActionEx.BuildResultCellList(CellStart,
  CellSel: TCell): TCellListNoOwn;
var List:TCellListNoOwn ;
    i:Integer ;
begin
  List:=TCellBuilder.BuildCellListByDest(CellStart,CellSel,DestCellsParams) ;
  Result:=TCellListNoOwn.Create ;
  for i := 0 to List.Count - 1 do
    Result.Add(List[i]) ;
end;

function TPonyActionEx.CanApply(BF:TBattleField; var errmsg: string): Boolean;
begin
  errmsg:='' ;
  Result:=False ;

  if TPonyUnit(BF.GetActiveObject()).GetEnergy()<Energy then begin
    errmsg:=errmsg+Format('Мало силы (нужно %d)!',[Energy]) ;
    Exit ;
  end ;

  if BF.GetStone<Stone then begin
    errmsg:=Format('Мало камня (нужно %d)!',[Stone]) ;
    Exit ;
  end;

  if BF.GetFood<Food then begin
    errmsg:=Format('Мало еды (нужно %d)!',[Food]) ;
    Exit ;
  end;

  if BF.GetWood<Wood then begin
    errmsg:=Format('Мало леса (нужно %d)!',[Wood]) ;
    Exit ;
  end;

  Result:=True ;
end;

function TPonyActionEx.Caption: string;
begin
  Result:=FCaption ;
end;

function TPonyActionEx.Code: string;
begin
  Result:=FCode ;
end;

constructor TPonyActionEx.Create(Params: TStringList);
begin
  inherited Create(Params);
  ListMActions:=TObjectList.Create() ;
end;

destructor TPonyActionEx.Destroy;
begin
  ListMActions.Free ;
  inherited Destroy ;
end;

function TPonyActionEx.GetActionObject: TActionObject;
begin
  Result:=ActionObject ;
end;

function TPonyActionEx.Icon(Pony: TGameObject): string;
var j,place:Integer ;
begin
  Result:=inherited Icon(Pony) ;
  for j := 0 to ListMActions.Count - 1 do
    if ListMActions[j] is TMetaActionDownload then begin
      place:=TMetaActionDownload(ListMActions[j]).place ;
      if BF.getActiveObject.StoredObject[place]<>nil then
        Result:='pony_'+TPonyUnit(BF.getActiveObject.StoredObject[place]).Code ;
    end;

end;

function TPonyActionEx.Info: string;
var str:TStringObject ;
begin
  str:=NewStrObj() ;
  if Energy>0 then str.AddWithSep('%s %d',[SYM_ENERGY,Energy],#32);
  if Food>0 then str.AddWithSep('%s %d',[SYM_FOOD,Food],#32);
  if Stone>0 then str.AddWithSep('%s %d',[SYM_STONE,Stone],#32);
  if str.s='' then Result:='Без затрат' else Result:=str.s ;
  str.Free ;
end;

function TPonyActionEx.OnlyForBusyStore(out place:Integer): Boolean;
var j:Integer ;
begin
  Result:=False ;
  for j := 0 to ListMActions.Count - 1 do
    if ListMActions[j] is TMetaActionDownload then begin
      place:=TMetaActionDownload(ListMActions[j]).place ;
      Result:=True ;
    end;
end;

function TPonyActionEx.OnlyForFreeStore(out place:Integer): Boolean;
var j:Integer ;
begin
  Result:=False ;
  for j := 0 to ListMActions.Count - 1 do
    if ListMActions[j] is TMetaActionUpload then begin
      place:=TMetaActionUpload(ListMActions[j]).place ;
      Result:=True ;
    end;
end;

function TPonyActionEx.SubInfo: string;
var j,place:Integer ;
begin
  Result:=FSubInfo ;
  for j := 0 to ListMActions.Count - 1 do
    if ListMActions[j] is TMetaActionDownload then begin
      place:=TMetaActionDownload(ListMActions[j]).place ;
      if BF.getActiveObject.StoredObject[place]<>nil then
        Result:=BF.getActiveObject.StoredObject[place].Name ;
    end;
  
end;

{ TActionObject }

procedure TActionObject.AddItem(Ama: TMetaAction; Acell: TCell);
begin
  items[poz].ma:=Ama ;
  items[poz].cell:=Acell ;
  Inc(poz) ;
end;

procedure TActionObject.Apply;
var
  i: Integer;
begin
  for i := 0 to poz-1 do
    items[i].ma.Apply(items[i].cell) ;
end;

constructor TActionObject.Create(ACode:string);
begin
  Code:=ACode ;
  poz:=0 ;
end;

end.
