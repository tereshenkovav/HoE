unit Effects ;

{
   Изменения:

   2009.10.27
    - Добавлен класс
    TSEPause = class(TSEAbstractLinear)

   TO-DO:

   Воспроизведение цепочки эффектов в обратную сторону

}

interface
uses SpriteEffects ;

type
  TProcEffectEvent = procedure (Sender:TSpriteEffect; param:string) ;
  TFuncVelocity = function(Render:TRenderAbstract):Single ;

  TSEAbstractLinear = class(TSpriteEffect)
  private
    Tall:Single ;
    t:Single ;
  public
    constructor Create(Render:TRenderAbstract;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSEAbstractHarmonic = class(TSpriteEffect)
  private
    Tms:Integer ;
    Wper:Single ;
    Tper:Single ;
    t:Single ;
    WaitForFinish:Boolean ;
    IsReadyForFinish:Boolean ;
    procedure SetIsFinish(const Value: Boolean); override ;
    procedure ResetByT(T:Integer) ;
  public
    constructor Create(Render:TRenderAbstract;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSEPause = class(TSEAbstractLinear) ;

  TSEEvent = class(TSEAbstractLinear)
  private
    EventProc:TProcEffectEvent ;
    param:string ;
  public
    constructor Create(Render:TSpriteRender;
      AEventProc:TProcEffectEvent;Aparam:string; T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSEMovementLinear = class(TSEAbstractLinear)
  private
    x1:Single ;
    y1:Single ;
    x2:Single ;
    y2:Single ;
    sx:Single ;
    sy:Single ;
  public
    constructor Create(Render:TRenderAbstract;
      ax1,ay1,ax2,ay2:Single;T:Integer) ;
    constructor CreateDxy(Render:TRenderAbstract;
      ax1,ay1,dx,dy:Single;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSEMovementCustom = class(TSEAbstractLinear)
  private
    FuncVel:TFuncVelocity ;
    x1:Single ;
    y1:Single ;
    x2:Single ;
    y2:Single ;
    sx:Single ;
    sy:Single ;
  public
    constructor Create(Render:TSpriteRender;
      ax1,ay1,ax2,ay2:Single;AFuncVel:TFuncVelocity;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;
  
  TSERotationLinear = class(TSEAbstractLinear)
  private
    Angle1:Integer ;
    Angle2:Integer ;
    sa:Single ;
  public
    constructor Create(Render:TSpriteRender;
      AAngle1,AAngle2:Integer;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSERotationMat = class(TSEAbstractLinear)
  private
    v:Single ;
    k,m:Single ;
  public
    constructor Create(Render: TSpriteRender; Speed:Single;
      Ak,Am:Single);
    procedure Update(dt:Single) ; override ;
  end;

  TSEMovementMat = class(TSEAbstractLinear)
  private
    k,m:Single ;
    vx,vy:Single ;
    x1,y1,x2,y2:Single ;
  public
    constructor Create(Render: TSpriteRender; ax1,ay1,ax2,ay2:Single;
      Ak,Am:Single);
    procedure Update(dt:Single) ; override ;
  end;

  TSEStretchMat = class(TSEAbstractLinear)
  private
    k,m:Single ;
    v:Single ;
    scale1,scale2:Single ;
  public
    constructor Create(Render: TSpriteRender; Ascale1,Ascale2:Single;
      Ak,Am:Single);
    procedure Update(dt:Single) ; override ;
  end;

  TSERotationHarmonic = class(TSEAbstractHarmonic)
  private
    Angle1:Integer ;
    Angle2:Integer ;
    Anglestart:Integer ;
  public
    constructor Create(Render:TSpriteRender;
      AAngle1,AAngle2,AAngleStart:Integer;
      T:Integer) ;
    procedure Update(dt:Single) ; override ;
    procedure IncParam(param_n:Integer; delta:Integer) ; override ;
    function GetParamStr():string ; override ;
    function GetPackedParams():string ; override ;
    procedure SetPackedParams(Value:string) ; override ;
  end;
    
  TSETransparentLinear = class(TSEAbstractLinear)
  private
    Transp1:Integer ;
    Transp2:Integer ;
    st:Single ;
  public
    constructor Create(Render:TRenderAbstract;
      ATransp1,ATransp2:Integer;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TStretchDirection = (sdVert, sdHorz) ;
  TStretchDirections = set of TStretchDirection ;

  TMovementDirection = (mdVert, mdHorz) ;
  TMovementDirections = set of TMovementDirection ;

  TSEStretchLinear = class(TSEAbstractLinear)
  private
    Mash1:Integer ;
    Mash2:Integer ;
    Directions:TStretchDirections ;
    sm:Single ;
  public
    constructor Create(Render:TSpriteRender;
      AMash1,AMash2:Integer;ADirections:TStretchDirections;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSEBrigthnessLinear = class(TSEAbstractLinear)
  private
    Bright1:Integer ;
    Bright2:Integer ;
    sb:Single ;
  public
    constructor Create(Render:TSpriteRender;
      ABright1,ABright2:Integer;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSEBrigthnessHarmonic = class(TSEAbstractHarmonic)
  private
    BrightMin:Integer ;
    BrightMax:Integer ;
    BrightStart:Integer ;
    Fix_bright:Single ;
  public
    constructor Create(Render:TRenderAbstract;
      ABrightMin,ABrightMax,ABrightStart:Integer;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSETransparentHarmonic = class(TSEAbstractHarmonic)
  private
    TranspMin:Integer ;
    TranspMax:Integer ;
    TranspStart:Integer ;
    Fix_transp:Single ;
  public
    constructor Create(Render:TSpriteRender;
      ATranspMin,ATranspMax,ATranspStart:Integer;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSEStretchHarmonic = class(TSEAbstractHarmonic)
  private
    MashMin:Integer ;
    MashMax:Integer ;
    Directions:TStretchDirections ;
    MashStart:Integer ;
    Fix_Scalex:Single ;
    Fix_Scaley:Single ;
  public
    constructor Create(Render:TSpriteRender;
      AMashMin,AMashMax,AMashStart:Integer;
      ADirections:TStretchDirections;T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

  TSEMovementHarmonic = class(TSEAbstractHarmonic)
  private
    vmin:Integer ;
    vmax:Integer ;
    vstart:Integer ;
    Directions:TMovementDirections ;
  public
    constructor Create(Render:TSpriteRender;
      AVMin,AVMax,AVStart:Integer;ADirections:TMovementDirections;
      T:Integer) ;
    procedure Update(dt:Single) ; override ;
  end;

implementation
uses SysUtils, Classes, simple_oper ;

{ TSEAbstractLinear }

constructor TSEAbstractLinear.Create(Render: TRenderAbstract; T: Integer);
begin
  inherited Create(Render) ;
  Tall:=T/1000 ;
  t:=0 ;
end;

procedure TSEAbstractLinear.Update(dt: Single);
begin
  t:=t+dt ;
  if t>Tall then IsFinish:=True ;
end;

{ TSEAbstractHarmonic }

constructor TSEAbstractHarmonic.Create(Render: TRenderAbstract; T: Integer);
begin
  inherited Create(Render) ;
  ResetByT(T) ;
  WaitForFinish:=False ;
  IsReadyForFinish:=False ;
end;

procedure TSEAbstractHarmonic.ResetByT(T: Integer);
begin
  Tms:=T ;
  Tper:=T/1000 ;
  Wper:=2*PI/Tper ;
  t:=0 ;
end;

procedure TSEAbstractHarmonic.SetIsFinish(const Value: Boolean);
begin
  if Value then WaitForFinish:=True ;
end;

procedure TSEAbstractHarmonic.Update(dt: Single);
begin
  t:=t+dt ;

  if WaitForFinish then
    if Trunc(t/Tper)<>Trunc((t+dt)/Tper) then begin
      inherited SetIsFinish(True) ;
      IsReadyForFinish:=True ;
    end;
end;

{ TSEMovementLinear }

constructor TSEMovementLinear.Create(Render:TRenderAbstract;
  ax1, ay1, ax2, ay2: Single; T: Integer);
begin
  inherited Create(Render,T) ;
  x1:=ax1 ; y1:=ay1 ; x2:=ax2 ; y2:=ay2 ;
  sx:=(x2-x1)/Tall ; sy:=(y2-y1)/Tall ;
end;

constructor TSEMovementLinear.CreateDxy(Render: TRenderAbstract; ax1, ay1, dx,
  dy: Single; T: Integer);
begin
  Create(Render,ax1,ay1,ax1+dx,ay1+dy,T) ;
end;

procedure TSEMovementLinear.Update(dt: Single);
begin
  inherited Update(dt) ;
  _Render.x:=x1+t*sx ;
  _Render.y:=y1+t*sy ;
  if ((x1<x2)and(_Render.x>x2))or((x1>x2)and(_Render.x<x2)) then
    _Render.x:=x2 ;
  if ((y1<y2)and(_Render.y>y2))or((y1>y2)and(_Render.y<y2)) then
    _Render.y:=y2 ;
end;

{ TSEMovementCustom }

constructor TSEMovementCustom.Create(Render: TSpriteRender; ax1, ay1, ax2,
  ay2: Single; AFuncVel: TFuncVelocity; T: Integer);
begin
  inherited Create(Render,T) ;
  x1:=ax1 ; y1:=ay1 ; x2:=ax2 ; y2:=ay2 ;
  sx:=(x2-x1)/Tall ; sy:=(y2-y1)/Tall ;
  FuncVel:=AFuncVel ;
end;

procedure TSEMovementCustom.Update(dt: Single);
begin
  if t=0 then begin  _Render.x:=x1 ; _Render.y:=y1 ; end ;
  t:=t+dt ;

  _Render.x:=_Render.x+dt*sx*FuncVel(_Render) ;
  _Render.y:=_Render.y+dt*sy*FuncVel(_Render) ;
  if ((x1<x2)and(_Render.x>x2))or((x1>x2)and(_Render.x<x2)) then
    _Render.x:=x2 ;
  if ((y1<y2)and(_Render.y>y2))or((y1>y2)and(_Render.y<y2)) then
    _Render.y:=y2 ;
  if (abs(_Render.y-y2)<1)and(abs(_Render.x-x2)<1) then IsFinish:=True ;
   
end;

{ TSETransparentLinear }

constructor TSETransparentLinear.Create(Render: TRenderAbstract; ATransp1,
  ATransp2, T: Integer);
begin
  inherited Create(Render,T) ;
  Transp1:=ATransp1 ; Transp2:=ATransp2 ;
  st:=(Transp2-Transp1)/Tall ;
end;

procedure TSETransparentLinear.Update(dt: Single);
begin
  inherited Update(dt) ;
  _Render.transp:=Transp1+Round(st*t) ;
end;

{ TSEStretchLinear }

constructor TSEStretchLinear.Create(Render: TSpriteRender; AMash1,
  AMash2: Integer; ADirections: TStretchDirections; T: Integer);
begin
  inherited Create(Render,T) ;
  Mash1:=AMash1 ; Mash2:=AMash2 ; sm:=(Mash2-Mash1)/Tall ;
  Directions:=ADirections ;
end;

procedure TSEStretchLinear.Update(dt: Single);
var scale:Single ;
begin
  inherited Update(dt);
  scale:=Mash1+sm*t ;
  if ((Mash1<Mash2)and(scale>Mash2))or((Mash1>Mash2)and(scale<Mash2)) then
    scale:=Mash2 ;
  if sdHorz in Directions then _Render.scalex:=scale ;
  if sdVert in Directions then _Render.scaley:=scale ;
end;

{ TSERotationLinear }

constructor TSERotationLinear.Create(Render: TSpriteRender; AAngle1, AAngle2,
  T: Integer);
begin
  inherited Create(Render,T) ;
  Angle1:=AAngle1 ; Angle2:=AAngle2 ;
  sa:=(Angle2-Angle1)/Tall ;
end;

procedure TSERotationLinear.Update(dt: Single);
begin
  inherited Update(dt) ;
  _Render.angle:=Angle1+Round(sa*t) ;
end;

{ TSERotationMat }

constructor TSERotationMat.Create(Render: TSpriteRender; Speed:Single;
  Ak,Am:Single);
begin
  inherited Create(Render,1000) ;
  v:=Speed ;
  k:=Ak ; m:=Am ;
end;

procedure TSERotationMat.Update(dt: Single);
begin
  //inherited Update(dt) ;
  _Render.angle:=_Render.angle+v*dt ;
  v:=v+(-k*_Render.angle-m*v)*dt ;
  if (abs(v)<2)and(abs(_Render.angle)<2) then IsFinish:=True ;
  
end;

{ TSEMovementMat }

constructor TSEMovementMat.Create(Render: TSpriteRender; ax1, ay1, ax2, ay2, Ak,
  Am: Single);
begin
  inherited Create(Render,1000) ;
  x1:=ax1 ; y1:=ay1 ; x2:=ax2 ; y2:=ay2 ;
  k:=Ak ; m:=Am ;
  vx:=0 ; vy:=0 ;
  _Render.x:=x1 ;  _Render.y:=y1 ;
end;

procedure TSEMovementMat.Update(dt: Single);
begin
  //inherited Update(dt) ;
  _Render.x:=_Render.x+vx*dt ;
  _Render.y:=_Render.y+vy*dt ;
  vx:=vx+(-k*(x2-_Render.x)-m*vx)*dt ;
  vy:=vy+(-k*(y2-_Render.y)-m*vy)*dt ;
  if (abs(vx)<2)and(abs(vx)<2)and
     (abs(_Render.x-x2)<2)and(abs(_Render.y-y2)<2) then IsFinish:=True ;
end;


{ TSEStretchMat }

constructor TSEStretchMat.Create(Render: TSpriteRender; Ascale1, Ascale2, Ak,
  Am: Single);
begin
  inherited Create(Render,1000) ;
  scale1:=Ascale1 ; scale2:=Ascale2 ;
  k:=Ak ; m:=Am ;
  v:=0 ;
  _Render.scalex:=scale1 ;  _Render.scaley:=scale1 ;
end;

procedure TSEStretchMat.Update(dt: Single);
begin
  //inherited Update(dt);
  _Render.scalex:=_Render.scalex+v*dt ;
  _Render.scaley:=_Render.scaley+v*dt ;
  v:=v+(k*(scale2-_Render.scalex)-m*v)*dt ;
  if (abs(v)<2)and(abs(_Render.scalex-scale2)<2) then IsFinish:=True ;
end;

{ TSEBrigthnessLinear }

constructor TSEBrigthnessLinear.Create(Render: TSpriteRender; ABright1,
  ABright2, T: Integer);
begin
  inherited Create(Render,T) ;
  Bright1:=ABright1 ; Bright2:=ABright2 ;
  sb:=(Bright2-Bright1)/Tall ;
end;

procedure TSEBrigthnessLinear.Update(dt: Single);
begin
  inherited Update(dt) ;
  _Render.bright:=Bright1+sb*t ;
end;

{ TSEBrigthnessHarmonic }

constructor TSEBrigthnessHarmonic.Create(Render: TRenderAbstract; ABrightMin,
  ABrightMax, ABrightStart, T: Integer);
begin
  inherited Create(Render,T) ;
  BrightMin:=ABrightMin ;  BrightMax:=ABrightMax ;  BrightStart:=ABrightStart ;
  Fix_bright:=_Render.bright ;
end;

procedure TSEBrigthnessHarmonic.Update(dt: Single);
begin
  inherited Update(dt);
  _Render.bright:=BrightMin+0.5*(BrightMax-BrightMin)*
    (1+Sin(Wper*t-PI/2)) ;

  if IsReadyForFinish then _Render.bright:=Fix_bright ;
end;

{ TSEStretchHarmonic }

constructor TSEStretchHarmonic.Create(Render: TSpriteRender; AMashMin, AMashMax,
  AMashStart:Integer; ADirections:TStretchDirections; T: Integer);
begin
  inherited Create(Render,T) ;
  MashMin:=AMashMin ;  MashMax:=AMashMax ;  MashStart:=AMashStart ;
  Directions:=ADirections ;
  Fix_Scalex:=_Render.scalex ;  Fix_Scaley:=_Render.scaley ;
end;

procedure TSEStretchHarmonic.Update(dt: Single);
var scale:Single ;
begin
  inherited Update(dt);

  scale:=MashMin+0.5*(MashMax-MashMin)*(1+Sin(Wper*t-PI/2)) ; ;
  if sdHorz in Directions then _Render.scalex:=scale ;
  if sdVert in Directions then _Render.scaley:=scale ;

  if IsReadyForFinish then begin
    if sdHorz in Directions then _Render.scalex:=Fix_Scalex ;
    if sdVert in Directions then _Render.scaley:=Fix_Scaley ;    
  end;
end;

{ TSEMovementHarmonic }

constructor TSEMovementHarmonic.Create(Render: TSpriteRender; AVMin, AVMax,
  AVStart:Integer; ADirections:TMovementDirections; T: Integer);
begin
  inherited Create(Render,T) ;
  VMin:=AVMin ;  VMax:=AVMax ;  VStart:=AVStart ;
  Directions:=ADirections ;
end;

procedure TSEMovementHarmonic.Update(dt: Single);
var V:Single ;
begin
  inherited Update(dt);

  V:=VMin+0.5*(VMax-VMin)*(1+Sin(Wper*t-PI/2+(PI*(VStart-VMax)/(VMax-VMin)))) ; ;

  if mdVert in Directions then _Render.Y:=V ;
  if mdHorz in Directions then _Render.X:=V ;  
end;

{ TSETransparentHarmonic }

constructor TSETransparentHarmonic.Create(Render: TSpriteRender; ATranspMin,
  ATranspMax, ATranspStart, T: Integer);
begin
  inherited Create(Render,T) ;
  TranspMin:=ATranspMin ;  TranspMax:=ATranspMax ;  TranspStart:=ATranspStart ;
  Fix_transp:=_Render.Transp ;
end;

procedure TSETransparentHarmonic.Update(dt: Single);
begin
  inherited Update(dt);
  _Render.Transp:=TranspMin+0.5*(TranspMax-TranspMin)*
    (1+Sin(Wper*t-PI/2)) ;

  if IsReadyForFinish then _Render.Transp:=Fix_transp ;
end;

{ TSERotationHarmonic }

constructor TSERotationHarmonic.Create(Render: TSpriteRender; AAngle1, AAngle2,
  AAngleStart, T: Integer);
begin
  inherited Create(Render,T) ;
  Angle1:=AAngle1 ; Angle2:=AAngle2 ; Anglestart:=AAnglestart ;
end;

procedure TSERotationHarmonic.Update(dt: Single);
begin
  inherited Update(dt);

  _Render.angle:=Angle1+0.5*(Angle2-Angle1)*
    (1+Sin(Wper*t-PI/2)) ;

end;

function TSERotationHarmonic.GetParamStr: string;
begin
  Result:=Format('T=%d ms, A1=%d, A2=%d',[Tms,Angle1,Angle2]) ;
end;

procedure TSERotationHarmonic.IncParam(param_n, delta: Integer);
begin
  case param_n of
    0: begin  Tms:=Tms+100*delta ; ResetByT(Tms) ; end;
    1: begin  Angle1:=Angle1+5*delta ; ResetByT(Tms) ; end;
    2: begin  Angle2:=Angle2+5*delta ; ResetByT(Tms) ; end;
  end;
end;

procedure TSERotationHarmonic.SetPackedParams(Value: string);
begin
  if Value='' then Exit ;

  with TStringList.Create() do begin
    CommaText:=HexToStr(Value) ;
    Tms:=StrToIntWt0(Values['TMS']) ;
    Angle1:=StrToIntWt0(Values['ANGLE1']) ;
    Angle2:=StrToIntWt0(Values['ANGLE2']) ;
    Free ;
  end;

  ResetByT(Tms) ;
end;

function TSERotationHarmonic.GetPackedParams: string;
begin
  with TStringList.Create() do begin
    Values['TMS']:=IntToStr(Tms) ;
    Values['ANGLE1']:=IntToStr(Angle1) ;
    Values['ANGLE2']:=IntToStr(Angle2) ;
    Result:=StrToHex(CommaText) ;
    Free ;
  end;
end;

{ TSEEvent }

constructor TSEEvent.Create(Render: TSpriteRender; AEventProc: TProcEffectEvent;
  Aparam:string; T: Integer);
begin
  inherited Create(Render,T) ;
  EventProc:=AEventProc ;
  param:=Aparam ;
end;

procedure TSEEvent.Update(dt: Single);
begin
  if t=0 then EventProc(Self,param) ;
  inherited Update(dt);
end;

end.
