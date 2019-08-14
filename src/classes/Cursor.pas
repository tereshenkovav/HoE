unit Cursor;

interface
uses PonyAction ;

type
  TCursor = class
  private
    FIsObject:Boolean ;
    FIsWalk:Boolean ;
    FIsPonyObject:Boolean ;
    FIsSpell:Boolean ;
    _PA:TPonyAction ;
  public
    constructor Create() ;
    procedure Reset() ;
    procedure SetObject() ;
    procedure SetPonyObject() ;
    procedure SetWalk() ;
    procedure SetSpell(PA:TPonyAction) ;
    procedure Render() ;
  end;

implementation
uses ObjModule, SpriteEffects ;

{ TCursor }

constructor TCursor.Create;
begin
  Reset() ;
end;

procedure TCursor.Render;
var mx,my:Single ;
    SR:TSpriteRender ;
begin
  mHGE.Input_GetMousePos(mx,my);
  if FIsWalk then
    sprMouseWalk.Render(mx,my)
  else
  if FIsSpell then begin
    sprMouseSpell.Render(mx,my) ;
    if _PA<>nil then begin
      SR:=SRPoolActionIcons.GetRenderByTag('icon_'+_PA.Icon(BF.GetActiveObject())) ;
      if SR<>nil then begin
        SR.transp:=50 ;
        SR.RenderAt(mx+35,my+35) ;
        SR.transp:=0 ;
      end;
    end;
  end
  else
  if FIsPonyObject then
    sprMouseLookActive.Render(mx,my)
  else
  if FIsObject then
    sprMouseLook.Render(mx,my)
  else
    sprMouse.Render(mx,my) ;
  Reset() ;
end;

procedure TCursor.Reset;
begin
  FIsObject:=False ;
  FIsPonyObject:=False ;
  FIsWalk:=False ;
  FIsSpell:=False ;
  _PA:=nil ;
end;

procedure TCursor.SetObject;
begin
  FIsObject:=True ;
end;

procedure TCursor.SetPonyObject;
begin
  FIsPonyObject:=True ;
end;

procedure TCursor.SetSpell(PA:TPonyAction);
begin
  FIsSpell:=True ;
  _PA:=PA ;
end;

procedure TCursor.SetWalk;
begin
  FIsWalk:=True ;
end;

end.
