unit PonyUnits ;

interface
uses GameObject, Classes, PonyAction, CommonClasses ;

type
  TPonyUnit = class(TGameObject)
  private
    PonyName:string ;
    PonyCode:string ;
    MaxStep:Integer ;
    OldMaxStep:Integer ;
    StepLeft:Integer ;
    Health:Integer ;
    MaxHealth:Integer ;
    Energy:Integer ;
    MaxEnergy:Integer ;
    ActionList:TPonyActionList ;
    PermittedActionList:TPonyActionList ;
    EmptyActionList:TPonyActionList ;
    CanAction:Boolean ;
    UnderAttack:Boolean ;
    infolist:TStringList ;
    FNoRestoredPony:Boolean ;
    WingsLeft:Integer ;
    ShieldLeft:Integer ;
    ShieldValue:Integer ;
    ShieldTag:string ; 
    StunLeft:Integer ;
    FIsWaterUnit:Boolean ;
    FDisableFlying:Boolean ;
    FDeathAllow:Boolean ;

    StoredStepLeft:Integer ;
    StoredEnergy:Integer ;
    StoredHealth:Integer ;

    FSpecialSpriteTag:string ;
    FIconTag:string ;

    FlagTeleport:Boolean ;
    TeleportCell:TObject ;
    TeleportTime:Single ;

    IsOnceAccel:Boolean ;

    function RelaxEnergyRest():Integer ;
    function RelaxHealthRest():Integer ;
    function StepEnergyRest():Integer ;
    function StepHealthRest():Integer ;
    procedure AddInfo(str:string) ; overload ;
    procedure AddInfo(fmt:string; d:Integer) ; overload ;
    procedure AddInfo(fmt:string; d1,d2:Integer) ; overload ;
  public
    constructor Create(Params:TStringList) ; override ;
    function CanRule():Boolean ; override ;
    class function GameClassName:string ; override ;
    function SpriteTag:string ; override ;
    function IconName:string ;
    function Name:string ; override ;
    function Code:string ;
    function WeaponCode:string ; 
    function Info():string ; override ;
    procedure NextStep() ; override ;
    function IsEnemyTarget():Boolean ; override ;
    function IsNoRestored():Boolean ;
    function DecStep(delta:Integer):Boolean ; override ;
    function GetStepLeft():Integer ;
    function GetStepLeftWithEnergy():Integer ;
    function GetMiniStepInfo():string ;
    function GetHealthPerc: Integer;
    function GetEnergyPerc: Integer;
//    function GetEnergy():Integer ;
//    function GetEnergyInfo():string ;
//    function GetHealth():Integer ;
//    function GetHealthInfo():string ;

    procedure AddAction(code:string) ;
    function GetActionList():TPonyActionList ;
    function GetPermittedActionList(PA:TPonyActionPermits):TPonyActionList ;
    procedure ApplyAction() ;
    function IsCanAction():Boolean ;
    function IsNoMakeStepWithEnergy():Boolean ;

    function DecEnergy(Value:Integer):Boolean ;
    function IncEnergy(Delta:Integer; NoBound:Boolean=False):Boolean ;
    function GetEnergy():Integer ;
    function DecEnergyForced(Value:Integer):Boolean ;
    function DecHealth(Delta:Integer;
      var iskilled:Boolean):Boolean ;
    function IncHealth(Delta:Integer; NoBound:Boolean=False):Boolean ;
    function IsKilled():Boolean ;
    procedure SetMaxHealth(Value:Integer) ;
    procedure SetMaxEnergy(Value:Integer) ;

    function SetWings(stepleft:Integer):Boolean ;
    function IsWings():Boolean ;
    function SetShield(stepleft:Integer; AShieldValue:Integer; AShieldTag:string):Boolean ;
    function IsShield():Boolean ;
    function IsShieldNR():Boolean ;
    function SetStun(stepleft:Integer):Boolean ;
    function IsStun():Boolean ;

    procedure SetOnceMaxStep(Value:Integer) ;

    function IsFlyer():Boolean ; override ;
    function IsUnicorn():Boolean ; override ;
    function IsEarthPony():Boolean ; override ;
    function IsWaterUnit: Boolean; override ;

    function DeathAllow():Boolean ;

    procedure ClearUnderAttack() ;

    function GetStepInfo():string ;
    procedure ClearStepInfo() ;

    procedure PushState() ;
    procedure PopState() ;

    procedure RunTeleportaion(ToCell:TObject) ;
    function IsHided: Boolean; override ;

    procedure Update(dt:Single) ; override ;

    function GetRestoredEnergyAtMoment():Integer ;
    function GetRestoredHealthAtMoment():Integer ;
    function GetDecFoodAtMoment():Integer ;

    property GetHealth:Integer read Health ;
    property GetMaxHealth:Integer read MaxHealth ;
    property GetMaxEnergy:Integer read MaxEnergy ;
    property IsTeleported:Boolean read FlagTeleport ;
  end;

implementation
uses SysUtils, BattleField, Config, IniFiles, ObjModule,
  TAVStrUtils, PonyActionEx, PonyActionAttackNear, PonyActionAttackLong,
  PassiveProp, FFGame, BuiltinMapFuncs, StepAction, HardLevels, Player ;

const
  DEC_HEALTH_BY0ENERGY = 2 ;

{ TPonyUnit }

function TPonyUnit.CanRule: Boolean;
begin
  Result:=True ;
end;

procedure TPonyUnit.ClearStepInfo;
begin
  infolist.Clear ;
end;

procedure TPonyUnit.ClearUnderAttack;
begin
  UnderAttack:=False ;
end;

function TPonyUnit.Code: string;
begin
  Result:=PonyCode ;
end;

constructor TPonyUnit.Create(Params: TStringList);
var SParams:TStringList ;
begin
  inherited Create(Params) ;

  infolist:=TStringList.Create ;

  PonyCode:=Params.Values['Code'] ;
  PonyName:=Params.Values['Name'] ;

  FIsFlyer:=GConfig(Self).AsBoolean(PonyCode+'_isflyer') ;
  FIsWaterUnit:=GConfig(Self).AsBoolean(PonyCode+'_iswaterpony') ;

  FNoRestoredPony:=GConfig(Self).AsBoolean(PonyCode+'_isnorestored') ;

  MaxStep:=GConfig(Self).AsInteger(PonyCode+'_maxstep') ;
  SetNoviceMaxPonyStep(MaxStep) ;
  oldMaxStep:=MaxStep ;

  MaxEnergy:=GConfig(Self).AsInteger(PonyCode+'_maxenergy') ;
  MaxHealth:=GConfig(Self).AsInteger(PonyCode+'_maxhealth') ;

  if PonyCode='twily' then
    if PL.IsTwailikorn then begin
      FIsFlyer:=True ;
      MaxStep:=4 ;
      oldMaxStep:=MaxStep ;
    end;

  if PonyCode='flatter' then begin
    SParams:=TStringList.Create ;
    SParams.CommaText:='Code=SpaceProtect,Dist=3' ;
    ListPProps.Add(PassiveProp.CreatePassiveProp(SParams)) ;
    SParams.Free ;
  end ;

  if PonyCode='bear' then begin
    SParams:=TStringList.Create ;
    SParams.CommaText:='Code=Destroy,StepLeft=3' ;
    ListSActions.Add(StepAction.CreateStepAction(SParams)) ;
    SParams.Free ;
  end ;

  StepLeft:=MaxStep ;
  Health:=MaxHealth ;
  Energy:=MaxEnergy ;

  CanAction:=True ;

  // Установка из параметров, если есть
  if params.Values['Health']<>'' then
    Health:=StrToInt(params.Values['Health']) ;
  if params.Values['Energy']<>'' then
    Energy:=StrToInt(params.Values['Energy']) ;


  FDisableFlying:=params.Values['disableflying']='true' ;

  FSpecialSpriteTag:=params.Values['SpriteTag'] ;
  FIconTag:=params.Values['IconTag'] ;
  FDeathAllow:=params.Values['DeathAllow']='true' ;

  IsOnceAccel:=False ;
//  UnderAttack:=False ;
end;

function TPonyUnit.DeathAllow: Boolean;
begin
  Result:=FDeathAllow ;
end;

function TPonyUnit.DecEnergy(Value: Integer): Boolean;
begin
  Result:=(Energy>=Value) ;
  if Result then Dec(Energy,Value) ;
end;

function TPonyUnit.DecEnergyForced(Value: Integer): Boolean;
begin
  Result:=True ;
  Dec(Energy,Value) ;
  if Energy<0 then Energy:=0 ;
end;

function TPonyUnit.DecHealth(Delta: Integer; var iskilled: Boolean): Boolean;
begin
  Result:=True ;
  if IsShield() then Dec(Health,Round(Delta*(1-ShieldValue/100))) else Dec(Health,Delta) ;
  iskilled:=(Health<=0) ;
  if Health<0 then Health:=0 ;

  UnderAttack:=True ;
  if IsShield and (ShieldValue=100) then UnderAttack:=False ;  

  if ObjModule.PL.GetHardLevel()=hlImmortal then
    if (Health=0)and(not IsShield) then begin
      Health:=1 ;
      SetShield(3,100,'') ;
      UnderAttack:=False ;
    end;
end;

function TPonyUnit.DecStep(delta: Integer):Boolean ;
var deltaforpony:Integer ;
begin
  if IsFlyer() then deltaforpony:=1 else deltaforpony:=delta ;

  if (Energy=0) then begin
    StepLeft:=0 ;
    if (Health>DEC_HEALTH_BY0ENERGY) then Dec(Health,DEC_HEALTH_BY0ENERGY) ;
  end
  else begin
    if not DecEnergyForced(deltaforpony) then Exit ;
    Dec(StepLeft,deltaforpony) ;
    if StepLeft<0 then StepLeft:=0 ;
  end;
end;

class function TPonyUnit.GameClassName: string;
begin
  Result:='Pony' ;
end;

function TPonyUnit.GetStepInfo: string;
begin
  Result:=infolist.Text ;
end;

function TPonyUnit.GetStepLeft: Integer;
begin
  Result:=StepLeft ;
end;

function TPonyUnit.GetStepLeftWithEnergy: Integer;
begin
  if IsStun() then Result:=0 else
  if (Energy=0)and(StepLeft=MaxStep)and(Health>DEC_HEALTH_BY0ENERGY)and
    (MaxStep>0) then Result:=1 else  
  if Energy>=StepLeft then Result:=StepLeft else
  Result:=Energy ;
end;

function TPonyUnit.IconName: string;
begin
  if FIconTag<>'' then Result:=FIconTag+'_ico' else Result:=Code+'_ico' ;
end;

function TPonyUnit.IncEnergy(Delta: Integer; NoBound:Boolean=False): Boolean;
begin
  Result:=True ;
  Inc(Energy,Delta) ;
  AddInfo('Восстановлено сил заклинанием: %d',Delta) ;
  if not NoBound then
    if Energy>MaxEnergy then Energy:=MaxEnergy ;
end;

function TPonyUnit.IncHealth(Delta: Integer; NoBound:Boolean=False): Boolean;
begin
  Result:=True ;
  Inc(Health,Delta) ;
  AddInfo('Восстановлено здоровья заклинанием: %d',Delta) ;
  if not NoBound then
    if Health>MaxHealth then Health:=MaxHealth ;
end;

function TPonyUnit.Info: string;
var i:Integer ;
    addinfo:string ;
begin
  Result:=Format('%s%d/%d [+%d]'#13'%s%d/%d [+%d]'#13'%s%d/%d',
   [SYM_ENERGY,Energy,MaxEnergy,GetRestoredEnergyAtMoment(),
    SYM_HEALTH,Health,MaxHealth,GetRestoredHealthAtMoment,
    SYM_STEP,GetStepLeft,MaxStep]) ;

  for i := 0 to ListSActions.Count - 1 do begin
    addinfo:=TStepAction(ListSActions[i]).AddInfo ;
    if addinfo<>'' then Result:=Result+#13+addinfo ;
  end;

end;

function TPonyUnit.Name: string;
begin
  Result:=PonyName ;
end;

procedure TPonyUnit.NextStep();
var i:Integer ;
begin
  // Hard-coded потеря сил в астрале
  if TBattleField(BF).GetCellByObject(Self)<>nil  then
    if TBattleField(BF).GetCellByObject(Self)._Terrain.Name='Astral' then
      Dec(MaxEnergy,2) ;

  if not Self.IsNoRestored() then begin

  if Energy<MaxEnergy then begin
    if TBattleField(BF).DecFood(GConfig(Self).AsInteger('Food2Energy')) then begin
      AddInfo('Потрачено еды для восстановления энергии: %d',
        GConfig(Self).AsInteger('Food2Energy')) ;
      // Не ходили и не делали действий
      if (GetStepLeft=MaxStep)and(CanAction)and(not UnderAttack) then begin
        Inc(Energy,RelaxEnergyRest()) ;
        AddInfo('Восстановлено энергии за состояние покоя: %d',
           RelaxEnergyRest()) ;
      end
      // Обычное восстановление
      else begin
        Inc(Energy,StepEnergyRest()) ;
        AddInfo('Восстановлено энергии за остаток ходов(%d): %d',
           StepLeft,StepEnergyRest()) ;
      end;
    end
    else
      AddInfo('Недостаточно еды для восстановления энергии (нужно %d)',
        GConfig(Self).AsInteger('Food2Energy')) ;
  if Energy>MaxEnergy then Energy:=MaxEnergy ;
  end;


  if Health<MaxHealth then begin
    // Не восстанавливаем здоровье под атакой
    if not UnderAttack then begin
      if TBattleField(BF).DecFood(GConfig(Self).AsInteger('Food2Health')) then begin

      AddInfo('Потрачено еды для восстановления здоровья: %d',
        GConfig(Self).AsInteger('Food2Health')) ;

      // Не ходили и не делали действий
      if (GetStepLeft=MaxStep)and(CanAction)and(not UnderAttack) then begin
        Inc(Health,RelaxHealthRest()) ;
        AddInfo('Восстановлено здоровья за состояние покоя: %d',
           RelaxHealthRest()) ;
      end
      // Обычное восстановление
      else begin
        Inc(Health,StepHealthRest()) ;
        AddInfo('Восстановлено здоровья за остаток ходов(%d): %d',
           StepLeft,StepHealthRest()) ;
      end;

      end
      else
        AddInfo('Недостаточно еды для восстановления здоровья (нужно %d)',
          GConfig(Self).AsInteger('Food2Health')) ;
    end
    else
    AddInfo('Здоровье после атаки не восстанавливается 1 ход!') ;

  if Health>MaxHealth then Health:=MaxHealth ;

  end;
  end;

  // Именно здесь, перед StepLeft:=MaxStep ;
  if IsOnceAccel then begin
    MaxStep:=oldMaxStep ;
    IsOnceAccel:=False ;
  end;

  // Восстановление ходов и возможности действия
  StepLeft:=MaxStep ;
  CanAction:=True ;
  UnderAttack:=False ;

  if WingsLeft>0 then Dec(WingsLeft) ;
  if WingsLeft=0  then MaxStep:=oldMaxStep ;
  if ShieldLeft>0 then Dec(ShieldLeft) ;
  if StunLeft>0 then Dec(StunLeft) ;

  for i := 0 to ListSActions.Count - 1 do
    TStepAction(ListSActions[i]).Apply(TBattleField(BF).GetCellByObject(Self)) ;
end;

procedure TPonyUnit.PopState;
begin
  StepLeft:=StoredStepLeft ;
  Energy:=StoredEnergy ;
  Health:=StoredHealth ;
end;

procedure TPonyUnit.PushState;
begin
  StoredStepLeft:=StepLeft ;
  StoredEnergy:=Energy ;
  StoredHealth:=Health ;
end;

function TPonyUnit.RelaxEnergyRest: Integer;
begin
  Result:=Round(GConfig(Self).AsPercent('PercPlusEnergy_ByRelax')*MaxEnergy) ;
end;

function TPonyUnit.RelaxHealthRest: Integer;
begin
  Result:=Round(GConfig(Self).AsPercent('PercPlusHealth_ByRelax')*MaxHealth) ;
end;

procedure TPonyUnit.RunTeleportaion(ToCell: TObject);
begin
  FlagTeleport:=True ;
  TeleportCell:=ToCell ;
  TeleportTime:=1 ;
end;

procedure TPonyUnit.SetMaxEnergy(Value: Integer);
begin
  MaxEnergy:=value ;
end;

procedure TPonyUnit.SetMaxHealth(Value: Integer);
begin
  MaxHealth:=Value ;
end;

procedure TPonyUnit.SetOnceMaxStep(Value: Integer);
begin
  oldMaxStep:=MaxStep ;
  MaxStep:=Value ;
  StepLeft:=MaxStep ;
  IsOnceAccel:=True ;
end;

function TPonyUnit.SetShield(stepleft: Integer; AShieldValue:Integer;
  AShieldTag:string): Boolean;
begin
  ShieldLeft:=stepleft ;
  ShieldValue:=AShieldValue ;
  ShieldTag:=AShieldTag ;
  Result:=True ;
end;

function TPonyUnit.SetStun(stepleft: Integer): Boolean;
begin
  StunLeft:=stepleft ;
  Result:=True ;
end;

function TPonyUnit.SetWings(stepleft: Integer):Boolean;
begin
  WingsLeft:=stepleft ;
  MaxStep:=4 ;
  StepLeft:=4 ;
  Result:=True ;
end;

function TPonyUnit.SpriteTag: string;
begin
  Result:='pony_'+PonyCode ;

  if IsWings then
    if IsStrInCommaList(Code,'rarity,nrarity,applejack,pinki,twily') then
      Result:='pony_'+PonyCode+'_wings' ;

  if PonyCode='twily' then
    if PL.IsTwailikorn then
      Result:='pony_twailikorn' ;

  if FSpecialSpriteTag<>'' then Result:='pony_'+FSpecialSpriteTag ;
     
end;

function TPonyUnit.StepEnergyRest: Integer;
begin
  Result:=Round(GConfig(Self).AsPercent('PercPlusEnergy_ByStepsLeft')*
          MaxEnergy*GetStepLeft/MaxStep) ;
end;

function TPonyUnit.StepHealthRest: Integer;
begin
  Result:=Round(GConfig(Self).AsPercent('PercPlusHealth_ByStepsLeft')*
          MaxHealth*GetStepLeft/MaxStep) ;
end;

procedure TPonyUnit.Update(dt: Single);
var MyCell:TCell ;
begin
  inherited Update(dt);
  if FlagTeleport then begin
    TeleportTime:=TeleportTime-dt ;
    if TeleportTime<0.5 then begin
      if TBattleField(BF).GetCellByObject(Self)<>TeleportCell then begin
        TBattleField(BF).GetCellByObject(Self).TransactObject(TCell(TeleportCell)) ;
        TBattleField(BF).setActiveCell(TCell(TeleportCell)) ;
        OM.StopMovingProcess() ;
        TCell(TeleportCell)._Object.stopShiftView() ;
        // Отключили изменение камеры при телепортации нафиг -\
        //   включим, когда появится нормальная камера
        //if testXYOutScreen(TCell(TeleportCell).XC,TCell(TeleportCell).YC) then
        //  TBattleField(BF).ImmediateRunTo(TCell(TeleportCell).XC,TCell(TeleportCell).YC) ;
      end;
      if TeleportTime<=0 then FlagTeleport:=False ;
    end;
  end ;

  // Механика телепортации - жестко вшитая
  MyCell:=TBattleField(BF).GetCellByObject(Self) ;
  if MyCell._Terrain.Name='Teleport' then
    MapFuncs_processBuildingTeleport(TBattleField(BF),MyCell) ;
end;

function TPonyUnit.WeaponCode: string;
begin
  if IsStrInCommaList(Code,
    'rarity,nrarity,applejack,pinki,flatter,rainbow,twily,celestia,luna,cadence') then
      Result:=Code
  else
    Result:='common' ;
end;

function TPonyUnit.GetActionList():TPonyActionList ;
var Ini:TIniFile ;
    List:TStringList ;
    i:Integer ;  
begin
  if ActionList=nil then begin
    ActionList:=TPonyActionList.Create() ;

    List:=TStringList.Create ;
    Ini:=TIniFile.Create('..\configs\ponyactions.ini') ;
    if not Ini.SectionExists(PonyCode) and
      FileExists(LevelFileName+'.data\configs\ponyactions.ini') then begin
      Ini.Free ;
      Ini:=TIniFile.Create(LevelFileName+'.data\configs\ponyactions.ini') ;
    end;
    Ini.ReadSectionValues(PonyCode,List) ;
    Ini.Free ;

    // Особый случай - действие атаки добавляем старым классом
    if List.Values['AttackNear']='1' then begin
      ActionList.Add(TPAAttackNear.Create(
      'AttackValue_min='+GConfig(Self).AsString(PonyCode+'_AttackNearValue_min')+
      ',AttackValue_max='+GConfig(Self).AsString(PonyCode+'_AttackNearValue_max'))) ;
      List.Delete(List.IndexOfName('AttackNear'));
    end;

    if List.Values['AttackLong']='1' then begin
      ActionList.Add(TPAAttackLong.Create(
      'AttackValue_min='+GConfig(Self).AsString(PonyCode+'_AttackLongValue_min')+
      ',AttackValue_max='+GConfig(Self).AsString(PonyCode+'_AttackLongValue_max')+
      ',AttackDist='+GConfig(Self).AsString(PonyCode+'_AttackLongDist'))) ;
      List.Delete(List.IndexOfName('AttackLong'));
    end ;

     for i := 0 to List.Count - 1 do
      if List.ValueFromIndex[i]='1' then
        ActionList.Add(CreatePonyActionExFromMainIni(List.Names[i]));

    List.Free ;

    EmptyActionList:=TPonyActionList.Create() ;
  end ;
  if CanAction then Result:=ActionList else Result:=EmptyActionList ;
end ;

function TPonyUnit.GetDecFoodAtMoment: Integer;
begin
  if Self.IsNoRestored() then begin
    Result:=0 ;
    Exit ;
  end ;

  Result:=0 ;
  if Energy<MaxEnergy then
    Inc(Result,GConfig(Self).AsInteger('Food2Energy')) ;
  if Health<MaxHealth then
    if not UnderAttack then
      Inc(Result,GConfig(Self).AsInteger('Food2Health')) ;

end;

function TPonyUnit.GetEnergy: Integer;
begin
  Result:=Energy ;
end;

function TPonyUnit.GetMiniStepInfo: string;
begin
  if GetStepLeft=0 then Result:='0' else
  Result:=Format('%d/%d',[GetStepLeftWithEnergy(),MaxStep]) ;
end;

function TPonyUnit.GetHealthPerc: Integer;
begin
  if Health>MaxHealth then Result:=100 else
  Result:=Round(100*Health/MaxHealth) ;
end;

function TPonyUnit.GetEnergyPerc: Integer;
begin
  if Energy>MaxEnergy then Result:=100 else
  Result:=Round(100*Energy/MaxEnergy) ;
end;

procedure TPonyUnit.AddAction(code:string) ;
begin
  GetActionList().Add(CreatePonyActionExFromMainIni(code));
end ;

function TPonyUnit.GetPermittedActionList(
  PA: TPonyActionPermits): TPonyActionList;
var i,place:Integer ;
    z:Boolean ;
begin
  if PermittedActionList=nil then PermittedActionList:=TPonyActionList.Create ;

  while PermittedActionList.Count>0 do
    PermittedActionList.Extract(0);

  PermittedActionList.Locked:=False ;
  PermittedActionList.Stuned:=False ;
  if IsStun() then
    PermittedActionList.Stuned:=True
  else
  if (TBattleField(BF).IsMagicLockedAtCell(TBattleField(BF).GetCellByObject(Self)))and
     (PonyCode<>'scorpion')and(Pos('taran',PonyCode)=0) then
    PermittedActionList.Locked:=True
  else begin
    for i := 0 to GetActionList.Count - 1 do
      if PA.IsActionPermitted(GetActionList.GetAction(i)) then begin
        z:=True ;
        if GetActionList.GetAction(i) is TPOnyActionEx then begin
          if TPonyActionEx(GetActionList.GetAction(i)).OnlyForFreeStore(place) then
            z:=StoredObject[place]=nil ;
          if TPonyActionEx(GetActionList.GetAction(i)).OnlyForBusyStore(place) then
            z:=StoredObject[place]<>nil ;
        end;

        if z then PermittedActionList.Add(GetActionList.GetAction(i));
      end;
  end ;
  
  Result:=PermittedActionList ;
end;

function TPonyUnit.GetRestoredEnergyAtMoment: Integer;
var Delta:Integer ;
begin
  if IsNoRestored() then Delta:=0 else
  begin
  if (GetStepLeft=MaxStep)and(CanAction)and(not UnderAttack) then
    Delta:=RelaxEnergyRest()
  else
    Delta:=StepEnergyRest() ;
  if Energy+Delta>MaxEnergy then Delta:=MaxEnergy-Energy ;
  end;

  if Delta<0 then Result:=0 else Result:=Delta ;
end;

function TPonyUnit.GetRestoredHealthAtMoment: Integer;
var Delta:Integer ;
begin
  if IsNoRestored() then Delta:=0 else
  if UnderAttack then Delta:=0 else
  begin
    if (GetStepLeft=MaxStep)and(CanAction)and(not UnderAttack) then
      Delta:=RelaxHealthRest()
    else
      Delta:=StepHealthRest() ;
  end;

  if Health+Delta>MaxHealth then Delta:=MaxHealth-Health ;
  if Delta<0 then Result:=0 else Result:=Delta ;
end;

procedure TPonyUnit.AddInfo(str: string);
begin
  infolist.Add('- '+str) ;
end;

procedure TPonyUnit.AddInfo(fmt: string; d: Integer);
begin
  AddInfo(Format(fmt,[d])) ;
end;

procedure TPonyUnit.AddInfo(fmt: string; d1, d2: Integer);
begin
  AddInfo(Format(fmt,[d1,d2])) ;
end;

procedure TPonyUnit.ApplyAction() ;
begin
  CanAction:=False ;
end ;

function TPonyUnit.IsCanAction():Boolean ;
begin
  Result:=CanAction ;
end ;

function TPonyUnit.IsEnemyTarget: Boolean;
begin
  Result:=True ;
end;

function TPonyUnit.IsFlyer: Boolean;
begin
  if FDisableFlying then
    Result:=False
  else
    Result:=(inherited IsFlyer()) or IsWings ;
end;

function TPonyUnit.IsKilled: Boolean;
begin
  Result:=Health<=0 ;
end;

function TPonyUnit.IsNoMakeStepWithEnergy: Boolean;
begin
  Result:=(StepLeft=MaxStep)and((Energy>0)or(MaxEnergy=0)) ;
end;

function TPonyUnit.IsNoRestored: Boolean;
begin
  Result:=FNoRestoredPony ;
end;

function TPonyUnit.IsShield: Boolean;
begin
  Result:=ShieldLeft>0 ;
end;

function TPonyUnit.IsShieldNR: Boolean;
begin
  Result:=ShieldTag='NR' ;
end;

function TPonyUnit.IsStun: Boolean;
begin
  Result:=StunLeft>0 ;
end;

function TPonyUnit.IsHided: Boolean;
begin
  Result:=FlagTeleport and (TeleportTime>=0.5) ;
end;

function TPonyUnit.IsWaterUnit: Boolean;
begin
  Result:=FIsWaterUnit ;
end;

function TPonyUnit.IsWings: Boolean;
begin
  Result:=WingsLeft>0 ;
end;

function TPonyUnit.IsUnicorn: Boolean;
begin

end;

function TPonyUnit.IsEarthPony: Boolean;
begin

end;

initialization

GetGOFactory(nil).RegisterGameObjectClass(TPonyUnit);

end.