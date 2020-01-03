%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    
    /* the symbol table entry */
    typedef struct entry 
    {
        char *name;
        char *type;
        char *value;
        int size;
        int address;
        struct entry *next;
    } entry_t;

    /* the symbol table structure */
    typedef struct symtab
    {
        entry_t *entry_top;
        struct symtab *child;
        struct symtab *next;
    } symtab_t;

    symtab_t *global = NULL;
    extern FILE* yyin;
    
    int yylex();
    int yyerror(const char *);
    void print_symtab(symtab_t *);
%}


%union
{
    char *value;
    char *name;
    char *type;
    int size;
    struct entry *entry;
    struct symtab *symtab;
}

%token OB CB OS CS EQ COMMA STAR SCOL
%token<value> INT_CONST 
%token<value> FLOAT_CONST 
%token<value> CHAR_CONST
%token<type> INT 
%token<type> FLOAT 
%token<type> CHAR
%token<name> ID

%type<symtab> block;
%type<symtab> block_inside;
%type<entry> decleration_list
%type<entry> decleration
%type<entry> arg_list
%type<entry> expression
%type<size> BOX
%type<value> const
%type<type> type_specifier


%%

block
    : OB block_inside CB block                  {
                                                    symtab_t *temp = $2;
                                                    temp->next = $4;
                                                    global = $2;
                                                    $$ = $2;
                                                }
    | OB block_inside CB                        {
                                                    global = $2;
                                                    $$ = $2; 
                                                }
    ;

block_inside
    : decleration_list block decleration_list   {
                                                    symtab_t *curr_table = (symtab_t *)malloc(sizeof(symtab_t));
                                                    curr_table->entry_top = $1;
                                                    curr_table->child = $2;

                                                    entry_t *temp = $1;
                                                    while(temp->next != NULL)
                                                    {
                                                        temp = temp->next;
                                                    }
                                                    temp->next = $3;
                                                    $$ = curr_table;
                                                }
    | decleration_list block                    {
                                                    symtab_t *curr_table = (symtab_t *)malloc(sizeof(symtab_t));
                                                    curr_table->entry_top = $1;
                                                    curr_table->child = $2;
                                                    $$ = curr_table;
                                                }
    | block decleration_list                    {
                                                    symtab_t *curr_table = (symtab_t *)malloc(sizeof(symtab_t));
                                                    curr_table->entry_top = $2;
                                                    curr_table->child = $1;
                                                    $$ = curr_table;
                                                }
    | decleration_list                          {
                                                    symtab_t *curr_table = (symtab_t *)malloc(sizeof(symtab_t));
                                                    curr_table->entry_top = $1;
                                                    curr_table->child = NULL;
                                                    $$ = curr_table;
                                                }
    ;

decleration_list
    : decleration_list decleration              {
                                                    entry_t *temp = $1;
                                                    while(temp->next != NULL)
                                                    {
                                                        temp = temp->next;
                                                    }
                                                    temp->next = $2;
                                                    $$ = $1;
                                                }
    | decleration
    ;

decleration
    : type_specifier arg_list SCOL              {
                                                    entry_t *temp = $2;
                                                    while(temp != NULL)
                                                    {
                                                        temp->type = $1;
                                                        if(temp->size != -1 && ($1 == "int" || $1 == "float"))
                                                            temp->size = 4 * temp->size;
                                                        else if(temp->size == -1)
                                                            temp->size = 4;

                                                        temp = temp->next;
                                                    }
                                                    $$ = $2;
                                                }
    ;

arg_list
    : arg_list COMMA expression                 {
                                                    entry_t *temp = $1;
                                                    while(temp->next != NULL)
                                                    {
                                                        temp = temp->next;
                                                    }
                                                    temp->next = $3;
                                                    $$ = $1;
                                                }
    | expression
    ;

expression
    : ID EQ const                               {
                                                    entry_t *new_entry = (entry_t *) malloc(sizeof(entry_t));
                                                    new_entry->name = $1;
                                                    new_entry->value = $3;
                                                    new_entry->size = 1;
                                                    new_entry->next = NULL;
                                                    $$ = new_entry;
                                                }
    | ID BOX                                    {   
                                                    entry_t *new_entry = (entry_t *) malloc(sizeof(entry_t));
                                                    new_entry->name = $1;
                                                    if($2 == 0)
                                                        new_entry->size = 1;
                                                    else
                                                        new_entry->size = $2;
                                                    new_entry->value = NULL;
                                                    new_entry->next = NULL;
                                                    $$ = new_entry;
                                                }
    | STAR ID                                   {   
                                                    entry_t *new_entry = (entry_t *) malloc(sizeof(entry_t));
                                                    new_entry->name = $2;
                                                    new_entry->size = -1;
                                                    new_entry->value = NULL;
                                                    new_entry->next = NULL;
                                                    $$ = new_entry; 
                                                }
    ;

BOX
    : OS INT_CONST CS BOX                       { $$ = atoi($2) + $4; }
    |                                           { $$ = 0; } 
    ;

const
    : INT_CONST                                 { $$ = strdup($1); }
    | FLOAT_CONST                               { $$ = strdup($1); }
    | CHAR_CONST                                { $$ = strdup($1); }
    ;

type_specifier
    : INT                                       { $$ = "int"; }
    | FLOAT                                     { $$ = "float"; }
    | CHAR                                      { $$ = "char"; }
    ;

%%


int main(int argc, char** argv)
{
    if (argc != 2) 
    {
       printf("\nUsage: <exefile> <inputfile>\n\n");
       exit(0);
    }
    
    yyin = fopen(argv[1], "r");
    yyparse();
    print_symtab(global);

    return 0;
}

int yyerror(const char *s)
{
    printf("error: %s\n", s);
}

void print_symtab(symtab_t *global)
{
    entry_t *entry = global->entry_top;
    int address = 0;

    while(entry != NULL)
    {
        printf("0x%x %s %s ", address, entry->name, entry->type);

        if(entry->value != NULL)
            printf("%s ", entry->value);
        else
            printf("NA ");

        printf("%d\n", entry->size);

        address += entry->size;
        entry = entry->next;
    }
    printf("\n");

    if(global->child != NULL)
        print_symtab(global->child);

    if(global->next != NULL)
        print_symtab(global->next);

    return;
}