unit MultiObjRender;

interface
uses SpriteEffects ;

type
  TMultiObjRender = class
  private
    arr:array[0..15] of TSpriteRender ;
    cnt:Integer ;
  public
    constructor Create ;
    procedure Add(SR:TSpriteRender) ;
    procedure RenderAt(x,y:Integer; R:Integer) ;
  end;

implementation

{ TMultiObjRender }

procedure TMultiObjRender.Add(SR: TSpriteRender);
begin
  arr[cnt]:=SR ;
  Inc(cnt) ;
end;

constructor TMultiObjRender.Create;
begin
  cnt:=0 ;
end;

procedure TMultiObjRender.RenderAt(x, y, R: Integer);
var i:Integer ;
    A:Single ;
begin
  if cnt=0 then Exit ;

  if cnt=1 then
    arr[0].RenderAt(x,y)
  else
    for i := 0 to cnt - 1 do begin
      A:=3.14/2+6.28*(i/cnt) ;
      arr[i].RenderAt(x+R*Cos(A),y+R*Sin(A));
    end;


end;

end.
