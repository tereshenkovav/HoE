unit CommonResource;

interface
uses GameObject, Classes ;

type
  TCommonResource = class(TGameObject)
  protected
    HeapSize:string ;
    Count:Integer ;
    FIsEnemyTarget:Boolean ;
  public
    constructor Create(Params:TStringList) ; override ;
    function IsResource: Boolean; override ;
    function IsEnemyTarget: Boolean; override ;
    procedure DoAttackFromEnemy(attackvalue: Integer;
      out ae: TAttackEvent); override ;
  end;

implementation
uses simple_oper, Config ;

function TCommonResource.IsEnemyTarget: Boolean;
begin
  Result:=FIsEnemyTarget ;
end;

constructor TCommonResource.Create(Params: TStringList);
begin
  inherited Create(Params) ;

  if Params.Values['exactcount']<>'' then begin
    Count:=StrToIntWt0(Params.Values['exactcount']) ;
  end
  else begin
    HeapSize:=Params.Values['size'] ;
    Count:=GConfig(Self).AsInteger(HeapSize) ;
  end;

  FIsEnemyTarget:=False ;
  if params.Values['EnemyTarget']='true' then FIsEnemyTarget:=True ;

end;

function TCommonResource.IsResource: Boolean;
begin
  Result:=True ;
end;

procedure TCommonResource.DoAttackFromEnemy(attackvalue: Integer;
  out ae: TAttackEvent);
begin
  ae.doFix:=True ;
  ae.doDelete:=True ;
  ae.msg:='грабеж' ;
  ae._object:=self ;
end;

end.
