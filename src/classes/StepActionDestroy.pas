unit StepActionDestroy ;

interface
uses StepAction, Classes, BattleField ;

type
  TStepActionDestroy = class(TStepAction)
  private
    StepLeft:Integer ;
  public
    function Apply(Cell:TObject):Boolean ; override ;
    constructor Create(Params:TStringList) ; override ;
    function AddInfo():string ; override ;
  end;

implementation
uses ObjModule, simple_oper, SysUtils ;

{ TStepActionDestroy }

function TStepActionDestroy.AddInfo: string;
begin
  Result:='Осталось ходов: '+IntToStr(StepLeft) ;
end;

function TStepActionDestroy.Apply(Cell: TObject): Boolean;
begin
  Dec(StepLeft) ;
  if StepLeft=0 then begin
    TCell(Cell).ClearObject ;
    if Cell=BF.GetActiveCell then BF.clearActiveCell() ;    
  end;
end;

constructor TStepActionDestroy.Create(Params: TStringList);
begin
  inherited Create(Params);
  StepLeft:=StrToIntWt0(params.Values['StepLeft']) ;
end;

initialization

  RegisterStepAction(TStepActionDestroy) ;

end.
