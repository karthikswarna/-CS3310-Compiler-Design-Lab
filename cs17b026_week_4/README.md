# [CS3310]Compiler Design Lab: Week-4

## I. Use the following commands:
    1. Use 'make' command to create 'slex' executable file.
    2. The input to the executable can be given through "./slex.out no_of states no_of_final_states no_of_alphabet" (for linux).
    3. The command "make clean" can be used to remove slex file.
    4. The program uses "table.txt" file to create the NFA and DFA; and "strings.txt" to take input strings.

## II. The NFA is generic enough:
    1. The name of a state can be a charecter or even a string of ASCII charecters.
    2. The input alphabet can be any ASCII charecter except $ and ^.

## III. THE DFA OBTAINED IS NOT A MINIMIZED DFA, SO IT MAY CONTAIN SOME STATE WHICH IS NOT A SET OF ANY NFA STATE(EMPTY SET). SUCH KIND OF STATES ARE CALLED "TRAP STATES"
    1. The state names of DFA created will be an upper case alphabet.

## IV. Algorithm for subset construction (NFA -> DFA conversion):

```
        // DTrans is the transition table.
        // DStates is a stack of sets of NFA states.
        // Visited is a set of states.
        // s0 - initial state.
        
        DStates.push(Eclosure(s0));
        while(DStates is not empty)
        {
            T = DStates.top();
            DStates.pop();
            add T to Visited;
            for(each input symbol a)
            {
                U = Eclosure(transition(T, a));
                if(U is not in Visited)
                    add U to DStates;
                DTrans[T, a] = U
            }
        }
```

## V. Algorithm for computing Eclosure of a set of states T:

```
        // T is a set of NFA states.

        push all states of T onto stack;
        initialize Eclosure(T) to T;
        while(stack is not empty)
        {
            t = stack.top();
            stack.pop();
            for(each state u with an edge from t to u labelled E)
            {
                if(u is not in Eclosure(T))
                {
                    add u to Eclosure(T);
                    push u onto stack;
                }
            }
        }
```

## VI. Algorithm for simulating a DFA:

```
        // F - set of final states.
        // s0 - initial state.

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

### NOTE: Problem description can be found in `Lab4.pdf`.