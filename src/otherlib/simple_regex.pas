unit simple_regex ;

{$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface
uses Classes ;

function GetValueByRegEx(s,regex:string; Index:Integer=0; default:string=''; CaseSens:Boolean=True):string ;
function String2RegEx(s:string):string ;
function CreateStringListByMatches(s,regex:string; Index:Integer=0):TStringList ;
function IsRegExMatched(s,regex:string):Boolean ;
function CreateStringListFromListMatched(ListIn:TStringList; regex:string):TStringList ;
function InjectEEOToRegEx(regex:string):string ;

implementation
uses RegExpr ;

const
  NOSLASHCHARS='0123456789_ ' +
   'abcdefghijklmnopqrstuvwxyz' +
   'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
   'àáâãäå¸æçèéêëìíîïğñòóôõö÷øùúûüışÿ'+
   'ÀÁÂÃÄÅ¨ÆÇÈ¨ÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞß' ;

function GetValueByRegEx(s,regex:string; Index:Integer=0; default:string='';
  CaseSens:Boolean=True):string ;
begin
  with TRegExpr.Create do begin
    Expression:=regex ;
    if not CaseSens then ModifierI:=True ;
    if Exec(s) then Result:=Match[Index] else Result:=default ;
    Free ;
  end ;
end ;

function String2RegEx(s:string):string ;
var i:Integer ;
    last_sp:Boolean ;
begin
  Result:='' ;
  last_sp:=False ;
  for i:=1 to Length(s) do begin
    if s[i]=chr(32) then begin
      if not last_sp then begin
        Result:=Result+'\x20+?' ;
        last_sp:=True ;
      end;
    end
    else begin
      last_sp:=False ;
      if Pos(s[i],NOSLASHCHARS)=0 then Result:=Result+'\' ;
      Result:=Result+s[i] ;
    end ;
  end ;
end ;

function CreateStringListByMatches(s,regex:string; Index:Integer=0):TStringList ;
begin
  Result:=TStringList.Create ;
  with TRegExpr.Create() do begin
    ModifierI:=True ;
    Expression:=regex ;
    if Exec(s) then
      repeat
        Result.Add(Match[Index]) ;
      until not ExecNext ;
    Free ;
  end;
end ;

function IsRegExMatched(s,regex:string):Boolean ;
begin
  with TRegExpr.Create() do begin
    ModifierI:=True ;
    Expression:=regex ;
    Result:=Exec(s) ;
    Free ;
  end ;
end ;

function CreateStringListFromListMatched(ListIn:TStringList; regex:string):TStringList ;
var R:TRegExpr ;
    i:Integer ;
begin
  Result:=TStringList.Create ;
  R:=TRegExpr.Create() ;
  R.ModifierI:=True ;
  R.Expression:=regex  ;
  for i:=0 to ListIn.Count-1 do
    if R.Exec(ListIn[i]) then
      Result.Add(ListIn[i]) ;
  R.Free ;
end ;

function InjectEEOToRegEx(regex:string):string ;
var i:Integer ;
begin
  Result:='' ;
  for i:=1 to Length(regex) do
    case regex[i] of
      'å','¸': Result:=Result+'[å¸]' ;
      'Å','¨': Result:=Result+'[Å¨]' ;
      else Result:=Result+regex[i] ;
    end ;
end ;

end.
