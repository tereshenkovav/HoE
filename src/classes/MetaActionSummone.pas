unit MetaActionSummone;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionSummone = class(TMetaAction)
  private
    SummonePony:string ;
    NoCheckCount:Boolean ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses GameObject, ObjModule ;

{ TMetaActionSummone }

function TMetaActionSummone.Apply(Cell: TCell): Boolean;
var GO:TGameObject ;
begin
  Result:=False ;
  if not Cell.IsEmpty() then Exit ;

  GO:=GetGOFactory(BF).CreateGameObject('Pony',SavedParams) ;
  if GO=nil then Exit ;

  Result:=True ;
  BF.AddGameObject(GO,Cell) ;
  mHGE.System_Log('objects with cname=%s and params "%s" added ok',
     [SummonePony,SavedParams.CommaText]);

end;

function TMetaActionSummone.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if (BF.getObjCountByCode(SummonePony)>0)and(not NoCheckCount) then begin
    errmsg:='Единица уже призвана!' ;
    Result:=False ;
  end
  else
  if not Cell.IsEmpty then begin
    Result:=False ;
    errmsg:='Место занято!' ;
  end
  else
    Result:=True ;

end;

constructor TMetaActionSummone.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  SummonePony:=Params.Values['Pony'] ;
  NoCheckCount:=Params.Values['NoCheckCount']='true' ;
  SavedParams.Delete(SavedParams.IndexOfName('Code'));
  SavedParams.Add('Code='+SavedParams.Values['Pony']) ;
end;

initialization

  RegisterMetaAction(TMetaActionSummone) ;

end.
