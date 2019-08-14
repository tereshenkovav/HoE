unit KeyAbstractList ;

interface
uses Classes ;

type
  TKeyAbstractList = class ; //forward

  { TKeyAbstractList }

  TKeyAbstractList = class
  protected
    List:TStringList ;
  public
    constructor Create ;
    destructor Destroy ; override;
    procedure MergeWith(ListSrc:TKeyAbstractList) ;
    procedure LoadFromFile(FileName:string) ;
    function Count():Integer ;
    procedure Clear ;
  end ;

implementation

{ TKeyAbstractList }

constructor TKeyAbstractList.Create;
begin
  List:=TStringList.Create ;
end;

destructor TKeyAbstractList.Destroy;
begin
  List.Free ;
  inherited Destroy;
end;

function TKeyAbstractList.Count(): Integer;
begin  Result:=List.Count ; end;

procedure TKeyAbstractList.Clear;
begin  List.Clear ; end;

procedure TKeyAbstractList.MergeWith(ListSrc: TKeyAbstractList);
begin
  List.AddStrings(ListSrc.List) ;
end;

procedure TKeyAbstractList.LoadFromFile(FileName:string) ;
begin
  List.LoadFromFile(FileName) ;
end ;

end.
