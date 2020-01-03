%{
    #include<algorithm>
    #include<iostream>
    #include<string>
    #include<map>
    #include<set>
    #define COMMENT_START '/'
    #define ONELINE_COMMENT 1
    #define MULTILINE_COMMENT 2

    using namespace std;

    map<int, string> M;
    set<string> S;
    int cnt = 0;
%}

DIGIT [0-9]
NUMBER {DIGIT}+
REAL {DIGIT}*"."{DIGIT}+
TEXT [a-zA-Z]+
TEXT_NUMBERS [a-zA-Z0-9]
IDENTIFIER [a-zA-Z_]{TEXT_NUMBERS}*|[a-zA-Z_]{TEXT_NUMBERS}*[[{NUMBER}+]]
NON_IDENTIFIER {NUMBER}+[A-Za-z_]+
FORMAT_SPECIFIER \"{STRING}?"%"{TEXT_NUMBERS}+{STRING}?\"
DELIMITER [;]
FUNCTION_CALL [()]
STRING \".*\"

ASSIGNMENT_OPERATOR "="|"+="|"-="|"*="|"/="|"%="|"<<="|">>="|"&="|"^="|"|="
RELATIONAL_OPERATOR "<"|">"|">="|"<="|"=="|"!="
BITWISE_OPERATOR "<<"|">>"|"&"|"^"|"|"
LOGICAL_OPERATOR "&&"|"||" 
UNARY_OPERATOR "&"|"*"|"+"|"-"|"~"|"!"|"++"|"--"|"("
BINARY_OPERATOR "+"|"-"|"*"|"/"|"%"
TERNARY_OPERATOR "?:"
COMMA ","
MEM_SEL "."|\t"->"
BLOCK_BEGINS "{"
BLOCK_ENDS "}"

KEYWORD "auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"int"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while"
PREPROCESSOR "#"|"#line"|"#undef"|"#error"|"#elif"|"#else"|"#endif"|"#if"|"#define"|"#include"|"#pragma"|"#ifndef"|"#ifdef"
FILE "<"{IDENTIFIER}.h">"

%%
[\n\t ]
{FUNCTION_CALL}         { printf("%s\t -> function call operator\n", yytext); }
{DELIMITER}             { printf("%s\t -> delimiter\n", yytext); }
{ASSIGNMENT_OPERATOR}   { printf("%s\t -> assignment operator\n", yytext); }
{RELATIONAL_OPERATOR}   { printf("%s\t -> relational operator\n", yytext); }
{BITWISE_OPERATOR}      { printf("%s\t -> bitwise operator\n", yytext); }
{LOGICAL_OPERATOR}      { printf("%s\t -> logical operator\n", yytext); }
{UNARY_OPERATOR}        { printf("%s\t -> unary operator\n", yytext); }
{BINARY_OPERATOR}       { printf("%s\t -> binary operator\n", yytext); }
{MEM_SEL}               { printf("%s\t -> member selection operator\n", yytext); }
{COMMA}                 { printf("%s\t -> expression saperator\n", yytext); }

{KEYWORD}               { printf("%s\t -> keyword\n", yytext); }
{NUMBER}                { printf("%s\t -> integer constant\n", yytext); }
{REAL}                  { printf("%s\t -> floating-point constant\n", yytext); }
{PREPROCESSOR}          { printf("%s\t -> preprocessor directive\n", yytext); }
{IDENTIFIER}            { if(S.find(yytext) == S.end())
                          {
                            M.insert(pair<int, string>(++cnt, yytext));
                            S.insert(yytext);
                          }
                        }
{TERNARY_OPERATOR}      { printf("%s\t -> mathematical operator\n", yytext); }
{BLOCK_BEGINS}          { printf("%s\t -> Block begin\n", yytext); }
{BLOCK_ENDS}            { printf("%s\t -> Block end\n", yytext); }
{FILE}                  { printf("%s\t -> file\n", yytext); }
{FORMAT_SPECIFIER}      { printf("%s\t -> format specifier\n", yytext); }

\&{IDENTIFIER}		    {printf("%s\t -> address\n", yytext);}
{STRING}			    {printf("%s\t -> string constant\n", yytext);}
{NON_IDENTIFIER}        { printf("Could not process %s", yytext); }
%%

int main(int argc, char **argv)
{
    if(argc > 1)    // if a file name is given as argument,
    {
        // removing all comments and storing program in a saperate file named 'out.c'. 
        char c;
        int escape = 0;
        int comment_type = 0;
        int skip_new_line = 0;
        int string_started = 0;
        int comment_ending = 0;
        int comment_started = 0;
        FILE *fp_in, *fp_out;

        fp_in = fopen(argv[1], "r");
        if (fp_in == NULL) 
        {
            printf("error: could not open input file\n");
            return 1;
        }

        fp_out = fopen("out.c", "w");
        if (fp_out == NULL) 
        {
            fclose(fp_in);
            printf("error: could not open output file\n");
            return 1;
        }

        while (1) 
        {
            c = fgetc(fp_in);
            
            if (feof(fp_in))
                break;

            if (skip_new_line == 1) 
            {
                skip_new_line = 0;
                if (c == '\n')
                    continue;
            }

            if (comment_type == ONELINE_COMMENT) 
            {
                if (c == '\\')
                    escape = !escape;
                else if (c == '\n' && !escape) 
                {
                    comment_type = 0;
                    comment_started = 0;
                } 
                else 
                {
                    escape = 0;
                }
                continue;
            }

            if (comment_type == MULTILINE_COMMENT) 
            {
                if (comment_ending) 
                {
                    if (c == '/') 
                    {
                        comment_ending = 0;
                        comment_started = 0;
                        comment_type = 0;
                        skip_new_line = 1;
                        continue;
                    }
                    comment_ending = 0;
                }

                if (c == '*')
                    comment_ending = 1;

                continue;
            }

            if (comment_started) 
            {
                if (c == '*') 
                {
                    comment_type = MULTILINE_COMMENT;
                    continue;
                }
                if (c == '/') 
                {
                    comment_type = ONELINE_COMMENT;
                    continue;
                }

                fputc(COMMENT_START, fp_out);
                comment_started = 0;
            }

            if (string_started) 
            {
                if (c == '\\')
                    escape = !escape;
                else if (c == '\"' && !escape)
                    string_started = 0;
                else
                    escape = 0;

                fputc(c, fp_out);
                continue;
            }

            if (c == '\"')
                string_started = 1;

            if (c == COMMENT_START) 
            {
                comment_started = 1;
                continue;
            }

            fputc(c, fp_out);
        }

        fclose(fp_in);
        fclose(fp_out);
        //*******************************************************

        if(!(yyin = fopen("out.c", "r"))) 
        {
            perror(argv[1]);
            return 1;
        }
        yylex();
        fclose(yyin);

        // printing the symbol table.
        printf("\n\n\tSYMBOL TABLE\n");
        printf("------------------------------------------------\n");
        printf("TOKEN NAME\tLEXEME\n");
        printf("------------------------------------------------\n");
        for(auto it = M.begin(); it != M.end(); it++)
        {
            printf("id%d\t\t", it->first);
            cout << it->second << endl;
        }
        printf("------------------------------------------------\n");
    }
    else            // or ask to enter a file name.
    {
        printf("Enter a file name!");
        return 1;
    }

    return 0;
}

int yywrap()
{
    return 1;
}