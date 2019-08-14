unit MiniMap ;

interface
uses HGE ;

type
  TPointColored = record
    x:Integer ;
    y:Integer ;
    Color:Cardinal ;
  end;
  
  TMiniMap = class
  private
    Width:Integer ;
    Height:Integer ;
    RealWidth:Single ;
    RealHeight:Single ;
    VWidth:Integer ;
    VHeight:Integer ;
    Colors:array[0..255,0..255] of Cardinal ;
    procedure SetViewWidthHeight(AVWidth,AVHeight:Integer) ;
    function GetColorByViewPoint(x,y:Integer):Cardinal ;
  public
    NoLandscape:Boolean ;
    constructor Create(AWidth,AHeight:Integer;ARealWidth,ARealHeight:Single) ;
    procedure SetColor(i,j:Integer; color:Cardinal) ;
    procedure FillTexture256(Tex:ITexture; AVWidth,AVHeight:Integer;
      Left,Top:Single; out ShiftVert:Integer; out ShiftHorz:Integer) ;
    procedure GetXYByClickPos(viewx,viewy:Single;
      out mapx:Integer; out mapy:Integer) ;

  end ;

implementation
uses TAVHGEUtils, ObjModule, BattleField ;

{ TMiniMap }

constructor TMiniMap.Create(AWidth, AHeight: Integer;
  ARealWidth,ARealHeight:Single);
begin
  Width:=AWidth ;
  Height:=AHeight ;
  VWidth:=Width ;
  VHeight:=Height ;
  RealWidth:=ARealWidth ;
  RealHeight:=ARealHeight ;
  NoLandscape:=False ;
end;

procedure TMiniMap.FillTexture256(Tex: ITexture; AVWidth, AVHeight: Integer;
  Left,Top:Single; out ShiftVert:Integer; out ShiftHorz:Integer);
var Col,ColFix:PLongWord ;
    x,y:Word ;
    x1,y1,x2,y2:Word ;
    NewVHeight,NewVWidth:Integer ;
const
  COLOR_BORDER_INNER=$FFFFFFFF ;
  COLOR_BORDER_OUTER=$FFA0A0A0 ;
begin
  if RealHeight<RealWidth then begin
    NewVHeight:=Round(AVWidth*(RealHeight/RealWidth)) ;
    NewVWidth:=AVWidth ;
    ShiftVert:=(AVHeight-NewVHeight) div 2 ;
    ShiftHorz:=0 ;
  end
  else begin
    NewVHeight:=AVHeight ;
    NewVWidth:=Round(AVHeight*(RealWidth/RealHeight)) ;
    ShiftVert:=0 ;
    ShiftHorz:=(AVWidth-NewVWidth) div 2 ;
  end;

  SetViewWidthHeight(NewVWidth,NewVHeight) ;
  ColFix:=mHGE.Texture_Lock(Tex,False,0,0,256,256) ;

  for x := 0 to VWidth do
    for y := 0 to VHeight do begin
      Col:=ColFix ;
      Inc(Col,y*256+x) ;
      try
      if (x=0)or(y=0) then Col^:=COLOR_BORDER_OUTER else
      Col^:=GetColorByViewPoint(x,y) ;
      except
      end;
    end;

  x1:=Trunc(VWidth*Left/RealWidth) ;
  y1:=Trunc(VHeight*Top/RealHeight) ;

  x2:=Trunc((VWidth-1)*(Left+SWindowOptions.Width-230)/RealWidth) ;
  y2:=Trunc((VHeight-1)*(Top+SWindowOptions.Height-40)/RealHeight) ;

  if x2>VWidth then x2:=VWidth ;
  if y2>VHeight then y2:=VHeight ;  

try
  for x := 0 to VWidth-1 do begin
    Col:=ColFix ;
    Inc(Col,(VHeight)*256+x) ;    Col^:=COLOR_BORDER_OUTER ;
  end;
  for y := 0 to VHeight-1 do begin
    Col:=ColFix ;
    Inc(Col,y*256+VWidth) ; Col^:=COLOR_BORDER_OUTER ;
  end;

  for x := x1 to x2-1 do begin
    Col:=ColFix ;
    Inc(Col,y1*256+x) ;    Col^:=COLOR_BORDER_INNER ;
    Inc(Col,256) ;    Col^:=COLOR_BORDER_INNER ;
    Col:=ColFix ;
    Inc(Col,(y2-1)*256+x) ;    Col^:=COLOR_BORDER_INNER ;
    Inc(Col,256) ;    Col^:=COLOR_BORDER_INNER ;
  end;
  for y := y1 to y2-1 do begin
    Col:=ColFix ;
    Inc(Col,y*256+x1) ; Col^:=COLOR_BORDER_INNER ;
    Inc(Col) ;  Col^:=COLOR_BORDER_INNER ;
    Col:=ColFix ;
    Inc(Col,y*256+x2-1) ; Col^:=COLOR_BORDER_INNER ;
    Inc(Col) ;  Col^:=COLOR_BORDER_INNER ;
  end;
except
end;
  mHGE.Texture_Unlock(Tex) ;

end;

function TMiniMap.GetColorByViewPoint(x, y:Integer): Cardinal;
var cx,cy:Integer ;
    dx,sx:Single ;
begin
  cy:=Trunc(y*(Height+1)/VHeight) ;
  dx:=Trunc(0.5*CELL_WIDTH*(VWidth/RealWidth)) ;
  sx:=x ;
  if cy mod 2 = 1 then sx:=sx+dx ;
  cx:=Trunc(sx*(Width+1)/VWidth) ;

  Result:=Colors[cx,cy] ;
  if Result=0 then Result:=Colors[cx,cy+1] ;
  if Result=0 then Result:=Colors[cx-1,cy] ;
end;

procedure TMiniMap.SetColor(i, j: Integer; color: Cardinal);
begin
  Colors[i,j]:=color ;
end;

procedure TMiniMap.SetViewWidthHeight(AVWidth, AVHeight: Integer);
begin
  VWidth:=AVWidth ;
  VHeight:=AVHeight ;
end;

procedure TMiniMap.GetXYByClickPos(viewx, viewy: Single; out mapx:Integer;
  out mapy: Integer);
begin
  mapx:=Round(viewx*(RealWidth/(VWidth))) ;
  mapy:=Round(viewy*(RealHeight/(VHeight))) ;
end;

end.