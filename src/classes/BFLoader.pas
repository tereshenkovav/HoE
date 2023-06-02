unit BFLoader ;

interface
uses BattleField, MapScript, Classes, VictoryCond, EmptyManager ;

type
  TBFLoader = class
  private
    data:TStringList ;
    BF:TBattleField ;
    EM:TEmptyManager ;
    MS:TMapScript ;
    VC:TVictoryCond ;
    Consts:TStringList ;
    function IsMapKey(poz: Integer):Boolean ;
    function IsObjectsKey(poz: Integer):Boolean ;
    function IsInitialKey(poz: Integer):Boolean ;
    function IsScriptKey(poz: Integer):Boolean ;
    function IsVictoryKey(poz: Integer):Boolean ;
    function IsConstsKey(poz: Integer):Boolean ;
    function IsKey(poz: Integer):Boolean ;
    procedure LoadMap(var poz:Integer) ;
    procedure LoadObjects(var poz:Integer) ;
    procedure LoadScript(var poz:Integer) ;
    procedure LoadInitial(var poz:Integer) ;             
    procedure LoadVictory(var poz:Integer) ;
    procedure LoadConsts(var poz:Integer) ;

    procedure InjectConsts() ;
    procedure ReplaceHouseTerr2HouseObject() ;
  public
    function CreateBattleField(FileName:string):TBattleField ;
    function CreateMapDescription(FileName: string;
      var Description:string; var IsNoNumber:Boolean; var IsNoMap:Boolean): Boolean;
    function GetMapScript():TMapScript ;
    function GetVictoryCond():TVictoryCond ;
  end ;

implementation
uses SysUtils, Terrain, TAVHGEUtils, simple_oper, gameObject,
  PonyAction, NeutralUnits, EmptyPlace, PonyUnits,
  Buildings, PassiveProp ;

const
  EMPTY_CELL = '*' ;

{ TBFLoader }

function TBFLoader.CreateMapDescription(FileName: string;
  var Description:string; var IsNoNumber:Boolean; var IsNoMap:Boolean): Boolean;
var poz:Integer ;
begin
  Description:='' ;
  IsNoNumber:=False ;
  IsNoMap:=False ;

  data:=TStringList.Create ;
  data.LoadFromFile(FileName) ;

  data.delete(0) ; // map name

  // Дублирование здесь и ниже, два блока

  // drop empty lines and comments
  poz:=0 ;
  while poz<data.Count do
    if (Trim(data[poz])='') then data.Delete(poz) else
    if (Trim(data[poz])[1]='#') then data.Delete(poz) else begin
      data[poz]:=Trim(data[poz]) ;
      Inc(poz) ;
    end;

  // Bond lines
  poz:=data.Count-2 ;
  while poz>=0 do
    if Pos('==>',data[poz])=Length(data[poz])-2 then begin
      data[poz]:=
        Copy(data[poz],1,Length(data[poz])-3)+
        data[poz+1] ;
      data.Delete(poz+1) ;
    end
    else
      Dec(poz) ;

  poz:=0 ;
  while poz<data.Count-1 do begin
    if Trim(data[poz])='DESCRIPTION' then begin
      Description:=StringReplace(data[poz+1],'\n',#13,[rfReplaceAll]) ;
      Inc(poz);
    end
    else
    if Trim(data[poz])='NONUMBER' then begin
      IsNoNumber:=AnsiLowerCase(data[poz+1])='true' ;
      Inc(poz);
    end
    else
    if Trim(data[poz])='NOMAP' then begin
      IsNoMap:=AnsiLowerCase(data[poz+1])='true' ;
      Inc(poz);
    end
    else
      Inc(poz) ;
  end;
  data.Free ;

  Result:=True ;
end ;

function TBFLoader.CreateBattleField(FileName: string): TBattleField;
var poz:Integer ;
begin
  BF:=TBattleField.Create ;
  BF.MapFile:=FileName ;
  
  MS:=TMapScript.Create(BF) ;
  EM:=TEmptyManager.Create(BF);
  BF.SetEmptyManager(EM) ;

  Consts:=TStringList.Create ;

  data:=TStringList.Create ;
  data.LoadFromFile(FileName) ;

  BF.MapName:=data[0] ;
  data.delete(0) ; // map name

  // drop empty lines and comments
  poz:=0 ;
  while poz<data.Count do
    if (Trim(data[poz])='') then data.Delete(poz) else
    if (Trim(data[poz])[1]='#') then begin
      if Trim(data[poz])='#DefaultSandStone' then BF.DefaultSandStone:=True ;
      data.Delete(poz) ;
    end
    else begin
      data[poz]:=Trim(data[poz]) ;
      Inc(poz) ;
    end;

  // Bond lines
  poz:=data.Count-2 ;
  while poz>=0 do
    if Pos('==>',data[poz])=Length(data[poz])-2 then begin
      data[poz]:=
        Copy(data[poz],1,Length(data[poz])-3)+
        data[poz+1] ;
      data.Delete(poz+1) ;
    end
    else
      Dec(poz) ;

  poz:=0 ;
  try
  while poz<data.Count do begin
    mHGE.System_Log('poz=%d',[poz]);
    if IsMapKey(poz) then
      LoadMap(poz)
    else
    if IsObjectsKey(poz) then
      LoadObjects(poz)
    else
    if IsScriptKey(poz) then
      LoadScript(poz)
    else
    if IsInitialKey(poz) then
      LoadInitial(poz)
    else
    if IsVictoryKey(poz) then
      LoadVictory(poz)
    else
    if IsConstsKey(poz) then
      LoadConsts(poz)
    else
      Inc(poz) ;
  end;
  except
    on E:Exception do begin
      mHGE.System_Log('Error: '+E.MEssage);

    end;
  end;

  BF.FM.DoInitBattleField(BF) ;

  ReplaceHouseTerr2HouseObject() ;

  BF.Update(1); // Чтобы убрать стартовую прозрачность

  Result:=BF ;
end;

function TBFLoader.GetMapScript: TMapScript;
begin
  Result:=MS ;
end;

function TBFLoader.GetVictoryCond: TVictoryCond;
begin
  Result:=VC ;
end;

function TBFLoader.IsKey(poz: Integer): Boolean;
begin
  if poz>=data.Count then Result:=True else  
  Result:=IsMapKey(poz) or
    IsObjectsKey(poz) or
    IsScriptKey(poz) or
    IsInitialKey(poz) or
    IsVictoryKey(poz) or
    IsConstsKey(poz) ;
end;

function TBFLoader.IsMapKey(poz: Integer): Boolean;
begin  Result:=(data[poz]='MAP') ; end;

function TBFLoader.IsObjectsKey(poz: Integer): Boolean;
begin  Result:=(data[poz]='OBJECTS') ; end;

function TBFLoader.IsScriptKey(poz: Integer): Boolean;
begin  Result:=(data[poz]='SCRIPT') ; end;

procedure TBFLoader.InjectConsts;
var i,j:Integer ;
begin
  for i := 0 to data.Count - 1 do
    for j := 0 to Consts.Count - 1 do
      data[i]:=StringReplace(data[i],'@'+Consts.Names[j]+'@',
        Consts.ValueFromIndex[j],[rfReplaceAll,rfIgnoreCase]) ;
end;

function TBFLoader.IsConstsKey(poz: Integer): Boolean;
begin  Result:=(data[poz]='CONSTANTS') ; end;

function TBFLoader.IsInitialKey(poz: Integer): Boolean;
begin  Result:=(data[poz]='INITIAL') ; end;

function TBFLoader.IsVictoryKey(poz: Integer): Boolean;
begin  Result:=(data[poz]='VICTORY') ; end;

procedure TBFLoader.LoadMap(var poz: Integer);
var i,j:Integer ;
    str:string ;
    Cell:TCell ;
    params:TStringList ;
begin
  Inc(poz) ;

  j:=0 ;

  while not IsKey(poz) do begin
    str:=data[poz] ;
    //mHGE.System_Log('poz=%d, str=%s',[poz,str]);
    for i := 1 to Length(str) do
      if str[i]<>EMPTY_CELL then begin
        //mHGE.System_Log('i=%d, str[i]=%s',[i,str[i]]);
        if str[i]='1' then begin
          Cell:=BF.AddCell(i-1,j,Terrains.GetByCodeChar('C')) ;
          params:=TStringList.Create() ;
          params.Values['Code']:='stonewall' ;
          params.Values['Name']:='Стена пещеры' ;
          Cell._Object:=TNeutralUnit.Create(params) ;
          Cell.tmpMapChar:='1' ;
          params.Free ;
        end
        else
        if str[i]='2' then begin
          Cell:=BF.AddCell(i-1,j,Terrains.GetByCodeChar('L')) ;
          params:=TStringList.Create() ;
          Cell._Object:=TEmptyPlace.Create(params) ;
          Cell.tmpMapChar:='2' ;
          params.Free ;
        end
        else
        if str[i]='4' then begin
          Cell:=BF.AddCell(i-1,j,Terrains.GetByCodeChar('L')) ;
          params:=TStringList.Create() ;
          Cell._Object:=TEmptyPlace.Create(params) ;
          TEmptyPlace(Cell._Object).Fixed:=True ;
          Cell.tmpMapChar:='2' ;
          params.Free ;
        end
        else
        if (str[i]='W')and(not BF.DefaultSandStone) then begin
          Cell:=BF.AddCell(i-1,j,Terrains.GetByCodeChar('L')) ;
          Cell.tmpMapChar:='W' ;
        end
        else
          BF.AddCell(i-1,j,Terrains.GetByCodeChar(str[i])) ; 
      end;
    Inc(poz) ;
    Inc(j) ;
  end ;

  BF.CalcMapSize() ;
  BF.BuildCellArray() ; // Именно после CalcMapSize!!!
  BF.MakeInternalLinks() ;

end;

procedure TBFLoader.LoadObjects(var poz: Integer);
var str,cname:string ;
    Params:TStringList ;
    G:TGameObject ;
begin
  Inc(poz) ;

  while not IsKey(poz) do begin
    str:=data[poz] ;
    //mHGE.System_Log('objects poz=%d, str=%s',[poz,str]);
    cname:=GetSplitPart1(str,':') ;

    Params:=TStringList.Create ;
    Params.CommaText:=GetSplitPart2(str,':') ; ;

    G:=GetGOFactory(BF).CreateGameObject(cname,Params) ;
    if G<>nil then begin
      BF.AddGameObject(G,StrToInt(Params.Values['i']),StrToInt(Params.Values['j'])) ;
      //mHGE.System_Log('objects with cname=%s and params "%s" added ok',
      //  [cname,Params.CommaText]);
    end
    else
      mHGE.System_Log('objects with cname=%s and params "%s" return NIL',
        [cname,Params.CommaText]);

    Params.Free ;

    Inc(poz) ;
  end ;
  //  mHGE.System_Log('objects exit poz=%d, str=%s',[poz,str]);
end;

procedure TBFLoader.LoadScript(var poz: Integer);
var action:string ;
    events:TStringList ;
begin
  Inc(poz) ;
  events:=TStringList.Create ;
  while Pos('Event',GetSplitPart1(data[poz],':'))=1 do begin
    events.Add(GetSplitPart2(data[poz],':')) ;
    Inc(poz) ;
  end;

  while Pos('Action',data[poz])=1 do begin
    action:=GetSplitPart2(data[poz],':') ;
    MS.AddScript(events,action) ;
    Inc(poz) ;
  end ;

  events.Free ;
end;

procedure TBFLoader.LoadConsts(var poz: Integer);
var cname,cvalue:string ;
    List:TStringList ;
begin
  Inc(poz) ;

  while not IsKey(poz) do begin
    cname:=GetSplitPart1(data[poz],':') ;
    cvalue:=GetSplitPart2(data[poz],':') ;
    Consts.Values[cname]:=cvalue ;
    Inc(poz) ;
  end ;

  InjectConsts() ;
end;

procedure TBFLoader.LoadInitial(var poz: Integer);
var Stone,Food:Integer ;
    task,value:string ;
    List:TStringList ;
    i:Integer ;
begin
  Inc(poz) ;

  while not IsKey(poz) do begin
    task:=GetSplitPart1(data[poz],':') ;
    value:=GetSplitPart2(data[poz],':') ;
    if task='Stone' then Stone:=StrToIntWt0(value) else
    if task='Food' then Food:=StrToIntWt0(value) else
    if task='Task' then BF.GetBattleTask().AddReqTask('initial',value) else
    if Task='Permits' then begin
      List:=TStringList.Create ;
      List.CommaText:=value ;
      TPonyActionPermits(BF.GetPAP()).setPermit(List.Values['action'],
        List.Values['code']);
      List.Free ;
    end else
    if Task='AssignAction' then begin
      List:=TStringList.Create ;
      List.CommaText:=value ;
      for i := 0 to BF.CellCount-1 do
        if not BF.GetCell(i).IsEmpty then
          if BF.GetCell(i)._Object is TPonyUnit then
            if TPonyUnit(BF.GetCell(i)._Object).Code=List.Values['pony'] then
               TPonyUnit(BF.GetCell(i)._Object).AddAction(List.Values['action']) ;
      List.Free ;
    end
    else
    if Task='AttackedDefeatString' then
      BF.AttackedDefeatString:=value
    else
    if Task='EmptyManager' then begin
      List:=TStringList.Create ;
      List.CommaText:=value ;
      for i := 0 to List.Count - 1 do
        EM.SetDirVer(i,StrToInt(List[i]));
      List.Free ;
    end
    else
    if Task='DeathAllow' then
      BF.DeathAllow:=(LowerCase(value)='true')
    else
    if Task='NoSpaceProtection' then
      BF.NoSpaceProtection:=(LowerCase(value)='true')
    else
    if Task='ProgressiveMonster' then
      BF.ProgressiveMonster:=(LowerCase(value)='true')
    else
    if Task='RegressiveFarms' then
      BF.RegressiveFarms:=(LowerCase(value)='true')
    else
    if Task='UseFog' then begin
      if LowerCase(value)='true' then BF.SetFogManagerNight()
    end
    else
    if Task='DefaultMonsterStrategy' then
      BF.DefaultMonsterStrategy:=value ;

    Inc(poz) ;
  end ;

  BF.SetResources(Stone,Food);

end;

procedure TBFLoader.LoadVictory(var poz: Integer);
var str,cname:string ;
    Params:TStringList ;
    G:TGameObject ;
    at:TCondAddType ;
begin
  Inc(poz) ;
   
  VC:=nil ;                        
//ByStone:StoneNeed=600
//->ByFood:FoodNeed=1000,AddType=And

  while not IsKey(poz) do begin
    str:=data[poz] ;
    mHGE.System_Log('victory cond:%s',[str]);
    cname:=GetSplitPart1(str,':') ;

    while Copy(cname,1,2)='->' do cname:=Copy(cname,3,1000) ;
    
    Params:=TStringList.Create ;
    Params.CommaText:=GetSplitPart2(str,':') ;
    if params.Values['AddType']='And' then at:=atAnd else at:=atOr ;
    
    if VC=nil then
      VC:=GetVCFactory().CreateVictoryCond(cname,params) 
    else
      VC.AddVictoryCond(
        GetVCFactory().CreateVictoryCond(cname,params),at) ;

    mHGE.System_Log('victorycond with cname=%s and params "%s" added ok',
      [cname,Params.CommaText]);

    Params.Free ;

    Inc(poz) ;
  end ;
    mHGE.System_Log('victory exit poz=%d, str=%s',[poz,str]);
end;


procedure TBFLoader.ReplaceHouseTerr2HouseObject;
var i:Integer ;

function getHouseCode(n:Integer):string ;
begin
   if n mod 3=0 then Result:='' else Result:=IntToStr((n mod 3)+1) ;   
end;

function StringListCreateFromComma(Comma:string):TStringList ;
begin
  Result:=TStringList.Create ;
  Result.CommaText:=Comma ;
end ;

begin
  for i := 0 to BF.CellCount-1 do
    if BF.GetCell(i)._Terrain.CharCode in ['H','E'] then begin
      BF.GetCell(i)._Terrain:=BF.GetCell(i).GetMostTerrainAround() ;
      if BF.GetCell(i).IsEmpty() then begin
        BF.GetCell(i)._Object:=GetGOFactory(BF).CreateGameObject
          ('Building',StringListCreateFromComma
          ('Code=House'+getHouseCode(i)+',"Name=Дом пони"')) ;
        // Жестко закодированный запрет на этой карте разрушать дома
        if (BF.MapName='Сомбромахия') then TBuilding(BF.GetCell(i)._Object).MakeNoTarget() ;
      end;
    end;

end;

end.