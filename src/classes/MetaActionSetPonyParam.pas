unit MetaActionSetPonyParam;

interface
uses MetaAction, BattleField, Classes, MinMaxValues ;

type
  TMetaActionSetPonyParam = class(TMetaAction)
  private
    ParamName:string ;
    ParamValue:Integer ;
    IsDelta:Boolean ;
    ToCaller:Boolean ;
  public
    constructor Create(Params:TStringList) ; override ;
    function Apply(Cell:TCell):Boolean ; override ;
    function CanApplyToCell(Cell:TCell; var errmsg:string):Boolean ; override ;
  end;

implementation
uses simple_oper, PonyUnits, ObjModule, HitViewer, SysUtils ;

{ TMetaActionSetPonyParam }

function TMetaActionSetPonyParam.Apply(Cell: TCell): Boolean;
var value:Integer ;
    pu:TPonyUnit ;
    tocell:TCell ;
begin
  Result:=False ;
  if not (Cell._Object is TPonyUnit) then Exit ;

  if ParamName='Health' then begin
    if IsDelta then 
      value:=ParamValue  
    else
      value:=ParamValue-TPonyUnit(Cell._Object).GetHealth ;
    if TPonyUnit(Cell._Object).IncHealth(value,True) then begin
      HV.addNewHit(Cell,hsGood,value) ;
      Result:=True ;
    end;
  end;

  if ParamName='Energy' then begin
    if IsDelta then
      value:=ParamValue
    else
      value:=ParamValue-TPonyUnit(Cell._Object).GetEnergy ;
    if ToCaller then pu:=TPonyUnit(BF.GetActiveCell()._Object)
                else pu:=TPonyUnit(Cell._Object) ;
    if pu.IncEnergy(value,True) then begin
      if ToCaller then
        tocell:=BF.GetActiveCell()
      else
        tocell:=Cell ;
      HV.addNewHit(tocell,hsEnergy,value) ;
      Result:=True ;
    end;
  end;

  if ParamName='MaxStep' then begin
    TPonyUnit(Cell._Object).SetOnceMaxStep(ParamValue) ;
    HV.addNewHit(Cell,hsEnergy,'+'+IntToStr(ParamValue)+' ходов') ;
  end;

end;

function TMetaActionSetPonyParam.CanApplyToCell(Cell: TCell;
  var errmsg: string): Boolean;
begin
  if not (Cell._Object is TPonyUnit) then begin
    Result:=False ;
    errmsg:='Нет пони для применения' ;
  end
  else
    Result:=True ;
end;

constructor TMetaActionSetPonyParam.Create(Params: TStringList);
begin
  inherited Create(Params);
  ParamName:=params.Values['ParamName'] ;
  ParamValue:=StrToIntWt0(params.Values['ParamValue']) ;
  IsDelta:=LowerCase(params.Values['IsDelta'])='true' ;
  ToCaller:=LowerCase(params.Values['ToCaller'])='true' ;
end;

initialization

  RegisterMetaAction(TMetaActionSetPonyParam) ;

end.
