unit MetaActionMineStone;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionMineStone = class(TMetaAction)
  private
    MineValue:Integer ;
  public
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
    constructor Create(Params: TStringList); override ;
  end;

implementation
uses ObjModule, NeutralUnits, GameObject, SysUtils ;

{ TMetaActionMineStone }

function IsStoneWall(GO:TGameObject):Boolean ;
begin
  Result:=GO is TNeutralUnit ;
  if Result then Result:=TNeutralUnit(GO).Code='stonewall' ;
end ;

function TMetaActionMineStone.Apply(Cell: TCell): Boolean;
begin
  if not Cell.IsEmpty() then begin
    if IsStoneWall(Cell._Object) then begin
      Result:=True ;
      BF.IncStone(MineValue) ;
      Cell.ClearObject() ;
    end
  end ;
end;

function TMetaActionMineStone.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  Result:=False ;
  errmsg:='Нет стены для добычи камня!' ;
  if not Cell.IsEmpty then
    if IsStoneWall(Cell._Object) then begin
      Result:=True ;
      errmsg:='' ;
    end;
end;

constructor TMetaActionMineStone.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  MineValue:=StrToInt(Params.Values['MineValue']) ;
end;

initialization

  RegisterMetaAction(TMetaActionMineStone) ;

end.
