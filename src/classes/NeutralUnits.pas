unit NeutralUnits ;

interface
uses GameObject, Classes, BattleField ;

type
  TNeutralUnit = class(TGameObject)
  private
    FCode:string ;
    FName:string ;
    FIsEnemyTarget:Boolean ;
    FIsMustSurvive:Boolean ;
    Removable:Boolean ;
  public
    constructor Create(Params:TStringList) ; override ;
    class function GameClassName:string ; override ;
    function IsEnemyTarget():Boolean ; override ;
    function IsMustSurvive():Boolean ; override ; 
    function SpriteTag:string ; override ;
    function Name:string ; override ;
    function Code():string ; 
    procedure DoAttackFromEnemy(attackvalue: Integer;
      out ae: TAttackEvent); override ;
  end;

  TNUCrystall = class(TNeutralUnit)
  public
    class function GameClassName:string ; override ;
  end ;

implementation
uses SysUtils ;

{ TNeutralUnit }

function TNeutralUnit.Code: string;
begin
  Result:=FCode ;
end;

constructor TNeutralUnit.Create(Params: TStringList);
begin
  inherited Create(Params) ;

  FCode:=Params.Values['Code'] ;
  FName:=Params.Values['Name'] ;

  FIsEnemyTarget:=False ;
  FIsMustSurvive:=False ;
  Removable:=False ;
  if params.Values['EnemyTarget']='true' then FIsEnemyTarget:=True ;
  if params.Values['MustSurvive']='true' then FIsMustSurvive:=True ;  
  if params.Values['Removable']='true' then Removable:=True ;  
end;

procedure TNeutralUnit.DoAttackFromEnemy(attackvalue: Integer;
  out ae: TAttackEvent);
begin
  ae.doFix:=True ;
  ae.doDelete:=Removable ;
  ae.msg:='атака' ;
  ae._object:=self ;
end;

class function TNeutralUnit.GameClassName: string;
begin
  Result:='Neutral' ;
end;

function TNeutralUnit.IsEnemyTarget: Boolean;
begin
  Result:=FIsEnemyTarget ;
end;

function TNeutralUnit.IsMustSurvive: Boolean;
begin
  Result:=FIsMustSurvive ;
end;

function TNeutralUnit.Name: string;
begin
  Result:=FName ;
end;

function TNeutralUnit.SpriteTag: string;
begin
  Result:='neutral_'+Code ;
end;

class function TNUCrystall.GameClassName:string ;
begin
  Result:='Crystall' ;
end ;

initialization

GetGOFactory(nil).RegisterGameObjectClass(TNeutralUnit);
GetGOFactory(nil).RegisterGameObjectClass(TNUCrystall);

end.