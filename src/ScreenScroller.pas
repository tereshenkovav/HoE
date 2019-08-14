unit ScreenScroller;

interface

function IsScreenScrolled(out dx:Integer; out dy:Integer; out mspeed:Single):Boolean ;
procedure initScreenScroller() ;

implementation
uses Windows, ObjModule, HGE, Editor ;

var
   WinHandle:THandle  ;

function IsScreenScrolled(out dx:Integer; out dy:Integer; out mspeed:Single):Boolean ;
var
    CurPoint:TPoint ;
    WinRect:TRect ;
    flagleft,flagright,flagup,flagdown:Boolean ;
    fullscr:Boolean ;
begin
  mspeed:=0.66 ;

  if WinHandle<>0 then
    if GetCursorPos(CurPoint) then
      if GetWindowRect(WinHandle,WinRect) then begin
      fullscr:=not mHGE.System_GetState(HGE_WINDOWED) ;
      flagleft:=CurPoint.X<=WinRect.Left ;
      if fullscr then
        flagright:=abs(CurPoint.X-WinRect.Right)=1 
      else
        flagright:=CurPoint.X>=WinRect.Right ;
      flagup:=CurPoint.Y<=WinRect.Top ;
      if fullscr then
        flagdown:=abs(CurPoint.Y-WinRect.Bottom)=1
      else
        flagdown:=CurPoint.Y>=WinRect.Bottom ;
      if PL.IsFastMouse then
        if flagleft or flagright or flagup or flagdown then mspeed:=1 ;
      end ;

  dx:=0 ;
  dy:=0 ;
  if mHGE.Input_GetKeyState(HGEK_LEFT) or
     (mHGE.Input_GetKeyState(HGEK_A) and not InEditMode()) then begin
       dx:=-1 ;
       if PL.IsFastKeyboard then mspeed:=1 ;
     end;
  if mHGE.Input_GetKeyState(HGEK_RIGHT) or
     (mHGE.Input_GetKeyState(HGEK_D) and not InEditMode()) then begin
       dx:=1 ;
       if PL.IsFastKeyboard then mspeed:=1 ;
     end;
  if mHGE.Input_GetKeyState(HGEK_UP) or
     (mHGE.Input_GetKeyState(HGEK_W) and not InEditMode()) then begin
       dy:=-1 ;
       if PL.IsFastKeyboard then mspeed:=1 ;
     end;
  if mHGE.Input_GetKeyState(HGEK_DOWN) or
     (mHGE.Input_GetKeyState(HGEK_S) and not InEditMode()) then begin
       dy:=1 ;
       if PL.IsFastKeyboard then mspeed:=1 ;
     end;

  if flagleft then dx:=-1 ;
  if flagright then dx:=1 ;
  if flagup then dy:=-1 ;
  if flagdown then dy:=1 ;

  Result:=(dx<>0)or(dy<>0) ;

end;

procedure initScreenScroller() ;
begin
  WinHandle:=FindWindow(nil,'Герои Эквестрии') ;
end ;

end.
