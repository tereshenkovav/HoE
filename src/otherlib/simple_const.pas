unit simple_const ;

interface

const
  {$ifdef fpc}
    {$ifdef unix}
      CRLF = chr(10) ;
    {$else}
      CRLF = chr(13)+chr(10) ;
    {$endif}
  {$else}
    CRLF = chr(13)+chr(10) ;
  {$endif}


  {$ifdef fpc}
    {$ifdef unix}
      PATH_SEP = '/' ;
    {$else}
      PATH_SEP = '\' ;
    {$endif}
  {$else}
    PATH_SEP = '\' ;
  {$endif}
  
  QUOTA_MONO = '''' ; // ��������� �������
  QUOTA_DOUBLE = '"' ; // ������� �������
  
  CHAR_ZPT = ',' ; // ��������, �������
  CHAR_DOT = '.' ; // �����

  HTML_BR='<br>' ; // ������� ������ � HTML
  HTML_SP='&nbsp' ;  // ����������� ������ � HTML
  
  // ����������� ���������, �������� ��� ������ � Magic Numbers

  SEC_IN_MINUTE = 60 ; //������ � ������
  MIN_IN_HOUR = 60 ; // ����� � ����
  HOUR_IN_DAY = 24 ; // ����� � ������

  SEC_IN_HOUR = SEC_IN_MINUTE*MIN_IN_HOUR ; // ������ � ���� 
  SEC_IN_DAY = SEC_IN_HOUR*HOUR_IN_DAY ; // ������ � ���
  MIN_IN_DAY = HOUR_IN_DAY*MIN_IN_HOUR ; // ����� � ������

  
  DAYS_IN_WEEK=7 ;  // ����� ���� � ������

var
  MUCH_FUTURE_DATE:TDateTime ; // ������ ����� ��������� ����
  MUCH_PAST_DATE:TDateTime ; // ������ ����� ������ ����

implementation
uses SysUtils ;

initialization

  MUCH_FUTURE_DATE:=EncodeDate(2030,12,31) ;
  MUCH_PAST_DATE:=EncodeDate(0001,01,01) ;

end.




