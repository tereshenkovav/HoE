unit EmptyPlace ;

interface
uses GameObject, Classes ;

type
  TEmptyPlace = class(TGameObject)
  private
  public
    Fixed:Boolean ;
    constructor Create(Params:TStringList) ; override ;
    class function GameClassName:string ; override ;
    function SpriteTag:string ; override ;
    function Name:string ; override ;
  end;

implementation
uses SysUtils ;

{ TEmptyPlace }

constructor TEmptyPlace.Create(Params: TStringList);
begin
  inherited Create(Params) ;
  Fixed:=False ;
end;

class function TEmptyPlace.GameClassName: string;
begin
  Result:='EmptyPlace' ;
end;

function TEmptyPlace.Name: string;
begin
  Result:='Пустота' ;
end;

function TEmptyPlace.SpriteTag: string;
begin
  Result:='empty_place' ;
end;

initialization

GetGOFactory(nil).RegisterGameObjectClass(TEmptyPlace);

end.