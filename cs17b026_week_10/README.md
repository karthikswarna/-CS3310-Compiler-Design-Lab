# [CS3310]Compiler Design Lab: Week-10

## I. Output Format:
    1. The output gives intermediate code for each of the arithmetic assignment statements, if-else statements and while statements.
    2. Statements in different blocks are saperated with a blank line.
    3. If an undeclared variable is used in an expression, error is thrown and exits.
    4. All the variables on RHS which are not the type of LHS will be implicitly casted (both narrow and wide conversion are done).

## II. Limitations:
    1. Variable declarations which are inside if-else and while statements are not added to the symbol table, and hence compiler doesn't care about them.
    2. Unary operators (like !) are not included as it is not mentioned in problem statement.

## III. Test cases

### INPUT 1:

```
{
    int x, y;
    if(x < 100)
        x = x + 100;
    else
    {
        y = y + 5;
    }

    while(x < 100 || x > 200 && x != y)
    {
        x = x + 1;
        y = x + y;
    }
}
```

### OUTPUT 1:

```
if x < 100 goto L1
goto L2
L1:
t0 = x + 100
x = t0
goto L3
L2:
t1 = y + 5
y = t1
L3:
if x < 100 goto L4
goto L6
L6:
if x > 200 goto L7
goto L5
L7:
if x != y goto L4
goto L5
L4:
t2 = x + 1
x = t2
t3 = x + y
y = t3
goto L3
L5:
```

### INPUT 2:

```
{
    int x1 , x2 , y1 , y2 , dist;
    float m1, m2, m3, total , x , y ;
    dist = ( x1 - m2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 );
    total = m1 * m2 * m3;
    x = y + 5 ;
  
    if(x < 3 || x > 1)
    {
        x1 = 6;
        y2 = 90;
    }
    else
    {
        m1 = 25;
        m2 = 453;
        m1 = x1 - x2;
    }
    
    while(x > 7)
        x = x - 1;
}
```

### OUTPUT 2:

```
t0 = x1 - (int)m2
t1 = x1 - x2
t2 = t0 * t1
t3 = y1 - y2
t4 = y1 - y2
t5 = t3 * t4
t6 = t2 + t5
dist = t6
t7 = m1 * m2
t8 = t7 * m3
total = t8
t9 = y + (float)5
x = t9
if x < 3 goto L1
goto L3
L3:
if x > 1 goto L1
goto L2
L1:
x1 = 6
y2 = 90
goto L4
L2:
m1 = 25
m2 = 453
t10 = (float)x1 - (float)x2
m1 = t10
L4:
if x > 7 goto L5
goto L6
L5:
t11 = x - (float)1
x = t11
goto L4
L6:
```

## IV. NOTE: 
    1. To print the symbol table, uncomment line number 493 (3rd line in main()).
    2. Problem description can be found in `Lab10.pdf`.