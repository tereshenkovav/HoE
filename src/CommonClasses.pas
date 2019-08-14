unit CommonClasses;

interface
uses IniFiles, Windows ;

type
  TPointSingle = record
    X:Single ;
    Y:Single ;
  end ;

  TIniFileEx=class(TIniFile)
  public
    function ReadPoint(Section,Name:string):TPoint ;
    function ReadColor(Section,Name:string):Cardinal ;
  end;

function PointSingle(x,y:Single):TPointSingle ;

implementation
uses simple_oper, CommonProc ;

function PointSingle(x,y:Single):TPointSingle ;
begin
  Result.X:=x ;
  Result.Y:=y ;
end;

{ TIniFileEx }

function TIniFileEx.ReadColor(Section, Name: string): Cardinal;
begin
  Result:=ColorStr2Int(ReadString(Section,Name,'FFFFFFF')) ;
end;

function TIniFileEx.ReadPoint(Section, Name: string): TPoint;
begin
  Result.X:=ReadInteger(Section,Name+'_X',0) ;
  Result.Y:=ReadInteger(Section,Name+'_Y',0) ;
end;

end.
