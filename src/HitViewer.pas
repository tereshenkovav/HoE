unit HitViewer;

interface
uses Windows, AutoCreatedSubList, SpriteEffects, HGEFont, FontHolder,
  BattleField, StaticText ;

type
  THitStyle = (hsGood,hsBad,hsEnergy,hsOnShield) ;

  THitMsg=class
    x:Integer ;
    y:Integer ;
    msg:string ;
    style:THitStyle ;
    function GetColor():Cardinal ;   
  end;

  THitViewer = class(TACObjectList)
  private
    FRHit:TFontRender ;
    SRHitBack:TSpriteRender ;
    HitText:TStaticText ;
    fntHit:IHGEFont ;
    FixHitPos:TPoint ;
    IsModified:Boolean ;
    function GetHM(i:Integer):THitMsg ;
  public
    constructor Create() ;
    procedure Render() ;
    function IsHitPopup():Boolean ;
    procedure AddNewHit(hitcell:TCell; hitstyle:THitStyle; hitvalue:Integer) ; overload ;
    procedure AddNewHit(hitcell:TCell; hitstyle:THitStyle; hitvalue:string) ; overload ;
  end ;

implementation
uses Classes, SysUtils, ObjModule, Effects, TAVHGEUtils, Constants, PonyUnits ;

{ THitViewer }

procedure THitViewer.AddNewHit(hitcell: TCell; hitstyle: THitStyle;
  hitvalue: Integer);
var str:string ;
begin
  str:=IntToStr(hitvalue) ;
  if hitvalue>0 then str:='+'+str ;

  AddNewHit(hitcell,hitstyle,str) ;
end;

procedure THitViewer.AddNewHit(hitcell: TCell; hitstyle: THitStyle;
  hitvalue: string);
var hm:THitMsg ;
begin
  hm:=THitMsg.Create ;
  hm.x:=hitcell.XC ;
  hm.y:=hitcell.YC ;
  hm.msg:=hitvalue ;
  hm.style:=hitstyle ;
  if hitstyle=hsBad then
    if hitcell.IsPonyUnit() then
      if TPonyUnit(hitcell._Object).IsShield() then
        hm.style:=hsOnShield ;

  List.Add(hm) ;
  IsModified:=True ;
end;

constructor THitViewer.Create;
begin
  inherited Create ;
  fntHit:=THGEFont.Create('..\fonts\Nubers.fnt');
  HitText:=TStaticText.Create('') ;
  FRHit:=TFontRender.Create(TFontHolder.Create(fntHit,HitText),0,0) ;
  FRHit.transp:=100 ;
  SRHitBack:=TSpriteRender.Create(LoadSizedSprite(mHGE,'hit_back.png'));

  IsModified:=False ;
end;

function THitViewer.GetHM(i: Integer): THitMsg;
begin
  Result:=THitMsg(List[i]) ;
end;

function THitViewer.IsHitPopup: Boolean;
begin
  Result:=List.Count>0 ;
end;

procedure THitViewer.Render;
var x,y:Integer ;
    tmp_x,tmp_y:Single ;
    i:Integer ;
begin
  if IsModified then begin
    if List.Count>0 then begin

      x:=GetHM(0).x ;
      y:=GetHM(0).y ;
   FixHitPos.x:=x ;
   FixHitPos.y:=y ;
   FRHit.x:=x ;
   FRHit.y:=y ;
   FRHit.transp:=0 ;
   FRHit.color:=GetHM(0).GetColor() ;
   HitText.Text:=GetHM(0).msg ;
   SRHitBack.x:=x ;
   SRHitBack.y:=y ;
   SRHitBack.transp:=0 ;
   SEPool.AddEffect(TSEMovementLinear.CreateDxy(FRHit,
     FRHit.x,FRHit.y,0,-150,800),
     TSETransparentLinear.Create(FRhit,0,100,800)) ;
   SEPool.AddEffect(TSEMovementLinear.CreateDxy(SRHitBack,
     SRHitBack.x,SRHitBack.y,0,-150,800),
     TSETransparentLinear.Create(SRHitBack,0,100,800)) ;
    end;
   IsModified:=False ;  
  end;

  if List.Count=0 then Exit ;

  if List.Count=1 then begin
    SRHitBack.Render ;
    FRHit.Render ;
  end
  else
    for i := 0 to List.Count - 1 do begin
      tmp_x:=SRHitBack.x ;
      tmp_y:=SRHitBack.y ;
      HitText.Text:=GetHM(i).msg ;
      SRHitBack.RenderAt(GetHM(i).X,
        GetHM(i).Y+(SRHitBack.y-FixHitPos.Y)) ;
      FRHit.color:=GetHM(i).GetColor() ;
      FRHit.RenderAt(GetHM(i).X,
        GetHM(i).Y+(FRHit.y-FixHitPos.Y)) ; ;
      SRHitBack.SetXY(tmp_x,tmp_y);
      FRHit.SetXY(tmp_x,tmp_y);
    end;

    if not(SEPool.IsEffectExist(TSEMovementLinear,SRHitBack) or
    SEPool.IsEffectExist(TSETransparentLinear,SRHitBack)) then
      List.Clear ;
end;

{ THitMsg }

function THitMsg.GetColor: Cardinal;
begin
  case style of
    hsGood: Result:=COLOR_GOOD_ATTACK ;
    hsBad: Result:=COLOR_BAD_ATTACK ;
    hsEnergy: Result:=COLOR_ENERGY_INC ;
    hsOnShield: Result:=COLOR_ON_SHIELD ;
  end;
end;

end.
