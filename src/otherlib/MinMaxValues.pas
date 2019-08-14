unit MinMaxValues;

{$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface

type
  TMinMaxValues = class
  private
    Min:Real ;
    Max:Real ;
  public
    function GetMin:Integer ;
    function GetMax:Integer ;
    procedure SetMin(const Value:Integer) ;
    procedure SetMax(const Value:Integer) ;
    function GetRndBetween():Integer ;
    constructor Create(const AMin,AMax:Integer) ;
  end;

function CreateNewMMV(const AMin,AMax:Integer):TMinMaxValues ;

implementation

function CreateNewMMV(const AMin,AMax:Integer):TMinMaxValues ;
begin
  Result:=TMinMaxValues.Create(AMin,AMax) ;
end ;

{ TMinMaxValues }

constructor TMinMaxValues.Create(const AMin, AMax: Integer);
begin
  SetMax(AMax) ; SetMin(AMin) ;
end;

function TMinMaxValues.GetMax: Integer;
begin
  Result:=Round(Max) ;
end;

function TMinMaxValues.GetMin: Integer;
begin
  Result:=Round(Min) ;
end;

function TMinMaxValues.GetRndBetween: Integer;
begin
  Result:=GetMin+Round(Random(GetMax()-GetMin()+1)) ;
end;

procedure TMinMaxValues.SetMax(const Value: Integer);
begin
  Max:=Value ;
end;

procedure TMinMaxValues.SetMin(const Value: Integer);
begin
  Min:=Value ;
end;

end.
