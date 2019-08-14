unit BFSaver ;

interface
uses BattleField, Classes ;

type
  TBFSaver = class
  public
    class function tmpRewriteMap(BF:TBattleField):Boolean ;
    class function tmpRewriteObjects(BF:TBattleField; CmdStore:TStringList):Boolean ;
  end ;

implementation
uses SysUtils, simple_oper, ObjModule ;

class function TBFSaver.tmpRewriteMap(BF:TBattleField):Boolean ;
var List,ListRes:TStringList ;
    i,j,maxj,p1,p2:Integer ;
    str:string ;
begin
  Result:=False ;

  List:=TStringList.Create ;
  List.LoadFromFile(BF.MapFile) ;

  p1:=-1 ;
  for i:=0 to List.Count-1 do
    if Trim(List[i])='MAP' then begin
      p1:=i ;
      Break ;
    end ;

  p2:=-1 ;
  for i:=0 to List.Count-1 do
    if Trim(List[i])='#===MAPEND===' then begin
      p2:=i ;
      Break ;
    end ;

  if (p1=-1)or(p2=-1) then Exit ;

  maxj:=BF.GetCell(0).CellJ ;
  for i:=1 to BF.CellCount-1 do
    if maxj<BF.GetCell(i).CellJ then
      maxj:=BF.GetCell(i).CellJ ;

  ListRes:=TStringList.Create ;
  for i:=0 to p1 do
    ListRes.Add(List[i]) ;

  for j:=0 to maxj do begin
    str:='' ;
    i:=0 ;
    while BF.GetCellByIJ(i,j)<>nil do begin
      if BF.GetCellByIJ(i,j).tmpMapChar<>chr(0) then
        str:=str+BF.GetCellByIJ(i,j).tmpMapChar
      else
        str:=str+BF.GetCellByIJ(i,j)._Terrain.CharCode ;
      Inc(i) ;
    end ;
    ListRes.Add(str) ;
  end ;

  for i:=p2 to List.Count-1 do
    ListRes.Add(List[i]) ;

  List.SaveToFile(BF.MapFile+'.old');
  ListRes.SaveToFile(BF.MapFile) ;
  ListRes.Free ;

  List.Free ;

  Result:=True ;
end ;

procedure AddOrReplaceObject(List:TStringList; obj:string) ;
var tmp:TStringList ;
    oi,oj:string ;
    i:Integer ;
begin
  tmp:=TStringList.Create ;
  try
  tmp.CommaText:=GetSplitPart2(obj,':') ;
  oi:=tmp.Values['i'] ;
  oj:=tmp.Values['j'] ;
  for i := 0 to List.Count - 1 do begin
    tmp.CommaText:=GetSplitPart2(List[i],':') ;
    if (tmp.Values['i']=oi)and(tmp.Values['j']=oj) then begin
      List[i]:=obj ;
      Exit ;
    end;
  end ;
  List.Add(obj) ;
  finally
    tmp.Free ;
  end;
end;

procedure TryRemoveObject(List:TStringList; coords:string) ;
var tmp:TStringList ;
    oi,oj:string ;
    i:Integer ;
begin
  tmp:=TStringList.Create ;
  try
  tmp.CommaText:=coords ;
  oi:=tmp.Values['i'] ;
  oj:=tmp.Values['j'] ;
  for i := 0 to List.Count - 1 do begin
    tmp.CommaText:=GetSplitPart2(List[i],':') ;
    if (tmp.Values['i']=oi)and(tmp.Values['j']=oj) then begin
      List.Delete(i) ;
      Exit ;
    end;
  end ;
  finally
    tmp.Free ;
  end;
end;

class function TBFSaver.tmpRewriteObjects(BF: TBattleField;
  CmdStore: TStringList): Boolean;
var List,ListRes,ListObj:TStringList ;
    i,j,maxj,p1,p2:Integer ;
    str:string ;
begin
  Result:=False ;

  List:=TStringList.Create ;
  List.LoadFromFile(BF.MapFile) ;

  p1:=-1 ;
  for i:=0 to List.Count-1 do
    if Trim(List[i])='OBJECTS' then begin
      p1:=i ;
      Break ;
    end ;

  p2:=-1 ;
  for i:=0 to List.Count-1 do
    if Trim(List[i])='#===OBJECTSEND===' then begin
      p2:=i ;
      Break ;
    end ;

  if (p1=-1)or(p2=-1) then Exit ;

  maxj:=BF.GetCell(0).CellJ ;
  for i:=1 to BF.CellCount-1 do
    if maxj<BF.GetCell(i).CellJ then
      maxj:=BF.GetCell(i).CellJ ;

  ListRes:=TStringList.Create ;
  for i:=0 to p1 do
    ListRes.Add(List[i]) ;

  // Заливка объектов
  ListObj:=TStringList.Create ;
  for i := p1+1 to p2-1 do
    ListObj.Add(List[i]) ;

  for i:=0 to CmdStore.Count-1 do begin
    //mHGE.System_Log(ListObj.Text);
    //mHGE.System_Log(CmdStore[i]);
    if CmdStore.Names[i]='SETUP' then
      AddOrReplaceObject(ListObj,CmdStore.ValueFromIndex[i]) ;
    if CmdStore.Names[i]='REMOVE' then
      TryRemoveObject(ListObj,CmdStore.ValueFromIndex[i]) ;
  end ;
  //mHGE.System_Log('final') ;
  //mHGE.System_Log(ListObj.Text);

  for i := 0 to ListObj.Count - 1 do
    ListRes.Add(ListObj[i]) ;
  // Конец заливки объектов

  for i:=p2 to List.Count-1 do
    ListRes.Add(List[i]) ;

  List.SaveToFile(BF.MapFile+'.old');
  ListRes.SaveToFile(BF.MapFile) ;
  ListRes.Free ;

  List.Free ;

  Result:=True ;
end;

end.
