unit PonyActionAttackLong ;

interface
uses PonyAction, Classes, BattleField, MinMaxValues, CommonClasses,
  GameObject ;

type
  TPAAttackLong = class(TPonyAction)
  private
    AttackValue:TMinMaxValues ;
    AttackDist:Integer ;
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
  Config, CellFinder, ObjModule, HitViewer, HardLevels ;

{ TPAAttackLong }

function TPAAttackLong.Apply(BF: TBattleField; Cell: TCell;
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

function TPAAttackLong.BuildAllowCellList(CellStart: TCell): TCellListNoOwn;
begin
  Result:=GetCellFinder().CreateListCellsRadials
    (CellStart,AttackDist,dtpToMonster,DoBreakOnThrow) ;
end;

function TPAAttackLong.CanApply(BF: TBattleField; var errmsg: string): Boolean;
begin
  Result:=TPonyUnit(BF.GetActiveObject()).GetEnergy>=AttackEnergy ;
  if not Result then errmsg:=Format('Мало силы (нужно %d)!',[AttackEnergy]) ;
end;

function TPAAttackLong.Caption: string;
begin  Result:='Атака дальняя' ; end;

function TPAAttackLong.Code: string;
begin  Result:='AttackLong' ; end;

constructor TPAAttackLong.Create(paramstr:string);
var params:TStringList ;
begin
  params:=TStringList.Create ;
  params.CommaText:=paramstr ;
  AttackValue:=TMinMaxValues.Create(
    StrToIntWt0(params.Values['AttackValue_min']),
    StrToIntWt0(params.Values['AttackValue_max'])) ;
  AttackDist:=StrToIntWt0(params.Values['AttackDist']) ;
  AttackEnergy:=GConfig(Self).AsInteger('AttackEnergy') ;
  SetNoviceEnergy(AttackEnergy) ;
  params.Free ;
end;

function TPAAttackLong.Icon(Pony: TGameObject): string;
begin
  Result:='attack_range_'+TPonyUnit(Pony).WeaponCode ;
end;

function TPAAttackLong.Info: string;
begin
  Result:=Format('%s%d',
    [SYM_ENERGY,AttackEnergy]) ;
end;

function TPAAttackLong.SubInfo: string;
begin
  Result:=Format('Наносит урон в размере %d-%d единиц выбранному противнику',
    [AttackValue.GetMin,AttackValue.GetMax]) ;
end;

end.
