unit MetaActionTransform;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionTransform = class(TMetaAction)
  private
    TransformPony:string ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses GameObject, ObjModule ;

{ TMetaActionTransform }

function TMetaActionTransform.Apply(Cell: TCell): Boolean;
var GO:TGameObject ;
begin
  Result:=False ;
  if Cell<>BF.GetActiveCell then Exit ;

  Cell.ClearObject() ;

  GO:=GetGOFactory(BF).CreateGameObject('Pony',SavedParams) ;
  if GO=nil then Exit ;

  Result:=True ;
  BF.AddGameObject(GO,Cell) ;
  mHGE.System_Log('objects with cname=%s and params "%s" added ok',
     [TransformPony,SavedParams.CommaText]);

end;

function TMetaActionTransform.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if BF.getObjCountByCode(TransformPony)>0 then begin
    errmsg:='Единица уже призвана!' ;
    Result:=False ;
  end
  else
  if Cell<>BF.GetActiveCell then begin
    Result:=False ;
    errmsg:='Применяется только на себя!' ;
  end
  else
    Result:=True ;

end;

constructor TMetaActionTransform.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  TransformPony:=Params.Values['Pony'] ;
  SavedParams.Delete(SavedParams.IndexOfName('Code'));
  SavedParams.Add('Code='+SavedParams.Values['Pony']) ;
end;

initialization

  RegisterMetaAction(TMetaActionTransform) ;

end.
