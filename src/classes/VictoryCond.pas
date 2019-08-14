unit VictoryCond ;

interface
uses BattleField, AutoCreatedSubList, Classes, contnrs, Windows ;

type
  TCondAddType = (atOr,atAnd) ;

  TVictoryCond = class(TACObjectList)
  protected
    at:TCondAddType ;
    function IsCond(BF:TBattleField):Boolean ; virtual ; abstract ;
  public
    class function VCClassName():string ;
    constructor Create(params:TStringList) ; virtual ;
    function IsVictory(BF:TBattleField):Boolean ;
    procedure AddVictoryCond(VC:TVictoryCond; AddType:TCondAddType) ;
  end ;

  TVCByStone = class(TVictoryCond)
  private
    StoneNeed:Integer ;
  protected
    function IsCond(BF:TBattleField):Boolean ; override ;
  public
    constructor Create(params:TStringList) ; override ;
  end ;

  TVCByFood = class(TVictoryCond)
  private
    FoodNeed:Integer ;
  protected
    function IsCond(BF:TBattleField):Boolean ; override ;
  public
    constructor Create(params:TStringList) ; override ;
  end ;

  TVCByStep = class(TVictoryCond)
  private
    StepNeed:Integer ;
  protected
    function IsCond(BF:TBattleField):Boolean ; override ;
  public
    constructor Create(params:TStringList) ; override ;
  end ;

  TVCByFlag = class(TVictoryCond)
  private
    FlagName:string ;
  protected
    function IsCond(BF:TBattleField):Boolean ; override ;
  public
    constructor Create(params:TStringList) ; override ;
  end ;

  TVCByObjectPos = class(TVictoryCond)
  private
    ObjectCode:string ;
    ObjectPos:TPoint ;
    IncludeLinked:Boolean ;
  protected
    function IsCond(BF:TBattleField):Boolean ; override ;
  public
    constructor Create(params:TStringList) ; override ;
  end ;

  TVCByNoTargetLeft = class(TVictoryCond)
  private
  protected
    function IsCond(BF:TBattleField):Boolean ; override ;
  public
    constructor Create(params:TStringList) ; override ;
  end ;

  TVCByNoMonsterLeft = class(TVictoryCond)
  private
  protected
    function IsCond(BF:TBattleField):Boolean ; override ;
  public
    constructor Create(params:TStringList) ; override ;
  end ;
  
  TVCByObjectCount = class(TVictoryCond)
  private
    ObjectCode:string ;
    ObjectCount:Integer ;
    CompareType:char ;
  protected
    function IsCond(BF:TBattleField):Boolean ; override ;
  public
    constructor Create(params:TStringList) ; override ;
  end ;

  TVCByNoSpaceLeft = class(TVictoryCond)
  private
  protected
    function IsCond(BF:TBattleField):Boolean ; override ;
  public
    constructor Create(params:TStringList) ; override ;
  end ;

  TVictoryCondClass = class of TVictoryCond ;

  TVictoryCondFactory = class
  private
    List:TClassList ;
  public
    constructor Create ;
    destructor Destroy ; override ;
    procedure RegisterVictoryCondClass(C:TVictoryCondClass) ;
    function CreateVictoryCond(VCClassName:string;
      Params:TStringList):TVictoryCond ;
  end;

function GetVCFactory():TVictoryCondFactory ;

implementation
uses SysUtils, simple_oper, MonsterUnits, EmptyPlace, TAVStrUtils ;

var
  GVCFactory:TVictoryCondFactory ;

function GetVCFactory():TVictoryCondFactory ;
begin
  if GVCFactory=nil then GVCFactory:=TVictoryCondFactory.Create() ;
  Result:=GVCFactory ;
end ;

constructor TVictoryCondFactory.Create;
begin
  List:=TClassList.Create ;
end;

function TVictoryCondFactory.CreateVictoryCond(VCClassName: string;
  Params: TStringList): TVictoryCond;
var i:Integer ;
begin
  Result:=nil ;
  for i := 0 to List.Count - 1 do
    if TVictoryCondClass(List[i]).VCClassName=VCClassName then begin
      Result:=TVictoryCondClass(List[i]).Create(Params) ;
      Break ;
    end;
end;

destructor TVictoryCondFactory.Destroy;
begin
  List.Free ;
  inherited Destroy ;
end;

procedure TVictoryCondFactory.RegisterVictoryCondClass(C: TVictoryCondClass);
begin
  List.Add(C) ;
end;

function TVCByStone.IsCond(BF:TBattleField):Boolean ; 
begin
  Result:=BF.GetStone()>=StoneNeed ;
end ;

constructor TVCByStone.Create(params:TStringList) ;
begin
  inherited Create(params) ;
  StoneNeed:=StrToIntWt0(params.Values['StoneNeed']) ;
end ;

function TVCByFood.IsCond(BF:TBattleField):Boolean ; 
begin
  Result:=BF.GetFood()>=FoodNeed ;
end ;

constructor TVCByFood.Create(params:TStringList) ;
begin
  inherited Create(params) ;
  FoodNeed:=StrToIntWt0(params.Values['FoodNeed']) ;
end ;

constructor TVictoryCond.Create(params:TStringList) ;
begin
  inherited Create ;
end ;

class function TVictoryCond.VCClassName():string ;
begin
  Result:=Copy(ClassName,Length('TVC')+1) ;
end ;

procedure TVictoryCond.AddVictoryCond(VC:TVictoryCond; AddType:TCondAddType) ;
begin
  VC.at:=AddType ;
  List.Add(VC) ;
end ;

function TVictoryCond.IsVictory(BF:TBattleField):Boolean ; 
var i:Integer ;
    z:Boolean ;
begin
  if BF.DefeatFlag then begin
    Result:=False ;
    Exit ;
  end;

  Result:=IsCond(BF) ;
  for i:=0 to List.Count-1 do begin
    z:=TVictoryCond(List[i]).IsVictory(BF) ;
    if TVictoryCond(List[i]).at=atOr then Result:=Result or z;
    if TVictoryCond(List[i]).at=atAnd then Result:=Result and z;
  end ;
end ;

{ TVCByStep }

constructor TVCByStep.Create(params: TStringList);
begin
  inherited Create(params) ;
  StepNeed:=StrToIntWt0(params.Values['StepNeed']) ;
end;

function TVCByStep.IsCond(BF: TBattleField): Boolean;
begin
  Result:=BF.GetCurrentStep>=StepNeed ;
end;

{ TVCByObjectPos }

constructor TVCByObjectPos.Create(params: TStringList);
begin
  inherited Create(params);
  ObjectCode:=params.Values['Object'] ;
  ObjectPos.X:=StrToIntWt0(params.Values['i']) ;
  ObjectPos.Y:=StrToIntWt0(params.Values['j']) ;
  IncludeLinked:=params.Values['IncludeLinked']='true' ;
end;

function TVCByObjectPos.IsCond(BF: TBattleField): Boolean;
var i:Integer ;
    Cell:TCell ;
begin
  Result:=BF.IsObjectAtPos(ObjectCode,ObjectPos.X,ObjectPos.Y) ;
  if IncludeLinked then begin
     Cell:=BF.GetCellByIJ(ObjectPos.X,ObjectPos.Y) ;
     for i := 0 to Cell.GetLinkCount - 1 do
       Result:=Result or BF.IsObjectAtPos(ObjectCode,
         Cell.GetLinked(i).CellI,Cell.GetLinked(i).CellJ) ;
  end;
end;

{ TVCByNoTargetLeft }

constructor TVCByNoTargetLeft.Create(params: TStringList);
begin
  inherited Create(params);
end;

function TVCByNoTargetLeft.IsCond(BF: TBattleField): Boolean;
var i:Integer ;
begin
  Result:=True ;
  for i := 0 to BF.CellCount-1 do
    if not BF.GetCell(i).IsEmpty then
      if BF.GetCell(i)._Object.IsTargeted then begin
        Result:=False ;
        Break ;
      end;
end;

{ TVCByFlag }

constructor TVCByFlag.Create(params: TStringList);
begin
  inherited Create(params);
  FlagName:=params.Values['FlagName'] ;
end;

function TVCByFlag.IsCond(BF: TBattleField): Boolean;
begin
  Result:=BF.IsFlag(FlagName) ;
end;

{ TVCByNoMonsterLeft }

constructor TVCByNoMonsterLeft.Create(params: TStringList);
begin
  inherited Create(params);
end;

function TVCByNoMonsterLeft.IsCond(BF: TBattleField): Boolean;
begin
  Result:=(BF.getObjCountByClass(TMonsterUnit)=0) ;
end;

{ TVCByNoSpaceLeft }

constructor TVCByNoSpaceLeft.Create(params: TStringList);
begin
  inherited Create(params);
end;

function TVCByNoSpaceLeft.IsCond(BF: TBattleField): Boolean;
begin
  Result:=(BF.getSpaceCount()=0) ;
end;

{ TVCByObjectCount }

const COMPARE_EQUAL='=' ;
      COMPARE_GREATEEQUAL='g' ;
      COMPARE_LESSEQUAL='l' ;

constructor TVCByObjectCount.Create(params: TStringList);
var scnt:string ;
begin
  inherited Create(params);
  ObjectCode:=params.Values['Object'] ;

  scnt:=params.Values['cnt'] ;
  if scnt[1]='g' then CompareType:=COMPARE_GREATEEQUAL else
  if scnt[1]='l' then CompareType:=COMPARE_LESSEQUAL else
  CompareType:=COMPARE_EQUAL ;
  ObjectCount:=StrToIntWt0(StripExceptDigits(scnt)) ;
end;

function TVCByObjectCount.IsCond(BF: TBattleField): Boolean;
var cnt:Integer ;
begin
  cnt:=BF.getObjCountByCode(ObjectCode) ;
  if CompareType=COMPARE_EQUAL then Result:=(cnt=ObjectCount) else
  if CompareType=COMPARE_GREATEEQUAL then Result:=(cnt>=ObjectCount) else
  if CompareType=COMPARE_LESSEQUAL then Result:=(cnt<=ObjectCount) else Result:=False ;
end;

initialization

GetVCFactory().RegisterVictoryCondClass(TVCByStone) ;
GetVCFactory().RegisterVictoryCondClass(TVCByFood) ;
GetVCFactory().RegisterVictoryCondClass(TVCByStep) ;
GetVCFactory().RegisterVictoryCondClass(TVCByObjectPos) ;
GetVCFactory().RegisterVictoryCondClass(TVCByNoTargetLeft) ;
GetVCFactory().RegisterVictoryCondClass(TVCByFlag) ;
GetVCFactory().RegisterVictoryCondClass(TVCByNoMonsterLeft) ;
GetVCFactory().RegisterVictoryCondClass(TVCByNoSpaceLeft) ;
GetVCFactory().RegisterVictoryCondClass(TVCByObjectCount) ;

end.
