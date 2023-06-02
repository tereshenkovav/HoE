unit DialogHistory;

interface
uses Classes ;

type
  TDialogHistory = class
  private
    List:TStringList ;
    function MakeKey(map,icon,msg:string):string ;
    function getHistoryFile():string ;
  public
    constructor Create() ;
    destructor Destroy ; override ;

    procedure AddDialogHistory(map,icon,msg:string) ;
    function IsDialogExist(map,icon,msg:string):Boolean ;
  end;

function GetDialogHistory():TDialogHistory ;

implementation
uses SysUtils, simple_oper, simple_files ;

var
  GDialogHistory:TDialogHistory ;

function GetDialogHistory():TDialogHistory ;
begin
  if GDialogHistory=nil then GDialogHistory:=TDialogHistory.Create ;
  Result:=GDialogHistory ;
end;

{ TDialogHistory }

constructor TDialogHistory.Create;
begin
  List:=TStringList.Create ;
  List.Sorted:=True ;
  List.Duplicates:=dupIgnore ;
  if FileExists(getHistoryFile()) then List.LoadFromFile(getHistoryFile());
end;

destructor TDialogHistory.Destroy;
begin
  List.Free ;
  inherited Destroy;
end;

function TDialogHistory.getHistoryFile: string;
begin
  Result:=AppDataPath()+'\dialoghistory.store'
end;

procedure TDialogHistory.AddDialogHistory(map, icon, msg: string);
var key:string ;
begin
  key:=MakeKey(map,icon,msg) ;
  List.Add(key) ;
  List.SaveToFile(getHistoryFile());
end;

function TDialogHistory.IsDialogExist(map, icon, msg: string): Boolean;
var idx:Integer ;
begin
  Result:=List.Find(MakeKey(map,icon,msg),idx) ;
end;

function TDialogHistory.MakeKey(map, icon, msg: string): string;
begin
  Result:=Map+'@'+icon+'@'+StrToHex(Copy(msg,1,32)) ;
end;

end.
