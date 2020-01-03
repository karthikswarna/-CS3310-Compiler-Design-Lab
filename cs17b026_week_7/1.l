%{
    #include <stdio.h>
    #include "y.tab.h"
%}

DIGIT [0-9]
CHAR [ -~]
INTEGER {DIGIT}+
FLOAT {DIGIT}*"."{DIGIT}+
CHAR_CONST [']{CHAR}[']
STRING ["]{CHAR}+["]
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*

LOGICAL_OR "||"
LOGICAL_AND "&&"
UNARY_OPERATOR "~"|"!"
EQUALITY_OPERATOR "=="|"!="
RELATIONAL_OPERATOR "<"|">"|">="|"<="
ADDITIVE_OPERATOR "+"|"-"
MULTIPLICATIVE_OPERATOR "*"|"/"|"%"

%%

[ \t]
{INTEGER}|{FLOAT}|{CHAR_CONST}      { return CONST; }                  
{STRING}                            { return STR; }
{IDENTIFIER}                        { return ID; }
{UNARY_OPERATOR}                    { return UOP; }
{LOGICAL_OR}                        { return LOR; }
{LOGICAL_AND}                       { return LAND; }
{EQUALITY_OPERATOR}                 { return EOP; }
{RELATIONAL_OPERATOR}               { return ROP; }
{ADDITIVE_OPERATOR}                 { return AOP; }
{MULTIPLICATIVE_OPERATOR}           { return MOP; }
\n|.                                { return yytext[0]; }

%%

int yywrap()
{
    return 1;
}