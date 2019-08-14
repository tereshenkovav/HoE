unit GameObject ;

interface
uses contnrs, Classes, AbstractList, PassiveProp, CommonClasses, StepAction ;

type
  TObjDirection = (odLeft,odRight) ;

  TGameObject = class ;// for future extends

  TAttackEvent = record
    msg:string[255] ;
    _object:TGameObject ;
    doFix:Boolean ;
    doDelete:Boolean ;
  end;

  TGameObject = class // for future extends
  protected
    BF:TObject ;
    create_delay:Single ;
    ObjDir:TObjDirection ;
    FTargeted:Boolean ;
    FIsFlyer:Boolean ;
    ListSActions:TObjectList ;
    ListPProps:TObjectList ;
    FShiftView:TPointSingle ;
    FShiftViewSpeed:TPointSingle ;
    IsViewMoved:Boolean ;
    FRank:Integer ;
    FNoMapping:Boolean ;
  public
    Tag:string ;
    StoredObject:array[0..15] of TGameObject ;
    constructor Create(Params:TStringList) ; virtual ; 
    procedure Update(dt:Single) ; virtual ;// Maybe, useless
    procedure NextStep() ; virtual ;
    procedure NextAfterStep() ; virtual ;
    function DecStep(delta:Integer):Boolean ; virtual ;
    function CanRule():Boolean ; virtual ;
    function IsEnemyTarget():Boolean ; virtual ;
    function IsResource():Boolean ; virtual ;
    class function GameClassName:string ; virtual ; abstract ;
    function SpriteTag:string ; virtual ; abstract ;
    function Name:string ; virtual ; abstract ;
    function Info():string ; virtual ;

    function GetTransp():Integer ; virtual ;
    function IsHorzReverse():Boolean ;
    procedure RotToRight ;
    procedure RotToLeft ;
    procedure SetTargeted(AIsTarget:Boolean) ;
    function IsTargeted:Boolean ;
    function GetRank():Integer ;
    function IsFlyer():Boolean ; virtual ;
    function IsWaterUnit():Boolean ; virtual ;
    function IsUnicorn():Boolean ; virtual ;
    function IsEarthPony():Boolean ; virtual ;

    procedure DoAttackFromEnemy(attackvalue: Integer;
      out ae: TAttackEvent); virtual ;
    function IsMustSurvive():Boolean ; virtual ;

    function getPassiveProp(PPC:TPassivePropClass; var PPO:TPassiveProp):Boolean ;
    function getStepAction(SAC:TStepActionClass; var SAO:TStepAction):Boolean ;

    procedure ProcessRemove() ; virtual ;

    function IsHided():Boolean ; virtual ;

    procedure startShiftView(x,y,vx,vy:Single) ;
    procedure stopShiftView() ;
    procedure showImmediate() ;

    function IsNoMapping():Boolean ;
    property ShiftView:TPointSingle read FShiftView ;
  end ;

  TGameObjectListNoOwn = class(TAbstractListNoOwn)
  private
    function GetItem(i:Integer):TGameObject ;
  public
    procedure CustomSort(funcSort:TListSortCompare) ;
    property Items[i:Integer]:TGameObject read GetItem ; default ;
  end ;

  TGameObjectClass = class of TGameObject ;

  TGameObjectFactory = class
  private
    List:TClassList ;
    BF:TObject ;
  public
    constructor Create ;
    destructor Destroy ; override ;
    procedure RegisterGameObjectClass(C:TGameObjectClass) ;
    function CreateGameObject(GameClassName:string;
      Params:TStringList):TGameObject ;
  end;

function GetGOFactory(BF:TObject):TGameObjectFactory ;
function GetEmptyParams():TStringList ;

implementation
uses BattleField, SysUtils, simple_oper ;

var
  GGOFactory:TGameObjectFactory ;
  GEmptyParams:TStringList ;

function GetGOFactory(BF:TObject):TGameObjectFactory ;
begin
  if GGOFactory=nil then GGOFactory:=TGameObjectFactory.Create() ;
  GGOFactory.BF:=BF ;
  Result:=GGOFactory ;
end ;

function GetEmptyParams():TStringList ;
begin
  if GEmptyParams=nil then GEmptyParams:=TStringList.Create ;
  Result:=GEmptyParams ;
end;

{ TGameObject }

function TGameObject.CanRule: Boolean;
begin
  Result:=False ;
end;

constructor TGameObject.Create(Params: TStringList);
begin
  if Params.Values['showimmediate']<>'true' then create_delay:=1 else create_delay:=0 ;
  ObjDir:=odRight ;
  FTargeted:=Params.Values['targeted']='true' ;
  Tag:=Params.Values['tag'] ;
  FRank:=0 ;
  if Params.Values['Rank']<>'' then FRank:=StrToIntWt0(Params.Values['Rank']) ;
  FNoMapping:=(LowerCase(Params.Values['nomapping'])='true') ;  

  ListSActions:=TObjectList.Create ;
  ListPProps:=TObjectList.Create ;
  FShiftView.X:=0 ;
  FShiftView.Y:=0 ;
  IsViewMoved:=False ;
end;

function TGameObject.DecStep(delta: Integer):Boolean;
begin
  //
end;

procedure TGameObject.DoAttackFromEnemy(attackvalue: Integer;
  out ae: TAttackEvent);
begin
  ae.doFix:=False ;
  ae.doDelete:=False ;
  ae.msg:='' ;
  ae._object:=self ;
end;

function TGameObject.getPassiveProp(PPC:TPassivePropClass; var PPO: TPassiveProp): Boolean;
var i:Integer ;
begin
  Result:=False ;
  for i := 0 to ListPProps.Count - 1 do
    if ListPProps[i] is PPC then begin
      PPO:=TPassiveProp(ListPProps[i]) ;
      Result:=True ;
      break ;
    end;
end;

function TGameObject.GetRank: Integer;
begin
  Result:=FRank ;
end;

function TGameObject.getStepAction(SAC: TStepActionClass;
  var SAO: TStepAction): Boolean;
var i:Integer ;
begin
  Result:=False ;
  for i := 0 to ListSActions.Count - 1 do
    if ListSActions[i] is SAC then begin
      SAO:=TStepAction(ListSActions[i]) ;
      Result:=True ;
      break ;
    end;
end;

function TGameObject.GetTransp: Integer;
begin
  Result:=Round(100*create_delay) ;
end;

function TGameObject.Info: string;
begin
  Result:='' ;
end;

function TGameObject.IsEarthPony: Boolean;
begin
  Result:=False ;
end;

function TGameObject.IsEnemyTarget: Boolean;
begin
  Result:=False ;
end;

function TGameObject.IsHided: Boolean;
begin
  Result:=False ;
end;

function TGameObject.IsHorzReverse: Boolean;
begin
  Result:=(ObjDir=odLeft) ;
end;

function TGameObject.IsMustSurvive: Boolean;
begin
  Result:=False ;
end;

function TGameObject.IsNoMapping: Boolean;
begin
  Result:=FNoMapping ;
end;

function TGameObject.IsResource: Boolean;
begin
  Result:=False ;
end;

function TGameObject.IsTargeted: Boolean;
begin
  Result:=FTargeted ;
end;

function TGameObject.IsUnicorn: Boolean;
begin
  Result:=False ;
end;

function TGameObject.IsFlyer: Boolean;
begin
  Result:=FIsFlyer ;
end;

function TGameObject.IsWaterUnit: Boolean;
begin
  Result:=False ;
end;

procedure TGameObject.NextStep();
begin
//
end;

procedure TGameObject.NextAfterStep();
begin
//
end;

procedure TGameObject.ProcessRemove;
begin
  // empty     
end;

procedure TGameObject.RotToLeft;
begin
  ObjDir:=odLeft ;
end;

procedure TGameObject.RotToRight;
begin
  ObjDir:=odRight ;
end;

procedure TGameObject.SetTargeted(AIsTarget: Boolean);
begin
  FTargeted:=AIsTarget ;
end;

procedure TGameObject.Update(dt: Single);
begin
  if create_delay>0 then create_delay:=create_delay-dt else
  if create_delay<0 then create_delay:=0 ;
  

  if IsViewMoved then begin
    FShiftView.X:=FShiftView.X+FShiftViewSpeed.X*dt ;
    FShiftView.Y:=FShiftView.Y+FShiftViewSpeed.Y*dt ;
  end;

end;

procedure TGameObject.showImmediate;
begin
  create_delay:=0 ;
end;

procedure TGameObject.startShiftView(x,y,vx,vy:Single) ;
begin
  FShiftView.X:=x ;
  FShiftView.Y:=y ;
  FShiftViewSpeed.X:=vx ;
  FShiftViewSpeed.Y:=vy ;
  if (vx>0) then RotToRight else 
  if (vx<0) then RotToLeft ;
  
  IsViewMoved:=True ;
end;

procedure TGameObject.stopShiftView() ;
begin
  IsViewMoved:=False ;
  FShiftView.X:=0 ;
  FShiftView.Y:=0 ;
end;

procedure TGameObjectListNoOwn.CustomSort(funcSort: TListSortCompare);
begin
  List.Sort(funcSort);
end;

function TGameObjectListNoOwn.GetItem(i:Integer):TGameObject ;
begin
  Result:=TGameObject(inherited GetItem(i)) ;
end ;

{ TGameObjectFactory }

constructor TGameObjectFactory.Create;
begin
  List:=TClassList.Create ;
end;

function TGameObjectFactory.CreateGameObject(GameClassName: string;
  Params: TStringList): TGameObject;
var i,cnt:Integer ;
begin
  Result:=nil ;
  for i := 0 to List.Count - 1 do
    if TGameObjectClass(List[i]).GameClassName=GameClassName then begin

      if (Pos('Monster',GameClassName)=1)and
        TBattleField(BF).ProgressiveMonster then begin
        cnt:=TBattleField(BF).GetScriptVar('internal_MonsterUnit_count') ;
        TBattleField(BF).IncScriptVar('internal_MonsterUnit_count') ;
        params.Values['classcount']:=IntToStr(cnt) ;
      end;
      if (Pos('Farm',GameClassName)=1)and
        TBattleField(BF).RegressiveFarms then begin
        cnt:=TBattleField(BF).GetScriptVar('internal_FarmUnit_count') ;
        TBattleField(BF).IncScriptVar('internal_FarmUnit_count') ;
        params.Values['classcount']:=IntToStr(cnt) ;
      end;

      if (Pos('Monster',GameClassName)=1)and
        (TBattleField(BF).DefaultMonsterStrategy<>'') then
          params.Values['strategy']:=TBattleField(BF).DefaultMonsterStrategy ;

      Result:=TGameObjectClass(List[i]).Create(Params) ;
      Result.BF:=BF ;

      Break ;
    end;
end;

destructor TGameObjectFactory.Destroy;
begin
  List.Free ;
  inherited Destroy ;
end;

procedure TGameObjectFactory.RegisterGameObjectClass(C: TGameObjectClass);
begin
  List.Add(C) ;
end;

end.