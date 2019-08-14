unit HardLevels;

interface
uses MinMaxValues ;

procedure SetNoviceMaxPonyStep(var MaxStep:Integer) ;
procedure SetCasualMonsterParam(var MaxHealth:Integer; var AttackValue:TMinMaxValues;
  var SplashAttackValue:TMinMaxValues) ;
procedure SetNoviceEnergy(var energy:Integer) ;

implementation
uses ObjModule, Player ;

procedure SetNoviceMaxPonyStep(var MaxStep:Integer) ;
begin
  if PL.GetHardLevel()<=hlNovice then
    if MaxStep>0 then MaxStep:=MaxStep+1 ;
end;

procedure SetCasualMonsterParam(var MaxHealth:Integer; var AttackValue:TMinMaxValues;
  var SplashAttackValue:TMinMaxValues) ;
begin
  if PL.GetHardLevel()<=hlCasual then begin
    MaxHealth:=Round(MaxHealth/1.5) ;
    AttackValue.SetMin(Round(AttackValue.GetMin/1.5));
    AttackValue.SetMax(Round(AttackValue.GetMax/1.5));
    SplashAttackValue.SetMin(Round(SplashAttackValue.GetMin/1.5));
    SplashAttackValue.SetMax(Round(SplashAttackValue.GetMax/1.5));
  end;
end ;

procedure SetNoviceEnergy(var energy:Integer) ;
begin
  if (ObjModule.PL.GetHardLevel()<=hlNovice) then
    energy:=Round(0.8*energy) ;
end;

end.
