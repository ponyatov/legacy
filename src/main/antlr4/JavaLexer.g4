lexer grammar JavaLexer;

PUBLIC : 'public' ;
STATIC : 'static' ;
VOID   : 'void'   ;

CHAR : . ;

WS           : [ \t\r\n\u000C]+ -> skip ;
COMMENT      : '/*' .*? '*/'    -> skip ;
LINE_COMMENT : '//' ~[\r\n]*    -> skip ;
