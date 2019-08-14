unit TexturePainter ;

interface
uses HGE, TAVHGEUtils ;

type
  TTexturePainterBase = class
  private
    _Tex:ITexture ;
    ColFix:PLongWord ;
    mx,my:Integer ;
    FReadOnly:Boolean ;
    function GetPixel(x,y:Integer):LongWord ;
    procedure SetPixel(x,y:Integer; Value:LongWord) ; virtual ;
    function GetAlpha(x,y:Integer):Byte ;
    procedure SetAlpha(x,y:Integer; Value:Byte) ; virtual ;
    function GetColor(x,y:Integer):LongWord ;
    procedure SetColor(x,y:Integer; Value:LongWord) ; virtual ;
    function IsOutsize(x,y:Integer):Boolean ;
  public
    constructor Create(Tex:ITexture; ReadOnly:Boolean=True) ; virtual ;
    destructor Destroy ; override ;
    procedure CopyFrom(Src:TTexturePainterBase) ;
    procedure StartPaint ;
    procedure FinishPaint ;
    procedure FillByColor(C:LongWord) ;
    function Width():Integer ;
    function Height():Integer ;
    function AvgPixels3(x,y:Integer):LongWord ;
    function AvgPixels123(x1,x,x2,y1,y,y2:Integer):LongWord ;
    function AvgPixelsR(x,y,rx,ry:Integer):LongWord ;
    property Pixels[x,y:Integer]:LongWord read GetPixel write SetPixel ;
    property Alpha[x,y:Integer]:Byte read GetAlpha write SetAlpha ;
    property Color[x,y:Integer]:LongWord read GetColor write SetColor ;
  end ;

  TTexturePainter = class(TTexturePainterBase)
  public
    constructor Create(Tex:ITexture; ReadOnly:Boolean=True) ; override ;
    destructor Destroy ; override ;
  end;

  TPixelMem = record
    x:Integer ;
    y:Integer ;
    PixelData:LongWord ;
  end;

  TTexturePainterMemed = class(TTexturePainterBase)
  private
    arr_mem:array[0..8191] of TPixelMem ;
    arr_mod:array[0..1023,0..767] of Boolean ;
    cntmem:Integer ;
    procedure StoreMem(x,y:Integer; PixelData:LongWord) ;
    procedure SetPixel(x,y:Integer; Value:LongWord) ; override ;
    procedure SetAlpha(x,y:Integer; Value:Byte) ; override ;
    procedure SetColor(x,y:Integer; Value:LongWord) ; override ;
  public
    procedure RestoreMem ;
    procedure PresaveSector(x1,y1,x2,y2:Integer) ;
    function IsPixelModified(x,y:Integer):Boolean ;
  end ;

implementation
uses Math ;

function TTexturePainterBase.AvgPixels123(x1, x, x2, y1, y,
  y2: Integer): LongWord;
var sum1,sum2,sum3,sum4:Integer ;
    dx,dy:Integer ;
    C:LongWord ;

  procedure AddPoint(tx,ty:Integer) ;
  begin
    C:=Pixels[tx,ty] ;
    Inc(sum1,(C shr 0) and $FF) ;
    Inc(sum2,(C shr 8) and $FF) ;
    Inc(sum3,(C shr 16) and $FF) ;
    Inc(sum4,(C shr 24) and $FF) ;
  end ;

begin
  sum1:=0 ; sum2:=0 ; sum3:=0 ; sum4:=0 ;

  AddPoint(x1,y1) ;  AddPoint(x1,y) ; AddPoint(x1,y2) ;
  AddPoint(x,y1) ;  AddPoint(x,y) ;  AddPoint(x,y2) ;
  AddPoint(x2,y1) ;  AddPoint(x2,y) ;  AddPoint(x2,y2) ;

  sum1:=Round(sum1/4) ;
  sum2:=Round(sum2/4) ;
  sum3:=Round(sum3/4) ;
  sum4:=Round(sum4/4) ;
  Result:=(sum4 shl 24)+(sum3 shl 16)+(sum2 shl 8)+(sum1 shl 0) ;
end;

function TTexturePainterBase.AvgPixels3(x, y: Integer): LongWord;
var sum1,sum2,sum3,sum4:Integer ;
    dx,dy:Integer ;
    C:LongWord ;
begin
  sum1:=0 ; sum2:=0 ; sum3:=0 ; sum4:=0 ;
  for dx := -1 to 1 do
    for dy := -1 to 1 do begin
      C:=Pixels[x+dx,y+dy] ;
      Inc(sum1,(C shr 0) and $FF) ;
      Inc(sum2,(C shr 8) and $FF) ;
      Inc(sum3,(C shr 16) and $FF) ;
      Inc(sum4,(C shr 24) and $FF) ;
    end ;
  sum1:=Round(sum1/9) ;
  sum2:=Round(sum2/9) ;
  sum3:=Round(sum3/9) ;
  sum4:=Round(sum4/9) ;
  Result:=(sum4 shl 24)+(sum3 shl 16)+(sum2 shl 8)+(sum1 shl 0) ;
end;

function TTexturePainterBase.AvgPixelsR(x, y, rx, ry: Integer): LongWord;
var sum1,sum2,sum3,sum4:Integer ;
    dx,dy:Integer ;
    C:LongWord ;
    cnt:Integer ;
begin
  cnt:=0 ;
  sum1:=0 ; sum2:=0 ; sum3:=0 ; sum4:=0 ;
  for dx := -rx to rx do
    for dy := -ry to ry do begin
      C:=Pixels[x+dx,y+dy] ;
      Inc(sum1,(C shr 0) and $FF) ;
      Inc(sum2,(C shr 8) and $FF) ;
      Inc(sum3,(C shr 16) and $FF) ;
      Inc(sum4,(C shr 24) and $FF) ;
      Inc(cnt) ;
    end ;
  sum1:=Round(sum1/cnt) ;
  sum2:=Round(sum2/cnt) ;
  sum3:=Round(sum3/cnt) ;
  sum4:=Round(sum4/cnt) ;
  Result:=(sum4 shl 24)+(sum3 shl 16)+(sum2 shl 8)+(sum1 shl 0) ;
end;

procedure TTexturePainterBase.CopyFrom(Src: TTexturePainterBase);
var Col,ColSrc:PLongWord ;
    x,y:Word ;
    delta:Word ;
begin
  delta:=mx-Width ;
  Col:=ColFix ;
  ColSrc:=Src.ColFix ;
  for y := 0 to Height-1 do begin
    for x := 0 to Width-1 do begin
      //Inc(Col,y*mx+x) ;
      //Inc(ColSrc,y*mx+x) ;
      Col^:=ColSrc^ ;
      Inc(Col,1) ;
      Inc(ColSrc,1) ;
    end;
    Inc(Col,delta) ;
    Inc(ColSrc,delta) ;
  end ;
end;

constructor TTexturePainterBase.Create(Tex:ITexture; ReadOnly:Boolean=True) ;
var smax:Integer ;
begin

  _Tex:=Tex ;
  FReadOnly:=ReadOnly ;

// Старый вариант, основан на калибраторе
{
  if GCaliber=crRealSize then begin
    mx:=_Tex.GetWidth(True) ;
    my:=_Tex.GetHeight(True) ;
  end ;

  if GCaliber=cr2powNSize then begin
    smax:=max(_Tex.GetWidth(True),_Tex.GetHeight(True)) ;
    // Получение минимального подходящего размера степени двойки
    mx:=1 ;
    repeat mx:=mx*2 ; until mx>=smax ;
    my:=mx ;
  end ;
}
// Новый вариант, всегда берем внутренний размер текстуры
  mx:=_Tex.GetWidth(False) ;
  my:=_Tex.GetHeight(False) ;

end ;

destructor TTexturePainterBase.Destroy ;
begin
  inherited Destroy ;
end ;

procedure TTexturePainterBase.FillByColor(C: LongWord);
var x,y:Integer;
begin
  for x := 0 to Width-1 do
    for y := 0 to Height - 1 do
      SetPixel(x,y,C) ;
end;

procedure TTexturePainterBase.FinishPaint;
begin
  mHGE.Texture_Unlock(_Tex) ;
end;

procedure TTexturePainterBase.StartPaint;
begin
  ColFix:=mHGE.Texture_Lock(_Tex,FReadOnly,0,0,mx,my) ;
end;

function TTexturePainterBase.Height: Integer;
begin
  Result:=_Tex.GetHeight(True) ;
end;

function TTexturePainterBase.Width: Integer;
begin
  Result:=_Tex.GetWidth(True) ;
end;

function TTexturePainterBase.IsOutsize(x, y: Integer): Boolean;
begin
  Result:=(x<0)or(y<0)or(x>=_Tex.GetWidth(True))or(y>=_Tex.GetHeight(True)) ;
end;

function TTexturePainterBase.GetPixel(x,y:Integer):LongWord ;
var Col:PLongWord ;
begin
  if IsOutsize(x,y) then Exit ;

  Col:=ColFix ;
  Inc(Col,y*mx+x) ;
  Result:=Col^ ;
end ;

procedure TTexturePainterBase.SetPixel(x,y:Integer; Value:LongWord) ;
var Col:PLongWord ;
begin
  if IsOutsize(x,y) then Exit ;

  Col:=ColFix ;
  Inc(Col,y*mx+x) ;
  Col^:=Value ;
end ;

function TTexturePainterBase.GetAlpha(x,y:Integer):Byte ;
var Col:PLongWord ;
begin
  if IsOutsize(x,y) then Exit ;

  Col:=ColFix ;
  Inc(Col,y*mx+x) ;
  Result:=(Col^ shr 24 and $FF) ;
end ;

procedure TTexturePainterBase.SetAlpha(x,y:Integer; Value:Byte) ;
var Col:PLongWord ;
    C:LongWord ;
begin
  if IsOutsize(x,y) then Exit ;

  Col:=ColFix ;
  Inc(Col,y*mx+x) ;
  C:=Col^ ;
  Col^:=(Value shl 24) + (C and $00FFFFFF) ;
end ;

function TTexturePainterBase.GetColor(x,y:Integer):LongWord ;
var Col:PLongWord ;
begin
  if IsOutsize(x,y) then Exit ;

  Col:=ColFix ;
  Inc(Col,y*mx+x) ;
  Result:=(Col^ and $00FFFFFF) ;
end ;

procedure TTexturePainterBase.SetColor(x,y:Integer; Value:LongWord) ;
var Col:PLongWord ;
    C:LongWord ;
begin
  if IsOutsize(x,y) then Exit ;

  Col:=ColFix ;
  Inc(Col,y*mx+x) ;
  C:=Col^ ;
  Col^:=(((C shr 24 and $FF) shl 24) and $FF00000)+Value;
end ;

{ TTexturePainter }

constructor TTexturePainter.Create(Tex: ITexture; ReadOnly: Boolean=True);
begin
  inherited Create(Tex,ReadOnly) ;
  StartPaint ;
end;

destructor TTexturePainter.Destroy;
begin
  FinishPaint ;
  inherited Destroy ;
end;

{ TTexturePainterMemed }

function TTexturePainterMemed.IsPixelModified(x, y: Integer): Boolean;
var i:Integer ;
begin
  Result:=arr_mod[x,y] ;
end;

procedure TTexturePainterMemed.PresaveSector(x1, y1, x2, y2: Integer);
var x,y:Integer ;
begin
{  for x := x1 to x2 do
    for y := y1 to y2 do
      StoreMem(x,y,GetPixel(x,y)) ;}
end;

procedure TTexturePainterMemed.RestoreMem;
var i:Integer ;
    x,y:Integer ;
begin
  StartPaint ;
  for i := 0 to cntmem - 1 do
    inherited SetPixel(arr_mem[i].x,arr_mem[i].y,arr_mem[i].PixelData) ;
  cntmem:=0 ;
  for x := 0 to _Tex.GetWidth(True)-1 do
    for y := 0 to _Tex.GetHeight(True)-1 do
      arr_mod[x,y]:=False ;    
  FinishPaint ;
end;

procedure TTexturePainterMemed.StoreMem(x, y: Integer; PixelData: LongWord);
begin
  if IsPixelModified(x,y) then Exit ;

  arr_mem[cntmem].x:=x ;
  arr_mem[cntmem].y:=y ;
  arr_mem[cntmem].PixelData:=PixelData ;
  Inc(cntmem) ;
  arr_mod[x,y]:=True ;
end;

procedure TTexturePainterMemed.SetAlpha(x, y: Integer; Value: Byte);
begin
  StoreMem(x,y,GetPixel(x,y)) ;
  inherited SetAlpha(x,y,Value) ;
end;

procedure TTexturePainterMemed.SetColor(x, y: Integer; Value: LongWord);
begin
  StoreMem(x,y,GetPixel(x,y)) ;
  inherited SetColor(x,y,Value) ;
end;

procedure TTexturePainterMemed.SetPixel(x, y: Integer; Value: LongWord);
begin
  StoreMem(x,y,GetPixel(x,y)) ;
  inherited SetPixel(x,y,Value) ;
end;

end.
