unit MonsterUnits ;

interface
uses GameObject, Classes, MinMaxValues, CommonClasses, KeyStrList ;

type
  TMonsterStrategy = (msDefault,msAttackNearFirst,msAttackByRank) ;
  TMonsterUnit = class(TGameObject)
  protected
    MonsterName:string ;
    MonsterCode:string ;
    MaxStep:Integer ;
    StepLeft:Integer ;
    Health:Integer ;
    MaxHealth:Integer ;
    FreezeLeft:Integer ;
    SleepLeft:Integer ;
    DownLeft:Integer ;
    DownDivide:Integer ;
    SlowLeft:Integer ;
    OldMaxStep:Integer ;
    Burned:Boolean ;
    AttackValue:TMinMaxValues ;
    FHoldGround:Boolean ;
    FPassiveMonster:Boolean ;
    FSplashAttack:Boolean ;
    FStun:Boolean ;
    SplashAttackValue:TMinMaxValues ;
    FSplashAttackRadius:Integer ;
    attackfromunit:TGameObject ;
    FIsPoison:Boolean ;
    FPoisonAttackValue:TMinMaxValues ;
    FPoisonDist:Integer ;
    FDescr:string ;
    FMonsterStrategy:TMonsterStrategy ;
    FIsMustSurvive:Boolean ;
    procedure ExecPoison() ;
    function IncHealth(Delta: Integer): Boolean;
  public
    SkipStep:Boolean ;

    constructor Create(Params:TStringList) ; override ;
    class function GameClassName:string ; override ;
    function SpriteTag:string ; override ;
    function Name:string ; override ;
    function Code:string ;
    function Info():string ; override ;
    procedure NextStep() ; override ;
    procedure NextAfterStep() ; override ;
    function DecStep(delta:Integer):Boolean ; override ;
    function GetStepLeft():Integer ;

    function IsFreezed():Boolean ;
    procedure Freeze(FreezeTime:Integer) ;
    function IsSleeped():Boolean ;
    procedure Sleep(SleepTime:Integer) ; virtual ;
    function IsBurned():Boolean ;
    procedure Burn() ;
    procedure DoDown(DownTime:Integer; Divide:Integer) ;
    procedure DoDecSpeed(SlowTime:Integer; NewSpeed:Integer) ;    
    function IsDown():Boolean ;
    function IsSlowDown():Boolean ;
    
    function IsHoldGround():Boolean ;
    function IsPassive():Boolean ;
    function IsMustSurvive():Boolean ; override ;
    function MonsterStrategy():TMonsterStrategy ;
    procedure ClearHoldGround() ;

    function IsSplashAttack():Boolean ;
    function IsStun():Boolean ;
    function SplashAttackRadius():Integer ;
    function GenSplashAttackValue():Integer ;

    function IsPoison():Boolean ;
    function PoisonDist: Integer;
    function PoisonAttackValue:TMinMaxValues ;

    function DecHealth(Delta:Integer;
      var iskilled:Boolean):Boolean ;
    function DecHealthByBurn(out delta:Integer;
      var iskilled:Boolean):Boolean ;
    function GenAttackValue():Integer ;
    function GetMaxStep():Integer ;
    function DecHealthForKill(out delta:Integer;
      var iskilled:Boolean):Boolean ;

    function IsWaterUnit():Boolean ; override ;
    function Antifreeze():Boolean ;

    function IsAttackedFrom(out FromObject:TGameObject):Boolean ;

    procedure ProcessRemove() ; override ;

    function GetHealthPerc():Integer ;

    property GetMaxHealth:Integer read MaxHealth ;
    property GetHealth:Integer read Health ;
    property GetAttackValue:TMinMaxValues read AttackValue ;
    property GetSplashAttackValue:TMinMaxValues read SplashAttackValue ;
    property Descr:string read FDescr ;
  end;

  TMonsterTwist = class(TMonsterUnit)
  private
  public
    class function GameClassName:string ; override ;
    procedure NextStep() ; override ;
  end;

  TMonsterCave = class(TMonsterUnit)
  private
    tekgen:Integer ;
    period:Integer ;
  public
    constructor Create(Params:TStringList) ; override ;
    class function GameClassName:string ; override ;
    procedure NextStep() ; override ;
  end;

  TMonsterTirek = class(TMonsterUnit)
  private
  public
    constructor Create(Params:TStringList) ; override ;
    class function GameClassName:string ; override ;
    function MagicStoleDist():Integer ;
    procedure NextStep() ; override ;
    procedure Sleep(SleepTime:Integer); override ;
  end;

  TMonsterPortal = class(TMonsterUnit)
  private
    tablegen:TKeyStrList ;
    tekgen:Integer ;
    period:Integer ;
    portalgen:Integer ;
    portalperiod:Integer ;
    function GenNewMonsterI():Integer ;    
  public
    constructor Create(Params:TStringList) ; override ;
    class function GameClassName:string ; override ;
    procedure NextStep() ; override ;
  end;

  TMonsterTent = class(TMonsterUnit)
  private
  public
    class function GameClassName:string ; override ;
    function MagicLockDist():Integer ;
  end;

implementation
uses SysUtils, Config, BattleField, CellFinder, PonyUnits, ObjModule,
  HitViewer, FFGame, MonsterAI, simple_oper, Windows, CommonProc,
  HardLevels ;

{ TMonsterUnit }

function TMonsterUnit.Antifreeze: Boolean;
begin
  if Code='corovan' then Result:=True else Result:=False ;  
end;

procedure TMonsterUnit.Burn;
begin
  Burned:=True ;
end;

procedure TMonsterUnit.ClearHoldGround;
begin
  FHoldGround:=False ;
end;

function TMonsterUnit.Code: string;
begin
  Result:=MonsterCode ;
end;

constructor TMonsterUnit.Create(Params: TStringList);
begin
  inherited Create(Params) ;

  SkipStep:=False ;

  MonsterCode:=Params.Values['Code'] ;
  MonsterName:=Params.Values['Name'] ;

  FHoldGround:=Params.Values['holdground']='true' ;
  FPassiveMonster:=Params.Values['passive']='true' ;

  FIsMustSurvive:=False ;
  if params.Values['MustSurvive']='true' then FIsMustSurvive:=True ;
  
  if Params.Values['strategy']='AttackNearFirst' then
    FMonsterStrategy:=msAttackNearFirst
  else
  if Params.Values['strategy']='AttackByRank' then
    FMonsterStrategy:=msAttackByRank
  else
    FMonsterStrategy:=msDefault ;

  FIsFlyer:=GConfig(Self).AsBoolean(MonsterCode+'_isflyer') ;

  FDescr:=GConfig(Self).AsString(MonsterCode+'_info','Описание отсутствует...') ;
  // tmp
  {if MonsterCode='ameba' then begin
    MaxStep:=3 ;
    MaxHealth:=20 ;
  end;
  }
  MaxStep:=GConfig(Self).AsInteger(MonsterCode+'_maxstep') ;
  MaxHealth:=GConfig(Self).AsInteger(MonsterCode+'_maxhealth') ;
  AttackValue:=TMinMaxValues.Create(
    GConfig(Self).AsInteger(MonsterCode+'_attackvalue_min'),
    GConfig(Self).AsInteger(MonsterCode+'_attackvalue_max')) ;

  FSplashAttack:=GConfig(Self).AsBoolean(MonsterCode+'_splash_attack') ;
  if FSplashAttack then begin
    FSplashAttackRadius:=GConfig(Self).AsInteger(MonsterCode+'_splash_radius') ;
    SplashAttackValue:=TMinMaxValues.Create(
      GConfig(Self).AsInteger(MonsterCode+'_splash_attackvalue_min'),
      GConfig(Self).AsInteger(MonsterCode+'_splash_attackvalue_max')) ;
  end
  else begin
    FSplashAttackRadius:=0 ;
    SplashAttackValue:=TMinMaxValues.Create(0,0);
  end ;

  FIsPoison:=GConfig(Self).AsBoolean(MonsterCode+'_ispoison') ;
  if FIsPoison then begin
    FPoisonDist:=GConfig(Self).AsInteger(MonsterCode+'_poisondist') ;
    FPoisonAttackValue:=TMinMaxValues.Create(
      GConfig(Self).AsInteger(MonsterCode+'_poison_attackvalue_min'),
      GConfig(Self).AsInteger(MonsterCode+'_poison_attackvalue_max')) ;
  end
  else begin
    FPoisonDist:=0 ;
    FPoisonAttackValue:=TMinMaxValues.Create(0,0);
  end ;

  FStun:=GConfig(Self).AsBoolean(MonsterCode+'_isstun') ;

  if Params.Values['classcount']<>'' then begin
    MaxHealth:=Round(MaxHealth*(1+0.005*StrToInt(Params.Values['classcount']))) ;
    AttackValue.SetMin(Round(AttackValue.GetMin()*(1+0.005*StrToInt(Params.Values['classcount'])))) ;
    AttackValue.SetMax(Round(AttackValue.GetMax()*(1+0.005*StrToInt(Params.Values['classcount'])))) ;
  end;

  SetCasualMonsterParam(MaxHealth,AttackValue,SplashAttackValue) ;

  Health:=MaxHealth ;
  StepLeft:=MaxStep ;
  Burned:=False ;

  attackfromunit:=nil ;

end;

function TMonsterUnit.DecHealth(Delta: Integer; var iskilled: Boolean): Boolean;
const SX=6 ;
      SY=13 ;
var   Cell,CellTO:TCell ;
begin
  Result:=True ;
  Dec(Health,Delta) ;
  iskilled:=(Health<=0) ;
  attackfromunit:=FFGame.GetActivePony() ;
  // Немедленно пробуждение от атаки
  SleepLeft:=0 ;

  if Code='sombra' then
    if not iskilled then begin
      Cell:=GetBF.GetCellByObject(Self) ;
      if (Cell.CellI<>SX)or(Cell.CellJ<>SY) then begin
        CellTO:=GetBF.GetCellByIJ(SX,SY) ;
        Cell.TransactObject(CellTo) ;
        GetBF.SetFlag('SombraEscaped');
        FHoldGround:=True ;
        TMonsterAI(GetBF.GetMAI).HoldMonsterToGround(Self);
        attackfromunit:=nil ;
      end ;
    end;

end;

function TMonsterUnit.DecHealthByBurn(out delta: Integer;
  var iskilled: Boolean): Boolean;
begin
  delta:=GConfig(TMonsterUnit.ClassName).AsInteger('BurnDamage') ;
  Result:=DecHealth(delta,iskilled) ;
end;

function TMonsterUnit.DecHealthForKill(out delta: Integer;
  var iskilled: Boolean): Boolean;
begin
  delta:=Health ;
  Result:=DecHealth(delta,iskilled) ;
end;

function TMonsterUnit.DecStep(delta: Integer):Boolean;
begin
  Result:=True ;

  Dec(StepLeft,delta) ;
  if StepLeft<0 then StepLeft:=0 ;
end;

procedure TMonsterUnit.DoDecSpeed(SlowTime, NewSpeed: Integer);
begin
  SlowLeft:=SlowTime ;
  OldMaxStep:=MaxStep ;
  MaxStep:=NewSpeed ;
  StepLeft:=MaxStep ;
end;

procedure TMonsterUnit.DoDown(DownTime, Divide: Integer);

function doLower(v:Integer):Integer ;
begin
  Result:=Round(v*(1-(DownDivide/100))) ;
end ;

begin
  DownLeft:=DownTime ;
  DownDivide:=Divide ;

  Health:=doLower(Health) ;
  AttackValue.SetMin(doLower(AttackValue.GetMin()));
  AttackValue.SetMax(doLower(AttackValue.GetMax()));
  SplashAttackValue.SetMin(doLower(SplashAttackValue.GetMin()));
  SplashAttackValue.SetMax(doLower(SplashAttackValue.GetMax()));
end;

procedure TMonsterUnit.ExecPoison;
var i:Integer ;
    RList:TCellListNoOwn ;
    attack:Integer ;
    MyCell,TargetCell:TCell ;
    ae:TAttackEvent ;
    iskilled:Boolean ;
begin

  MyCell:=TBattleField(BF).GetCellByObject(Self) ;

  RList:=GetCellFinder().GetCellsOnDistN(MyCell,
    PoisonDist,[spIgnoreTerrain,spIncludeBusyCell]);

  if RList.Count=0 then Exit ;

  for i := 0 to RList.Count - 1 do begin
    if RList[i].IsEmpty() then Continue ;
    if RList[i].IsMonster() then Continue ;

    attack:=PoisonAttackValue.GetRndBetween ;

    if RList[i]._Object is TPonyUnit then begin
      if TPonyUnit(RList[i]._Object).DecHealth(attack,iskilled) then
          HV.AddNewHit(RList[i],hsBad,-attack) ;
    end
    else begin
       // Временно отключили для отравителя возможность
       // атаковать что-либо, кроме пони
       {RList[i]._Object.DoAttackFromEnemy(attack,ae) ;
       if ae.msg<>'' then begin
         TBattleField(BF).AddAttackEvent(ae) ;
         AfterAction.Add(RList[i].XC,RList[i].YC,ae.msg) ;
       end;
       }
    end;
  end ;

  RList.Free ;

end;

procedure TMonsterUnit.Freeze(FreezeTime:Integer);
begin
  if Antifreeze() then Exit ;
  
  FreezeLeft:=FreezeTime ;
end;

class function TMonsterUnit.GameClassName: string;
begin
  Result:='Monster' ;
end;

function TMonsterUnit.GenAttackValue: Integer;
begin
  Result:=AttackValue.GetRndBetween() ;
end;

function TMonsterUnit.GetHealthPerc: Integer;
begin
  if GetHealth>GetMaxHealth then Result:=100 else
  Result:=Round(100*GetHealth/GetMaxHealth) ;
end;

function TMonsterUnit.GetMaxStep: Integer;
begin
  Result:=MaxStep ;
end;

function TMonsterUnit.GenSplashAttackValue: Integer;
begin
  Result:=SplashAttackValue.GetRndBetween() ;
end;

function TMonsterUnit.GetStepLeft: Integer;
begin
  Result:=StepLeft ;
end;

function TMonsterUnit.Info: string;
begin
  Result:=Format('%s %d/%d',[SYM_HEALTH,Health,MaxHealth]) ;
  if IsFreezed() then
    Result:=Result+#13+Format('Заморожен на %d ходов',[FreezeLeft]) ;
  if IsSleeped() then
    Result:=Result+#13+Format('Усыплен на %d ходов',[SleepLeft]) ;
  if IsDown() then
    Result:=Result+#13+Format('Подавлен на %d ходов',[DownLeft]) ;
  if IsBurned() then
    Result:=Result+#13+'Горит' ;

end;

function TMonsterUnit.IsAttackedFrom(out FromObject: TGameObject): Boolean;
begin
  Result:=attackfromunit<>nil ;
  if Result then FromObject:=attackfromunit ;  
end;

function TMonsterUnit.IsBurned: Boolean;
begin
  Result:=Burned ;
end;

function TMonsterUnit.IsDown: Boolean;
begin
  Result:=(DownLeft>0) ;
end;

function TMonsterUnit.IsFreezed: Boolean;
begin
  Result:=(FreezeLeft>0) ;
end;

function TMonsterUnit.IsHoldGround: Boolean;
begin
  Result:=FHoldGround ;
end;

function TMonsterUnit.IsMustSurvive: Boolean;
begin
  Result:=FIsMustSurvive ;
end;

function TMonsterUnit.IsSleeped: Boolean;
begin
  Result:=(SleepLeft>0) ;
end;

function TMonsterUnit.IsSlowDown: Boolean;
begin
  Result:=SlowLeft>0 ;
end;

function TMonsterUnit.IsSplashAttack: Boolean;
begin
  Result:=FSplashAttack ;
end;

function TMonsterUnit.IsStun: Boolean;
begin
  Result:=FStun ;
end;

function TMonsterUnit.IsWaterUnit: Boolean;
begin
  Result:=(Code='watersnake')or(Code='cracken')or(Code='shark')or(Code='pirateship') ;
end;

function TMonsterUnit.MonsterStrategy: TMonsterStrategy;
begin
  Result:=FMonsterStrategy ;
end;

function TMonsterUnit.Name: string;
begin
  Result:=MonsterName ;
end;

procedure TMonsterUnit.NextStep();
var RList:TCellListNoOwn ;
    i:Integer ; 
begin
  StepLeft:=MaxStep ;

  if IsPoison then ExecPoison() ;

  if (Code='sombra')and(Health<MaxHealth) then begin
     RList:=GetCellFinder().GetCellsOnDistN(GetBF().GetCellByObject(Self),
     3,
     [spIgnoreTerrain,spIncludeBusyCell]) ;

     for i := 0 to RList.Count - 1 do
       if not RList[i].IsEmpty() then
         if RList[i]._Object is TMonsterUnit then
           if TMonsterUnit(RList[i]._Object).Code='darkcrystall' then begin
             Self.IncHealth(40) ;
             HV.addNewHit(GetBF().GetCellByObject(Self),hsGood,'+40') ;
             Break ;
           end;
  end;

end;

procedure TMonsterUnit.NextAfterStep();
var RList:TCellListNoOwn ;
    i:Integer ;

function doRest(v:Integer):Integer ;
begin
  Result:=Round(v/(1-(DownDivide/100))) ;
end ;

begin
  StepLeft:=MaxStep ;
  if IsFreezed() then Dec(FreezeLeft) ;
  if IsSleeped() then Dec(SleepLeft) ;
  if IsDown() then begin
    Dec(DownLeft) ;
    if not IsDown() then begin
      Health:=doRest(Health) ;
      AttackValue.SetMin(doRest(AttackValue.GetMin()));
      AttackValue.SetMax(doRest(AttackValue.GetMax()));
      SplashAttackValue.SetMin(doRest(SplashAttackValue.GetMin()));
      SplashAttackValue.SetMax(doRest(SplashAttackValue.GetMax()));
    end ;
  end;
  if IsSlowDown() then begin
    Dec(SlowLeft) ;
    if not IsSlowDown() then begin
      MaxStep:=OldMaxStep ;
      StepLeft:=MaxStep ;
    end; 
  end ;  
  
end;

function TMonsterUnit.IncHealth(Delta: Integer): Boolean;
begin
  Result:=True ;
  Inc(Health,Delta) ;
  if Health>MaxHealth then Health:=MaxHealth ;
end;

procedure TMonsterUnit.Sleep(SleepTime:Integer);
begin
  SleepLeft:=SleepTime ;
end;

function TMonsterUnit.SplashAttackRadius: Integer;
begin
  Result:=FSplashAttackRadius ;
end;

function TMonsterUnit.SpriteTag: string;
begin
  Result:='monster_'+MonsterCode ;
end;

function TMonsterUnit.IsPassive: Boolean;
begin
  Result:=FPassiveMonster ;
end;

function TMonsterUnit.IsPoison(): Boolean;
begin
  Result:=FIsPoison ;
end;

function TMonsterUnit.PoisonAttackValue:TMinMaxValues ;
begin
  Result:=FPoisonAttackValue ;
end;

function TMonsterUnit.PoisonDist: Integer;
begin
  Result:=FPoisonDist ;
end;

procedure TMonsterUnit.ProcessRemove;
var GO:TGameObject ;
    Params:TStringList ;
    RList:TCellListNoOwn ;
    Cell,TargetCell:TCell ;
    i:Integer ;
begin
  inherited ProcessRemove();

  Cell:=TBattleField(BF).GetCellByObject(Self) ;
  if Cell=nil then Exit ;

  if Code='cracken' then begin
    RList:=TCellListNoOwn.Create() ;
    for i := 0 to Cell.GetLinkCount - 1 do
      if Cell.GetLinked(i).IsEmpty then
        RList.Add(Cell.GetLinked(i)) ;

    Params:=TStringList.Create ;
    Params.CommaText:='code=watersnake,"Name=Водный змей"' ;

    for i := 1 to 2 do begin
      if RList.Count=0 then Exit ;

      TargetCell:=RList[Round(Random(RList.Count))] ;
      GO:=GetGOFactory(BF).CreateGameObject('Monster',Params) ;
      if GO<>nil then begin
        TMonsterUnit(GO).SkipStep:=True ;
        TBattleField(BF).AddGameObject(GO,TargetCell) ;
      end;

      RList.Delete(TargetCell);
    end ;

    RList.Free ;

    Params.Free ;
  end;

  if Code='corovan' then begin
    RList:=TCellListNoOwn.Create() ;
    for i := 0 to Cell.GetLinkCount - 1 do
      if Cell.GetLinked(i).IsEmpty then
        RList.Add(Cell.GetLinked(i)) ;
    if RList.Count=0 then Exit ;

    Params:=TStringList.Create ;
    Params.CommaText:='size=min' ;

    GO:=GetGOFactory(BF).CreateGameObject('Food',Params) ;
    if GO<>nil then
      TBattleField(BF).AddGameObject(GO,RList[Round(Random(RList.Count))]) ;

    RList.Free ;
  end;

  if IsMustSurvive() then begin
    SetResultMsg('Причина поражения: '+Name+' потерян.') ;
    TBattleField(BF).DefeatFlag:=True ;
  end ;

end;

{ TMonsterTwist }

class function TMonsterTwist.GameClassName: string;
begin
  Result:='MonsterTwist' ;
end;

procedure TMonsterTwist.NextStep();
var GO:TGameObject ;
    Params:TStringList ;
    RList:TCellListNoOwn ;
    Cell,TargetCell:TCell ;
    i:Integer ;
begin
  inherited NextStep();

  Cell:=TBattleField(BF).GetCellByObject(Self) ;
  if Cell<>nil then begin

    RList:=TCellListNoOwn.Create() ;
    for i := 0 to Cell.GetLinkCount - 1 do
      if Cell.GetLinked(i).IsEmpty then
        RList.Add(Cell.GetLinked(i)) ;
    if RList.Count>0 then begin
    TargetCell:=RList[Round(Random(RList.Count))] ;

    Params:=TStringList.Create ;
    Params.CommaText:='code=batred,"Name=Красный нетопырь"' ;
    GO:=GetGOFactory(BF).CreateGameObject('Monster',Params) ;
    if GO<>nil then
      TBattleField(BF).AddGameObject(GO,TargetCell) ;
    Params.Free ;
    end;
    RList.Free ;

  end ;
end;

{ TMonsterCave }

constructor TMonsterCave.Create(Params: TStringList);
begin
  inherited Create(Params);
  period:=StrToIntWt0(Params.Values['Period']) ;
  if period=0 then period:=1 ;
  tekgen:=period ;
end;

class function TMonsterCave.GameClassName: string;
begin
  Result:='MonsterCave' ;
end;

procedure TMonsterCave.NextStep();
var GO:TGameObject ;
    Params:TStringList ;
    RList:TCellListNoOwn ;
    Cell,TargetCell:TCell ;
    i:Integer ;
begin
  inherited NextStep();

  Dec(tekgen) ;
  if tekgen=0 then begin
  tekgen:=period ;
  Cell:=TBattleField(BF).GetCellByObject(Self) ;
  if Cell<>nil then begin

    RList:=TCellListNoOwn.Create() ;
    for i := 0 to Cell.GetLinkCount - 1 do
      if Cell.GetLinked(i).IsEmpty then
        RList.Add(Cell.GetLinked(i)) ;
    if RList.Count>0 then begin
      TargetCell:=RList[Round(Random(RList.Count))] ;
      Params:=TStringList.Create ;
      Params.CommaText:='code=bat,"Name=Нетопырь"' ;
      GO:=GetGOFactory(BF).CreateGameObject('Monster',Params) ;
      if GO<>nil then
        TBattleField(BF).AddGameObject(GO,TargetCell) ;
      Params.Free ;
    end;
    RList.Free ;

  end ;
  end;
end;

{ TMonsterTent }

class function TMonsterTent.GameClassName: string;
begin
  Result:='MonsterTent' ;
end;

function TMonsterTent.MagicLockDist: Integer;
begin
  Result:=GConfig(Self).AsInteger('MagicLockDist') ;
end;

{ TMonsterPortal }

constructor TMonsterPortal.Create(Params: TStringList);
begin
  inherited Create(Params);
  tablegen:=TKeyStrList.Create() ;
  tablegen.Add('code@bat,"Name@Нетопырь"',40) ;
  tablegen.Add('code@ameba,"Name@Амеба"',40) ;
  tablegen.Add('code@troll,"Name@Тролль"',30) ;
  tablegen.Add('code@poison,"Name@Ядовитый шар"',20) ;
  tablegen.Add('code@tent,"Name@Зеленый ужас"',20) ;
  tablegen.Add('code@gidra,"Name@Гидра"',10) ;
//  tablegen.SortByValue(True);
  if period=0 then begin
    if MonsterCode='darkportal_small' then period:=4 else period:=2 ;
  end;
  if portalperiod=0 then portalperiod:=7 ;

  tekgen:=period ;
  portalgen:=portalperiod ;

end;

class function TMonsterPortal.GameClassName: string;
begin
  Result:='MonsterPortal' ;
end;

function TMonsterPortal.GenNewMonsterI():Integer ;
var i,sum,gen,genid:Integer ;
    level:Integer ;
    dpc:Integer ;
begin
    dpc:=TBattleField(BF).getObjCountByCode('darkportal_small') ;
    if dpc=0 then level:=1 else // Мыши
    if dpc=1 then level:=2 else // +Амебы
    if dpc=2 then level:=4 else // Тролли и шары
    level:=tablegen.Count ;

    while (True) do begin

      sum:=0 ;
      for i := 0 to level-1 do
        Inc(sum,tablegen.ValueFromIndex[i]) ;
      gen:=Round(Random(sum)) ;
      sum:=0 ;
      genid:=0 ;
      mHGE.System_Log('gen: %d',[gen]);
      for i := 0 to level - 1 do begin
        if (gen>=sum)and(gen<sum+tablegen.ValueFromIndex[i]) then begin
          genid:=i ;
          Break ;
        end
        else
          Inc(sum,tablegen.ValueFromIndex[i]) ;
      end;

      if genid<=3 then Break ;
      // Зеленый ужас
      if (genid=4)and(TBattleField(BF).getObjCountByCode('tent')<3) then Break ;
      // Гидра
      if (genid=5)and(TBattleField(BF).getObjCountByCode('gidra')<2) then Break ;

    end;
    
    Result:=genid ;
    
end ;

procedure TMonsterPortal.NextStep;
var GO:TGameObject ;
    Params:TStringList ;
    RList:TCellListNoOwn ;
    Cell,TargetCell:TCell ;
    i,genid:Integer ;
    
const MAX_DARKPORTALS=4 ;
    
begin
  inherited NextStep();

  Dec(tekgen) ;
  if tekgen=0 then begin
  tekgen:=period ;

  Cell:=TBattleField(BF).GetCellByObject(Self) ;
  if Cell<>nil then begin

    RList:=TBattleField(BF).GetCellsOnDistN(Cell,3,[spIgnoreTerrain]) ;
    RList.RemoveNonEmptyCells() ;
    if RList.Count>0 then begin
      TargetCell:=RList[Round(Random(RList.Count))] ;
      Params:=TStringList.Create ;

      genid:=GenNewMonsterI() ;

      Params.CommaText:=StringReplace(tablegen.Key[genid],'@','=',[rfReplaceAll])+
        ',holdground=true' ;// 'code=bat,"Name=Нетопырь"' ;
      if Params.Values['code']='tent' then
        GO:=GetGOFactory(BF).CreateGameObject('MonsterTent',Params)
      else
        GO:=GetGOFactory(BF).CreateGameObject('Monster',Params) ;
      if GO<>nil then
        TBattleField(BF).AddGameObject(GO,TargetCell) ;
      Params.Free ;
    end;
    RList.Free ;

  end ;
  end;

  if MonsterCode='darkportal_main' then
  if TBattleField(BF).getObjCountByCode('darkportal_small')<MAX_DARKPORTALS then begin
  Dec(portalgen) ;
  if portalgen=0 then begin
  portalgen:=portalperiod ;
  Cell:=TBattleField(BF).GetCellByObject(Self) ;
  if Cell<>nil then begin

    RList:=TBattleField(BF).GetCellsOnDistN(Cell,4,[spIgnoreTerrain]) ;
    RList.RemoveNonEmptyCells() ;

    if RList.Count>0 then begin
      TargetCell:=RList[Round(Random(RList.Count))] ;
      Params:=TStringList.Create ;
      Params.CommaText:='code=darkportal_small,"Name=Темный портал малый"' ;
      GO:=GetGOFactory(BF).CreateGameObject('MonsterPortal',Params) ;
      if GO<>nil then
        TBattleField(BF).AddGameObject(GO,TargetCell) ;
      Params.Free ;
    end;
    RList.Free ;

  end ;
  end;
  end;

end;

{ TMonsterTirek }

constructor TMonsterTirek.Create(Params: TStringList);
begin
  inherited Create(Params);
end;

class function TMonsterTirek.GameClassName: string;
begin
  Result:='MonsterTirek' ;
end;

function TMonsterTirek.MagicStoleDist: Integer;
begin
  Result:=10 ;
end;

procedure TMonsterTirek.NextStep;
var Cell:TCell ;
    RList:TCellListNoOwn ;
    i:Integer ;
const magicstole=150 ;
begin
  Cell:=TBattleField(BF).GetCellByObject(Self) ;
  if Cell<>nil then begin
    RList:=GetCellFinder().FastGetAllCellsOnRadius(Cell,MagicStoleDist()) ;
    for i := 0 to RList.Count - 1 do begin
      if RList[i].IsPonyUnit() then begin
         if TPonyUnit(RList[i]._Object).Code<>'scorpion' then
         if Pos('taran',TPonyUnit(RList[i]._Object).Code)=0 then begin
         TPonyUnit(RList[i]._Object).DecEnergyForced(magicstole) ;
         HV.addNewHit(RList[i],hsEnergy,-magicstole) ;
         end ;
      end;
    end;
    RList.Free ;
  end ;
end;

procedure TMonsterTirek.Sleep(SleepTime: Integer);
begin
  TBattleField(BF).SetFlag('TirekFailSleep');
end;

initialization

GetGOFactory(nil).RegisterGameObjectClass(TMonsterUnit);
GetGOFactory(nil).RegisterGameObjectClass(TMonsterTwist);
GetGOFactory(nil).RegisterGameObjectClass(TMonsterCave);
GetGOFactory(nil).RegisterGameObjectClass(TMonsterTent);
GetGOFactory(nil).RegisterGameObjectClass(TMonsterTirek);
GetGOFactory(nil).RegisterGameObjectClass(TMonsterPortal);

end.