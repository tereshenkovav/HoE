unit EffectsMacro ;

interface
uses SpriteEffects, Effects, ListInt ;

type
  TStretchSeq = class
  private
    LI:TListInt ;
  public
    constructor Create(PackedStr:string) ;
    destructor Destroy ; override ;
    function Count():Integer ;
    function GetScale(i:Integer):Integer ;
    function GetTime(i:Integer):Integer ;    
  end ;

procedure AddStretchSeq(SEPool:TSpriteEffectPool;
  SR:TSpriteRender; SD: TStretchDirections; SS:TStretchSeq; 
  NextEffect:TSpriteEffect=nil) ;

procedure AddRenderBlink(SEPool:TSpriteEffectPool;
  SR:TSpriteRender; brstart,brmax,fulltime:Integer) ;

implementation

procedure AddStretchSeq(SEPool:TSpriteEffectPool; 
  SR:TSpriteRender; SD: TStretchDirections; SS:TStretchSeq; 
  NextEffect:TSpriteEffect=nil) ;
var i:Integer ;
    arrE:array[0..255] of TSpriteEffect ;
begin
  for i:=0 to SS.Count-2 do
    arrE[i]:=TSEStretchLinear.Create(SR,SS.GetScale(i),SS.GetScale(i+1),SD,SS.GetTime(i)) ;

  for i:=0 to SS.Count-3 do
    SEPool.AddEffect(arrE[i],arrE[i+1]) ;

  if NextEffect<>nil then 
    SEPool.AddEffect(arrE[SS.Count-2],NextEffect) ;
end ;

procedure AddRenderBlink(SEPool:TSpriteEffectPool;
  SR:TSpriteRender; brstart,brmax,fulltime:Integer) ;
begin
  SEPool.AddEffect(
    TSEBrigthnessLinear.Create(SR,brstart,brmax,fulltime div 2),
    TSEBrigthnessLinear.Create(SR,brmax,brstart,fulltime div 2)) ;
end ;

{ TStretchSeq }

constructor TStretchSeq.Create(PackedStr: string);
begin
  LI:=TListInt.Create(PackedStr) ;
end;

destructor TStretchSeq.Destroy;
begin
  LI.Free ;
  inherited;
end;

function TStretchSeq.Count: Integer;
begin  Result:=LI.Count div 2 ; end;

function TStretchSeq.GetScale(i: Integer): Integer;
begin  Result:=LI[2*i] ; end;

function TStretchSeq.GetTime(i: Integer): Integer;
begin  Result:=LI[2*i+1] ; end;

end.