unit MessageList;

interface
uses AutoCreatedSubList ;

type
  TMessageList = class(TACStringList)
  private
  public
    procedure AddMessage(ico:string; msg:string) ;
    function Count:Integer ;
    function getIco(i:Integer):string ;
    function getMsg(i:Integer):string ;    
  end;

implementation
uses simple_oper ;

{ TMessageList }

procedure TMessageList.AddMessage(ico, msg: string);
begin
  List.Add(ico+'@'+msg) ;
end;

function TMessageList.Count: Integer;
begin
  Result:=List.Count ;
end;

function TMessageList.getIco(i: Integer): string;
begin
  Result:=GetSplitPart1(List[i],'@') ;
end;

function TMessageList.getMsg(i: Integer): string;
begin
  Result:=GetSplitPart2(List[i],'@') ;
end;

end.
