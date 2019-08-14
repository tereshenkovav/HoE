unit FFMessageList;

interface
uses MessageList ;

function FrameFuncMessageList():Boolean ;
procedure RenderMessageListDialog(XC:Integer) ;
procedure setMessageList(ML:TMessageList) ;

var
  showmessagelist:Boolean ;

implementation
uses TAVHGEUtils, HGE, HGEFont, ObjModule, FFGame ;

var
  GML:TMessageList ;
  topi:Integer ;

const
  COUNT_ON_FORM=7 ;

function CanUp():Boolean ;
begin
  Result:=(topi>0) ;
end;

function CanDown():Boolean ;
begin
  Result:=topi+COUNT_ON_FORM<GML.Count ;
end;

procedure setMessageList(ML:TMessageList) ;
begin
  showmessagelist:=True ;
  GML:=ML ;
  topi:=GML.Count-COUNT_ON_FORM ;
  if topi<0 then topi:=0 ;  
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncMessageList);
end;

procedure RenderMessageListDialog(XC:Integer) ;
var mx,my:Single ;
    i,pos:Integer ;
begin
  mHGE.Input_GetMousePos(mx,my);

  if GML.Count=0 then Exit ;

  SRDlgBack.RenderAt(0,0) ;
  SRMessageListBack.RenderAt(XC,SWindowOptions.GetYCenter) ;

  fnt2.SetColor($FF202020);
  fnt2.SetScale(0.80);
  pos:=0 ;
  for i := topi to topi+COUNT_ON_FORM-1 do begin
    if i>=GML.Count then break ;

    SRPoolIcons.GetRenderByTag(GML.getIco(i)).RenderAt(
      XC-300,110+pos*90);

    fnt2.PrintFB(XC-260,70+pos*90,
      560,1000,
      HGETEXT_CENTER,'%s',[GML.getMsg(i)]);

    Inc(pos) ;
  end;
  fnt2.SetScale(1);

  if CanUp() then SRButUp.RenderAt(XC+310,70) ;
  if CanDown() then SRButDown.RenderAt(XC+310,670) ;
end;

function FrameFuncMessageList():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE)or
     mHGE.Input_KeyDown(HGEK_ENTER)or
     mHGE.Input_KeyDown(HGEK_SPACE) then begin
    showmessagelist:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    if SRButUp.IsMouseOver(mx,my) then begin
      if CanUp() then Dec(topi) ;
      Exit ;
    end ;
    if SRButDown.IsMouseOver(mx,my) then begin
      if CanDown() then Inc(topi) ;
      Exit ;    end ;
    if SRMessageListBack.IsMouseOver(mx,my) then begin
      showmessagelist:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
      Exit ;
    end ;
  end ;
end ;

end.
