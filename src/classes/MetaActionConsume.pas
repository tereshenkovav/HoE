unit MetaActionConsume;

interface
uses MetaAction, Classes, BattleField ;

type
  TMetaActionConsume = class(TMetaAction)
  private
    FeedbackEnergy:Integer ;
    FeedbackHealth:Integer ;
    ObjectName:string ;
  public
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
    constructor Create(Params: TStringList); override ;
  end;

implementation
uses ObjModule, NeutralUnits, PonyUnits, simple_oper ;

{ TMetaActionConsume }

function TMetaActionConsume.Apply(Cell: TCell): Boolean;
begin
  Result:=False ;
  if Cell.IsEmpty() then Exit ;

  if not (Cell._Object is TNeutralUnit) then Exit ;

  if TNeutralUnit(Cell._Object).Code=ObjectName then begin
    TPonyUnit(BF.GetActiveObject()).IncEnergy(FeedbackEnergy) ;
    TPonyUnit(BF.GetActiveObject()).IncHealth(FeedbackHealth) ;
    Cell.ClearObject() ;
    Result:=True ;
  end;
end;

function TMetaActionConsume.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if Cell.IsEmpty then begin
    Result:=False ;
    errmsg:='Нет объекта для поглощения!' ;
  end
  else
  if not (Cell._Object is TNeutralUnit) then begin
    Result:=False ;
    errmsg:='Нет объекта для поглощения!' ;
  end
  else
  if TNeutralUnit(Cell._Object).Code<>ObjectName then begin
    Result:=False ;
    errmsg:='Нет объекта для поглощения!' ;
  end 
  else
    Result:=True ;
end;

constructor TMetaActionConsume.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  FeedbackHealth:=StrToIntWt0(Params.Values['FeedbackHealth']) ;
  FeedbackEnergy:=StrToIntWt0(Params.Values['FeedbackEnergy']) ;
  ObjectName:=Params.Values['Object'] ;
end;

initialization

  RegisterMetaAction(TMetaActionConsume) ;

end.
