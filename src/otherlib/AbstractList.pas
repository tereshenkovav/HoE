unit AbstractList ;

{
  Изменения:
    04.09.2008
      - Добавлено свойство Items
      
    13.05.2008
      - Добавлена функция Sort (делегат)
    08.11.2007
      - Свойство List перенесено из Private в Protected, для видимости в потомках
    19.10.2007
      - Добавлена функция
          function IsObjectIn(O:TObject):Boolean ;

}

interface
uses contnrs, Classes ;

type

  { TAbstractListAbstract }

  TAbstractListAbstract = class
  protected
    List:TObjectList ;
    function GetItem(i:Integer):TObject ;
  private
    function GetCount:Integer ;
  public
    property Count:Integer read GetCount ;
    function Add(O:TObject):Integer ; virtual ;
    function AddIfNoExist(O:TObject):Integer ;
    function AddNoExistFrom(List:TAbstractListAbstract):Integer ; 
    function Insert(O:TObject; index:Integer):Integer; virtual ;
    procedure Delete(O:TObject) ; virtual ;
    procedure Clear ; virtual ;
    function IsEmpty:Boolean ;
    function IsObjectIn(O:TObject):Boolean ; virtual ;
    procedure Sort(Compare: TListSortCompare);
    constructor Create ; virtual ; abstract ;
    destructor Destroy ; override ;
    property Items[i:Integer]:TObject read GetItem ;
  end ;

  TAbstractList = class(TAbstractListAbstract)
  public
    constructor Create ; override ;
  end ;

  TAbstractListNoOwn = class(TAbstractListAbstract)
  public
    constructor Create ; override ;
  end ;
  
implementation

{ TAbstractListAbstract }

function TAbstractListAbstract.GetItem(i: Integer): TObject;
begin
  Result:=List[i] ;
end;

function TAbstractListAbstract.GetCount: Integer;
begin
  Result:=List.Count ;
end;

function TAbstractListAbstract.Add(O: TObject):Integer;
begin
  Result:=List.Add(O) ;
end;

procedure TAbstractListAbstract.Delete(O: TObject);
begin
  List.Remove(O) ;
end;

function TAbstractListAbstract.AddIfNoExist(O: TObject): Integer;
begin
  if IsObjectIn(O) then Result:=-1 else
  Result:=Add(O) ;
end;

function TAbstractListAbstract.AddNoExistFrom(
  List: TAbstractListAbstract): Integer;
var i:Integer ;
begin
  Result:=0 ;
  for i := 0 to List.Count - 1 do
    if not IsObjectIn(List.Items[i]) then begin
      Add(List.Items[i]) ;
      Inc(Result) ;
    end;
end;

procedure TAbstractListAbstract.Clear ;
begin
  List.Clear ;
end ;

destructor TAbstractListAbstract.Destroy;
begin
  List.Free ;
  inherited Destroy;
end;

function TAbstractListAbstract.Insert(O: TObject; index: Integer): Integer;
begin
  List.Insert(Index,O);
end;

function TAbstractListAbstract.IsEmpty:Boolean ;
begin
  Result:=(Count=0) ;
end ;

function TAbstractListAbstract.IsObjectIn(O: TObject): Boolean;
var i:Integer ;
begin
  Result:=False ;
  for i:=0 to Count-1 do
    if GetItem(i)=O then begin
      Result:=True ;
      Break ;
    end ;  
end;

procedure TAbstractListAbstract.Sort(Compare: TListSortCompare);
begin  List.Sort(Compare) ; end;

{ TAbstractList }

constructor TAbstractList.Create;
begin
  List:=TObjectList.Create(True) ;
end;

{ TAbstractListNoOwn }

constructor TAbstractListNoOwn.Create;
begin
  List:=TObjectList.Create(False) ;
end;

end.






