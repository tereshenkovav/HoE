unit CellBuilder;

interface
uses BattleField ;

type
  TCellBuilder = class
  private
    class procedure BuildCellByAlgAndDir(CellList:TCellListNoOwn;
      CellStart,CellSelected:TCell; dir:Integer; const alg:string) ;
  public
    class function calcDirection(CellStart,CellDest:TCell):Integer ;

    class function BuildCellListFromCenter(CellStart:TCell;
      const paramstr:string):TCellListNoOwn ;
    class function BuildCellListByDest(CellStart,CellDest:TCell;
      const paramstr:string):TCellListNoOwn ;
  end;

implementation
uses simple_oper, CellFinder, SysUtils ;

type
  TCellListWorld = class(TCellListNoOwn)
  public
    function IsObjectIn(O:TObject):Boolean ; override ;
  end;

{ TCellBuilder }

class function TCellBuilder.BuildCellListFromCenter(CellStart: TCell;
  const paramstr: string): TCellListNoOwn;
var code,str:string ;
    i,r,r2:Integer ;
    ListR:TCellListNoOwn ;
begin
  code:=GetSplitPart1OrAll(paramstr,',') ;
  if code='point' then begin
    Result:=TCellListNoOwn.Create ;
    Result.Add(CellStart) ;
  end
  else
  if code='world' then begin
    Result:=TCellListWorld.Create ;
  end
  else
  if code='linked' then begin
    Result:=TCellListNoOwn.Create ;
    for i:=0 to CellStart.GetLinkCount()-1 do
      Result.Add(CellStart.GetLinked(i))
  end
  else
  if code='round' then begin
    r:=StrToIntWt0(GetSplitPart2(paramstr,',')) ;
    Result:=GetCellFinder().GetCellsOnDistN(CellStart,r,
      [spIgnoreTerrain,spIncludeBusyCell]) ;
  end
  else
  if code='circle' then begin
    str:=GetSplitPart2(paramstr,',') ;
    r:=StrToIntWt0(GetSplitPart1(str,',')) ;
    r2:=StrToIntWt0(GetSplitPart2(str,',')) ;
    Result:=GetCellFinder().GetCellsOnDistN(CellStart,r2,
      [spIgnoreTerrain,spIncludeBusyCell]) ;
    ListR:=GetCellFinder().GetCellsOnDistN(CellStart,r,
      [spIgnoreTerrain,spIncludeBusyCell]) ;
    Result.RemoveIfInList(ListR);
    ListR.Free ;
  end
  else
  if code='radial' then begin
    r:=StrToIntWt0(GetSplitPart2(paramstr,',')) ;
    Result:=GetCellFinder().CreateListCellsRadials(CellStart,r,dtpNone, NoBreakOnThrow) ;
  end
  else
    Result:=TCellListNoOwn.Create ;
end;

class procedure TCellBuilder.BuildCellByAlgAndDir(CellList: TCellListNoOwn;
  CellStart,CellSelected:TCell; dir: Integer; const alg: string);

  procedure ExecAlg(Cell:TCell; const dir:Integer; const alg:string);
  var NewCell:TCell ;
      p,p2:Integer ;
      newdir,sign,cnt:Integer ;
      skip:Boolean ;
  begin
    p:=1 ;
    NewCell:=Cell ;
    newdir:=dir ;
    sign:=1 ;
    skip:=False ;
    while p<=Length(alg) do begin
      if alg[p]='-' then
        sign:=-1
      else
      if alg[p]='x' then
        skip:=True
      else
      if alg[p]='(' then begin
        p2:=p+1 ;
        cnt:=1 ;
        while (cnt>0)and(p2<=Length(alg)) do begin
          if alg[p2]='(' then Inc(cnt) else
          if alg[p2]=')' then Dec(cnt) ;
          Inc(p2) ;
        end ;
        ExecAlg(NewCell,newdir,Copy(alg,p+1,p2-p-2)) ;
        p:=p2-1 ;
      end
      else begin
        Inc(newdir,StrToInt(alg[p])*sign) ;
        if newdir<0 then Inc(newdir,6) ;
        if newdir>5 then Dec(newdir,6) ;
        
        NewCell:=NewCell.GetLinkByDir(newdir) ;
        if NewCell=nil then Break ;
        if not skip then CellList.AddIfNoExist(NewCell) ;
        skip:=False ;
        sign:=1 ;
      end ;
      Inc(p) ;
    end ;
  end ;

var tmpalg:string ;
    RealStartCell:TCell ;
begin
  tmpalg:=alg ;
  RealStartCell:=CellStart ;
  if tmpalg[1]='s' then begin
    RealStartCell:=CellSelected ;
    tmpalg:=Copy(tmpalg,2,Length(tmpalg)-1) ;
  end ;
  if tmpalg[1]='i' then begin
    CellList.AddIfNoExist(RealStartCell) ;
    tmpalg:=Copy(tmpalg,2,Length(tmpalg)-1) ;
  end;

  ExecAlg(RealStartCell,dir,tmpalg)
end;

class function TCellBuilder.calcDirection(CellStart, CellDest: TCell): Integer;
var dir,dist:Integer ;
    TekCell:TCell ;
begin
  Result:=-1 ;
  for dir := 0 to 5 do begin
    TekCell:=CellStart ;
    for dist := 1 to 32 do
      if TekCell.GetLinkByDir(dir)<>nil then begin
        if TekCell.GetLinkByDir(dir)=CellDest then begin
          Result:=dir ;
          Exit ;
        end;
        TekCell:=TekCell.GetLinkByDir(dir) ;
      end;
  end ;
end;

class function TCellBuilder.BuildCellListByDest(CellStart, CellDest: TCell;
  const paramstr: string): TCellListNoOwn;
var code:string ;
    i,r:Integer ;
begin
  Result:=TCellListNoOwn.Create ;
  code:=GetSplitPart1OrAll(paramstr,',') ;
  if code='point' then
    Result.Add(CellDest)
  else
  if code='linked' then begin
    Result.Add(CellDest) ;
    for i:=0 to CellDest.GetLinkCount()-1 do
      Result.Add(CellDest.GetLinked(i)) ;
  end
  else
  if code='round' then begin
    r:=StrToIntWt0(GetSplitPart2(paramstr,',')) ;
    Result:=GetCellFinder().GetCellsOnDistN(CellDest,r,
      [spIgnoreTerrain,spIncludeBusyCell]) ;
  end
  else
  if code='alg' then begin
    BuildCellByAlgAndDir(Result,CellStart,CellDest,calcDirection(CellStart,CellDest),
      GetSplitPart2(paramstr,',')) ;
  end
  else
  if code='map' then begin
    BuildCellByAlgAndDir(Result,CellDest,CellDest,2,
      GetSplitPart2(paramstr,',')) ;
  end;

end;

{ TCellListWorld }

function TCellListWorld.IsObjectIn(O: TObject): Boolean;
begin
  Result:=O<>nil ;
end;

end.
