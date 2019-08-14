unit AutoCreatedSubList ;

interface
uses Classes, SysUtils, contnrs ;

type
  TACObjectList = class
  protected
    List:TObjectList ;
  public
    constructor Create() ; virtual ;
    destructor Destroy ; override ;
  end ;

  TACObjectListNoOwn = class
  protected
    List:TObjectList ;
  public
    constructor Create() ; virtual ;
    destructor Destroy ; override ;
  end ;

  TACStringList = class
  protected
    List:TStringList ;
  public
    constructor Create() ; virtual ;
    destructor Destroy ; override ;
  end ;

  {$ifdef fpc}
  TACStringHashTable = class
  protected
    List:TFPStringHashTable ;
  public
    constructor Create() ; virtual ;
    destructor Destroy ; override ;
  end ;
  {$endif}

implementation

constructor TACObjectList.Create() ;
begin  
  List:=TObjectList.Create(True) ; 
end ;

destructor TACObjectList.Destroy ; 
begin  
  List.Free ; 
  inherited Destroy ; 
end ;

constructor TACObjectListNoOwn.Create() ;
begin  
  List:=TObjectList.Create(False) ; 
end ;

destructor TACObjectListNoOwn.Destroy ; 
begin  
  List.Free ; 
  inherited Destroy ; 
end ;

constructor TACStringList.Create() ;
begin  
  List:=TStringList.Create() ; 
end ;

destructor TACStringList.Destroy ; 
begin  
  List.Free ; 
  inherited Destroy ; 
end ;

{$ifdef fpc}
constructor TACStringHashTable.Create() ;
begin
  List:=TFPStringHashTable.Create() ;
end ;

destructor TACStringHashTable.Destroy ;
begin
  List.Free ;
  inherited Destroy ;
end ;
{$endif}

end.
