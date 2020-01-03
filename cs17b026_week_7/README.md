# [CS3310]Compiler Design Lab: Week-7

## I. Use the following commands:
    1. Use 'make' command to create 'myparser' executable file.
    2. The myparser can be executed using "./myparser" command(for linux).
    3. An expression can be given as input to find whether it is valid or invalid.
    4. The command "make clean" can be used to remove myparser, lex.yy.c, y.tab.c, y.tab.h, y.output files.

## II. GRAMMAR FOR C-EXPRESSIONS WITH ARITHMETIC, LOGICAL, RELATIONAL, EQUALITY OPERATORS IN BNF(BACKUS-NAUR FORM):

            <logical-or-expression> ::= <logical-and-expression>
                                      | <logical-or-expression> "||" <logical-and-expression>

            <logical-and-expression> ::= <equality-expression>
                                       | <logical-and-expression> "&&" <equality-expression>

            <equality-expression> ::= <relational-expression>
                                    | <equality-expression> <equality-operator> <relational-expression>

            <relational-expression> ::= <additive-expression>
                                      | <relational-expression> <relational-operator> <additive-expression>

            <additive-expression> ::= <multiplicative-expression> 
                                    | <additive-expression> <additive-operator> <multiplicative-expression> 

            <multiplicative-expression> ::= <unary_expression>
                                          | <multiplicative-expression> <multiplicative-operator> <unary_expression>

            <unary_expression> ::= <primary-expression>
                                 | <unary-operator> <unary_expression>

            <primary-expression> ::= <identifier>
                                   | <constant>
                                   | <string>
                                   | <logical-or-expression>
                                
            <constant> ::= <integer-constant>
                         | <character-constant>
                         | <floating-constant>

            <unary-operator> ::= ~
                               | !

            <equality-operator> ::= ==
                                  | !=

            <relational-operator> ::= <
                                    | >
                                    | <=
                                    | >=

            <additive-operator> ::= +
                                  | -
                                
            <multiplicative-operator> ::= *
                                        | /
                                        | %

### NOTE: Problem description can be found in `Lab7.pdf`.