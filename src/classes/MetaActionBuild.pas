unit MetaActionBuild;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionBuild = class(TMetaAction)
  private
    BuildCode:string ;
    AnyTerrain:Boolean ;
    Limit:Integer ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses GameObject, ObjModule, SysUtils, simple_oper ;

{ TMetaActionBuild }

function TMetaActionBuild.Apply(Cell: TCell): Boolean;
var GO:TGameObject ;
begin
  Result:=False ;
  if not Cell.IsEmpty() then Exit ;

  GO:=GetGOFactory(BF).CreateGameObject('Building',SavedParams) ;
  if GO=nil then Exit ;

  Result:=True ;
  BF.AddGameObject(GO,Cell) ;
  mHGE.System_Log('objects with cname=%s and params "%s" added ok',
     ['Building',SavedParams.CommaText]);

end;

function TMetaActionBuild.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsEmpty then begin
    Result:=False ;
    errmsg:='Место занято!' ;
  end
  else
  if not (Cell._Terrain.AllowBuild or AnyTerrain) then begin
    Result:=False ;
    errmsg:='Нельзя строить на этом рельефе!' ;
  end
  else
  if BF.getObjCountByCode(BuildCode)>=Limit then begin
    errmsg:='Нельзя построить более зданий этого типа!' ;
    Result:=False ;
  end
  else
    Result:=True ;

end;

constructor TMetaActionBuild.Create(Params: TStringList);
begin
  Params.Delete(0);
  BuildCode:=Params.Values['BuildCode'] ;
  Params.Values['Code']:=BuildCode ;
  AnyTerrain:=LowerCase(Params.Values['AnyTerrain'])='true' ;
  Limit:=StrToIntWt0(Params.Values['Limit']) ;
  if Limit=0 then Limit:=High(Limit) ;
  
  inherited Create(Params) ;
end;

initialization

  RegisterMetaAction(TMetaActionBuild) ;

end.
