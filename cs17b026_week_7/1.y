%{
    #include<stdio.h>
    #include<stdlib.h>
	int yylex();
    int yyerror(char *);
%}

%token ID CONST STR END
%token UOP LOR LAND EOP ROP AOP MOP
%start expression_list

%%

expression_list
	: expression
	| expression_list expression 
	;

expression
	: logical_or_expression '\n' {printf("valid\n");}
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression LOR logical_and_expression
    ;
	
logical_and_expression
	: equality_expression
	| logical_and_expression LAND equality_expression
	;

equality_expression
	: relational_expression
	| equality_expression EOP relational_expression
	;

relational_expression
	: additive_expression
	| relational_expression ROP additive_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression AOP multiplicative_expression
	;

multiplicative_expression
	: unary_expression
	| multiplicative_expression MOP unary_expression
	;

unary_expression
	: primary_expression
	| UOP unary_expression
	;

primary_expression
	: ID
    | CONST
    | STR
    ;

%%

int main()
{
	//do
	//{
    	yyparse();

	//}while(!feof(yyin));

	return 0;
}

int yyerror(char *s)
{
	printf("invalid\n");
    exit(0);
}