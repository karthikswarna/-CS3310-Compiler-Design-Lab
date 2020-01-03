# [CS3310]Compiler Design Lab: Week-2

## I. Use the following commands:
    1. Use 'make' command to create 'slex' executable file.
    2. The input to the executable can be given through "./slex.out no_of states no_of_final_states no_of_alphabet" (for linux).
    3. The command "make clean" can be used to remove slex file.
    4. The program uses "table.txt" and "strings.txt" files to create the transition table and take input strings.

## II. The DFA is generic enough:
    1. The name of a state can be a charecter or even a string of ASCII charecters.
    2. The input alphabet can be any ASCII charecter except $ and ^.

## III. Algorithm for simulating a DFA:

```
        //F - set of final states.
        //s0 - initial state.

        S = s0;
        c = nextChar();
        while(c != EOF)
        {
            S = transition(S, c);   // Given current state and input symbol, next state can be found in DFA.
            c = nextChar();
        }

        if(S is present in F)
            return "yes"
        else
            return "no"
```

### NOTE: Problem description can be found in `Lab2.pdf`.