unit LinkedList ;

{$ifdef fpc}{$mode objfpc}{$endif}

interface
uses contnrs ;

type

  { TLinkedList}

  TLinkedList = class
  protected
    function GetItem(LinkTo:TObject):TObject ;
  private
    List:TObjectList ;
    FIsDestroyMains:Boolean ;
    function GetCount:Integer ;
  public
    function Add(O:TObject; LinkTo:TObject):Integer ; 
    procedure Delete(LinkTo:TObject) ;
    procedure Clear ;
    function IsEmpty:Boolean ;
    constructor Create(CMain,CLink:TClass;const AIsDestroyMains:Boolean) ;
    destructor Destroy ; override ;
    property Count:Integer read GetCount ;
    property Items[LinkTO:TObject]:TObject read GetItem ; default ;
    property IsDestroyMains:Boolean read FIsDestroyMains ;
  end ;

implementation
uses SysUtils ;

type

   { TLinkedListItem }

   TLinkedListItem = class
   private
     _O:TObject ;
     _L:TObject ;
     IsDestroyO:Boolean ;
   public
     function IsEqualTo(LinkTo:TObject):Boolean ;
     constructor Create(O:TObject;LinkTo:TObject;const AIsDestroyO:Boolean) ;
     destructor Destroy ; override ;
     property O:TObject read _O ;
   end ;

{ TLinkedListItem }

function TLinkedListItem.IsEqualTo(LinkTo: TObject): Boolean;
begin  Result:=(_L=LinkTo) ; end;

constructor TLinkedListItem.Create(O: TObject; LinkTo: TObject;
  const AIsDestroyO:Boolean);
begin  _O:=O ;  _L:=LinkTo ;  IsDestroyO:=AIsDestroyO ; end;

destructor TLinkedListItem.Destroy;
begin
  if IsDestroyO then begin  _O.Free ; _O:=nil ; end ;
  inherited Destroy;
end;

{ TLinkedList }

function TLinkedList.GetItem(LinkTo: TObject): TObject;
var i:Integer ;
begin
  Result:=nil ;
  for i:=0 to List.Count-1 do
    if TLinkedListItem(List[i]).IsEqualTo(LinkTo) then begin
      Result:=TLinkedListItem(List[i])._O ; Break ;
    end ;
end;

function TLinkedList.GetCount: Integer;
begin  Result:=List.Count ; end;

function TLinkedList.Add(O: TObject; LinkTo: TObject): Integer;
begin  List.Add(TLinkedListItem.Create(O,LinkTo,IsDestroyMains)) ; end;

procedure TLinkedList.Delete(LinkTo: TObject);
var i:Integer ;
begin
  for i:=0 to List.Count-1 do
    if TLinkedListItem(List[i]).IsEqualTo(LinkTo) then begin
      List.Remove(List[i]) ;
      Break ;
    end;
end;

procedure TLinkedList.Clear;
begin  List.Clear ; end;

function TLinkedList.IsEmpty: Boolean;
begin  Result:=(List.Count=0) ; end;

constructor TLinkedList.Create(CMain, CLink: TClass;
  const AIsDestroyMains:Boolean);
begin
  List:=TObjectList.Create ;
  FIsDestroyMains:=AIsDestroyMains ;
end;

destructor TLinkedList.Destroy;
begin
  List.Free ;
  inherited Destroy;
end;

end.
