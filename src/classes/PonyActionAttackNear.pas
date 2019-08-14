unit PonyActionAttackNear ;

interface
uses PonyAction, Classes, BattleField, MinMaxValues, CommonClasses,
  GameObject ;

type
  TPAAttackNear = class(TPonyAction)
  private
    AttackValue:TMinMaxValues ;
    AttackEnergy:Integer ;
  public
    function Code():string ; override ;

    function Caption():string ; override ;
    function Info():string ; override ;
    function SubInfo():string ; override ;
    function Icon(Pony:TGameObject):string ; override ;

    constructor Create(paramstr:string);
    function BuildAllowCellList(CellStart:TCell):TCellListNoOwn ; override ;
    function Apply(BF:TBattleField; Cell:TCell; var errmsg:string):Boolean ; override ;

    function CanApply(BF:TBattleField; var errmsg:string):Boolean ; override ;
  end ;

implementation
uses SysUtils, TAVHGEUtils, simple_oper, MonsterUnits, PonyUnits,
  Config, ObjModule, HitViewer, HardLevels ;

{ TPAAttackNear }

function TPAAttackNear.Apply(BF: TBattleField; Cell: TCell;
  var errmsg:string): Boolean;
var iskilled:Boolean ;
    attack:Integer ;
begin
  Result:=False ;
  errmsg:='Нет врага для атаки' ;
  if not Cell.IsEmpty() then
    if Cell._Object is TMonsterUnit then
    if TPonyUnit(BF.GetActiveObject()).DecEnergy(AttackEnergy) then begin
      attack:=AttackValue.GetRndBetween ;
      if TMonsterUnit(Cell._Object).DecHealth(attack,iskilled) then begin
        HV.AddNewHit(Cell,hsGood,-attack) ;
        if iskilled then Cell.ClearObject ;
        Result:=True ;
        errmsg:='' ;
      end;
    end;
end;

function TPAAttackNear.BuildAllowCellList(CellStart: TCell): TCellListNoOwn;
var i:Integer ;
    z:Boolean ;
begin
  Result:=inherited BuildAllowCellList(CellStart) ;

  for i:=0 to CellStart.GetLinkCount()-1 do begin
    if CellStart.GetLinked(i).IsEmpty then
      z:=True
    else
      z:=CellStart.GetLinked(i)._Object is TMonsterUnit ;
    if z then Result.Add(CellStart.GetLinked(i)) ;
  end;
end;

function TPAAttackNear.CanApply(BF: TBattleField; var errmsg: string): Boolean;
begin
  Result:=TPonyUnit(BF.GetActiveObject()).GetEnergy>=AttackEnergy ;
  if not Result then errmsg:=Format('Мало силы (нужно %d)!',[AttackEnergy]) ;
end;

function TPAAttackNear.Caption: string;
begin  Result:='Атака ближняя' ; end;

function TPAAttackNear.Code: string;
begin  Result:='AttackNear' ; end;

constructor TPAAttackNear.Create(paramstr: string);
var params:TStringList ;
begin
  params:=TStringList.Create ;
  params.CommaText:=paramstr ;
  AttackValue:=TMinMaxValues.Create(
    StrToIntWt0(params.Values['AttackValue_min']),
    StrToIntWt0(params.Values['AttackValue_max'])) ;
  AttackEnergy:=GConfig(Self).AsInteger('AttackEnergy') ;
  SetNoviceEnergy(AttackEnergy) ;  
  params.Free ;  
end;

function TPAAttackNear.Icon(Pony:TGameObject): string;
begin
  Result:='attack_melee_'+TPonyUnit(Pony).WeaponCode ;
end;

function TPAAttackNear.Info: string;
begin
  Result:=Format('%s%d',
    [SYM_ENERGY,AttackEnergy]) ;
end;

function TPAAttackNear.SubInfo: string;
begin
  Result:=Format('Наносит урон в размере %d-%d единиц выбранному противнику',
    [AttackValue.GetMin,AttackValue.GetMax]) ;
end;

end.
