%{

%}

binary [0-1]
octal [0-7]
decimal [0-9]
hexa [0-9a-fA-F]

%%
{binary}+   {printf("binary");}
{octal}+    {printf("octal");}
{decimal}+  {printf("decimal");}
{hexa}+     {printf("hexa");}
.*          {printf("invalid");}
%%

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

int yywrap()        // read from a file and return.
{
    return 1;
}