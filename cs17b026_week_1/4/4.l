%{

%}

at      [@]
uns     [_]
dot     [.]
name    {iden}(({uns}|{dot})?{iden})*{uns}?
iden    [0-9a-zA-Z]

%%
{name}{at}{name}({dot}{name})+      {printf("valid email");}
.*                                  {printf("invalid email");}
%%

/*
    'iden' charecter class has all the charecters allowed in Accoutnname and Domainname except special charecters(_ and .).
    'name' charecter class generates all kinds of allowed Account and Domain names.
    It is assumed that both Account and Domain names can end with an underscore(_)(As it was not mentioned in the question).
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