unit PonyAction ;

interface

uses AutoCreatedSubList, BattleField, Classes, StringListSmart, Windows,
 CommonClasses, GameObject ;

type
  TPonyAction = class
  protected
    FOrder:Integer ;
  public
    function Code():string ; virtual ; abstract ;

    function Order():Integer ; virtual ;
    function Caption():string ; virtual ;
    function Info():string ; virtual ;
    function SubInfo():string ; virtual ;
    function Icon(Pony:TGameObject):string ; virtual ;

    constructor Create(params:TStringList); virtual ;
    function BuildAllowCellList(CellStart:TCell):TCellListNoOwn ; virtual ;
    function BuildResultCellList(CellStart,CellSel:TCell):TCellListNoOwn; virtual ;
    function Apply(BF:TBattleField; Cell:TCell; var errmsg:string):Boolean ; virtual ;

    function CanApply(BF:TBattleField; var errmsg:string):Boolean ; virtual ;
  end ;

  TPonyActionList = class(TACObjectList)
  private
  public
    Locked:Boolean ;
    Stuned:Boolean ;
    function Count():Integer ;
    function GetAction(i:Integer):TPonyAction ;
    procedure Add(PA:TPonyAction) ; overload ;
    procedure Extract(i:Integer) ;
  end ;

  TPonyActionPermits = class
  private
     ListAllow:TStringListSmart ;
     ListDeny:TStringListSmart ;
     isallowedall:Boolean ;
  public
     constructor Create() ;
     destructor Destroy ; override ;
     procedure setPermit(action,code:string) ;
     function IsActionPermitted(PA:TPonyAction):Boolean ;
  end;

implementation
uses SysUtils, IniFiles, simple_files, ObjModule ;

function TPonyAction.Order():Integer ;
begin
  if FOrder=0 then begin
    with TIniFile.Create(AppPath+'\..\configs\ui.ini') do begin
      FOrder:=ReadInteger('ActionGroups',Code,0) ;
      Free ;
    end;
    if (FOrder=0) and
      FileExists(LevelFileName+'.data\configs\ui.ini') then
      with TIniFile.Create(LevelFileName+'.data\configs\ui.ini') do begin
        FOrder:=ReadInteger('ActionGroups',Code,0) ;
        Free ;
      end;
    if FOrder=0 then FOrder:=1 ;
  end;

  Result:=FOrder ;
end ;

function TPonyAction.SubInfo: string;
begin
  Result:='' ;
end;

function TPonyAction.CanApply(BF: TBattleField;
  var errmsg: string): Boolean;
begin
  Result:=True ;
end;

function TPonyAction.Caption():string ;  
begin  Result:='Без имени' ; end ;

constructor TPonyAction.Create(params:TStringList); 
begin  end ;

function TPonyAction.Icon(Pony: TGameObject): string;
begin
  Result:=LowerCase(Code) ;
end;

function TPonyAction.Info: string;
begin
  Result:='' ;
end;

function TPonyAction.BuildAllowCellList(CellStart:TCell):TCellListNoOwn ;
begin  
  Result:=TCellListNoOwn.Create() ;
end ;

function TPonyAction.BuildResultCellList(CellStart,CellSel: TCell): TCellListNoOwn;
begin
  Result:=TCellListNoOwn.Create ;
  Result.Add(CellSel) ;
end;

function TPonyAction.Apply(BF:TBattleField; Cell:TCell; var errmsg:string):Boolean ;  
begin
  // Nothing
end ;

procedure TPonyActionList.Add(PA: TPonyAction);
begin
  List.Add(PA) ;
end;

function TPonyActionList.Count():Integer ;
begin  Result:=List.Count ; end ;

procedure TPonyActionList.Extract(i: Integer);
begin
  List.Extract(List[i]) ;
end;

function TPonyActionList.GetAction(i:Integer):TPonyAction ;
begin  Result:=TPonyAction(List[i]) ; end ;

{ TPonyActionPermits }

constructor TPonyActionPermits.Create;
begin
  ListAllow:=TStringListSmart.Create ;
  ListDeny:=TStringListSmart.Create ;
end;

destructor TPonyActionPermits.Destroy;
begin
  ListAllow.Free ;
  ListDeny.Free ;
  inherited Destroy ;
end;

function TPonyActionPermits.IsActionPermitted(PA: TPonyAction): Boolean;
begin
  if isallowedall then
    Result:=ListDeny.IndexOf(PA.Code)=-1
  else
    Result:=ListAllow.IndexOf(PA.Code)<>-1 ;
end;

procedure TPonyActionPermits.setPermit(action,code:string);
begin
  if action='allow' then begin
    if code='all' then begin
      ListDeny.Clear ;
      ListAllow.Clear ;
      isallowedall:=True ;
    end
    else begin
      ListAllow.AddIfNoExist(code) ;
      ListDeny.DelStringIfExist(code) ;
    end;
  end ;
//  11111 Дописать действия в скрипт и карту, а также проверку в построении списка
//  действий интерфейса
  if action='deny' then begin
    if code='all' then begin
      ListDeny.Clear ;
      ListAllow.Clear ;
      isallowedall:=False ;
    end
    else begin
      ListDeny.AddIfNoExist(code) ;
      ListAllow.DelStringIfExist(code) ;
    end;
  end ;

end;

end.