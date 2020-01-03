%{

%}

digit   [0-9]
zero    [0]+
plus    [+]
minus   [-]
dot     [.]
exp     [e|E]
integer {digit}+
real    {integer}?{dot}{integer}

%%
{zero}|{zero}{dot}{zero}                {printf("zero");}
{plus}?{integer}                        {printf("positive integer");}
{minus}{integer}                        {printf("negative integer");}
{plus}?{integer}{exp}{plus}?{integer}   {printf("positive integer in exponential form");}
{plus}?{integer}{exp}{minus}{integer}   {printf("positive integer in negative exponential form");}
{minus}{integer}{exp}{plus}?{integer}   {printf("negative integer in exponential form");}
{minus}{integer}{exp}{minus}{integer}   {printf("negative integer in negative exponential form");}
{plus}?{real}                           {printf("positive real");}
{minus}{real}                           {printf("negative real");}
{plus}?{real}{exp}{plus}?{integer}      {printf("positive real in exponential form");}
{plus}?{real}{exp}{minus}{integer}      {printf("positive real in negative exponential form");}
{minus}{real}{exp}{plus}?{integer}      {printf("negative real in exponential form");}
{minus}{real}{exp}{minus}{integer}      {printf("negative real in negative exponential form");}
.*                                      {printf("neither integer nor real");}
%%

/*
    integer charecter class generates all integers and real generates all decimal and fractional numbers.
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
