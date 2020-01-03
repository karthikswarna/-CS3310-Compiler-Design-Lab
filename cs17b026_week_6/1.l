%{
    #include<iostream>
    #include<vector>
    #include<string>
    using namespace std;
    vector<string> tokens;
    
    bool CheckValidity(int &);
    bool O(int &);
    bool O1(int &);
    bool A(int &);
    bool A1(int &);
    bool Q(int &);
    bool Q1(int &);
    bool R(int &);
    bool R1(int &);
    bool S(int &);
    bool S1(int &);
    bool M(int &);
    bool M1(int &);
    bool P(int &);
    bool P1(int &);
    bool isValidIdentifier(int &);
    bool isValidConstant(int &);
%}

DIGIT [0-9]
CHAR [ -~]
INTEGER {DIGIT}+
FLOAT {DIGIT}*"."{DIGIT}+
CHAR_CONST [']{CHAR}[']
STRING ["]{CHAR}+["]
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*

UNARY_OPERATOR "~"|"!"
LOGICAL_OPERATOR "&&"|"||"
EQUALITY_OPERATOR "=="|"!="
RELATIONAL_OPERATOR "<"|">"|">="|"<="
ADDITIVE_OPERATOR "+"|"-"
MULTIPLICATIVE_OPERATOR "*"|"/"|"%"

%%

[ \t]                   
[\n]                    {return 0;}
[']{CHAR}{CHAR}+[']     {cout << "invalid" << endl; exit(0);}
{DIGIT}*[.]({DIGIT}*[.])+{DIGIT}+   {cout << "invalid" << endl; exit(0);}
{CHAR_CONST}|{STRING}|{IDENTIFIER}|{INTEGER}|{FLOAT}|{UNARY_OPERATOR}|{LOGICAL_OPERATOR}|{EQUALITY_OPERATOR}|{RELATIONAL_OPERATOR}|{ADDITIVE_OPERATOR}|{MULTIPLICATIVE_OPERATOR} {tokens.push_back(yytext);}
.                       {cout  << "invalid" << endl; exit(0);}

%%

int main(int argc, char **argv)
{
    yyin = stdin;
    yylex();

    int i = 0;
    if (CheckValidity(i))
        cout << "valid" << endl;
    else
        cout << "invalid" << endl;

    tokens.clear();
    return 0;
}

int yywrap()
{
    return 1;
}

bool CheckValidity(int &s) 
{
    int original = s;

    if (O(s)) 
    {
        if (s == tokens.size())
            return true;
        else 
        {
            s = original;
            return false;
        }
    }

    return false;
}

bool O(int &s)
{
    int original = s;

    if(!A(s))
    {
        s = original;
        return false;
    }

    if(!O1(s))
    {
        s = original;
        return false;
    }

    return true;
}

bool O1(int &s)
{
    if(tokens.size() == s)
        return true;

    int original = s;
    
    if(s < tokens.size() && (tokens.at(s) == "||"))
    {
        s += 1;
        if(!A(s))
        {
            s = original;
            return false;
        }

        if(!O1(s))
        {
            s = original;
            return false;
        }

        return true;
    }

    return true;
}

bool A(int &s)
{
    int original = s;

    if(!Q(s))
    {
        s = original;
        return false;
    }

    if(!A1(s))
    {
        s = original;
        return false;
    }

    return true;
}

bool A1(int &s)
{
    if(tokens.size() == s)
        return true;

    int original = s;
    
    if(s < tokens.size() && (tokens.at(s) == "&&"))
    {
        s += 1;
        if(!Q(s))
        {
            s = original;
            return false;
        }

        if(!A1(s))
        {
            s = original;
            return false;
        }

        return true;
    }

    return true;
}

bool Q(int &s)
{
    int original = s;

    if(!R(s))
    {
        s = original;
        return false;
    }

    if(!Q1(s))
    {
        s = original;
        return false;
    }

    return true;
}

bool Q1(int &s)
{
    if(tokens.size() == s)
        return true;

    int original = s;
    
    if(s < tokens.size() && (tokens.at(s) == "==" || tokens.at(s) == "!="))
    {
        s += 1;
        if(!R(s))
        {
            s = original;
            return false;
        }

        if(!Q1(s))
        {
            s = original;
            return false;
        }

        return true;
    }

    return true;
}

bool R(int &s)
{
    int original = s;

    if(!S(s))
    {
        s = original;
        return false;
    }

    if(!R1(s))
    {
        s = original;
        return false;
    }

    return true;
}

bool R1(int &s)
{
    if(tokens.size() == s)
        return true;

    int original = s;
    
    if(s < tokens.size() && (tokens.at(s) == ">" || tokens.at(s) == "<" || tokens.at(s) == ">=" || tokens.at(s) == "<="))
    {
        s += 1;
        if(!S(s))
        {
            s = original;
            return false;
        }

        if(!R1(s))
        {
            s = original;
            return false;
        }

        return true;
    }

    return true;
}

bool S(int &s)
{
    int original = s;

    if(!M(s))
    {
        s = original;
        return false;
    }

    if(!S1(s))
    {
        s = original;
        return false;
    }

    return true;
}

bool S1(int &s)
{
    if(tokens.size() == s)
        return true;

    int original = s;
    
    if(s < tokens.size() && (tokens.at(s) == "+" || tokens.at(s) == "-"))
    {
        s += 1;
        if(!M(s))
        {
            s = original;
            return false;
        }

        if(!S1(s))
        {
            s = original;
            return false;
        }

        return true;
    }

    return true;
}

bool M(int &s)
{
    int original = s;

    if(!P(s))
    {
        s = original;
        return false;
    }

    if(!M1(s))
    {
        s = original;
        return false;
    }

    return true;
}

bool M1(int &s)
{
    if(tokens.size() == s)
        return true;

    int original = s;

    if(s < tokens.size() && (tokens.at(s) == "*" || tokens.at(s) == "/" || tokens.at(s) == "%"))
    {
        s += 1;
        if(!P(s))
        {
            s = original;
            return false;
        }

        if(!M1(s))
        {
            s = original;
            return false;
        }

        return true;
    }

    return true;
}

bool P(int &s)
{
    int original = s;
        
    if(isValidIdentifier(s))
    {
        s += 1;
        if(!P1(s))
        {
            s = original;
            return false;
        }

        return true;
    }

    if(isValidConstant(s))
    {
        s += 1;
        if(!P1(s))
        {
            s = original;
            return false;
        }

        return true;
    }
        
    if(s < tokens.size() && (tokens.at(s) == "~" || tokens.at(s) == "!"))
    {
        s += 1;
        if(!O(s))
        {
            s = original;
            return false;
        }
        
        if(!P1(s))
        {
            s = original;
            return false;
        }

        return true;
    }
    
    s = original;
    return false;
}

bool P1(int &s)
{
    if(tokens.size() == s)
        return true;

    int original = s;

    if(!M1(s))
    {
        s = original;
        return false;
    }

    if(!S1(s))
    {
        s = original;
        return false;
    }

    if(!R1(s))
    {
        s = original;
        return false;
    }

    if(!Q1(s))
    {
        s = original;
        return false;
    }

    if(!A1(s))
    {
        s = original;
        return false;
    }

    if(!O1(s))
    {
        s = original;
        return false;
    }

    if(!P1(s))
    {
        s = original;
        return false;
    }

    return true;
}

bool isValidIdentifier(int &s) 
{
    if(tokens.size() == s)
        return false;
    int original = s;
  
    if (!( (tokens.at(s).at(0) >= 'a' && tokens.at(s).at(0) <= 'z') 
        || (tokens.at(s).at(0) >= 'A' && tokens.at(s).at(1) <= 'Z') 
        || tokens.at(s).at(0) == '_')) 
        return false; 
  
    for (int i = 1; i < tokens.at(s).size(); i++) 
    { 
        if (!( (tokens.at(s).at(i) >= 'a' && tokens.at(s).at(i) <= 'z') 
            || (tokens.at(s).at(i) >= 'A' && tokens.at(s).at(i) <= 'Z') 
            || (tokens.at(s).at(i) >= '0' && tokens.at(s).at(i) <= '9') 
            || tokens.at(s).at(i) == '_')) 
            return false; 
    }

    return true; 
}

bool isValidConstant(int &s)
{
    if(tokens.size() == s)
        return false;
    int original = s;
    bool flag = false;
    int i;

    if(tokens.at(s).at(0) == '"' && tokens.at(s).at(tokens.at(s).size() - 1) == '"')
        return true;
    if(tokens.at(s).at(0) == '\'' && tokens.at(s).at(tokens.at(s).size() - 1) == '\'' && tokens.at(s).size() == 3)
        return true;
    
    for(int i = 0; i < tokens.at(s).size(); i++)
        if(tokens.at(s).at(i) <= '0' || tokens.at(s).at(i) >= '9')
            break;
    if(i == tokens.at(s).size())
    {
        return true;
    }

    for(i = 0; i < tokens.at(s).size(); i++)
    {
        if(tokens.at(s).at(i) >= '0' && tokens.at(s).at(i) <= '9')
            continue;
        else if(tokens.at(s).at(i) == '.')
        {
            if(flag == false)
                flag = true;
            else
                break;
        }
        else
            break;
    }
    if(i == tokens.at(s).size())
    {
        return true;
    }

    s = original;
    return false;
}