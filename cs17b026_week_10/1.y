%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include<ctype.h>
    #include<stdbool.h>
    
    /* a declaration's structure */
    typedef struct entry 
    {
        char name[25];
        char type[10];
        char value[10];
        int size;
        struct entry *next;
    } entry_t;

    /* node of the syntax tree for expressions */
    typedef struct node
    {
        char op[25];
        struct node *left;
        struct node *right;
    } node_t;

    /* node of the syntax tree for if-else statement */
    typedef struct ifNode
    {
        struct node *condition;
        struct expStatement *ifBody;
        struct expStatement *elseBody;
    } ifNode_t;

    /* node of the syntax tree for while statement */
    typedef struct whileNode
    {
        struct node *condition;
        struct expStatement *body;
    } whileNode_t;

    /* an entry in symbol table */
    typedef struct expStatement
    {
        struct entry *head;
        struct node *root;
        struct ifNode *ifElse;
        struct whileNode *whileBod;
        struct expStatement *next;
    } expStatement;

    /* symbol table structure */
    typedef struct symtab
    {
        struct expStatement *MChead;
        struct symtab *child;
        struct symtab *next;
    } symtab_t;

    symtab_t *global = NULL;

    // Variables to avoid additional goto's.
    bool labelFlag = false;
    int aftermath = -1;
    extern FILE* yyin;
    
    int yylex();
    int yyerror(const char *);

    /* Function to print symbol table. */
    void print_symtab(symtab_t *);

    /* The set of five functions work together to produce the intermediate code.*/
    void generateCode(symtab_t *);
    void postOrder(symtab_t *, expStatement *, char);
    int postOrderUtil(symtab_t *, expStatement *, node_t *, char [], int *);
    void generateCtrlBody(symtab_t *, expStatement *, int *, int *);
    void generateBoolean(symtab_t *, expStatement *, node_t *, int, int, int *, int *); // Postorder traversal.

    
    /* 
        Checks if the variable is declared previously, if yes return var->type, else throw error.
        Takes pointer to symbol table and a pointer to place where variable is used.
    */
    char *varCheck(symtab_t *, expStatement *, char []);
    
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
    struct ifNode *ifNode;
    struct whileNode *whileNode;
    struct expStatement *expStatement;
    struct symtab *symtab;
}

%token OB CB OS CS OP CP EQ COMMA STAR LOR LAND SCOL IF ELSE WHILE

%token<value> INT_CONST  
%token<value> FLOAT_CONST 
%token<value> CHAR_CONST
%token<type> INT 
%token<type> FLOAT 
%token<type> CHAR
%token<name> ID
%token<name> EOP
%token<name> ROP
%token<name> AOP
%token<name> MOP
%token<name> UOP

%type<symtab> block;
%type<symtab> block_inside;
%type<expStatement> statement_list
%type<expStatement> statement
%type<entry> decleration
%type<entry> arg_list
%type<entry> arg
%type<size> BOX
%type<value> const
%type<type> type_specifier
%type<ifNode> selection_statement
%type<ifNode> else
%type<whileNode> iteration_statement
%type<node> assignment
%type<node> logical_or_expression
%type<node> logical_and_expression
%type<node> equality_expression
%type<node> relational_expression
%type<node> additive_expression
%type<node> multiplicative_expression
%type<node> primary_expression

%nonassoc then
%nonassoc ELSE


%%

block
    : OB block_inside CB block                              {
                                                                symtab_t *temp = $2;
                                                                temp->next = $4;
                                                                global = $2;
                                                                $$ = $2;
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

                                                                expStatement *temp = $1;
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

statement_list
    : statement_list statement                              {
                                                                expStatement *temp = $1;
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
                                                                expStatement *temp = (expStatement *)malloc(sizeof(expStatement));
                                                                temp->head = $1;
                                                                temp->root = NULL;
                                                                temp->ifElse = NULL;
                                                                temp->whileBod = NULL;
                                                                temp->next = NULL;
                                                                $$ = temp; 
                                                            }
    | assignment SCOL                                       {
                                                                expStatement *temp = (expStatement *)malloc(sizeof(expStatement));
                                                                temp->head = NULL;
                                                                temp->root = $1;
                                                                temp->ifElse = NULL;
                                                                temp->whileBod = NULL;
                                                                temp->next = NULL;
                                                                $$ = temp; 
                                                            }
    | selection_statement                                   {
                                                                expStatement *temp = (expStatement *)malloc(sizeof(expStatement));
                                                                temp->head = NULL;
                                                                temp->root = NULL;
                                                                temp->ifElse = $1;
                                                                temp->whileBod = NULL;
                                                                temp->next = NULL;
                                                                $$ = temp; 
                                                            }
    | iteration_statement                                   {
                                                                expStatement *temp = (expStatement *)malloc(sizeof(expStatement));
                                                                temp->head = NULL;
                                                                temp->root = NULL;
                                                                temp->ifElse = NULL;
                                                                temp->whileBod = $1;
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

selection_statement
    : IF OP logical_or_expression CP statement else             {
                                                                    ($6)->condition = $3;
                                                                    ($6)->ifBody = $5;
                                                                    $$ = $6;
                                                                }
    | IF OP logical_or_expression CP OB statement_list CB else  {
                                                                    ($8)->condition = $3;
                                                                    ($8)->ifBody = $6;
                                                                    $$ = $8;
                                                                }
    ;

else
    : ELSE statement                                        {
                                                                ifNode_t *new_node = (ifNode_t *)malloc(sizeof(ifNode_t));
                                                                new_node->elseBody = $2;
                                                                $$ = new_node;
                                                            }
    | ELSE OB statement_list CB                             {
                                                                ifNode_t *new_node = (ifNode_t *)malloc(sizeof(ifNode_t));
                                                                new_node->elseBody = $3;
                                                                $$ = new_node;
                                                            }
    | %prec then                                            {
                                                                ifNode_t *new_node = (ifNode_t *)malloc(sizeof(ifNode_t));
                                                                new_node->elseBody = NULL;
                                                                $$ = new_node;
                                                            }
    ; 

iteration_statement
    : WHILE OP logical_or_expression CP statement           {
                                                                whileNode_t *new_node = (whileNode_t *)malloc(sizeof(whileNode_t));
                                                                new_node->condition = $3;
                                                                new_node->body = $5;
                                                                $$ = new_node;
                                                            }
    | WHILE OP logical_or_expression CP OB statement_list CB{
                                                                whileNode_t *new_node = (whileNode_t *)malloc(sizeof(whileNode_t));
                                                                new_node->condition = $3;
                                                                new_node->body = $6;
                                                                $$ = new_node;
                                                            }
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

logical_or_expression 
    : logical_and_expression                                {
                                                                $$ = $1;
                                                            }
    | logical_or_expression LOR logical_and_expression      {
                                                                node_t *new_node = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node->op, "||");
                                                                new_node->left = $1;
                                                                new_node->right = $3;
                                                                $$ = new_node;
                                                            }
    ;

logical_and_expression
    : equality_expression                                   {
                                                                $$ = $1;
                                                            }
    | logical_and_expression LAND equality_expression       {
                                                                node_t *new_node = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node->op, "&&");
                                                                new_node->left = $1;
                                                                new_node->right = $3;
                                                                $$ = new_node;
                                                            }
    ;

equality_expression 
    : relational_expression                                 {
                                                                $$ = $1;
                                                            }
    | equality_expression EOP relational_expression         {
                                                                node_t *new_node = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node->op, $2);
                                                                new_node->left = $1;
                                                                new_node->right = $3;
                                                                $$ = new_node;
                                                            }
    ;

relational_expression 
    : additive_expression                                   {
                                                                $$ = $1;
                                                            }
    | relational_expression ROP additive_expression         {
                                                                node_t *new_node = (node_t *)malloc(sizeof(node_t));
                                                                strcpy(new_node->op, $2);
                                                                new_node->left = $1;
                                                                new_node->right = $3;
                                                                $$ = new_node;
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
    | OP logical_or_expression CP                           { 
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
    expStatement *stmt = global->MChead;
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
    expStatement *stmt = global->MChead;

    while(stmt != NULL)
    {
        if(stmt->root != NULL)
            postOrder(global, stmt, 'e');
        else if(stmt->ifElse != NULL)
            postOrder(global, stmt,'i');
        else if(stmt->whileBod != NULL)
            postOrder(global, stmt, 'w');

        stmt = stmt->next;
    }
    printf("\n");

    if(global->child != NULL)
        generateCode(global->child);

    if(global->next != NULL)
        generateCode(global->next);

    return;
}

void postOrder(symtab_t *table, expStatement *stmt, char mode)
{
    static int i = -1; // variable for temporary variables.
    static int j = 0; // variable for labels.
    char type[10];

    if(mode == 'e')
    {
        strcpy(type, varCheck(table, stmt, stmt->root->left->op));
        if(postOrderUtil(table, stmt, stmt->root->right, type, &i) == -1)
            printf("%s = %s\n", stmt->root->left->op, stmt->root->right->op);
        else
            printf("%s = t%d\n", stmt->root->left->op, i);
    }
    else if(mode == 'i')
    {
        j++; int trueLabel = j;
        j++; int falseLabel = j;
        
        generateBoolean(table, stmt, stmt->ifElse->condition, trueLabel, falseLabel, &i, &j);
        printf("L%d:\n", trueLabel);
        generateCtrlBody(table, stmt->ifElse->ifBody, &i, &j);
        
        j++; aftermath = j; 
        printf("goto L%d\n", j); labelFlag = true;

        printf("L%d:\n", falseLabel);
        generateCtrlBody(table, stmt->ifElse->elseBody, &i, &j);
        printf("L%d:\n", aftermath);
    }
    else
    {
        if(labelFlag == true)
        {
            j++; int trueLabel = j;
            j++; int falseLabel = j;
            generateBoolean(table, stmt, stmt->whileBod->condition, trueLabel, falseLabel, &i, &j);
            printf("L%d:\n", trueLabel);
            generateCtrlBody(table, stmt->whileBod->body, &i, &j);
            printf("goto L%d\n", aftermath);
            printf("L%d:\n", falseLabel);
        }
        else
        {
            j++; j++; int trueLabel = j;
            j++; int falseLabel = j;
            printf("L%d:\n", trueLabel - 1);
            generateBoolean(table, stmt, stmt->whileBod->condition, trueLabel, falseLabel, &i, &j);
            printf("L%d:\n", trueLabel);
            generateCtrlBody(table, stmt->whileBod->body, &i, &j);
            printf("goto L%d\n", trueLabel - 1);
            printf("L%d:\n", falseLabel);
        }
    }
}

void generateBoolean(symtab_t *table, expStatement *stmt, node_t *root, int trueLabel, int falseLabel, int *i, int *j)
{
    // Base case.
    if(root->left == NULL && root->right == NULL)
    {
        printf("if %s goto L%d\ngoto L%d\n", root->op, trueLabel, falseLabel);
    }

    // Recursive case.
    if(strcmp(root->op, ">") == 0 || strcmp(root->op, "<") == 0 || strcmp(root->op, "<=") == 0 || strcmp(root->op, ">=") == 0 || strcmp(root->op, "==") == 0 || strcmp(root->op, "!=") == 0)
    {
        int index1 = postOrderUtil(table, stmt, root->left, "float", i);
        int index2 = postOrderUtil(table, stmt, root->right, "float", i);

        printf("if t%d %s t%d goto L%d\ngoto L%d\n", index1, root->op, index2, trueLabel, falseLabel);
    }
    else if(strcmp(root->op, "&&") == 0)
    {
        (*j)++;
        generateBoolean(table, stmt, root->left, *j, falseLabel, i, j);
        printf("L%d:\n", *j);
        generateBoolean(table, stmt, root->right, trueLabel, falseLabel, i, j);
    }
    else if(strcmp(root->op, "||") == 0)
    {
        (*j)++;
        generateBoolean(table, stmt, root->left, trueLabel, *j, i, j);
        printf("L%d:\n", *j);
        generateBoolean(table, stmt, root->right, trueLabel, falseLabel, i, j);
    }
}

void generateCtrlBody(symtab_t *table, expStatement *body, int *i, int *j)
{
    expStatement *temp = body;
    char type[10];

    while(temp != NULL)
    {
        if(temp->root != NULL)
        {
            strcpy(type, varCheck(table, temp, temp->root->left->op));
            if(postOrderUtil(table, temp, temp->root->right, type, i) == -1)
                printf("%s = %s\n", temp->root->left->op, temp->root->right->op);
            else
                printf("%s = t%d\n", temp->root->left->op, *i);
        }
        else if(temp->ifElse != NULL)
        {
            (*j)++; int trueLabel = (*j);
            (*j)++; int falseLabel = (*j);
            generateBoolean(table, temp, temp->ifElse->condition, trueLabel, falseLabel, i, j);
            printf("L%d:\n", trueLabel);
            generateCtrlBody(table, temp->ifElse->ifBody, i, j);
            printf("L%d:\n", falseLabel);
            generateCtrlBody(table, temp->ifElse->elseBody, i, j);
        }
        else if(temp->whileBod != NULL)
        {
            (*j)++; (*j)++; int trueLabel = (*j);
            (*j)++; int falseLabel = (*j);
            printf("L%d:\n", trueLabel - 1);
            generateBoolean(table, temp, temp->whileBod->condition, trueLabel, falseLabel, i, j);
            printf("L%d:\n", trueLabel);
            generateCtrlBody(table, temp->whileBod->body, i, j);
            printf("goto L%d\n", trueLabel - 1);
            printf("L%d:\n", falseLabel);
        }

        temp = temp->next;
    }
}

int postOrderUtil(symtab_t *table, expStatement *stmt, node_t *root, char type[], int *i)
{
    if(root->left == NULL || root->right == NULL)
    {
        return -1;
    }

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
        else
            printf("t%d = (%s)%s %s (%s)%s\n", *i, type, root->left->op, root->op, type, root->right->op);

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

char *varCheck(symtab_t *table, expStatement *stmt, char var[])
{
    expStatement *temp = table->MChead;
    int flag = 0;
    
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