unit StringObject ;

{
    Модуль представляет собой прослойку для представления строк
  как объекта

}

{$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface
type

  { TStringObject }

  TStringObject = class
  public
    s:string ;
    procedure Add(const str:string) ; overload ;
    procedure Add(const str:string; params:array of const) ; overload ;
    procedure AddToStart(const str:string) ; overload ;
    procedure AddToStart(const str:string; params:array of const) ; overload ;
    procedure AddToStartAndFinish(const str1,str2:string) ;
    procedure AddWithSep(const str:string; const sep:string=',') ; overload ;
    procedure AddWithSep(const str:string; params:array of const; const sep:string=',') ; overload ;
    constructor Create(const str:string='') ; overload ;
    constructor Create(const str:string; params:array of const) ; overload ;
  end ;

function NewStrObj(const str:string=''):TStringObject ; overload ;
function NewStrObj(const str:string; params:array of const):TStringObject ; overload ;

implementation
uses SysUtils ;

function NewStrObj(const str:string=''):TStringObject ;
begin
  Result:=TStringObject.Create(str) ;
end ;

function NewStrObj(const str:string; params:array of const):TStringObject ; overload ;
begin  Result:=NewStrObj(Format(str,params)) ; end;

{ TStringObject }

procedure TStringObject.AddWithSep(const str:string; const sep:string=',') ;
begin
  if s<>'' then s:=s+sep ; 
  Add(str) ;
end ;

procedure TStringObject.AddWithSep(const str: string; params: array of const;
  const sep: string);
begin  AddWithSep(Format(str,params),sep) ; end;

procedure TStringObject.Add(const str:string) ;
begin  s:=s+str ; end ;

procedure TStringObject.Add(const str: string; params: array of const);
begin  Add(Format(str,params)) ; end;

procedure TStringObject.AddToStart(const str: string);
begin  s:=str+s ; end;

procedure TStringObject.AddToStart(const str: string; params: array of const);
begin  AddToStart(Format(str,params)) ; end;

procedure TStringObject.AddToStartAndFinish(const str1, str2: string);
begin
  AddToStart(str1) ;
  Add(str2) ;
end;

constructor TStringObject.Create(const str:string='') ;
begin  s:=str ; end ;

constructor TStringObject.Create(const str: string; params: array of const);
begin  Create(Format(str,params)) ; end;

end.
