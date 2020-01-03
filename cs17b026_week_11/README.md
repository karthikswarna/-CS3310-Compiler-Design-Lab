# [CS3310]Compiler Design Lab: Week-11

## I. ASSUMPTIONS:
    1. Scope of variables are checked and error is thrown if they don't exist. Hence, the sample test case gives different output.
    2. Intermediate Code and Instructions are not optimized and may contain redundant instructions.
    3. Precedence and Associativity are considered while constructing Instructions. Hence, the sample test case gives different output(order of operations).

## II. Output Format for Intermediate Code:
    1. The output gives intermediate code for each of the arithmetic assignment statements.
    2. Statements in different blocks are saperated with a blank line.
    3. If an undeclared variable is used in an expression, error is thrown and exits.
    4. All the variables on RHS which are not the type of LHS will be implicitly casted (both narrow and wide conversion are done).

## III. Output Format for MIPS Instructions:
    1. The output gives instructions for each of the arithmetic assignment statements.
    2. Each of the intermediate code statement is translated into a sets of instructions which are saperated by a new line.
    3. Load Immediate(LI) instruction will be used if the operand is a constant.

## IV. NOTE: 
    1. To print the symbol table, uncomment line number 337 (3rd line in main()). 
    2. Problem description can be found in `Lab11.pdf`.