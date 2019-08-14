unit FoodResource ;

interface
uses GameObject, Classes, CommonResource ;

type
  TFoodResource = class(TCommonResource)
  public
    class function GameClassName:string ; override ;
    function SpriteTag:string ; override ;
    function Name:string ; override ;
    function GetFoodCount():Integer ;
  end;

implementation
uses SysUtils, Config, simple_oper ;

{ TFoodResource }

class function TFoodResource.GameClassName: string;
begin
  Result:='Food' ;
end;

function TFoodResource.GetFoodCount: Integer;
begin
  Result:=Count ;
end;

function TFoodResource.Name: string;
begin
  Result:=Format('Бочка яблок(%d)',[GetFoodCount()]) ;
end;

function TFoodResource.SpriteTag: string;
begin
  Result:='resource_apple' ;
end;

initialization

GetGOFactory(nil).RegisterGameObjectClass(TFoodResource);

end.