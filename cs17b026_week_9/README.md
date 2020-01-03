# [CS3310]Compiler Design Lab: Week-9

## I. Use the following commands:
    1. Use 'make' command to create 'minicc' executable file.
    2. The minicc can be executed using "./minicc <file name>" command(for linux).
    3. The command "make clean" can be used to remove minicc, lex.yy.c, y.tab.c, y.tab.h, y.output files.

## II. Output Format:
    1. The output gives intermediate code for each of the arithmetic assignment statements.
    2. Statements in different blocks are saperated with a blank line.
    3. If an undeclared variable is used in an expression, error is thrown and exits.
    4. All the variables on RHS which are not the type of LHS will be implicitly casted (both narrow and wide conversion are done).

## III. NOTE: 
    1. To print the symbol table, uncomment line number 336 (3rd line in main()).
    2. Problem description can be found in `Lab9.pdf`.