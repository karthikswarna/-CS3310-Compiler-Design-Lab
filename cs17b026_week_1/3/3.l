%{

%}

range   [01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5]
dot     [.]

%%
{range}{dot}{range}{dot}{range}{dot}{range} {printf("valid, %s", yytext);}
.*                                          {printf("invalid, %s", yytext);}
%%

/*
    The 'range' character class generates numbers from 0 to 255.
    Also, the numbers 0 to 99 can be given as 000 to 099 also. Both ways are accepted.
*/

int main(int argc, char **argv)
{
    if(argc > 1)    // if a file name is given as argument,
    {
        if(!(yyin = fopen(argv[1], "r"))) 
        {
            perror(argv[1]);
            return 1;
        }
        yylex();
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
