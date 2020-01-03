%{
    #include<stdlib.h>
    #include<string.h>
    #include "y.tab.h"
%}

DIGIT [0-9]
CHAR [ -~]
INTEGER {DIGIT}+
FLOAT {DIGIT}*"."{DIGIT}+
CHAR_CONST [']{CHAR}[']
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]+

EQUALITY_OPERATOR "=="|!=
RELATIONAL_OPERATOR "<"|">"|"<="|">="
ADDITIVE_OPERATOR "+"|"-"
MULTIPLICATIVE_OPERATOR "/"|"%"
UNARY_OPERATOR "~"|"!"

%%

[ \t\n]
"int"                               { return INT; }
"float"                             { return FLOAT; }
"char"                              { return CHAR;}
"if"                                { return IF; }
"else"                              { return ELSE; }
"while"                             { return WHILE; }
"{"                                 { return OB; }
"}"                                 { return CB; }
"["                                 { return OS; }
"]"                                 { return CS; }
"("                                 { return OP; }
")"                                 { return CP; }
"*"                                 { return STAR; }
"="                                 { return EQ; }
","                                 { return COMMA; }
";"                                 { return SCOL; }
"||"                                { return LOR; }
"&&"                                { return LAND; }
{INTEGER}                           { strcpy(yylval.value, yytext); return INT_CONST; }
{FLOAT}                             { strcpy(yylval.value, yytext); return FLOAT_CONST; }
{CHAR_CONST}                        { strcpy(yylval.value, yytext); return CHAR_CONST; }                  
{IDENTIFIER}                        { strcpy(yylval.name, yytext); return ID; }
{EQUALITY_OPERATOR}                 { strcpy(yylval.name, yytext); return EOP; }
{RELATIONAL_OPERATOR}               { strcpy(yylval.name, yytext); return ROP; }
{ADDITIVE_OPERATOR}                 { strcpy(yylval.name, yytext); return AOP; }
{MULTIPLICATIVE_OPERATOR}           { strcpy(yylval.name, yytext); return MOP; }
{UNARY_OPERATOR}                    { strcpy(yylval.name, yytext); return UOP; }
.                                   { return yytext[0]; }

%%

int yywrap()
{
    return 1;
}