# [CS3310]Compiler Design Lab: Week-6 

## I. Use the following commands:
    1. Use 'make' command to create 'rdparser' executable file.
    2. The rdparser can be executed using "./rdparser" command(for linux).
    3. An expression can be given as input to find whether it is valid or invalid.
    4. The command "make clean" can be used to remove rdparser, lex.yy.c, y.tab.c, y.tab.h, y.output files.

## II. GRAMMAR FOR C-EXPRESSIONS WITH ARITHMETIC, LOGICAL, RELATIONAL, EQUALITY OPERATORS IN BNF(BACKUS-NAUR FORM):

            <expression> ::= <logical-or-expression>

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

            <multiplicative-expression> ::= <primary-expression>
                                          | <multiplicative-expression> <multiplicative-operator> <primary-expression>

            <primary-expression> ::= <identifier>
                                   | <constant>
                                   | <string>
                                   | <expression>
                                   | <unary-operator> <expression>
                                
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


## III. ABOVE GRAMMAR AFTER REMOVING LEFT RECURSION AND NON-DETERMINISM (LEFT-FACTORED):
### NOTATION:

            O - <logical-or-expression> (START SYMBOL)
            A - <logical-and-expression>
            Q - <equality-expression>
            R - <relational-expression>
            S - <additive-expression>
            M - <multiplicative-expression>
            P - <primary-expression>
            C - <constant>
            uop - <unary-operator>
            eop - <equality-operator>
            rop - <relational-operator>
            aop - <additive-operator>
            mop - <multiplicative-operator>

### GRAMMAR:

            O ::= A O'
            O' ::= "||" A O' | ε

            A ::= Q A'
            A' ::= "&&" Q A' | ε

            Q ::= R Q'
            Q' ::= eop R Q' | ε

            R ::= S R'
            R' ::= rop S R' | ε

            S ::= M S'
            S' ::= aop M S' | ε

            M ::= P M'
            M' ::= mop P M' | ε

            P ::= <identifier> P' 
                | <constant> P' 
                | <string> P' 
                | uop O P'
            P' ::= M' S' R' Q' A' O' P' | ϵ
            
            <constant> ::= <integer-constant>
                         | <character-constant>
                         | <floating-constant>

            uop ::= ~ | !

            eop ::= == | !=

            rop ::= < | > | <= | >=

            aop ::= + | -
                                
            mop ::= * | / | %
        
### NOTE: Problem description can be found in `Lab6.pdf`.