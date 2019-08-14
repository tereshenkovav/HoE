unit TAVHGEUtils ;

interface
uses HGESprite, HGE, WindowOptions, Windows, SpriteEffects ;

type
  TCaliberRes = (crRealSize,cr2powNSize) ;
  TfuncTagTransform = function(tag:string):string ;

procedure SetPathForLoader(Path:string) ;  
function LoadSizedSprite(mHGE:IHGE; FileName:string):THGESprite ;
function LoadAndCenteredSizedSprite(mHGE:IHGE; FileName:string):THGESprite ;
procedure SetGlobalWindowOptions(AWO:TWindowOptions) ;
procedure RenderSpriteMashed(Spr:IHGESprite; x,y:Integer) ; overload ;
procedure RenderSpriteMashed(Spr:IHGESprite; P:TPoint) ; overload ;
procedure RenderSpriteMashedMirroredScale(Spr:IHGESprite; P:TPoint; scale:Single) ; overload ;
procedure RenderSpriteMashedMirroredScale(Spr:IHGESprite; x,y:Integer; scale:Single) ; overload ;
procedure SetSpriteTransparent(Spr:IHGESprite; Transp:Single) ;
function GetTextureAlphaByXY(mHGE:IHGE; Tex:ITexture; const x,y:Integer;
  const Caliber:TCaliberRes):Byte ;
function SetTextureAlphaByXY(mHGE:IHGE; Tex:ITexture; const x,y:Integer;
  const Alpha:Byte; const Caliber:TCaliberRes):Byte ;  
function DoCalibrateHGELocker(mHGE:IHGE; var CaliberRes:TCaliberRes):Boolean ;
procedure SetFuncsAndRun(mHGE:IHGE; const FrameFunc,RenderFunc:THGECallback) ;
procedure SetFuncsNoRun(mHGE:IHGE; const FrameFunc,RenderFunc:THGECallback) ;
function InvertColor(Color:LongWord):LongWord ;
procedure LoadFilesToSRPool(SRPool:TSpriteRenderPool; mask:string; subpath:string='';
  tagTransform:TfuncTagTransform=nil) ;

var
  GCaliber:TCaliberRes ;
  mHGE:IHGE ;

  PathLoader:string ;

  WO:TWindowOptions ;

implementation
uses SysUtils, Math, UnitFileSys, Classes, simple_files ;

procedure SetPathForLoader(Path:string) ;
begin
  PathLoader:=Path ;
end;

function LoadSizedSprite(mHGE:IHGE; FileName:string):THGESprite ;
var Tex:ITexture ;
    fullname:string ;
begin
  fullname:=PathLoader+FileName ;
  if not FileExists(fullname) then begin
    MessageBox(0,Pchar('Файл '+fullname+' не найден!'),Pchar('Ошибка!'),MB_OK) ;
    Exit ;
  end;

  Tex:=mHGE.Texture_Load(fullname) ;
  Result:=THGESprite.Create(Tex,
    0,0,Tex.GetWidth(True),Tex.GetHeight(True)) ;
end;

function LoadAndCenteredSizedSprite(mHGE:IHGE; FileName:string):THGESprite ;
begin
  Result:=LoadSizedSprite(mHGE,FileName) ;
  IHGESprite(Result).SetHotSpot(
    IHGESprite(Result).GetWidth()/2,IHGESprite(Result).GetHeight()/2) ;
end;

procedure SetGlobalWindowOptions(AWO:TWindowOptions) ;
begin
  WO:=AWO ;
end ;

procedure RenderSpriteMashed(Spr:IHGESprite; x,y:Integer) ;
begin
  Spr.RenderStretch(WO.GetMashX()*x,WO.GetMashY()*y,
    WO.GetMashX()*(x+Spr.GetWidth()),WO.GetMashY()*(y+Spr.GetHeight())) ;
end ;

procedure RenderSpriteMashed(Spr:IHGESprite; P:TPoint) ;
begin
  RenderSpriteMashed(Spr,P.x,P.y) ;
end ;

procedure RenderSpriteMashedMirroredScale(Spr:IHGESprite; P:TPoint; scale:Single) ;
begin
  RenderSpriteMashedMirroredScale(Spr,P.x,P.y,scale) ;
end ;

procedure RenderSpriteMashedMirroredScale(Spr:IHGESprite; x,y:Integer; scale:Single) ;
var x1,y1,x2,y2:Single ;
begin
  x1:=WO.GetMashX()*x ;
  y1:=WO.GetMashY()*y ;
  x2:=WO.GetMashX()*(x+scale*Spr.GetWidth()) ;
  y2:=WO.GetMashY()*(y+scale*Spr.GetHeight()) ;
  Spr.Render4V(x2,y1, x1,y1, x1,y2, x2,y2) ;
end;

procedure SetSpriteTransparent(Spr:IHGESprite; Transp:Single) ;
var d:Single ;
    b:Byte ;
begin
  d:=High(Byte)*Transp ;
  if d>High(Byte) then b:=High(Byte) else b:=Round(d) ;
  Spr.SetColor($FFFFFF+(b shl 24)) ;
end;

function GetTextureAlphaByXY(mHGE:IHGE; Tex:ITexture; const x,y:Integer;
  const Caliber:TCaliberRes):Byte ;
var Col:PLongWord ;
    mx,my:Integer ;
    smax:Integer ;
begin

  if Caliber=crRealSize then begin
    mx:=Tex.GetWidth(True) ;
    my:=Tex.GetHeight(True) ;
  end ;

  if Caliber=cr2powNSize then begin
    smax:=max(Tex.GetWidth(True),Tex.GetHeight(True)) ;

    // Получение минимального подходящего размера степени двойки
    mx:=1 ;
    repeat
      mx:=mx*2 ;
    until mx>=smax ;

    my:=mx ;
  end ;

  Col:=mHGE.Texture_Lock(Tex,True,0,0,mx,my) ;
  Inc(Col,y*mx+x) ;
  Result:=(Col^ shr 24 and $FF) ;

  mHGE.Texture_Unlock(Tex) ;

end;

function SetTextureAlphaByXY(mHGE:IHGE; Tex:ITexture; const x,y:Integer;
  const Alpha:Byte; const Caliber:TCaliberRes):Byte ;
var Col,ColFix:PLongWord ;
    mx,my:Integer ;
    smax:Integer ;
    dx,dy:Integer ;
begin

  if Caliber=crRealSize then begin
    mx:=Tex.GetWidth(True) ;
    my:=Tex.GetHeight(True) ;
  end ;

  if Caliber=cr2powNSize then begin
    smax:=max(Tex.GetWidth(True),Tex.GetHeight(True)) ;

    // Получение минимального подходящего размера степени двойки
    mx:=1 ;
    repeat
      mx:=mx*2 ;
    until mx>=smax ;

    my:=mx ;
  end ;

  ColFix:=mHGE.Texture_Lock(Tex,False,0,0,mx,my) ;
  for dx := -10 to 10 do
    for dy := -10 to 10 do begin
      if dx*dx+dy*dy>10*10 then Continue ;
      
      Col:=ColFix ;
      Inc(Col,(y+dy)*mx+(x+dx)) ;
      Col^:=$00000000 ;
    end;
  //Result:=(Col^ shr 24 and $FF) ;

  mHGE.Texture_Unlock(Tex) ;

end;

function DoCalibrateHGELocker(mHGE:IHGE; var CaliberRes:TCaliberRes):Boolean ;
var TexEtalon:ITexture ;
    Col:PLongWord ;
    i:Integer ;
begin
  Result:=False ;

  try

  TexEtalon:=mHGE.Texture_Load('etalon.png') ;

  Col:=mHGE.Texture_Lock(TexEtalon,True,0,0,4,4) ;

  Inc(Col,8) ;
  if (Col^ and $FFFFFFFF)=$FFFFFFFF then begin
    CaliberRes:=crRealSize ;
    Result:=True ;
  end ;

  Inc(Col,2) ;
  if (Col^ and $FFFFFFFF)=$FFFFFFFF then begin
    CaliberRes:=cr2powNSize ;
    Result:=True ;
  end ;

  mHGE.Texture_Unlock(TexEtalon) ;

  except
    on E:Exception do begin
      Result:=False ;
    end;
  end;

  if Result then GCaliber:=CaliberRes ;
end;


procedure SetFuncsAndRun(mHGE:IHGE; const FrameFunc,RenderFunc:THGECallback) ;
begin
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFunc);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFunc);
  mHGE.System_Start;
end ;

procedure SetFuncsNoRun(mHGE:IHGE; const FrameFunc,RenderFunc:THGECallback) ;
begin
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFunc);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFunc);
end ;

function InvertColor(Color:LongWord):LongWord ;
begin
  Result:=0 ;
  Result:=Result+(((Color shr 0) and $FF) shl 16) and $FF0000 ;
  Result:=Result+(((Color shr 8) and $FF) shl 8) and $00FF00 ;
  Result:=Result+(((Color shr 16) and $FF) shl 0) and $0000FF ;
end ;

procedure LoadFilesToSRPool(SRPool:TSpriteRenderPool; mask:string;
  subpath:string=''; tagTransform:TfuncTagTransform=nil) ;
var List:TStringList ;
    IsOk:Boolean ;
    i:Integer ;
    OldPath:string ;
    tag:string ;
    imagefilename:string ;
    using_aliases:Boolean ;
begin
  if subpath<>'' then begin
    OldPath:=PathLoader ;
    PathLoader:=PathLoader+subpath+'\' ;
  end;

  using_aliases:=FileExists(PathLoader+'.aliases') ;

  List:=CreateFilesList(PathLoader,Mask,IsOk) ;
  for i := 0 to List.Count - 1 do begin
    tag:=NameWithoutExt(OnlyFile(List[i])) ;

    imagefilename:=List[i] ;
    if (tag[Length(tag)]='@')and(using_aliases) then begin
      tag:=Copy(tag,1,Length(tag)-1) ;
      with TStringList.Create() do begin
        LoadFromFile(PathLoader+imagefilename) ;
        imagefilename:=Values['filename'] ;
        Free ;
      end;
    end;

    if Assigned(tagTransform) then tag:=tagTransform(tag) ;

    SRPool.AddRenderTagged(TSpriteRender.Create(
      LoadAndCenteredSizedSprite(mHGE,imagefilename)),
      tag);
  end;
  List.Free ;

  if subpath<>'' then PathLoader:=OldPath ;
end;

end.