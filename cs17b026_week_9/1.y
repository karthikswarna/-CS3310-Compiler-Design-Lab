%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include<ctype.h>
    
    /* a declaration's structure */
    typedef struct entry 
    {
        char name[25];
        char type[10];
        char value[10];
        int size;
        struct entry *next;
    } entry_t;

    /* node of the syntax tree */
    typedef struct node
    {
        char op[25];
        struct node *left;
        struct node *right;
    } node_t;

    /* an entry in symbol table */
    typedef struct headOrRoot
    {
        struct entry *head;
        struct node *root;
        struct headOrRoot *next;
    } headOrRoot;

    /* symbol table structure */
    typedef struct symtab
    {
        struct headOrRoot *MChead;
        struct symtab *child;
        struct symtab *next;
    } symtab_t;

    symtab_t *global = NULL;
    extern FILE* yyin;
    
    int yylex();
    int yyerror(const char *);

    /* Function to print symbol table. */
    void print_symtab(symtab_t *);

    /* The set of three functions work together to product the intermediate code.*/
    void generateCode(symtab_t *);
    void postOrder(symtab_t *, headOrRoot *, node_t *);
    int postOrderUtil(symtab_t *, headOrRoot *, node_t *, char *, int *);
    
    /* 
        Checks if the variable is declared previously, if yes return var->type, else throw error.
        Takes pointer to symbol table and a pointer to place where variable is used.
    */
    char *varCheck(symtab_t *, headOrRoot *, char []);
    
    /* Returns 1 if given string is an integer, 2 if floating point, 0 otherwise. */
    int isNumber(char []);
%}


%union
{
    char name[25];
    char type[10];
    char value[10];
    int size;
    struct entry *entry;
    struct node *node;
    struct headOrRoot *headOrRoot;
    struct symtab *symtab;
}

%token OB CB OS CS OP CP EQ COMMA STAR SCOL

%token<value> INT_CONST  
%token<value> FLOAT_CONST 
%token<value> CHAR_CONST
%token<type> INT 
%token<type> FLOAT 
%token<type> CHAR
%token<name> ID
%token<name> AOP
%token<name> MOP

%type<symtab> block;
%type<symtab> block_inside;
%type<headOrRoot> statement_list
%type<headOrRoot> statement
%type<entry> decleration
%type<entry> arg_list
%type<entry> arg
%type<size> BOX
%type<value> const
%type<type> type_specifier
%type<node> assignment
%type<node> additive_expression
%type<node> multiplicative_expression
%type<node> primary_expression

%%

block
    : OB block_inside CB block                              {
                                                                symtab_t *temp = $2;
                                                                temp->next = $4;
                                                                $$ = $2;
                                                                global = $2;
                                                            }
    | OB block_inside CB                                    {
                                                                global = $2;
                                                                $$ = $2;
                                                            }
    ;

block_inside
    : statement_list block statement_list                   {
                                                                symtab_t *curr_table = (symtab_t *)malloc(sizeof(symtab_t));
                                                                curr_table->MChead = $1;
                                                                curr_table->child = $2;

                                                                headOrRoot *temp = $1;
                                                                while(temp->next != NULL)
                                                                {
                                                                    temp = temp->next;
                                                                }
                                                                temp->next = $3;

                                                                $$ = curr_table;
                                                            }
    | statement_list block                                  {
                                                                symtab_t *curr_table = (symtab_t *)malloc(sizeof(symtab_t));
                                                                curr_table->MChead = $1;
                                                                curr_table->child = $2;
                                                                $$ = curr_table;
                                                            }
    | block statement_list                                  {
                                                                symtab_t *curr_table = (symtab_t *)malloc(sizeof(symtab_t));
                                                                curr_table->MChead = $2;
                                                                curr_table->child = $1;
                                                                $$ = curr_table;
                                                            }
    | statement_list                                        {
                                                                symtab_t *curr_table = (symtab_t *)malloc(sizeof(symtab_t));
                                                                curr_table->MChead = $1;
                                                                curr_table->child = NULL;
                                                                $$ = curr_table;
                                                            }
    ;

statement_list
    : statement_list statement                              {
                                                                headOrRoot *temp = $1;
                                                                while(temp->next != NULL)
                                                                {
                                                                    temp = temp->next;
                                                                }
                                                                temp->next = $2;
                                                                $$ = $1;
                                                            }
    | statement
    ;

statement
    : decleration SCOL                                      {
                                                                headOrRoot *temp = (headOrRoot *)malloc(sizeof(headOrRoot));
                                                                temp->head = $1;
                                                                temp->root = NULL;
                                                                temp->next = NULL;
                                                                $$ = temp; 
                                                            }
    | assignment SCOL                                       {
                                                                headOrRoot *temp = (headOrRoot *)malloc(sizeof(headOrRoot));
                                                                temp->head = NULL;
                                                                temp->root = $1;
                                                                temp->next = NULL;
                                                                $$ = temp; 
                                                            }
    ;

decleration
    : type_specifier arg_list                               {
                                                                entry_t *temp = $2;
                                                                while(temp != NULL)
                                                                {
                                                                    strcpy(temp->type, $1);
                                                                    if(temp->size != -1 && (strcmp($1, "int") == 0 || strcmp($1, "float") == 0))
                                                                        temp->size *= 4;
                                                                    else if(temp->size == -1)
                                                                        temp->size = 4;

                                                                    temp = temp->next;
                                                                }
                                                                $$ = $2;
                                                            }
    ;

arg_list
    : arg_list COMMA arg                                    {
                                                                entry_t *temp = $1;
                                                                while(temp->next != NULL)
                                                                {
                                                                    temp = temp->next;
                                                                }
                                                                temp->next = $3;
                                                                $$ = $1;
                                                            }
    | arg
    ;

arg
    : ID EQ const                                           {
                                                                entry_t *new_entry = (entry_t *) malloc(sizeof(entry_t));
                                                                strcpy(new_entry->name, $1);
                                                                strcpy(new_entry->value, $3);
                                                                new_entry->size = 1;
                                                                new_entry->next = NULL;
                                                                $$ = new_entry;
                                                            }
    | ID BOX                                                {   
                                                                entry_t *new_entry = (entry_t *) malloc(sizeof(entry_t));
                                                                strcpy(new_entry->name, $1);
                                                                if($2 == 0)
                                                                    new_entry->size = 1;
                                                                else
                                                                    new_entry->size = $2;
                                                                new_entry->next = NULL;
                                                                $$ = new_entry;
                                                            }
    | STAR ID                                               {   
                                                                entry_t *new_entry = (entry_t *) malloc(sizeof(entry_t));
                                                                strcpy(new_entry->name, $2);
                                                                new_entry->size = -1;
                                                                new_entry->next = NULL;
                                                                $$ = new_entry; 
                                                            }
    ;

BOX
    : OS INT_CONST CS BOX                                   { $$ = atoi($2) + $4; }
    |                                                       { $$ = 0; }
    ;

const
    : INT_CONST                                             { strcpy($$, $1); }
    | FLOAT_CONST                                           { strcpy($$, $1); }
    | CHAR_CONST                                            { strcpy($$, $1); }
    ;

type_specifier
    : INT                                                   { strcpy($$, "int"); }
    | FLOAT                                                 { strcpy($$, "float"); }
    | CHAR                                                  { strcpy($$, "char"); }
    ;

assignment
    : ID EQ additive_expression                             {
                                                                node_t *new_node1 = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node1->op, $1);
                                                                new_node1->left = NULL;
                                                                new_node1->right = NULL;
                                                                
                                                                node_t *new_node2 = (node_t *)malloc(sizeof(node_t));                                                                
                                                                strcpy(new_node2->op, "=");
                                                                new_node2->left = new_node1;
                                                                new_node2->right = $3;
                                                                
                                                                $$ = new_node2;
                                                            } 
    ;

additive_expression
	: multiplicative_expression                             {
                                                                $$ = $1;
                                                            }
	| additive_expression AOP multiplicative_expression     {
                                                                node_t *new_node = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node->op, $2);
                                                                new_node->left = $1;
                                                                new_node->right = $3;
                                                                $$ = new_node;
                                                            }
	;

multiplicative_expression
	: primary_expression                                    {
                                                                $$ = $1;
                                                            }
	| multiplicative_expression MOP primary_expression      {
                                                                node_t *new_node = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node->op, $2);
                                                                new_node->left = $1;
                                                                new_node->right = $3;
                                                                $$ = new_node;
                                                            }
	| multiplicative_expression STAR primary_expression     {
                                                                node_t *new_node = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node->op, "*");
                                                                new_node->left = $1;
                                                                new_node->right = $3;
                                                                $$ = new_node;
                                                            }
	;

primary_expression
	: ID                                                    { 
                                                                node_t *new_node = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node->op, $1);
                                                                new_node->left = NULL;
                                                                new_node->right = NULL;
                                                                $$ = new_node;
                                                            }
    | const                                                 { 
                                                                node_t *new_node = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node->op, $1);
                                                                new_node->left = NULL;
                                                                new_node->right = NULL;
                                                                $$ = new_node;
                                                            }
    | OP additive_expression CP                             { 
                                                                $$ = $2;
                                                            }
    ;


%%

int main(int argc, char** argv)
{
    yyin = fopen(argv[1], "r");
    yyparse();
    //print_symtab(global);
    generateCode(global);
    return 0;
}

int yyerror(const char *s)
{
    printf("error: %s\n", s);
    exit(0);
}

void print_symtab(symtab_t *global)
{
    headOrRoot *stmt = global->MChead;
    int address = 0;

    while(stmt != NULL)
    {
        if(stmt->head != NULL)
        {
            entry_t *entry = stmt->head;

            while(entry != NULL)
            {                    
                printf("0x%x %s %s ", address, entry->name, entry->type);

                if(entry->value[0] != '\0')
                    printf("%s ", entry->value);
                else
                    printf("NA ");

                printf("%d\n", entry->size);

                address += entry->size;
                entry = entry->next;
            }
        }

        stmt = stmt->next;
    }
    printf("\n");

    if(global->child != NULL)
        print_symtab(global->child);

    if(global->next != NULL)
        print_symtab(global->next);

    return;
}

void generateCode(symtab_t *global)
{
    headOrRoot *stmt = global->MChead;

    while(stmt != NULL)
    {
        if(stmt->root != NULL)
            postOrder(global, stmt, stmt->root);

        stmt = stmt->next;
    }
    printf("\n");

    if(global->child != NULL)
        generateCode(global->child);

    if(global->next != NULL)
        generateCode(global->next);

    return;
}

void postOrder(symtab_t *table, headOrRoot *stmt, node_t *root)
{
    static int i = -1;
    char type[10];

    strcpy(type, varCheck(table, stmt, root->left->op));
    postOrderUtil(table, stmt, root->right, type, &i);
    printf("%s = t%d\n", root->left->op, i);       
}

int postOrderUtil(symtab_t *table, headOrRoot *stmt, node_t *root, char type[], int *i)
{
    if(root->left->left == NULL && root->left->right == NULL && root->right->left == NULL && root->right->right == NULL)
    {
        char type1[10], type2[10];
        if(isNumber(root->left->op) == 0)
            strcpy(type1, varCheck(table, stmt, root->left->op));
        else if(isNumber(root->left->op) == 1)
            strcpy(type1, "int");
        else if(isNumber(root->left->op) == 2)
            strcpy(type1, "float");

        if(isNumber(root->right->op) == 0)        
            strcpy(type2, varCheck(table, stmt, root->right->op));
        else if(isNumber(root->right->op) == 1)
            strcpy(type2, "int");
        else if(isNumber(root->right->op) == 2)
            strcpy(type2, "float");

        (*i)++;
        if(strcmp(type1, type) == 0 && strcmp(type2, type) == 0)
            printf("t%d = %s %s %s\n", *i, root->left->op, root->op, root->right->op);
        else if(strcmp(type1, type) == 0 && strcmp(type2, type) != 0)
            printf("t%d = %s %s (%s)%s\n", *i, root->left->op, root->op, type, root->right->op);
        else if(strcmp(type1, type) != 0 && strcmp(type2, type) == 0)
            printf("t%d = (%s)%s %s %s\n", *i, type, root->left->op, root->op, root->right->op);

        return *i;
    }
    else if(root->left->left == NULL && root->left->right == NULL && root->right->left != NULL && root->right->right != NULL)
    {
        char type1[10];
        if(isNumber(root->left->op) == 0)
            strcpy(type1, varCheck(table, stmt, root->left->op));
        else if(isNumber(root->left->op) == 1)
            strcpy(type1, "int");
        else if(isNumber(root->left->op) == 2)
            strcpy(type1, "float");
        
        int index2 = postOrderUtil(table, stmt, root->right, type, i);

        (*i)++;
        if(strcmp(type1, type) == 0)
            printf("t%d = %s %s t%d\n", *i, root->left->op, root->op, index2);
        else if(strcmp(type1, type) != 0)
            printf("t%d = (%s)%s %s t%d\n", *i, type, root->left->op, root->op, index2);

        return *i;
    }
    else if(root->left->left != NULL && root->left->right != NULL && root->right->left == NULL && root->right->right == NULL)
    {
        char type2[10];
        if(isNumber(root->right->op) == 0)
            strcpy(type2, varCheck(table, stmt, root->right->op));
        else if(isNumber(root->right->op) == 1)
            strcpy(type2, "int");
        else if(isNumber(root->right->op) == 2)
            strcpy(type2, "float");
        
        int index1 = postOrderUtil(table, stmt, root->left, type, i);

        (*i)++;
        if(strcmp(type2, type) == 0)
            printf("t%d = t%d %s %s\n", *i, index1, root->op, root->right->op);
        else if(strcmp(type2, type) != 0)
            printf("t%d = t%d %s (%s)%s\n", *i, index1, root->op, type, root->right->op);

        return *i;
    }
    
    int index1 = postOrderUtil(table, stmt, root->left, type, i);
    int index2 = postOrderUtil(table, stmt, root->right, type, i);

    (*i)++;
    printf("t%d = t%d %s t%d\n", *i, index1, root->op, index2);
    return *i;
}

char *varCheck(symtab_t *table, headOrRoot *stmt, char var[])
{
    headOrRoot *temp = table->MChead;
    
    while(temp != NULL && temp != stmt)
    {
        if(temp->head != NULL)
        {
            entry_t *entry = temp->head;

            while(entry != NULL)
            {
                if(strcmp(entry->name, var) == 0)
                    return entry->type;

                entry = entry->next;
            }
        }

        temp = temp->next;
    }

    char err[50] = "undefined reference to ";
    strcat(err, var);
    yyerror(err);
}

int isNumber(char str[])
{
    int flag = 0;
    for(int i = 0; str[i] != '\0'; i++)
    {
        if(isdigit(str[i]) == 0 && str[i] != '.')
            return 0;
        if(str[i] == '.')
            flag = 1;
    }

    if(flag == 1)
        return 2;       // floating point.
    else
        return 1;       // integer.
}