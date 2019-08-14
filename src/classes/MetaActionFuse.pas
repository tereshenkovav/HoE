unit MetaActionFuse;

interface
uses MetaAction, BattleField, Classes ;

type
  TMetaActionFuse = class(TMetaAction)
  private
    TargetPonyName:string ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, PonyUnits, ObjModule, GameObject, TAVStrUtils ;

{ TMetaActionFuse }

function TMetaActionFuse.Apply(Cell: TCell): Boolean;
var GO:TGameObject ;
begin
  Result:=False ;
  if not Cell.IsPonyUnit then Exit ;

  Cell.ClearObject() ;
  BF.GetActiveCell.ClearObject() ;

  GO:=GetGOFactory(BF).CreateGameObject('Pony',SavedParams) ;
  if GO=nil then Exit ;

  Result:=True ;
  BF.AddGameObject(GO,BF.GetActiveCell) ;

end;

function TMetaActionFuse.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
var PonyList:TStringList ;
begin
  if not Cell.IsPonyUnit then begin
    Result:=False ;
    errmsg:='Нет пони для слияния' ;
  end
  else begin
    PonyList:=CreateStringListBySep(TargetPonyName,'|') ;
    if PonyList.IndexOf(TPonyUnit(Cell._Object).Name)=-1 then begin
      Result:=False ;
      errmsg:='Слияние возможно с пони: '+TargetPonyName ;
    end
    else
      Result:=True ;
    PonyList.Free ;
  end ;

end;

constructor TMetaActionFuse.Create(Params: TStringList);
begin
  inherited Create(Params);
  TargetPonyName:=Params.Values['TargetPonyName'] ;
  SavedParams.Delete(SavedParams.IndexOfName('Code'));
  SavedParams.Add('Code='+SavedParams.Values['NewPony']) ;
end;

initialization

  RegisterMetaAction(TMetaActionFuse) ;

end.
