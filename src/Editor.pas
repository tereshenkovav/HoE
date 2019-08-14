unit Editor;

interface

type
  TEditorSetupMode = ( esmObjects, esmTerrains ) ;

function InEditMode():Boolean ;
procedure switchEditMode() ;
function ProcessEditor():Boolean ;
procedure LoadEditorKeys(MapFile:string='') ;

var
  editorsetupmode:TEditorSetupMode = esmTerrains ;

implementation
uses BattleField, ObjModule, HGE, Terrain, BFSaver, contnrs, GameObject,
  Classes, SysUtils, IniFiles, simple_oper ;

type
  TEditorKey = class
  public
    Key:Word ;
    GOClassName:string ;
    GOParams:TStringList ;
  end;

var editMode:Boolean = False ;
var ListKeys:TObjectList = nil ;
    CmdStore:TStringList = nil ;
    LastMapFile:string='' ;

procedure AddKeysFromFile(FileName:string) ;
var List:TStringList ;
    i:Integer ;
    ek:TEditorKey ;
    c:char ;
begin
  if not FileExists(FileName) then Exit ;
  
  List:=TStringList.Create ;
  with TIniFile.Create(FileName) do begin
    ReadSectionValues('Keys',List) ;
    Free ;
  end;
  for i := 0 to List.Count - 1 do begin
    ek:=TEditorKey.Create ;

    c:=List.Names[i][1] ;
    if (c>='0')and(c<='9') then ek.Key:=HGEK_0+ord(c)-ord('0') ;
    if (c>='A')and(c<='Z') then ek.Key:=HGEK_A+ord(c)-ord('A') ;

    ek.GOParams :=TStringList.Create ;
    ek.GOParams.CommaText :=GetSplitPart2(List.ValueFromIndex[i],':') ; ;
    ek.GOClassName:=GetSplitPart1(List.ValueFromIndex[i],':') ;
    ListKeys.Add(ek) ;
  end;
  List.Free ;
end;

procedure LoadEditorKeys(MapFile:string='') ;
begin
  ListKeys:=TObjectList.Create ;
  AddKeysFromFile('..\configs\editor.ini') ;
  if MapFile<>'' then LastMapFile:=MapFile ;
  if LastMapFile<>'' then AddKeysFromFile(LastMapFile+'.data\configs\editor.ini') ;
end;

function InEditMode():Boolean ;
begin
  Result:=editMode ;
end;

procedure switchEditMode() ;
begin
  editMode:=not editMode ;
  if editMode then LoadEditorKeys() ;  
end;

function ProcessEditor():Boolean ;
var OverCell:TCell ;
    mx,my:Single ;
    keyCode:Integer ;
    i:Integer ;
    GO:TGameObject ;
    z:Boolean ;
begin
  if editMode then begin
    if ListKeys=nil then LoadEditorKeys() ;
    if CmdStore=nil then CmdStore:=TStringList.Create ;
    
    mHGE.Input_GetMousePos(mx,my);
    OverCell:=BF.GetCellByXY(Round(mx),Round(my)) ;
    if OverCell<>nil then begin
      for i := 0 to ListKeys.Count - 1 do
         if mHGE.Input_KeyDown(TEditorKey(ListKeys[i]).Key) then begin
            if (TEditorKey(ListKeys[i]).GOClassName='Terrain')and
               (editorsetupmode=esmTerrains) then begin
               OverCell._Terrain:=Terrains.GetByCodeChar(
                 TEditorKey(ListKeys[i]).GOParams.Values['Code'][1]) ;
            end ;
            if (TEditorKey(ListKeys[i]).GOClassName<>'Terrain')and
               (editorsetupmode=esmObjects) then begin
              GO:=GetGOFactory(BF).CreateGameObject(
                 TEditorKey(ListKeys[i]).GOClassName,
                 TEditorKey(ListKeys[i]).GOParams) ;
              GO .showImmediate() ;
              OverCell._Object:=GO ;
              CmdStore.Add('SETUP='+TEditorKey(ListKeys[i]).GOClassName+':'+
                TEditorKey(ListKeys[i]).GOParams.CommaText+
                Format(',i=%d,j=%d',[OverCell.CellI,OverCell.CellJ])) ;
            end;
         end;

      if mHGE.Input_KeyDown(HGEK_SPACE) then begin
        OverCell._Object:=nil ;
        CmdStore.Add('REMOVE='+Format('i=%d,j=%d',[OverCell.CellI,OverCell.CellJ])) ;
      end;

    end ;
    if mHGE.Input_KeyDown(HGEK_F2) then begin
      z:=True ;
      z:=z and TBFSaver.tmpRewriteMap(BF) ;
      z:=z and TBFSaver.tmpRewriteObjects(BF,CmdStore) ;
      if z then
        LP.setTemporaryMsg('Запись успешна!',3)
      else
        LP.setTemporaryMsg('Ошибка записи!',3) ;
      CmdStore.Clear ;
    end;
    if mHGE.Input_KeyDown(HGEK_TAB) then begin
      if editorsetupmode=esmTerrains then editorsetupmode:=esmObjects else
        editorsetupmode:=esmTerrains ;
    end;

    
  end;
end;

end.
