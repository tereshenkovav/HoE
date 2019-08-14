unit MapScript ;

interface
uses Classes, BattleField, AutoCreatedSubList,
  CommonProc, Windows, ListInt, contnrs ;
  
type
  TScriptEventType = (setStep,setStepVar,setStepModN,setVictory,setObjectPos,setBuildingCount,
    setNeutralCount,setSpaceCount,setMonsterCount,setFoodReach,setStoneReach,setWoodReach,setFlag,setVarGreat,setTagCount) ;

  TDirection = (dGreatX,dGreatY,dLessX,dLessY,dPosition,dLessXmin) ;

  TEventActual = (eaUndef,eaFalse,eaTrue) ;

  TScriptEvent = class
  public
    EventType:TScriptEventType ;
    EventInt:Integer ;
    EventInt2:Integer ;
    EventInt3:Integer ;
    EventPos:TPoint ;
    EventStr:string ;
    EventBool:Boolean ;
    EventBool2:Boolean ;
    function CreateCopy():TScriptEvent ;
  end;

  TScriptRec = class
  private
    parampacked:string ;
    Events:TObjectList ;
    ScriptID:Integer ;
    NoDel:Boolean ;
    OnceAtStep:Boolean ;
    LISteps:TListInt ;
    FDebugInfo:string ;
    FAllowTransp:Boolean ;
    FMark:string ;
    CachedEventActual:TEventActual ;
    function testObjPos(SE:TScriptEvent; BF:TBattleField):Boolean ;
  public
    DialogMsg:string ;
    DialogIcon:string ;
    constructor Create(params:TStringList) ;
    function IsDialog():Boolean ; virtual ;
    function IsChooseSol():Boolean ; virtual ;
    function IsEventActual(BF:TBattleField):Boolean ;
    procedure ExecEvent(BF:TBattleField) ; virtual ; abstract ;
    function debugInfo():string ;
    property AllowTransp:Boolean read FAllowTransp ;
    property Mark:string read FMark ;
  end ;

  TScriptRecMessage = class(TScriptRec)
  public
    function IsDialog():Boolean ; override ;
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptRecChooseSol = class(TScriptRec)
  public
    function IsChooseSol():Boolean ; override ;
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptRecShowBattleTask = class(TScriptRec)
  public
    function IsDialog():Boolean ; override ;
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptRecSetBattleTask = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptRecCompBattleTask = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptRecFailBattleTask = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptNewObject = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptReplaceObject = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptNewObjectGroup = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptMoveObject = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptTeleportObject = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptRemoveObject = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetFocus = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSleep = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetEmptyManager = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetPermits = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptClearTarget = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetFlag = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetPersistentFlag = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetPersistentVar = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetTerrain = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetDefeat = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptClearFlag = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptDecStone = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetVar = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptDecFood = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptFireTotalAttack = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptExecProc = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TScriptSetExtInfoModel = class(TScriptRec)
  public
    procedure ExecEvent(BF:TBattleField) ; override ;
  end ;

  TMapScript = class(TACObjectList)
  private
    _BF:TBattleField ;
  public
    constructor Create(BF:TBattleField) ;
    function IsActualScript():Boolean ;
    function IsActualScriptIsDialog():Boolean ;
    function IsActualScriptInTransp():Boolean ;
    function IsActualScriptGetMark():string ;
    function CreateActualScript():TScriptRec ;
    procedure AddScript(Events:TStringList; Action:string) ;
    procedure ClearAllScripts() ;
    procedure ResetCachedResults() ;
  end ;


implementation
uses simple_oper, GameObject, SysUtils, TAVHGEUtils, ObjectMover,
  PonyAction, CellFinder, NeutralUnits, MonsterUnits, Buildings, MonsterAI,
  LocalProc, EmptyPlace, FFBattleTask, TAVStrUtils, EmptyManager,
  Terrain, PonyUnits, PersistentFlags ;

var
  GScriptCounter:Integer ;

constructor TScriptRec.Create(params:TStringList) ;
begin
  Events:=TObjectList.Create ;
  ScriptID:=GScriptCounter ;
  Inc(GScriptCounter) ;
  DialogMsg:=ConvertLongString(params.Values['text']) ;
  DialogIcon:=params.Values['icon'] ;
  parampacked:=params.CommaText ;
  LISteps:=TListInt.Create ;
end ;

function TScriptRec.debugInfo: string;
begin
  Result:=FDebugInfo ;
end;

function TScriptRec.IsDialog():Boolean ;
begin
  Result:=False ;
end ;

function TScriptRec.IsChooseSol():Boolean ;
begin
  Result:=False ;
end ;

function TScriptRec.testObjPos(SE:TScriptEvent; BF:TBattleField):Boolean ;
var ListObjs:TStringList ;
    Cell:TCell ;
    i,k,idxi,idxj:Integer ;
    x,y:Integer ;
begin
  Result:=False ;
  with SE do begin
  ListObjs:=TStringList.Create() ;
  ListObjs.CommaText:=EventStr ;
  for k := 0 to ListObjs.Count - 1 do begin
     if not BF.GetObjectPos(ListObjs[k],x,y) then Continue ;
        case TDirection(EventInt) of
          dPosition: begin
            if EventBool2 { Старая схема с условием вхождения } then begin
              Result:=BF.IsObjectAtPos(ListObjs[k],EventPos.X,EventPos.Y) ;
              if EventBool { IncludeLinked } then begin
                Cell:=BF.GetCellByIJ(EventPos.X,EventPos.Y) ;
                for i := 0 to Cell.GetLinkCount - 1 do
                  Result:=Result or BF.IsObjectAtPos(ListObjs[k],
                    Cell.GetLinked(i).CellI,Cell.GetLinked(i).CellJ) ;
              end;
            end
            else begin
              Result:=not BF.IsObjectAtPos(ListObjs[k],EventPos.X,EventPos.Y) ;
              if EventBool { IncludeLinked } then begin
                Cell:=BF.GetCellByIJ(EventPos.X,EventPos.Y) ;
                for i := 0 to Cell.GetLinkCount - 1 do
                  Result:=Result and (not BF.IsObjectAtPos(ListObjs[k],
                    Cell.GetLinked(i).CellI,Cell.GetLinked(i).CellJ)) ;
              end;
            end;
        end;
        dGreatX: begin
          if BF.GetObjectPos(ListObjs[k],idxi,idxj) then
            Result:=(idxi>EventPos.X) ;
        end;
        dGreatY: begin
          if BF.GetObjectPos(ListObjs[k],idxi,idxj) then
            Result:=(idxj>EventPos.Y) ;
        end;
        dLessX: begin
          if BF.GetObjectPos(ListObjs[k],idxi,idxj) then
            Result:=(idxi<EventPos.X) ;
        end;
        dLessXmin: begin
          if BF.tmpGetMinObjectPos(ListObjs[k],idxi,idxj) then
            Result:=(idxi<EventPos.X) ;
        end;
        dLessY: begin
          if BF.GetObjectPos(ListObjs[k],idxi,idxj) then
            Result:=(idxj<EventPos.Y) ;
        end;
        end;
        if Result then Break ;
  end;
  ListObjs.Free ;
  end;
end ;

function TScriptRec.IsEventActual(BF:TBattleField):Boolean ;
var Cell:TCell ;
    i,j,k,idxi,idxj:Integer ;

begin
  if CachedEventActual=eaTrue then begin Result:=True ; Exit ; end ;
  if CachedEventActual=eaFalse then begin Result:=False ; Exit ; end ;

  Result:=False ;
  CachedEventActual:=eaFalse ;
  if OnceAtStep and LISteps.IsElemIn(BF.GetCurrentStep) then Exit ;

  for j := 0 to Events.Count - 1 do begin

  with TScriptEvent(Events[j]) do
  case EventType of
    setStep: Result:=(EventInt=BF.GetCurrentStep) ;
    setStepVar: Result:=(BF.GetScriptVar(EventStr)=BF.GetCurrentStep) ;
    setFlag:
      if EventBool then
        Result:=not BF.IsFlag(EventStr)
      else
        Result:=BF.IsFlag(EventStr) ;
    setVarGreat: Result:=BF.GetScriptVar(EventStr)>EventInt ;
    setStepModN:
      Result:=((BF.GetCurrentStep mod EventInt) = 0) and
        (BF.GetCurrentStep > EventInt2) and
        (BF.GetCurrentStep < EventInt3) and
        (BF.GetCurrentStep>0)  ;
    setVictory: Result:=(BF.VictoryFlag)and(not BF.DefeatFlag) ;
    setNeutralCount: Result:=(BF.getObjCountByClass(TNeutralUnit)=EventInt) ;
    setBuildingCount: begin
      if EventStr='' then
        Result:=(BF.getObjCountByClass(TBuilding)=EventInt)
      else
        Result:=(BF.getObjCountByCode(EventStr)=EventInt) ;
    end;
    setMonsterCount: Result:=(BF.getObjCountByClass(TMonsterUnit)=EventInt) ;
    setSpaceCount: Result:=(BF.getSpaceCount()<=EventInt) ;
    setTagCount: begin
      if EventInt2=0 then Result:=(BF.getObjCountByTag(EventStr)=EventInt) else
      if EventInt2<0 then Result:=(BF.getObjCountByTag(EventStr)<=EventInt) else
      if EventInt2>0 then Result:=(BF.getObjCountByTag(EventStr)>=EventInt) ;
    end;
    setStoneReach: Result:=(BF.GetStone>=EventInt) ;
    setFoodReach: Result:=(BF.GetFood>=EventInt) ;
    setWoodReach: Result:=(BF.GetWood>=EventInt) ;
    setObjectPos: Result:=testObjPos(TScriptEvent(Events[j]),BF)
  end ;
  if not Result then Exit ;
  end;
  Result:=True ;
  CachedEventActual:=eaTrue ;
end ;

function TScriptRecMessage.IsDialog():Boolean ;
begin
  Result:=True ;
end ;

procedure TScriptRecMessage.ExecEvent(BF:TBattleField) ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;
  // nothing
end ;

function TScriptRecChooseSol.IsChooseSol():Boolean ;
begin
  Result:=True ;
end ;

procedure TScriptRecChooseSol.ExecEvent(BF:TBattleField) ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;
  // nothing
end ;

function TScriptRecShowBattleTask.IsDialog():Boolean ;
begin
  Result:=False ;
end ;

procedure TScriptRecShowBattleTask.ExecEvent(BF:TBattleField) ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  //Self.DialogMsg:=BF.GetBattleTask().GetLastInfo() ;
  //Self.DialogIcon:='ok_ico' ;
  FFBattleTask.GoBattleTask() ;
end ;

function TMapScript.IsActualScript():Boolean ;
var i:Integer ;
begin
  Result:=False ;
  for i:=0 to List.Count-1 do
    if TScriptRec(List[i]).IsEventActual(_BF) then begin
      Result:=True ;
      Break ;
    end ;
end ;

function TMapScript.IsActualScriptGetMark: string;
var i:Integer ;
begin
  Result:='' ;
  for i:=0 to List.Count-1 do
    if TScriptRec(List[i]).IsEventActual(_BF) then begin
      Result:=TScriptRec(List[i]).Mark ;
      Break ;
    end ;
end;

function TMapScript.IsActualScriptInTransp():Boolean ;
var i:Integer ;
begin
  Result:=False ;
  for i:=0 to List.Count-1 do
    if TScriptRec(List[i]).IsEventActual(_BF) then begin
      Result:=TScriptRec(List[i]).AllowTransp ;
      Break ;
    end ;
end ;

function TMapScript.IsActualScriptIsDialog():Boolean ;
type TScrType = ( stDialog, stSetFocus, stOther ) ;
var i,p:Integer ;
    arr:array[0..1] of TScrType ;
begin

  arr[0]:=stOther ; arr[1]:=stOther ;
  p:=0 ;
  for i:=0 to List.Count-1 do
    if TScriptRec(List[i]).IsEventActual(_BF) then begin
      if TScriptRec(List[i]).IsDialog() then arr[p]:=stDialog else
        if TScriptRec(List[i]) is TScriptSetFocus then arr[p]:=stSetFocus else
          arr[p]:=stOther ;
      Inc(p) ;
      if p=2 then Break ;
    end ;

  Result:=(arr[0]=stDialog) or
         ((arr[0]=stSetFocus) and (arr[1]=stDialog)) ;
end ;

procedure TMapScript.ResetCachedResults;
var i:Integer ;
begin
  for i:=0 to List.Count-1 do
    TScriptRec(List[i]).CachedEventActual:=eaUndef ;
end;

function TMapScript.CreateActualScript():TScriptRec ;
var i:Integer ;
begin
  Result:=nil ;
  for i:=0 to List.Count-1 do
    if TScriptRec(List[i]).IsEventActual(_BF) then begin
      Result:=TScriptRec(List[i]) ;
      if not Result.NoDel then List.Extract(List[i]) ;
      Break ;
    end ;
end ;

procedure TMapScript.AddScript(Events:TStringList; Action:string) ;
var params:TStringList ;
    Script,ScriptFocus:TScriptRec ;
    autofocus:Boolean ;
    i:Integer ;
    SE:TScriptEvent ;
begin
  Script:=nil ;

  params:=TStringList.Create ;
  params.CommaText:=Action ;
  autofocus:=params.Values['autofocus']='true' ;
  if params.Values['Type']='Message' then
    Script:=TScriptRecMessage.Create(params)
  else
  if params.Values['Type']='ChooseSol' then
    Script:=TScriptRecChooseSol.Create(params)
  else
  if params.Values['Type']='ShowBattleTask' then
    Script:=TScriptRecShowBattleTask.Create(params)
  else
  if params.Values['Type']='SetBattleTask' then
    Script:=TScriptRecSetBattleTask.Create(params)
  else
  if params.Values['Type']='CompBattleTask' then
    Script:=TScriptRecCompBattleTask.Create(params)
  else
  if params.Values['Type']='FailBattleTask' then
    Script:=TScriptRecFailBattleTask.Create(params)
  else
  if params.Values['Type']='NewObject' then
    Script:=TScriptNewObject.Create(params)
  else
  if params.Values['Type']='ReplaceObject' then
    Script:=TScriptReplaceObject.Create(params)
  else
  if params.Values['Type']='NewObjectGroup' then
    Script:=TScriptNewObjectGroup.Create(params)
  else
  if params.Values['Type']='SetFocus' then
    Script:=TScriptSetFocus.Create(params)
  else
  if params.Values['Type']='Sleep' then
    Script:=TScriptSleep.Create(params)
  else
  if params.Values['Type']='SetDefeat' then
    Script:=TScriptSetDefeat.Create(params)
  else
  if params.Values['Type']='MoveObject' then
    Script:=TScriptMoveObject.Create(params)
  else
  if params.Values['Type']='TeleportObject' then
    Script:=TScriptTeleportObject.Create(params)
  else
  if params.Values['Type']='RemoveObject' then
    Script:=TScriptRemoveObject.Create(params)
  else
  if params.Values['Type']='SetPermits' then
    Script:=TScriptSetPermits.Create(params)
  else
  if params.Values['Type']='ClearTarget' then
    Script:=TScriptClearTarget.Create(params)
  else
  if params.Values['Type']='SetFlag' then
    Script:=TScriptSetFlag.Create(params)
  else
  if params.Values['Type']='SetPersistentFlag' then
    Script:=TScriptSetPersistentFlag.Create(params)
  else
  if params.Values['Type']='SetPersistentVar' then
    Script:=TScriptSetPersistentVar.Create(params)
  else
  if params.Values['Type']='SetEmptyManager' then
    Script:=TScriptSetEmptyManager.Create(params)
  else
  if params.Values['Type']='SetVar' then
    Script:=TScriptSetVar.Create(params)
  else
  if params.Values['Type']='ClearFlag' then
    Script:=TScriptClearFlag.Create(params)
  else
  if params.Values['Type']='DecStone' then
    Script:=TScriptDecStone.Create(params)
  else
  if params.Values['Type']='DecFood' then
    Script:=TScriptDecFood.Create(params)
  else
  if params.Values['Type']='FireTotalAttack' then
    Script:=TScriptFireTotalAttack.Create(params)
  else
  if params.Values['Type']='ExecProc' then
    Script:=TScriptExecProc.Create(params)
  else
  if params.Values['Type']='SetExtInfoModel' then
    Script:=TScriptSetExtInfoModel.Create(params)
  else
  if params.Values['Type']='SetTerrain' then
    Script:=TScriptSetTerrain.Create(params) ;

  if Script<>nil then begin
    script.FdebugInfo:=params.Values['debuginfo'] ;
    for i := 0 to Events.Count - 1 do begin
    SE:=TScriptEvent.Create() ;
    params.CommaText:=Events[i] ;
    if LowerCase(Params.Values['ForceNoDel'])='true' then Script.NoDel:=True ;
    if LowerCase(Params.Values['ForceOnceAtStep'])='true' then Script.OnceAtStep:=True ;
    if LowerCase(Params.Values['AllowTransp'])='true' then Script.FAllowTransp:=True ;
    Script.FMark:=Params.Values['Mark'] ;
    if Params.Values['Step']<>'' then begin
      SE.EventType:=setStep ;
      SE.EventInt:=StrToIntWt0(params.Values['Step']) ;
    end
    else
    if Params.Values['StepVar']<>'' then begin
      SE.EventType:=setStepVar ;
      SE.EventStr:=params.Values['StepVar'] ;
      Script.OnceAtStep:=True ;
      Script.NoDel:=True ;
    end
    else
    if Params.Values['Flag']<>'' then begin
      SE.EventType:=setFlag ;
      SE.EventStr:=params.Values['Flag'] ;
      SE.EventBool:=params.Values['CheckNoFlag']='true' ;
    end
    else
    if Params.Values['VarGreat']<>'' then begin
      SE.EventType:=setVarGreat ;
      SE.EventStr:=params.Values['VarGreat'] ;
      SE.EventInt:=StrToIntWt0(params.Values['Value']) ;
    end
    else
    if Params.Values['StepModN']<>'' then begin
      SE.EventType:=setStepModN ;
      SE.EventInt:=StrToIntWt0(params.Values['StepModN']) ;
      SE.EventInt2:=StrToIntWt0(params.Values['Great']) ;
      SE.EventInt3:=StrToIntWt0(params.Values['Less']) ;
      if SE.EventInt3=0 then SE.EventInt3:=99999 ;
      Script.OnceAtStep:=True ;
      Script.NoDel:=True ;
    end
    else
    if Params.Values['NeutralCount']<>'' then begin
      SE.EventType:=setNeutralCount ;
      SE.EventInt:=StrToIntWt0(params.Values['NeutralCount']) ;
    end
    else
    if Params.Values['BuildingCount']<>'' then begin
      SE.EventType:=setBuildingCount ;
      SE.EventInt:=StrToIntWt0(params.Values['BuildingCount']) ;
      SE.EventStr:=params.Values['BuildingCode'] ;
    end
    else
    if Params.Values['MonsterCount']<>'' then begin
      SE.EventType:=setMonsterCount ;
      SE.EventInt:=StrToIntWt0(params.Values['MonsterCount']) ;
    end
    else
    if Params.Values['SpaceCount']<>'' then begin
      SE.EventType:=setSpaceCount ;
      SE.EventInt:=StrToIntWt0(params.Values['SpaceCount']) ;
    end
    else
    if Params.Values['TagCount']<>'' then begin
      SE.EventType:=setTagCount ;
      if params.Values['Compare']='LessOrEqual' then SE.EventInt2:=-1 else
      if params.Values['Compare']='GreatOrEqual' then SE.EventInt2:=1 else
      SE.EventInt2:=0 ;
      SE.EventInt:=StrToIntWt0(params.Values['TagCount']) ;
      SE.EventStr:=params.Values['TagName'] ;
    end
    else
    if Params.Values['Victory']<>'' then begin
      SE.EventType:=setVictory ;
    end
    else
    if Params.Values['StoneReach']<>'' then begin
      SE.EventType:=setStoneReach ;
      SE.EventInt:=StrToIntWt0(params.Values['StoneReach']) ;
    end
    else
    if Params.Values['FoodReach']<>'' then begin
      SE.EventType:=setFoodReach ;
      SE.EventInt:=StrToIntWt0(params.Values['FoodReach']) ;
    end
    else
    if Params.Values['WoodReach']<>'' then begin
      SE.EventType:=setWoodReach ;
      SE.EventInt:=StrToIntWt0(params.Values['WoodReach']) ;
    end
    else
    if Params.Values['ObjectPos']<>'' then begin
      SE.EventType:=setObjectPos ;
      SE.EventPos.X:=StrToIntWt0(params.Values['i']) ;
      SE.EventPos.Y:=StrToIntWt0(params.Values['j']) ;
      SE.EventStr:=params.Values['Object'] ;
      SE.EventBool:=params.Values['IncludeLinked']='true' ;
      SE.EventBool2:=LowerCase(params.Values['ObjectPos'])<>'false' ;
      if params.Values['Direction']='GreatX' then
        SE.EventInt:=ord(dGreatX) else
      if params.Values['Direction']='GreatY' then
        SE.EventInt:=ord(dGreatY) else
      if params.Values['Direction']='LessX' then
        SE.EventInt:=ord(dLessX) else
      if params.Values['Direction']='LessXmin' then
        SE.EventInt:=ord(dLessXmin) else
      if params.Values['Direction']='LessY' then
        SE.EventInt:=ord(dLessY) else
      SE.EventInt:=ord(dPosition) ;
    end ;

    Script.Events.Add(SE) ;

    end;


    if autofocus then begin
      params.CommaText:=Action ;
      ScriptFocus:=TScriptSetFocus.Create(params) ;
      // Рефакторинг на объект-событие
      for i := 0 to Script.Events.Count - 1 do
        ScriptFocus.Events.Add(TScriptEvent(Script.Events[i]).CreateCopy()) ;
      ScriptFocus.NoDel:=Script.NoDel ;
      ScriptFocus.OnceAtStep:=Script.OnceAtStep ;
      List.Add(ScriptFocus) ;
    end;

    List.Add(script) ;
  end;
  params.Free ;

end ;

procedure TMapScript.ClearAllScripts;
begin
  List.Clear ;
end;

constructor TMapScript.Create(BF:TBattleField) ;
begin
  GScriptCounter:=0 ;
  _BF:=BF ;
  inherited Create ;
end ;

{ TScriptNewObject }

procedure TScriptNewObject.ExecEvent(BF: TBattleField);
var GO:TGameObject ;
    Params:TStringList ;
    Cell:TCell ;
    i,r:Integer ;
    CellList:TCellListNoOwn ;
    CF:TCellFinder ;
label fin ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  GO:=GetGOFactory(BF).CreateGameObject(Params.Values['Object'],Params) ;
  if GO<>nil then begin
    Cell:=BF.GetCellByIJ(StrToInt(Params.Values['i']),StrToInt(Params.Values['j'])) ;
    if not Cell.IsEmpty then begin

      CF:=TCellFinder.Create ;
      for r := 1 to 2 do begin
        CellList:=CF.FastGetAllCellsOnRadius(Cell,r) ;
        for i := 0 to CellList.Count-1 do
          if CellList[i].IsEmpty() then begin
            Cell:=CellList[i] ;
            goto fin ;
          end;
        CellList.Free ;
      end ;
      CF.Free ;

      fin:
    end ;
    if Cell.IsEmpty then begin
      BF.AddGameObject(GO,Cell) ;
      mHGE.System_Log('objects with cname=%s and params "%s" added ok',
        [Params.Values['Object'],Params.CommaText]);
    end
    else
      mHGE.System_Log('Not found free cell for objects with cname=%s and params "%s"',
        [Params.Values['Object'],Params.CommaText]);
  end;
  Params.Free ;
end;

{ TScriptReplaceObject }

procedure TScriptReplaceObject.ExecEvent(BF: TBattleField);
var GO:TGameObject ;
    Params:TStringList ;
    Cell:TCell ;
    usestore:Boolean ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  usestore:=LowerCase(Params.Values['UseStore'])='true' ;

  if BF.GetObjectCell(Params.Values['OldCode'],Cell) then begin
  if usestore then begin
    if not BF.findObjectInStore(Params.Values['Code'],GO) then
      // Дубль
      GO:=GetGOFactory(BF).CreateGameObject(Params.Values['Object'],Params)
    else
      BF.extractObjectFromStore(GO);
  end
  else
    // Дубль
    GO:=GetGOFactory(BF).CreateGameObject(Params.Values['Object'],Params) ;

  if GO<>nil then begin
    if BF.GetActiveCell=Cell then BF.clearActiveCell ;
    if usestore then BF.addObjectInStore(Cell._Object);

    Cell._Object:=GO ;
    mHGE.System_Log('objects with cname=%s and params "%s" replace old',
      [Params.Values['Object'],Params.CommaText]);
  end;
  end ;
  Params.Free ;
end;

function execFunc(BF:TBattleField; str:string; var iserr:Boolean):Integer ;
var p1,p2:Integer ;
    listp:TStringList ;
begin
  iserr:=True ;
  Result:=0 ;
  p1:=Pos('(',str) ;
  p2:=Pos(')',str) ;
  listp:=CreateStringListBySep(Copy(str,p1+1,p2-p1-1),',') ;
  if listp.Count=2 then begin
    if BF.getObjCountByTag(listp[0])=0 then Exit ;
    if listp[1]='x' then
      Result:=BF.GetCellByFirstObjectTag(listp[0]).CellI ;
    if listp[1]='y' then
      Result:=BF.GetCellByFirstObjectTag(listp[0]).CellJ ;
    iserr:=False ;  
  end ;
  listp.Free ;
end ;

{ TScriptNewObjectGroup }

procedure TScriptNewObjectGroup.ExecEvent(BF: TBattleField);
var GO:TGameObject ;
    Params:TStringList ;
    Cell,DstCell:TCell ;
    i,k:Integer ;
    CList:TCellListNoOwn ;
    iserr:Boolean ;

begin
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;

  // Временное решение для установки в i/j вычисляемых значений
  if Pos('$GetObjPos',Params.Values['i'])=1 then begin
    Params.Values['i']:=IntToStr(execFunc(BF,Params.Values['i'],iserr)) ;
    if iserr then Exit ;
  end;
  if Pos('$GetObjPos',Params.Values['j'])=1 then begin
    Params.Values['j']:=IntToStr(execFunc(BF,Params.Values['j'],iserr)) ;
    if iserr then Exit ;
  end;

  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Cell:=BF.GetCellByIJ(StrToInt(Params.Values['i']),StrToInt(Params.Values['j'])) ;

  RandSeed:=10*ScriptID+(BF.GetCurrentStep mod 10) ;

  for k := 0 to StrToInt(params.Values['count']) - 1 do begin
    CList:=GetCellFinder().GetCellsOnDistN(Cell,StrToInt(Params.Values['radius']),
      [spIgnoreTerrain]) ;

    CList.RemoveNonEmptyCells() ;

    if CList.Count=0 then Break ;
    DstCell:=CList[Round(Random(CList.Count))] ;

    GO:=GetGOFactory(BF).CreateGameObject(Params.Values['Object'],Params) ;
    if GO<>nil then begin
      BF.AddGameObject(GO,DstCell) ;
      mHGE.System_Log('objects with cname=%s and params "%s" added ok',
      [Params.Values['Object'],Params.CommaText]);
    end;

    CList.Free ;
  end;
  Params.Free ;
end;

{ TScriptSetFocus }

procedure TScriptSetFocus.ExecEvent(BF: TBattleField);
var Params:TStringList ;
    i,j:Integer ;
    iserr:Boolean ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;

  // Временное решение для установки в i/j вычисляемых значений
  if Pos('$GetObjPos',Params.Values['i'])=1 then begin
    Params.Values['i']:=IntToStr(execFunc(BF,Params.Values['i'],iserr)) ;
    if iserr then Exit ;
  end;
  if Pos('$GetObjPos',Params.Values['j'])=1 then begin
    Params.Values['j']:=IntToStr(execFunc(BF,Params.Values['j'],iserr)) ;
    if iserr then Exit ;
  end;

  i:=StrToInt(Params.Values['i']) ;
  j:=StrToInt(Params.Values['j']) ;
  // Тэг immediate теперь по умолчанию считается true
  if Params.Values['immediate']='false' then
    BF.SetFocusMovingPoint(i,j) 
  else
    BF.ImmediateRunTo(BF.GetCellByIJ(i,j).XonMap,BF.GetCellByIJ(i,j).YonMap) ;
  Params.Free ;
end;

{ TScriptSleep }

procedure TScriptSleep.ExecEvent(BF: TBattleField);
var Params:TStringList ;
    i,j:Integer ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  BF.SetIntTimer(StrToInt(Params.Values['ms'])/1000) ;
  Params.Free ;
end;

{ TScriptMoveObject }

procedure TScriptMoveObject.ExecEvent(BF: TBattleField);
var Params:TStringList ;
    i,src_i,dst_i,src_j,dst_j:Integer ;
    CellDst,CellSrc:TCell ;
    ListWay:TCellListNoOwn ;
    iserr:Boolean ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;

  // Временное решение для установки в i/j вычисляемых значений
  if Pos('$GetObjPos',Params.Values['dst_i'])=1 then begin
    Params.Values['dst_i']:=IntToStr(execFunc(BF,Params.Values['dst_i'],iserr)) ;
    if iserr then Exit ;
  end;
  if Pos('$GetObjPos',Params.Values['dst_j'])=1 then begin
    Params.Values['dst_j']:=IntToStr(execFunc(BF,Params.Values['dst_j'],iserr)) ;
    if iserr then Exit ;
  end;

  if (Params.Values['method']='tag') then begin
    CellSrc:=BF.GetCellByFirstObjectTag(Params.Values['Tag']) ;
  end
  else begin
    src_i:=StrToInt(Params.Values['i']) ;
    src_j:=StrToInt(Params.Values['j']) ;
    CellSrc:=BF.GetCellByIJ(src_i,src_j) ;
  end;

  dst_i:=StrToInt(Params.Values['dst_i']) ;
  dst_j:=StrToInt(Params.Values['dst_j']) ;
  CellDst:=BF.GetCellByIJ(dst_i,dst_j) ;
  if not CellDst.IsEmpty then
    for i := 0 to CellDst.GetLinkCount-1 do
      if CellDst.GetLinked(i).IsEmpty then begin
        CellDst:=CellDst.GetLinked(i) ;
        Break ;
      end;

  if CellSrc<>nil then
    if CellDst.isEmpty() then begin
      if Params.Values['immediate']='true' then begin
         if BF.GetActiveCell=CellSrc then begin
           CellSrc.TransactObject(CellDst) ;
           BF.setActiveCell(CellDst);
         end
         else
           CellSrc.TransactObject(CellDst) ;
      end
      else begin
         if BF.GetActiveCell=CellSrc then
           BF.ClearActiveCell() ;
         ListWay:=BF.CreateListCellsOnWay(CellSrc,CellDst,9,[spIgnoreTerrain]) ;
         if ListWay.Count>0 then
           TObjectMover(BF.GetOM()).RunMovingProcess(CellSrc,ListWay);
      end;
    end ;
  
  Params.Free ;
end;

{ TScriptRemoveObject }

procedure TScriptRemoveObject.ExecEvent(BF: TBattleField);
var Params:TStringList ;
    Cell:TCell ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;

  if (Params.Values['method']='tag') then begin
    Cell:=BF.GetCellByFirstObjectTag(Params.Values['Tag']) ;
  end
  else begin
    Cell:=BF.GetCellByIJ(StrToInt(Params.Values['i']),StrToInt(Params.Values['j'])) ;
  end ;

  if Cell<>nil then begin
    if BF.GetActiveCell=Cell then BF.clearActiveCell() ;
    Cell.ClearObject() ;
  end;
  Params.Free ;
end;

{ TScriptSetPermits }

procedure TScriptSetPermits.ExecEvent(BF: TBattleField);
var Params:TStringList ;
begin
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  TPonyActionPermits(BF.GetPAP).setPermit(Params.Values['action'],
    Params.Values['code']) ;
  Params.Free ;
end;

{ TScriptClearTarget }

procedure TScriptClearTarget.ExecEvent(BF: TBattleField);
var Params:TStringList ;
    Cell:TCell ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  Cell:=BF.GetCellByIJ(
    StrToInt(Params.Values['i']),StrToInt(Params.Values['j'])) ;
  if Cell<>nil then
    if not Cell.IsEmpty() then
      Cell._Object.SetTargeted(False);
  Params.Free ;
end;

procedure TScriptRecSetBattleTask.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
    code:string ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  code:=Trim(Params.Values['Code']) ;
  if code='' then code:='initial' ;
  if Params.Values['isreq']<>'false' then
    BF.GetBattleTask().AddReqTask(code,Params.Values['Task'])
  else
    BF.GetBattleTask().AddOptTask(code,Params.Values['Task']) ;
  Params.Free ;
end ;

procedure TScriptRecCompBattleTask.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
    code:string ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  code:=Trim(Params.Values['Code']) ;
  if code='' then code:='initial' ;
  BF.GetBattleTask().SetTaskComp(code) ;
  Params.Free ;
end ;

procedure TScriptRecFailBattleTask.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
    code:string ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  code:=Trim(Params.Values['Code']) ;
  if code='' then code:='initial' ;
  BF.GetBattleTask().SetTaskFail(code) ;
  Params.Free ;
end ;

procedure TScriptSetFlag.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  BF.SetFlag(Params.Values['FlagName']) ;
  Params.Free ;
end ;

procedure TScriptSetPersistentFlag.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  GetPersistentFlags().SetFlag(Params.Values['FlagName']) ;
  Params.Free ;
end ;

procedure TScriptSetDefeat.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;
  
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  SetResultMsg('Причина поражения: '+Params.Values['DefeatStr']) ;
  BF.DefeatFlag:=True ;
  Params.Free ;
end ;

procedure TScriptDecStone.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;
  
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  BF.DecStone(StrToInt(Params.Values['Delta'])) ;
  Params.Free ;
end ;

procedure TScriptSetVar.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  if Params.Values['Initial']='CurrentStep' then
    BF.SetScriptVar(Params.Values['Name'],BF.GetCurrentStep) ;
  BF.IncScriptVar(Params.Values['Name'],StrToIntWt0(Params.Values['Delta']));
  mHGE.System_Log('Set var: '+Params.Values['Name']+' '+
    IntToStr(BF.GetScriptVar(Params.Values['Name'])));
  Params.Free ;
end ;

procedure TScriptDecFood.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;
  
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  BF.DecFood(StrToInt(Params.Values['Delta'])) ;
  Params.Free ;
end ;

procedure TScriptFireTotalAttack.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;
  
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  TMonsterAI(BF.GetMAI()).FireTotalAttack() ;
  Params.Free ;
end ;

procedure TScriptExecProc.ExecEvent(BF:TBattleField) ;
var Params:TStringList ;
    LP:TLocalProc ;
    Proc:TMethod ;
type
  TProc = procedure(BF:TBattleField) of object ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;
  
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;

  LP:=TLocalProc.Create() ;
  LP.str:=Params.Values['str'] ;
  Proc.Code:=LP.MethodAddress(Params.Values['ProcName']) ;
  Proc.Data:=LP ;

  mHGE.System_Log('heal_all search');

  TProc(Proc)(BF) ;
//  Proc() ;
  LP.Free ;
  
  Params.Free ;
end ;

{ TScriptEvent }

function TScriptEvent.CreateCopy: TScriptEvent;
begin
  Result:=TScriptEvent.Create ;
  Result.EventType:=EventType ;
  Result.EventInt:=EventInt ;
  Result.EventInt2:=EventInt2 ;
  Result.EventInt3:=EventInt3 ;
  Result.EventPos:=EventPos ;
  Result.EventStr:=EventStr ;
  Result.EventBool:=EventBool ;
  Result.EventBool2:=EventBool2 ;
end;

{ TScriptClearFlag }

procedure TScriptClearFlag.ExecEvent(BF: TBattleField);
var Params:TStringList ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  BF.ClearFlag(Params.Values['FlagName']) ;
  Params.Free ;
end;

{ TScriptSetExtInfoModel }

procedure TScriptSetExtInfoModel.ExecEvent(BF: TBattleField);
var Params:TStringList ;
begin
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  BF.setExtInfoModel(Params.Values['ModelMicroCode']) ;
  Params.Free ;
end;

{ TScriptSetEmptyManager }

procedure TScriptSetEmptyManager.ExecEvent(BF: TBattleField);
var i:Integer ;
    Params:TStringList ;
begin
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  for i := 0 to 5 do
    TEmptyManager(BF.getEM()).SetDirVer(i,StrToInt(Params.Values['AnyDir'])) ;
  Params.Free ;
end;

{ TScriptSetTerrain }

procedure TScriptSetTerrain.ExecEvent(BF: TBattleField);
var Params:TStringList ;
    Cell:TCell ;
begin
  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  Cell:=BF.GetCellByIJ(StrToInt(Params.Values['i']),StrToInt(Params.Values['j'])) ;
  if Cell<>nil then
    if Length(Params.Values['NewTerrCode'])>0 then
      Cell._Terrain:=Terrains().GetByCodeChar(Params.Values['NewTerrCode'][1]) ;
  Params.Free ;
end;

{ TScriptTeleportObject }

procedure TScriptTeleportObject.ExecEvent(BF: TBattleField);
var Params:TStringList ;
    i,src_i,dst_i,src_j,dst_j:Integer ;
    CellDst,CellSrc:TCell ;
    ListWay:TCellListNoOwn ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;

  if (Params.Values['method']='tag') then begin
    CellSrc:=BF.GetCellByFirstObjectTag(Params.Values['Tag']) ;
  end
  else begin
    src_i:=StrToInt(Params.Values['i']) ;
    src_j:=StrToInt(Params.Values['j']) ;
    CellSrc:=BF.GetCellByIJ(src_i,src_j) ;
  end;

  dst_i:=StrToInt(Params.Values['dst_i']) ;
  dst_j:=StrToInt(Params.Values['dst_j']) ;
  CellDst:=BF.GetCellByIJ(dst_i,dst_j) ;
  if not CellDst.IsEmpty then
    for i := 0 to CellDst.GetLinkCount-1 do
      if CellDst.GetLinked(i).IsEmpty then begin
        CellDst:=CellDst.GetLinked(i) ;
        Break ;
      end;

  if CellSrc<>nil then
    if CellDst.isEmpty() then
      TPonyUnit(CellSrc._Object).RunTeleportaion(CellDst);

  Params.Free ;
end;

{ TScriptSetPersistentVar }

procedure TScriptSetPersistentVar.ExecEvent(BF: TBattleField);
var Params:TStringList ;
begin
  if OnceAtStep then LISteps.Add(BF.GetCurrentStep) ;

  Params:=TStringList.Create ;
  Params.CommaText:=parampacked ;
  GetPersistentFlags().Setvar(Params.Values['VarName'],Params.Values['VarValue']) ;
  Params.Free ;
end;

end.