unit MetaActionUpload;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionUpload = class(TMetaAction)
  private
  public
    place:Integer ;
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses GameObject, ObjModule, simple_oper ;

{ TMetaActionUpload }

function TMetaActionUpload.Apply(Cell: TCell): Boolean;
begin
  Result:=False ;
  if not Cell.IsPonyUnit then Exit ;

  BF.getActiveObject.StoredObject[place]:=Cell._Object ;

  Cell.ClearObject(false);
  Result:=True ;
end;

function TMetaActionUpload.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not Cell.IsPonyUnit then begin
    Result:=False ;
    errmsg:='Нет пони для загрузки!' ;
  end
  else
    Result:=True ;
end;

constructor TMetaActionUpload.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  place:=StrToIntWt0(Params.Values['place']) ;
end;

initialization

  RegisterMetaAction(TMetaActionUpload) ;

end.
