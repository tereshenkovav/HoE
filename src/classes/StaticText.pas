unit StaticText;

interface
uses FontHolder ;

type
  TStaticText = class(TTextGetter)
  public
    Text:string ;
    function GetText():string ; override ;
    constructor Create(AText:string) ;
  end;

implementation

{ TStaticText }

constructor TStaticText.Create(AText: string);
begin
  Text:=AText ;
end;

function TStaticText.GetText: string;
begin
  Result:=Text ;
end;

end.
