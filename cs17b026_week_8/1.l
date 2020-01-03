%{
    #include<stdlib.h>
    #include<string.h>
    #include "y.tab.h"
%}

DIGIT [0-9]
CHAR [ -~]
INTEGER {DIGIT}+
BOX "["{INTEGER}"]"
FLOAT {DIGIT}*"."{DIGIT}+
CHAR_CONST [']{CHAR}[']
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*

%%

[ \t\n]*   
"int"                               { return INT; }
"float"                             { return FLOAT; }
"char"                              { return CHAR;}
"{"                                 { return OB; }
"}"                                 { return CB; }
"["                                 { return OS; }
"]"                                 { return CS; }
"*"                                 { return STAR; }
"="                                 { return EQ; }
","                                 { return COMMA; }
";"                                 { return SCOL; }
{INTEGER}                           { yylval.value = strdup(yytext); return INT_CONST; }
{FLOAT}                             { yylval.value = strdup(yytext); return FLOAT_CONST; }
{CHAR_CONST}                        { yylval.value = strdup(yytext); return CHAR_CONST; }                  
{IDENTIFIER}                        { yylval.name = strdup(yytext); return ID; }
.                                   { return yytext[0]; }

%%

int yywrap()
{
    return 1;
}