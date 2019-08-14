unit FontHolder ;

interface
uses HGEFont ;

type
  TTextGetter = class
  private
  public
    function GetText():string ; virtual ; abstract ;
  end ;

  TFontHolder = class
  private

  public
    _Font:IHGEFont ;
    _TG:TTextGetter ;
    constructor Create(AFont:IHGEFont; ATG:TTextGetter) ;
  end ; 

implementation

constructor TFontHolder.Create(AFont:IHGEFont; ATG:TTextGetter) ;
begin
  _Font:=AFont ;
  _TG:=ATG ;
end ;

end.