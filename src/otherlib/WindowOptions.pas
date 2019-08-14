unit WindowOptions;

interface

type
  TWindowOptions = class
  public
    Width:Integer ;
    Height:Integer ;
    FullScreen: Boolean ;
    constructor Create(const AWidth,AHeight:Integer;
      const AFullScreen:Boolean) ;
    function GetMashX():Single ; virtual ;
    function GetMashY():Single ; virtual ;
    function GetXCenter():Integer ;
    function GetYCenter():Integer ;    
  end;

  TWindowOptionsNoMash = class(TWindowOptions)
  public
    function GetMashX():Single ; override ;
    function GetMashY():Single ; override ;
  end;

implementation

{ TWindowOptions }

constructor TWindowOptions.Create(const AWidth, AHeight: Integer;
  const AFullScreen: Boolean);
begin
  Width:=AWidth ;
  Height:=AHeight ;
  FullScreen:=AFullScreen ;
end;

function TWindowOptions.GetMashX: Single;
begin
  Result:=Width/1024 ;
end;

function TWindowOptions.GetMashY: Single;
begin
  Result:=Height/768 ;
end;

function TWindowOptions.GetXCenter: Integer;
begin
  Result:=Width div 2 ;
end;

function TWindowOptions.GetYCenter: Integer;
begin
  Result:=Height div 2 ;
end;

{ TWindowOptionsNoMash }

function TWindowOptionsNoMash.GetMashX: Single;
begin  Result:=1 ;  end;

function TWindowOptionsNoMash.GetMashY: Single;
begin  Result:=1 ;  end;

end.
