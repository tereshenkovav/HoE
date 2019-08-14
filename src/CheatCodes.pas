unit CheatCodes;

interface

procedure ProcessCheatCodes() ;

implementation
uses TAVHGEUtils, SysUtils, ObjMOdule, CommonProc ;

var
  keystr:string='' ;

procedure ProcessCheatCodes() ;
var c:char ;
begin
  c:=chr(mHGE.Input_GetChar()) ;
  if ord(c)<>0 then keystr:=keystr+c ;
  if Length(keystr)>6 then keystr:=Copy(keystr,Length(keystr)-5,6) ;
  if LowerCase(keystr)='deusex' then begin
    keystr:='' ;
    BF.VictoryFlag:=True ;
    SetResultMsg('Активация кода победы') ;
    MS.ClearAllScripts() ;
  end;
end ;

end.
