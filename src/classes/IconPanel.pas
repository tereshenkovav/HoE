unit IconPanel;

interface
uses SpriteEffects ;

type
  TIconPanel = class
  private
    FClicked:Boolean ;
    ActiveIdx:Integer ;
    SRIndicator:TSpriteRender ;
    SRPonyIconBack:TSpriteRender ;
    RenderedCount:Integer ;
    procedure RenderIndicator(i:Integer; color:Cardinal; transp:Integer;
      value:Integer; posxdelta:Integer) ;
  public
    constructor Create() ;
    procedure Render() ;
    procedure Update(dt:Single) ;
    function IsOverPanel(mx,my:Single):Boolean ;
    function IsNoStepActionsYet():Boolean ;
  end;

implementation
uses ObjModule, Classes, PonyUnits, BattleField, simple_oper, HGE, HGEFont,
  TAVHGEUtils ;

var
  ListMonsterStep:TCellListNoOwn=nil ;
  tfix:Single ;
  
{ TIconPanel }

function GetPonyIconPosX(i:Integer):Integer ;
begin
  Result:=SWindowOptions.Width-50-90*i ;
end ;

function GetPonyIconPosY(i:Integer):Integer ;
begin
  Result:=43 ;
end ;

procedure TIconPanel.RenderIndicator(i:Integer; color:Cardinal; transp:Integer; value:Integer;
  posxdelta:Integer) ;
begin
  SRIndicator.color:=color ;
  SRIndicator.transp:=transp ;
  SRIndicator.scaley:=value ;
  SRIndicator.RenderAt(GetPonyIconPosX(i)+posxdelta,
    GetPonyIconPosY(i)-33+Round(SRIndicator.GetSprite.GetHeight*
      (1-(value/100)))) ;
end ;

constructor TIconPanel.Create;
begin
  SRIndicator:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'indicator.png')) ;
  SRPonyIconBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'ponyicon_back.png')) ;
  with BF.GetPonyList() do begin
    RenderedCount:=Count ;
    Free ;
  end;
end;

function TIconPanel.IsOverPanel(mx,my:Single): Boolean;
begin
  Result:=(my<GetPonyIconPosY(RenderedCount-1)+SRPonyIconBack.GetSprite.GetHeight/2)and
  (mx>GetPonyIconPosX(RenderedCount-1)-SRPonyIconBack.GetSprite.GetWidth/2) ;
end;

function TIconPanel.IsNoStepActionsYet():Boolean ;
var i:Integer ;
begin
  Result:=True ;
  for i := 0 to BF.CellCount-1 do
    if BF.GetCell(i).IsPonyUnit then
      if not(TPonyUnit(BF.GetCell(i)._Object).IsCanAction() and
         TPonyUnit(BF.GetCell(i)._Object).IsNoMakeStepWithEnergy()) then begin
           Result:=False ;
           Exit ;
      end;
end;

procedure TIconPanel.Render;
var i,j:Integer ;
    ListPony:TStringList ;
    PonyCell:TCell ;
    mx,my:Single ;
    perc:Integer ;
begin
  ActiveIdx:=-1 ;
  mHGE.Input_GetMousePos(mx,my);

  if ListMonsterStep=nil then begin
    ListMonsterStep:=BF.CreateMonsterStepsCellList()
  end
  else begin
    if mHGE.Timer_GetTime-tfix>0.25 then begin
      tfix:=mHGE.Timer_GetTime ;
      ListMonsterStep.Free ;
      ListMonsterStep:=BF.CreateMonsterStepsCellList() ;
    end ;
  end;
  
  ListPony:=BF.GetPonyList() ;
  SRIconBack.SetScaleBoth(80);
  fnt2.SetScale(0.75);
  RenderedCount:=ListPony.Count ;
  for i := 0 to ListPony.Count - 1 do

    if BF.GetObjectCell(ListPony[i],PonyCell) then
      with TPonyUnit(PonyCell._Object) do begin

        SRPonyIconBack.RenderAsButton(GetPonyIconPosX(i),GetPonyIconPosY(i),mx,my,100,150) ;
        if SRPonyIconBack.IsMouseOver(mx,my) then begin
          ActiveIdx:=i ;
          //CSR.SetActive() ;
        end;

        with SRPoolIcons.GetRenderByTag(TPonyUnit(PonyCell._Object).IconName()) do begin
          SetScaleBoth(75);
          if (not IsCanAction())and(GetStepLeftWithEnergy()=0) then
             transp:=75 ;
          RenderAt(GetPonyIconPosX(i)+8,GetPonyIconPosY(i)-7);

          SetScaleBoth(100); transp:=0 ;
        end;

        for j := 0 to PonyCell.GetLinkCount-1 do
          if ListMonsterStep.IsObjectIn(PonyCell.GetLinked(j)) then begin
            SRUnderAttack.RenderAt(GetPonyIconPosX(i)+8,GetPonyIconPosY(i)-7);
            break ;
          end ;
        
        fnt2.PrintF(GetPonyIconPosX(i)+8,GetPonyIconPosY(i)+20,
          HGETEXT_CENTER,'%s%s',[GetMiniStepInfo(),
            Alternate(IsCanAction(),', Ä','')]);

        perc:=Round(100*(GetHealth+GetRestoredHealthAtMoment())/GetMaxHealth) ;
        if perc>100 then perc:=100 ;
        RenderIndicator(i,$FFF0F040,0,perc,-33) ;

        perc:=Round(100*(GetEnergy()+GetRestoredEnergyAtMoment())/GetMaxEnergy) ;
        if perc>100 then perc:=100 ;
        RenderIndicator(i,$FFF0F040,0,perc,-27) ;

        RenderIndicator(i,$FF40F040,0,GetHealthPerc(),-33) ;
        RenderIndicator(i,$FF40F0F0,0,GetEnergyPerc(),-27) ;
      end;

  fnt2.SetScale(1);
  SRIconBack.SetScaleBoth(100);
  ListPony.Free ;

end;

procedure TIconPanel.Update(dt: Single);
var ListPony:TStringList ;
    i:Integer ;
    z:Boolean ;
    PonyCell:TCell ;
begin
  FClicked:=False ;

  ListPony:=BF.GetPonyList() ;
  for i := 0 to ListPony.Count - 1 do begin
    if mHGE.Input_KeyDown(HGEK_LBUTTON) then z:=(ActiveIdx=i)
    else
    if mHGE.Input_KeyDown(HGEK_1+ListPony.Count-i-1) then z:=True
    else
    z:=False ;

    if z then
      if BF.GetObjectCell(ListPony[i],PonyCell) then begin
        BF.ImmediateRunTo(PonyCell.XOnMap,PonyCell.YOnMap);
        BF.setActiveCell(PonyCell);
        LP.ActiveAction:=nil ;
        FClicked:=True ;
        Break ;
      end;
  end;
  ListPony.Free ;

end;

end.
