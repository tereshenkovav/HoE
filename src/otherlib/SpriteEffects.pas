unit SpriteEffects ;

{

   2009.10.27

     - Добавлена процедура
    procedure AddRenderTagged(Render:TSpriteRender;Tag:Integer) ; overload ;

   2009.10.11
     - Добавлена процедура
     procedure TSpriteRender.SetXY(ax,ay:Single) ;
     procedure TSpriteRender.DelRender(Sprite:IHGESprite) ;
     procedure TSpriteRender.DelRenderTagged(Sprite:IHGESprite;Tag:string) ; overload ;
     procedure TSpriteRender.DelRenderTagged(Sprite:IHGESprite;Tag:Integer) ; overload ;

   2009.10.06
     - добавлена процедура
     procedure TSpriteRender.SetScaleBoth(scale:Single) ;
     function TSpriteRender.IsMouseOver(mx,my:Single):Boolean ;
}

interface
uses HGE, HGESprite, HGEFont, FontHolder, contnrs, WindowOptions, Windows ;

type
  TMirrorType = (mirrVert,mirrHorz) ;
  TMirrorSet = set of TMirrorType ;
  TRenderAlign = (alLeft,alRight,alCenter) ;

  TRenderAbstract = class
  protected

  public
    // Общие свойства всех рендеров
    x:Single ;
    y:Single ;
    scalex:Single ;
    scaley:Single ;
    transp:Single ;
    angle:Single ;
    bright:Single ;
    color:LongWord ;
    mirror:TMirrorSet ;
    align:TRenderAlign ;
    RightBottom:TPoint ;
    DeltaX:Single ;
    DeltaY:Single ;
    hotspot:TPoint ;
    z:Cardinal ;
    
    Tag:string ;

    // Конструктор только для общих свойств
    constructor Create(ax,ay:Single; ascalex:Single=100; ascaley:Single=100;
      atransp:Single=0; aangle:Single=0) ;
    // Управление общими свойствами
    procedure SetScaleBoth(scale:Single) ;
    procedure SetXY(ax,ay:Single) ;
    // Перегружаются в потомках, не имеет смысла в абстрактном рендере
    function IsMouseOver(mx,my:Single):Boolean ; virtual ; abstract ;
    function IsMouseOverEx(mx,my:Single):Boolean ; virtual ; abstract ;
    function IsObjEqual(Obj:TObject):Boolean ; virtual ; abstract ;
    procedure Render ; virtual ; abstract ;
    procedure RenderAt(const ax,ay:Single) ;
    procedure RenderAs(Dst:TRenderAbstract) ;
    // Метод выводит со вторым значением яркости, если мышь над объектом
    procedure RenderAsButton(const ax,ay:Single; const mx,my:Single;
      const br1,br2:Integer) ;
  end ;

  TSpriteRender = class(TRenderAbstract)
  private
    _Sprite:IHGESprite ;
  public
    constructor Create(Sprite:IHGESprite;
      ax:Single=0; ay:Single=0; ascalex:Single=100; ascaley:Single=100;
      atransp:Single=0; aangle:Single=0) ;
    destructor Destroy ; override ;  
    procedure SetSprite(ASprite:IHGESprite) ;  
    // Перегрузка абстрактных методов
    function IsMouseOver(mx,my:Single):Boolean ; override ;
    function IsMouseOverEx(mx,my:Single):Boolean ; override ;
    function IsObjEqual(Obj:TObject):Boolean ; override ;
    function GetSprite():IHGESprite ;
    procedure SetCenterHotSpot() ;
    procedure Render ; override ;
  end ;

  TFontRender = class(TRenderAbstract)
  private
    _FontHolder:TFontHolder ;
  public
    constructor Create(FontHolder:TFontHolder;
      ax,ay:Single; ascalex:Single=100; ascaley:Single=100;
      atransp:Single=0; aangle:Single=0) ;
    // Перегрузка абстрактных методов
    function IsMouseOver(mx,my:Single):Boolean ; override ;
    function IsObjEqual(Obj:TObject):Boolean ; override ;
    procedure Render ; override ;
    // Специфичные функции
    function GetFontHeight():Single ;
    function GetText():string ;
  end ;

  TSpriteRenderPool = class
  private
    ListSpriteRenders:TObjectList ;
    function GetItem(i:Integer):TRenderAbstract ;
  public
    constructor Create ;
    destructor Destroy ; override ;
    procedure AddRender(Render:TRenderAbstract) ;
    procedure AddRenderTagged(Render:TRenderAbstract;Tag:string) ; overload ;
    procedure AddRenderTagged(Render:TRenderAbstract;Tag:Integer) ; overload ;
    function GetRenderBySprite(Sprite:IHGESprite):TSpriteRender ;
    function GetRenderBySpriteAndTag(Sprite:IHGESprite;Tag:string):TSpriteRender ; overload ;
    function GetRenderBySpriteAndTag(Sprite:IHGESprite;Tag:Integer):TSpriteRender ; overload ;
    function GetRenderByTag(Tag:string):TSpriteRender ; overload ;
    function GetRenderByTag(Tag:Integer):TSpriteRender ; overload ;
    function GetRenderByFontHolder(FH:TFontHolder):TFontRender ;
    procedure DelRender(Sprite:IHGESprite) ;
    procedure DelRenderTagged(Sprite:IHGESprite;Tag:string) ; overload ;
    procedure DelRenderTagged(Sprite:IHGESprite;Tag:Integer) ; overload ;
    procedure DelAllRenders ;
    function Count():Integer ;
    procedure Render ;
    property Items[i:Integer]:TRenderAbstract read GetItem ; default ;
  end ;

  TSpriteEffect = class
  private
    ListNextEffects:TObjectList ;
    FIsFinish: Boolean;
  protected
    _Render:TRenderAbstract ;
    procedure SetIsFinish(const Value: Boolean); virtual ;
  public
    Active:Boolean ;
    constructor Create(Render:TRenderAbstract) ;
    destructor Destroy ; override ;
    procedure AddNextEffect(Effect:TSpriteEffect) ;
    procedure Update(dt:Single) ; virtual ;
    procedure IncParam(param_n:Integer; delta:Integer) ; virtual ; abstract ;
    function GetParamStr():string ; virtual ; abstract ;
    function GetPackedParams():string ; virtual ; abstract ;
    procedure SetPackedParams(Value:string) ; virtual ; abstract ;
    property IsFinish:Boolean read FIsFinish write SetIsFinish ;
  end ;

  TSpriteEffectClass = class of TSpriteEffect ;

  TSpriteEffectPool = class
  private
    ListSpriteEffect:TObjectList ;
    function Count:Integer ;
    function GetSpriteEffect(i:Integer):TSpriteEffect ;
  public
    constructor Create ;
    destructor Destroy ; override ;
    procedure AddEffect(Effect:TSpriteEffect;
      NextEffect:TSpriteEffect=nil) ;
    procedure DelEffect(EffectClass:TSpriteEffectClass; Spr:IHGESprite) ; overload ;
    procedure DelEffect(EffectClass:TSpriteEffectClass; Render:TRenderAbstract) ; overload ; 
    procedure DelEffect(Effect:TSpriteEffect) ; overload ;
    procedure DelAllEffects ;  
    //function IsEffectExist(EffectClass:TSpriteEffectClass; Spr:IHGESprite):Boolean ; overload ;
    function IsEffectExist(EffectClass:TSpriteEffectClass; Render:TSpriteRender):Boolean ; overload ;
    //function IsEffectExist(Effect:TSpriteEffect):Boolean ; overload ;
    procedure Update(dt:Single) ;
  end ;

procedure SetWindowOptions(WO:TWindowOptions) ;

implementation
uses SysUtils, simple_oper, Classes, TexturePainter ;

var
  _WO:TWindowOptions ;

procedure SetWindowOptions(WO:TWindowOptions) ;
begin  _WO:=WO ; end ;

function Int2Byte(Value:Integer):byte ;
begin
  if Value<0 then Result:=0 else
  if Value>255 then Result:=255 else
  Result:=Value ;
end ;

{ TSpriteEffect }

procedure TSpriteEffect.AddNextEffect(Effect: TSpriteEffect);
begin
  ListNextEffects.Add(Effect) ;
end;

constructor TSpriteEffect.Create(Render: TRenderAbstract);
begin
  ListNextEffects:=TObjectList.Create(False) ;
  _Render:=Render ;
  Active:=True ;
  IsFinish:=False ;
end;

destructor TSpriteEffect.Destroy;
begin
  ListNextEffects.Free ;
  inherited Destroy ;
end;

procedure TSpriteEffect.SetIsFinish(const Value: Boolean);
var i:Integer ;
begin
  FIsFinish := Value;
  if FIsFinish then 
    for i := 0 to ListNextEffects.Count - 1 do
      TSpriteEffect(ListNextEffects[i]).Active:=True ;
end;

procedure TSpriteEffect.Update(dt: Single);
begin
  // Empty
end;

{ TSpriteEffectPool }

function TSpriteEffectPool.Count: Integer;
begin
  Result:=ListSpriteEffect.Count ;
end;

function TSpriteEffectPool.GetSpriteEffect(i: Integer): TSpriteEffect;
begin
  Result:=TSpriteEffect(ListSpriteEffect[i]) ;
end;

function TSpriteEffectPool.IsEffectExist(EffectClass: TSpriteEffectClass;
  Render: TSpriteRender): Boolean;
var i:Integer ;
    z:Boolean ;
begin
  Result:=False ;
  for i := 0 to Count - 1 do
    if (GetSpriteEffect(i) is EffectClass)and
       (GetSpriteEffect(i)._Render=Render) then begin
         Result:=True ; Break ;
    end;
end;

constructor TSpriteEffectPool.Create;
begin
  ListSpriteEffect:=TObjectList.Create ;
end;

procedure TSpriteEffectPool.DelEffect(EffectClass: TSpriteEffectClass;
  Spr: IHGESprite);
var i:Integer ;
    z:Boolean ;
begin
    for i := 0 to Count - 1 do
      if (GetSpriteEffect(i) is EffectClass)and
         (GetSpriteEffect(i)._Render.IsObjEqual(Spr.Implementor)) then begin
           DelEffect(GetSpriteEffect(i)) ;
         end;
end;

procedure TSpriteEffectPool.DelAllEffects;
begin
  while ListSpriteEffect.Count>0 do
    ListSpriteEffect.Delete(0) ; 
end;

procedure TSpriteEffectPool.DelEffect(Effect: TSpriteEffect);
begin
  Effect.IsFinish:=True ;
end;

procedure TSpriteEffectPool.DelEffect(EffectClass: TSpriteEffectClass;
  Render: TRenderAbstract);
var i:Integer ;
    z:Boolean ;
begin
    for i := 0 to Count - 1 do
      if (GetSpriteEffect(i) is EffectClass)and
         (GetSpriteEffect(i)._Render=Render) then begin
           DelEffect(GetSpriteEffect(i)) ;
         end;
end;

destructor TSpriteEffectPool.Destroy;
begin
  ListSpriteEffect.Free ;
  inherited Destroy ;
end;

procedure TSpriteEffectPool.AddEffect(Effect:TSpriteEffect;
  NextEffect:TSpriteEffect=nil) ;
begin
  if ListSpriteEffect.IndexOf(Effect)=-1 then
    ListSpriteEffect.Add(Effect) ;

  if NextEffect<>nil then begin
    if ListSpriteEffect.IndexOf(NextEffect)=-1 then
      ListSpriteEffect.Add(NextEffect) ;
    NextEffect.Active:=False ;
    Effect.AddNextEffect(NextEffect) ;
  end;
end;

procedure TSpriteEffectPool.Update(dt: Single);
var i:Integer ;
begin
  i:=0 ;
  while i<=Count - 1 do
    if GetSpriteEffect(i).IsFinish then
      ListSpriteEffect.Delete(i)
    else
      Inc(i) ;

  for i := 0 to Count - 1 do
    if GetSpriteEffect(i).Active then
      GetSpriteEffect(i).Update(dt) ;
      
end;

{ TRenderAbstract }

constructor TRenderAbstract.Create(
  ax,ay:Single; ascalex:Single=100; ascaley:Single=100;
  atransp:Single=0; aangle:Single=0) ;
begin
  x:=ax ;  y:=ay ;
  scalex:=ascalex ; scaley:=ascaley ;
  transp:=atransp ;
  angle:=aangle ;
end;

procedure TRenderAbstract.RenderAs(Dst: TRenderAbstract);
begin
  RenderAt(Dst.x,Dst.y) ;
end;

procedure TRenderAbstract.RenderAsButton(const ax, ay, mx, my: Single;
  const br1, br2: Integer);
var br_old:Single ;
begin
  br_old:=bright ;
  SetXY(ax,ay) ;
  if IsMouseOver(mx,my) then bright:=br2 else bright:=br1 ;
  Render() ;
  bright:=br_old ;  
end;

procedure TRenderAbstract.RenderAt(const ax, ay: Single);
begin
  x:=ax ; y:=ay ; Render ;
end;

procedure TRenderAbstract.SetScaleBoth(scale: Single);
begin  scalex:=scale ; scaley:=scale ; end;

procedure TRenderAbstract.SetXY(ax, ay:Single);
begin  x:=ax ; y:=ay ; end;

{ TSpriteRender }

constructor TSpriteRender.Create(Sprite:IHGESprite;
  ax:Single=0; ay:Single=0; ascalex:Single=100; ascaley:Single=100;
  atransp:Single=0; aangle:Single=0) ;
var xc,yc:Single ;  
begin
  inherited Create(ax,ay,ascalex,ascaley,atransp,aangle) ;
  _Sprite:=Sprite ;
  color:=$00FFFFFF ;
  _Sprite.GetHotSpot(xc,yc);
  hotspot:=Point(Round(xc),Round(yc)) ;
end;

destructor TSpriteRender.Destroy;
begin
  inherited Destroy ;
end;

function TSpriteRender.GetSprite: IHGESprite;
begin
  Result:=_Sprite ;
end;

function TSpriteRender.IsMouseOver(mx, my: Single): Boolean;
var x1,y1,x2,y2,xc,yc:Single ;
begin
  _Sprite.GetHotSpot(xc,yc) ;
  xc:=xc*(scalex/100) ;
  yc:=yc*(scaley/100) ;
  x1:=_WO.GetMashX()*(x-xc) ;
  y1:=_WO.GetMashY()*(y-yc) ;
  x2:=x1+_WO.GetMashX()*_Sprite.GetWidth()*(scalex/100) ;
  y2:=y1+_WO.GetMashY()*_Sprite.GetHeight()*(scaley/100) ;
  Result:=(x1<=mx)and(y1<=my)and(mx<=x2)and(my<=y2) ;
end;

function TSpriteRender.IsMouseOverEx(mx, my: Single): Boolean;
var x1,y1,x2,y2,xc,yc:Single ;
    xn,yn:Integer ;
begin
  xc:=hotspot.X ;  yc:=hotspot.Y ;
  x1:=_WO.GetMashX()*(x-(scalex/100)*xc) ;
  y1:=_WO.GetMashY()*(y-(scaley/100)*yc) ;
  x2:=x1+_WO.GetMashX()*(scalex/100)*_Sprite.GetWidth() ;
  y2:=y1+_WO.GetMashY()*(scaley/100)*_Sprite.GetHeight() ;
  if (x1<=mx)and(y1<=my)and(mx<=x2)and(my<=y2) then begin
    with TTexturePainter.Create(_Sprite.GetTexture,True) do begin
      xn:=Round((mx-x1)/(_WO.GetMashX*(scalex/100))) ;
      yn:=Round((my-y1)/(_WO.GetMashY*(scaley/100))) ;
      Result:=(Alpha[xn,yn]<>$00) ;
      Free ;
    end ;
  end
  else Result:=False ;
end;

function TSpriteRender.IsObjEqual(Obj: TObject): Boolean;
begin
  Result:=(Obj=_Sprite.Implementor) ;
end;

procedure TSpriteRender.Render;
var b:byte ;
    bm:Integer ;

  procedure intRender() ;
  begin
    _Sprite.SetColor(b shl 24 +(color and $FFFFFF)) ;
    _Sprite.RenderEx(_WO.GetMashX()*(x+DeltaX),_WO.GetMashY()*(y+DeltaY),
       2*PI*angle/360,
       _WO.GetMashX()*scalex/100,_WO.GetMashY()*scaley/100) ;
  end ;

  procedure intRenderMirroredHorz() ;
  var x1,y1,x2,y2:Single ;
  begin
    _Sprite.SetColor(b shl 24 +(color and $FFFFFF)) ;
    x1:=_WO.GetMashX()*(x+DeltaX-hotspot.X) ;
    y1:=_WO.GetMashY()*(y+DeltaY-hotspot.Y) ;
    x2:=_WO.GetMashX()*(x+DeltaX-hotspot.X+(scalex/100)*_Sprite.GetWidth()) ;
    y2:=_WO.GetMashY()*(y+DeltaY-hotspot.Y+(scaley/100)*_Sprite.GetHeight()) ;
    _Sprite.Render4V(x2,y1, x1,y1, x1,y2, x2,y2) ;
  end ;

  procedure intRenderMirroredVert() ;
  var x1,y1,x2,y2:Single ;
  begin
    _Sprite.SetColor(b shl 24 +(color and $FFFFFF)) ;
    x1:=_WO.GetMashX()*(x+DeltaX-hotspot.X) ;
    y1:=_WO.GetMashY()*(y+DeltaY-hotspot.Y) ;
    x2:=_WO.GetMashX()*(x+DeltaX-hotspot.X+(scalex/100)*_Sprite.GetWidth()) ;
    y2:=_WO.GetMashY()*(y+DeltaY-hotspot.Y+(scaley/100)*_Sprite.GetHeight()) ;
    _Sprite.Render4V(x1,y2, x2,y2, x2,y1, x1,y1) ;
  end ;

  procedure intRenderMirroredBoth() ;
  var x1,y1,x2,y2:Single ;
  begin
    _Sprite.SetColor(b shl 24 +(color and $FFFFFF)) ;
    x1:=_WO.GetMashX()*(x+DeltaX-hotspot.X) ;
    y1:=_WO.GetMashY()*(y+DeltaY-hotspot.Y) ;
    x2:=_WO.GetMashX()*(x+DeltaX-hotspot.X+(scalex/100)*_Sprite.GetWidth()) ;
    y2:=_WO.GetMashY()*(y+DeltaY-hotspot.Y+(scaley/100)*_Sprite.GetHeight()) ;
    _Sprite.Render4V(x2,y2, x1,y2, x1,y1, x2,y1) ;
  end ;

begin
  // Если 100% прозрачен, или нулевой масштаб, то не выводим
  if (Round(transp)=100)or(Abs(scalex)<1)or(Abs(scaley)<1) then Exit ;

  _Sprite.SetHotSpot(hotspot.X,hotspot.Y);

  b:=Int2Byte(Round(255*(100-transp)/100)) ;
  if (mirrHorz in mirror)and(mirrVert in mirror) then 
    intRenderMirroredBoth() else
  if mirrHorz in mirror then intRenderMirroredHorz() else
  if mirrVert in mirror then intRenderMirroredVert() else
  intRender ;

  if bright>100 then begin
    bm:=_Sprite.GetBlendMode() ;
    //_Sprite.SetBlendMode(BLEND_COLORMUL or BLEND_ALPHAADD or BLEND_NOZWRITE) ;
    // Новый режим в Delphi 10
    _Sprite.SetBlendMode(Blend_Bright) ;

    b:=Int2Byte(Round(255*(bright-100)/100)) ;
    if mirrHorz in mirror then intRenderMirroredHorz() else
    if mirrVert in mirror then intRenderMirroredVert() else
    intRender ;

    _Sprite.SetBlendMode(bm) ;
  end ;
end;

procedure TSpriteRender.SetCenterHotSpot;
begin
  hotspot:=Point(Round(_Sprite.GetWidth()/2),Round(_Sprite.GetHeight()/2)) ;
end;

procedure TSpriteRender.SetSprite(ASprite: IHGESprite);
begin
  _Sprite:=ASprite ;
end;

{ TFontRender }

constructor TFontRender.Create(FontHolder:TFontHolder;
  ax,ay:Single; ascalex:Single=100; ascaley:Single=100;
  atransp:Single=0; aangle:Single=0) ;
begin
  inherited Create(ax,ay,ascalex,ascaley,atransp,aangle) ;
  align:=alLeft ;
  _FontHolder:=FontHolder ;
  RightBottom.X:=200 ; RightBottom.Y:=100 ;
end;

function TFontRender.GetFontHeight: Single;
begin
  _FontHolder._Font.SetScale(scalex/100) ;
  Result:=_FontHolder._Font.GetHeight() ;
end;

function TFontRender.GetText: string;
begin
  Result:=_FontHolder._TG.GetText() ;
end;

function TFontRender.IsMouseOver(mx, my: Single): Boolean;
var x1,y1,x2,y2,h,w:Single ;
begin
  Result:=False ;

  w:=_FontHolder._Font.GetStringWidth(_FontHolder._TG.GetText(),False) ;
  h:=_FontHolder._Font.GetHeight() ;

  x1:=_WO.GetMashX()*x ;
  y1:=_WO.GetMashY()*y ;
  x2:=x1+_WO.GetMashX()*w ;
  y2:=y1+_WO.GetMashY()*h ;
  Result:=(x1<=mx)and(y1<=my)and(mx<=x2)and(my<=y2) ;
end;

function TFontRender.IsObjEqual(Obj: TObject): Boolean;
begin
  Result:=(Obj=_FontHolder) ;
end;

procedure TFontRender.Render;
var b:byte ;
    bm:Integer ;
    s,sn:string ;
    List:TStringList ;
    i:Integer ;
    w:Integer ;
begin
  // Если 100% прозрачен, или нулевой масштаб, то не выводим
  if (Round(transp)=100)or(Abs(scalex)<1)or(Abs(scaley)<1) then Exit ;

  b:=Int2Byte(Round(255*(100-transp)/100)) ;

  _FontHolder._Font.SetScale(scalex/100) ;
  _FontHolder._Font.SetColor(b shl 24 + color) ;

// Простой рендер без блока
{
  _FontHolder._Font.PrintF(
    _WO.GetMashX()*x,_WO.GetMashY()*y,
    Alternate(align=alLeft,HGETEXT_LEFT,
    Alternate(align=alRight,HGETEXT_RIGHT,
    Alternate(align=alCenter,HGETEXT_CENTER,0))),
    _FontHolder._TG.GetText(),[]) ;
}

// Рендер с блоком
  {if align=alCenter then
    _FontHolder._Font.PrintF(
      _WO.GetMashX()*x,_WO.GetMashY()*y,HGETEXT_CENTER,
      _FontHolder._TG.GetText(),[])
  else begin}
    s:=_FontHolder._TG.GetText() ;
    List:=TStringList.Create ;

    sn:='' ;
    for i := 1 to Length(s) do
      if s[i]<>' ' then sn:=sn+s[i] else begin List.Add(sn) ; sn:='' ; end ;
    if sn<>'' then List.Add(sn) ;

    w:=0 ;
    sn:='' ;
    for i := 0 to List.Count - 1 do begin
      w:=w+Round(_FontHolder._Font.GetStringWidth(List[i]+' ')) ;
      if w>RightBottom.X then begin
        sn:=sn+chr(13)+List[i]+' ' ;
        w:=Round(_FontHolder._Font.GetStringWidth(List[i]+' ')) ;
      end
      else
        sn:=sn+List[i]+' ' ;
    end;
    List.Free ;
    _FontHolder._Font.PrintF(
      _WO.GetMashX()*(x+DeltaX),_WO.GetMashY()*(y+DeltaY),
      Alternate(align=alLeft,HGETEXT_LEFT,
      Alternate(align=alRight,HGETEXT_RIGHT,
      Alternate(align=alCenter,HGETEXT_CENTER,0))),
      sn,[])
  //end;

end;

{ TSpriteRenderPool }

procedure TSpriteRenderPool.AddRender(Render: TRenderAbstract);
begin
  AddRenderTagged(Render,'') ;
end;

procedure TSpriteRenderPool.AddRenderTagged(Render: TRenderAbstract; Tag: string);
begin
  ListSpriteRenders.Add(Render) ;
  Render.Tag:=Tag ;
  //Result:=Render ;
end;

procedure TSpriteRenderPool.AddRenderTagged(Render: TRenderAbstract;
  Tag: Integer);
begin
  AddRenderTagged(Render,IntToStr(Tag)) ;
end;

function TSpriteRenderPool.Count: Integer;
begin  Result:=ListSpriteRenders.Count ; end;

constructor TSpriteRenderPool.Create;
begin
  ListSpriteRenders:=TObjectList.Create ;
end;

procedure TSpriteRenderPool.DelAllRenders;
begin
  while ListSpriteRenders.Count>0 do
    ListSpriteRenders.Delete(0) ; 
end;

procedure TSpriteRenderPool.DelRender(Sprite: IHGESprite);
begin
  ListSpriteRenders.Remove(GetRenderBySprite(Sprite)) ;
end;

procedure TSpriteRenderPool.DelRenderTagged(Sprite: IHGESprite; Tag: string);
begin
  ListSpriteRenders.Remove(GetRenderBySpriteAndTag(Sprite,Tag)) ;
end;

procedure TSpriteRenderPool.DelRenderTagged(Sprite: IHGESprite; Tag: Integer);
begin
  ListSpriteRenders.Remove(GetRenderBySpriteAndTag(Sprite,Tag)) ;
end;

destructor TSpriteRenderPool.Destroy;
begin
  ListSpriteRenders.Free ;
  inherited Destroy ;
end;

function TSpriteRenderPool.GetItem(i: Integer): TRenderAbstract;
begin  Result:=TRenderAbstract(ListSpriteRenders[i]) ; end;

function TSpriteRenderPool.GetRenderByFontHolder(FH: TFontHolder): TFontRender;
var i:Integer ;
begin
  Result:=nil ;
  for i := 0 to ListSpriteRenders.Count - 1 do
    if TRenderAbstract(ListSpriteRenders[i]).IsObjEqual(FH) then begin
      Result:=TFontRender(ListSpriteRenders[i]) ;
      Break ;
    end ;
end;

function TSpriteRenderPool.GetRenderBySprite(Sprite: IHGESprite): TSpriteRender;
var i:Integer ;
begin
  Result:=nil ;
  for i := 0 to ListSpriteRenders.Count - 1 do
    if TRenderAbstract(ListSpriteRenders[i]).IsObjEqual(Sprite.Implementor) then begin
      Result:=TSpriteRender(ListSpriteRenders[i]) ;
      Break ;
    end ;
end;

function TSpriteRenderPool.GetRenderBySpriteAndTag(Sprite: IHGESprite;
  Tag: Integer): TSpriteRender;
begin
  Result:=GetRenderBySpriteAndTag(Sprite,IntToStr(Tag)) ;
end;

function TSpriteRenderPool.GetRenderByTag(Tag: string): TSpriteRender;
var i:Integer ;
begin
// Неочевидное дублирование с кодом GetRenderBySprite
  Result:=nil ;
  for i := 0 to ListSpriteRenders.Count - 1 do
    if TRenderAbstract(ListSpriteRenders[i]).Tag=Tag then begin
      Result:=TSpriteRender(ListSpriteRenders[i]) ;
      Break ;
    end ;
end;

function TSpriteRenderPool.GetRenderByTag(Tag: Integer): TSpriteRender;
begin
  Result:=GetRenderByTag(IntToStr(Tag)) ;
end;

function TSpriteRenderPool.GetRenderBySpriteAndTag(Sprite: IHGESprite;
  Tag: string): TSpriteRender;
var i:Integer ;
begin
// Неочевидное дублирование с кодом GetRenderBySprite
  Result:=nil ;
  for i := 0 to ListSpriteRenders.Count - 1 do
    if (TRenderAbstract(ListSpriteRenders[i]).IsObjEqual(Sprite.Implementor))and
       (TRenderAbstract(ListSpriteRenders[i]).Tag=Tag) then begin
      Result:=TSpriteRender(ListSpriteRenders[i]) ;
      Break ;
    end ;
end;

procedure TSpriteRenderPool.Render;
var i:Integer ;
begin
  for i := 0 to ListSpriteRenders.Count - 1 do
    TRenderAbstract(ListSpriteRenders[i]).Render ;
end;

end.
