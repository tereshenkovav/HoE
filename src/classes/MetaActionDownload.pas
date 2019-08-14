unit MetaActionDownload;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionDownload = class(TMetaAction)
  private
  public
    place:Integer ;
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses GameObject, ObjModule, simple_oper ;

{ TMetaActionDownload }

function TMetaActionDownload.Apply(Cell: TCell): Boolean;
var GO:TGameObject ;
begin
  Result:=False ;
  if not Cell.IsEmpty() then Exit ;

  if BF.getActiveObject=nil then Exit ;

  Result:=True ;

  BF.AddGameObject(BF.getActiveObject.StoredObject[place],Cell) ;
  BF.getActiveObject.StoredObject[place]:=nil ;
  
end;

function TMetaActionDownload.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if BF.getActiveObject=nil then begin
    errmsg:='Некого выгружать!' ;
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

constructor TMetaActionDownload.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  place:=StrToIntWt0(Params.Values['place']) ;
end;

initialization

  RegisterMetaAction(TMetaActionDownload) ;

end.
