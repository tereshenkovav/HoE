unit StepActionProduce;

interface
uses StepAction, Classes, BattleField ;

type
  TStepActionProduce = class(TStepAction)
  private
    Resource:string ;
    Value:Integer ;
    NoNeedHouse:Boolean ;
  public
    function GetValueByFood():Integer ;
    function GetValueByStone():Integer ;
    function Apply(Cell:TObject):Boolean ; override ;
    constructor Create(Params:TStringList) ; override ;    
  end;

implementation
uses ObjModule, simple_oper, SysUtils ;

{ TStepActionProduce }

function TStepActionProduce.Apply(Cell: TObject): Boolean;
begin
  if NoNeedHouse or ObjModule.BF.canProduceResource then begin
    if Resource='Stone' then BF.IncStone(Value) ;
    if Resource='Food' then BF.IncFood(Value) ;
    if Resource='Wood' then BF.IncWood(Value) ;
  end;
end;

constructor TStepActionProduce.Create(Params: TStringList);
begin
  inherited Create(Params);
  Value:=StrToIntWt0(params.Values['Value']) ;
  Resource:=params.Values['Resource'] ;
  NoNeedHouse:=LowerCase(params.Values['NoNeedHouse'])='true' ;
end;

function TStepActionProduce.GetValueByFood: Integer;
begin
  Result:=0 ;
  if NoNeedHouse or ObjModule.BF.canProduceResource then
    if Resource='Food' then Result:=Value ;
end;

function TStepActionProduce.GetValueByStone: Integer;
begin
  Result:=0 ;
  if NoNeedHouse or ObjModule.BF.canProduceResource then
    if Resource='Stone' then Result:=Value ;
end ;

initialization

  RegisterStepAction(TStepActionProduce) ;

end.
