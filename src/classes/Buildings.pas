unit Buildings ;

interface

uses GameObject, Classes, StepAction, PassiveProp, contnrs ;

type
  TBuilding = class(TGameObject)
  private
    FHealth:Integer ;
    FMaxHealth:Integer ;
    FIsReparable:Boolean ;
    FCode:string ;
    FCaption:string ;
    FInfo:string ;
    FIsMustSurvive:Boolean ;
  public
    class function GameClassName:string ; override ;

    function SpriteTag:string ; override ;
    function Name:string ; override ;
    function Info():string ; override ;
    procedure NextStep() ; override ;

    function CalcProduceFoodAtMoment():Integer ;
    function CalcProduceStoneAtMoment():Integer ;

    procedure ProcessRemove() ; override ;
    function IsMustSurvive():Boolean ; override ;

    constructor Create(Params:TStringList) ; override ;
    function IsEnemyTarget():Boolean ; override ;
    procedure DoAttackFromEnemy(attackvalue: Integer;
      out ae: TAttackEvent); override ;

    procedure MakeNoTarget() ;

    function Repair(rest:Integer):Boolean ;

    property Code:string read FCode ;
    property Health:Integer read FHealth ;
    property MaxHealth:Integer read FMaxHealth ;
    property IsReparable:Boolean read FIsReparable ;
  end;

implementation
uses SysUtils, ObjModule, IniFiles, simple_oper, BattleField,
  PassivePropIDDQD, PassivePropNoTarget, FFGame, StepActionProduce ;

  { TBuilding }

function TBuilding.CalcProduceFoodAtMoment: Integer;
var i:Integer ;
begin
  Result:=0 ;
  for i := 0 to ListSActions.Count - 1 do
     if ListSActions[i] is TStepActionProduce then
       Inc(Result,TStepActionProduce(ListSActions[i]).GetValueByFood()) ;
end;

function TBuilding.CalcProduceStoneAtMoment: Integer;
var i:Integer ;
begin
  Result:=0 ;
  for i := 0 to ListSActions.Count - 1 do
     if ListSActions[i] is TStepActionProduce then
       Inc(Result,TStepActionProduce(ListSActions[i]).GetValueByStone()) ;
end;

constructor TBuilding.Create(Params: TStringList);
var Ini:TIniFile ;
    SParams:TStringList ;
    str:string ;
    p:Integer ;
begin
  inherited Create(Params);

  FCode:=Params.Values['Code'] ;

  Ini:=TIniFile.Create('..\configs\buildings.ini') ;
  if not Ini.SectionExists(Code) and
    FileExists(LevelFileName+'.data\configs\buildings.ini') then begin
    Ini.Free ;
    Ini:=TIniFile.Create(LevelFileName+'.data\configs\buildings.ini') ;
  end;

  FCaption:=Ini.ReadString(Code,'Caption','Не задан') ;
  FInfo:=Ini.ReadString(Code,'Info','') ;
  FHealth:=Ini.ReadInteger(Code,'StrongValue',1) ;
  FIsReparable:=Ini.ReadString(Code,'IsReparable','false')='true' ;
  FMaxHealth:=FHealth ;

  FIsMustSurvive:=params.Values['MustSurvive']='true' ;

  p:=0 ;
  while True do begin
    str:=Ini.ReadString(Code,'StepAction'+IntToStrWt0(p),'') ;
    if str='' then Break ;

    SParams:=TStringList.Create ;
    SParams.CommaText:=str ;
    ListSActions.Add(StepAction.CreateStepAction(SParams)) ;
    SParams.Free ;

    Inc(p) ;
  end;

  p:=0 ;
  while True do begin
    str:=Ini.ReadString(Code,'PassiveProp'+IntToStrWt0(p),'') ;
    if str='' then Break ;

    SParams:=TStringList.Create ;
    SParams.CommaText:=str ;
    ListPProps.Add(PassiveProp.CreatePassiveProp(SParams)) ;
    SParams.Free ;

    Inc(p) ;
  end;

  Ini.Free ;
end;

class function TBuilding.GameClassName: string;
begin
  Result:='Building' ;
end;

function TBuilding.Info: string;
var addinfo:string ;
    i:Integer ;
begin
  Result:=FInfo+#13+'прочность '+IntToStr(Health) ;
  for i := 0 to ListSActions.Count - 1 do begin
    addinfo:=TStepAction(ListSActions[i]).AddInfo ;
    if addinfo<>'' then Result:=Result+#13+addinfo ;
  end;
  for i := 0 to ListPProps.Count - 1 do begin
    addinfo:=TPassiveProp(ListPProps[i]).AddInfo ;
    if addinfo<>'' then Result:=Result+#13+addinfo ;
  end;

end;

function TBuilding.Name: string;
begin
  Result:=FCaption ;
end;

procedure TBuilding.NextStep();
var i:Integer ;
begin
  for i := 0 to ListSActions.Count - 1 do
    TStepAction(ListSActions[i]).Apply(TBattleField(BF).GetCellByObject(Self)) ;
end;

function TBuilding.SpriteTag: string;
begin
  Result:=LowerCase('building_'+Code) ;
end;

procedure TBuilding.DoAttackFromEnemy(attackvalue: Integer;
  out ae: TAttackEvent);
var PP:TPassiveProp ;
begin
  if GetPassiveProp(TPassivePropIDDQD,PP) then begin
    ae.doFix:=False ;
    ae._Object:=Self ;
    ae.doDelete:=False ;
    ae.msg:=IntToStr(-attackvalue) ; ;
    Exit ;
  end;
  
  Dec(FHealth,attackvalue) ;
  if FHealth<=0 then begin
    FHealth:=0 ;
    ae.doDelete:=True ;
    ae.msg:='хрустъ' ;
  end
  else begin
    ae.doDelete:=False ;
    ae.msg:=IntToStr(-attackvalue) ;
  end;
  ae.doFix:=True ;
  ae._object:=self ;

end;

function TBuilding.IsEnemyTarget: Boolean;
var SP:TPassiveProp ;
begin
  Result:=True ;
  if getPassiveProp(TPassivePropNoTarget,SP) then Result:=False ;

end;

function TBuilding.IsMustSurvive: Boolean;
begin
  Result:=FIsMustSurvive ;
end;

procedure TBuilding.MakeNoTarget;
var SParams:TStringList ;
begin
  SParams:=TStringList.Create() ;
  SParams.CommaText:='Code=NoTarget' ;
  ListPProps.Add(PassiveProp.CreatePassiveProp(SParams)) ;
  SParams.Free ;
end;

procedure TBuilding.ProcessRemove() ; 
begin
  if (Code='CrystalTowerSmall') then begin
    effect_init_pos:=TBattleField(BF).GetShift() ;
    sct_del_pos.X:=TBattleField(BF).GetCellByObject(Self).XC ;
    sct_del_pos.Y:=TBattleField(BF).GetCellByObject(Self).YC ;
    sctDelAnim.Play ;
  end;
  if (Code='CrystalTowerBig') then begin
    effect_init_pos:=TBattleField(BF).GetShift() ;
    sct_del_pos.X:=TBattleField(BF).GetCellByObject(Self).XC ;
    sct_del_pos.Y:=TBattleField(BF).GetCellByObject(Self).YC ;
    bctDelAnim.Play ;
  end;
end;

function TBuilding.Repair(rest: Integer):Boolean;
begin
  Inc(FHealth,rest) ;
  if FHealth>MaxHealth then FHealth:=MaxHealth ;
  Result:=True ;
end;

initialization

GetGOFactory(nil).RegisterGameObjectClass(TBuilding);

end.
