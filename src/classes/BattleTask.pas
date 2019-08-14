unit BattleTask;

interface

type
  TBattleTaskRes = (bttNormal,bttComp,bttFail) ;

  TBattleTask = class
  protected
    type TTask = record
      code:string[255] ;
      name:string[255] ;
      res:TBattleTaskRes ;
      isreq:Boolean ;
      function getOrder():Integer ;
      function getPrefix():string ;
    end;
  private
    tasks:array[0..32] of TTask ;
    size:Integer ;
    LastInfo:string ;
    procedure AddTask(code:string; taskname:string; isreq:Boolean) ;
    procedure Sort() ;
  public
    constructor Create ;
    procedure AddReqTask(code:string; taskname:string) ;
    procedure AddOptTask(code:string; taskname:string) ;
    procedure SetTaskComp(code:string) ;
    procedure SetTaskFail(code:string) ;
    function GetType(i:Integer):TBattleTaskRes ;
    function GetLastInfo():string ;
    function IsReq(i:Integer):Boolean ;
    function GetTask(i:Integer):string ;
    function Count():Integer ;
  end;

implementation

{ TBattleTask }

procedure TBattleTask.AddOptTask(code, taskname: string);
begin
  AddTask(code,taskname,False) ;
end;

procedure TBattleTask.AddReqTask(code, taskname: string);
begin
  AddTask(code,taskname,True) ;
end;

procedure TBattleTask.AddTask(code, taskname: string; isreq: Boolean);
var i,idx:Integer ;
begin
  idx:=-1 ;
  for i := 0 to Count - 1 do
    if tasks[i].code=code then idx:=i ;

  if idx=-1 then begin
    idx:=size ;
    Inc(size) ;
  end ;

  tasks[idx].code:=code ;
  tasks[idx].name:=taskname ;
  tasks[idx].res:=bttNormal ;
  tasks[idx].isreq:=isreq ;
  LastInfo:=taskname ;

  Sort() ;
end;

function TBattleTask.Count: Integer;
begin
  Result:=size ;
end;

constructor TBattleTask.Create;
begin
  size:=0 ;
end;

function TBattleTask.GetLastInfo: string;
begin
  if size=0 then Result:='' else
  if size=1 then Result:='Задание: '+LastInfo else
  Result:='Новое задание: '+LastInfo ;
end;

function TBattleTask.GetTask(i: Integer): string;
begin
  Result:=tasks[i].getPrefix()+tasks[i].name ;
end;

function TBattleTask.GetType(i: Integer): TBattleTaskRes;
begin
  Result:=tasks[i].res ;
end;

function TBattleTask.IsReq(i: Integer): Boolean;
begin
  Result:=tasks[i].isreq ;
end;

procedure TBattleTask.SetTaskComp(code: string);
var i:Integer ;
begin
  for i := 0 to Count - 1 do
    if tasks[i].code=code then
      tasks[i].res:=bttComp ;
  Sort() ;
end;

procedure TBattleTask.SetTaskFail(code: string);
var i:Integer ;
begin
  for i := 0 to Count - 1 do
    if tasks[i].code=code then
      tasks[i].res:=bttFail ;
  Sort() ;      
end;

procedure TBattleTask.Sort;
var flag:Boolean ;
    i:Integer ;
    tmp:TTask ;
begin
  repeat
    flag:=False ;
    for i := 0 to Count - 2 do
      if tasks[i].getOrder()>tasks[i+1].getOrder() then begin
        tmp:=tasks[i] ;
        tasks[i]:=tasks[i+1] ;
        tasks[i+1]:=tmp ;
        flag:=True ;
      end;
  until not flag;

end;

{ TBattleTask.TTask }

function TBattleTask.TTask.getOrder: Integer;
begin
  case res of
    bttNormal: if isreq then Result:=1 else Result:=2 ;
    bttComp: if isreq then Result:=3 else Result:=4 ;
    bttFail: if isreq then Result:=5 else Result:=6 ;
    else Result:=99 ;
  end ;
end;

function TBattleTask.TTask.getPrefix: string;
var str:string ;
begin
  Result:='' ;
  if (res=bttNormal) then begin
    if not isreq then Result:='(дополнительно) ' ;
  end
  else
  if (res=bttComp) then Result:='(выполнено) '
  else
  if (res=bttFail) then Result:='(провалено) ' ;
end;

end.
