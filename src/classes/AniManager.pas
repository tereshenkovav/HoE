unit AniManager;

interface
uses AutoCreatedSubList, SpriteEffects, HGEAnim ;

type
  TAniManager = class(TACObjectList)
  private
  public
    class function OnlyCreateSprite(FileName:string; Frames,FPS:Integer; x,y,w,h:Integer;
      xc:Integer; yc:Integer; var ani:IHGEAnimation):TSpriteRender ;
    function CreateSprite(FileName:string; Frames,FPS:Integer; x,y,w,h:Integer;
      xc:Integer=-1; yc:Integer=-1):TSpriteRender ;
    function GetLastAnim():IHGEAnimation ;
    procedure UpdateAll(dt:Single) ;
  end;

implementation
uses HGE, TAVHGEUtils ;

{ TAniManager }

// Дублирование!!!
function TAniManager.CreateSprite(FileName: string; Frames, FPS, x, y, w, h,
  xc,yc: Integer): TSpriteRender;
var Tex:ITexture ;
    Anim:IHGEAnimation ;
begin
  Tex:=mHGE.Texture_Load(FileName) ;
  Anim:=THGEAnimation.Create(Tex,Frames,FPS,x,y,w,h) ;
  Anim.Play ;
  if (xc=-1) then xc:=w div 2 ;
  if (yc=-1) then yc:=h div 2 ;
  Anim.SetHotSpot(xc,yc);
  List.Add(Anim.Implementor) ;
  Result:=TSpriteRender.Create(Anim) ;
end;

class function TAniManager.OnlyCreateSprite(FileName: string; Frames, FPS, x, y, w, h,
  xc,yc: Integer; var ani:IHGEAnimation): TSpriteRender;
var Tex:ITexture ;
    Anim:IHGEAnimation ;
begin
  Tex:=mHGE.Texture_Load(FileName) ;
  Anim:=THGEAnimation.Create(Tex,Frames,FPS,x,y,w,h) ;
  Anim.Play ;
  if (xc=-1) then xc:=w div 2 ;
  if (yc=-1) then yc:=h div 2 ;
  Anim.SetHotSpot(xc,yc);
  Result:=TSpriteRender.Create(Anim) ;
  ani:=Anim ;//THGEAnimation(Anim.Implementor) ;
end;

function TAniManager.GetLastAnim: IHGEAnimation;
begin
  Result:=(THGEAnimation(List[List.Count-1]) as IHGEAnimation) ;
end;

procedure TAniManager.UpdateAll(dt: Single);
var i:Integer ;
begin
  for i := 0 to List.Count - 1 do
    (THGEAnimation(List[i]) as IHGEAnimation).Update(dt) ;
end;

end.
