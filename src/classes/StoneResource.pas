unit StoneResource ;

interface
uses GameObject, Classes, CommonResource ;

type
  TStoneResource = class(TCommonResource)
  public
    class function GameClassName:string ; override ;
    function SpriteTag:string ; override ;
    function Name:string ; override ;
    function GetStoneCount():Integer ;
  end;

implementation
uses SysUtils, Config, simple_oper ;

{ TStoneResource }

class function TStoneResource.GameClassName: string;
begin
  Result:='Stone' ;
end;

function TStoneResource.GetStoneCount: Integer;
begin
  Result:=Count ;
end;

function TStoneResource.Name: string;
begin
  Result:=Format('Куча камней(%d)',[GetStoneCount()]) ;
end;

function TStoneResource.SpriteTag: string;
begin
  Result:='resource_stone' ;
end;

initialization

GetGOFactory(nil).RegisterGameObjectClass(TStoneResource);

end.