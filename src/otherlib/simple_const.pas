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
  
  QUOTA_MONO = '''' ; // Одинарная кавычка
  QUOTA_DOUBLE = '"' ; // Двойная кавычка
  
  CHAR_ZPT = ',' ; // Очевидно, запятая
  CHAR_DOT = '.' ; // Точка

  HTML_BR='<br>' ; // Перевод строки в HTML
  HTML_SP='&nbsp' ;  // Неразрывный пробел в HTML
  
  // Специальные константы, вводимые для борьбы с Magic Numbers

  SEC_IN_MINUTE = 60 ; //Секунд в минуте
  MIN_IN_HOUR = 60 ; // Минут в часе
  HOUR_IN_DAY = 24 ; // Часов в сутках

  SEC_IN_HOUR = SEC_IN_MINUTE*MIN_IN_HOUR ; // Секунд в часе 
  SEC_IN_DAY = SEC_IN_HOUR*HOUR_IN_DAY ; // Секунд в дне
  MIN_IN_DAY = HOUR_IN_DAY*MIN_IN_HOUR ; // Минут в сутках

  
  DAYS_IN_WEEK=7 ;  // Число дней в неделе

var
  MUCH_FUTURE_DATE:TDateTime ; // Просто очень удаленная дата
  MUCH_PAST_DATE:TDateTime ; // Просто очень ранняя дата

implementation
uses SysUtils ;

initialization

  MUCH_FUTURE_DATE:=EncodeDate(2030,12,31) ;
  MUCH_PAST_DATE:=EncodeDate(0001,01,01) ;

end.




