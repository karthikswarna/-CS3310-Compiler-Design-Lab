#include<unordered_set>
#include<algorithm>
#include<iostream>
#include<fstream>
#include<vector>
#include<string>
#include<stack>
#include<map>

using namespace std;

void subsetConstruct(const map<string, vector<vector<string>>> &, map<char, vector<char>> &, unordered_set<char> &, const vector<char> &, const unordered_set<string> &, const string &);
void Eclosure(const map<string, vector<vector<string>>> &, unordered_set<string> &);
void Eclosure(const map<string, vector<vector<string>>> &, unordered_set<string> &, stack<string> &);

int main(int argc, char **argv)
{
    if(argc == 4)                                               // process only if number of arguments are 4.
    {
        map<string, vector<vector<string>>> Table;              // Transition table.
        unordered_set<string> finalStates;                      // Set of final states.
        vector<char> inputAlphabet;                             // Array of input alphabet.
        vector<string> states;                                  // Array of states in a given order.
        string temp;

        ifstream fin;
        fin.open("table.txt");
        
        // taking a line from the file and inserting states into transition table.
        for(int i = 1; i <= atoi(argv[1]); i++) 
        { 
            fin >> temp;
            Table.insert({temp, vector<vector<string>>()});
            states.push_back(temp);
        }

        // taking a line from the file and inserting final states into a set.
        for(int i = 1; i <= atoi(argv[2]); i++) 
        { 
            fin >> temp;
            finalStates.insert(temp);
        }

        // taking input alphabet from the file.
        char x;
        for(int i = 1; i <= atoi(argv[3]); i++) 
        { 
            fin >> x;
            inputAlphabet.push_back(x);
        }
        inputAlphabet.push_back('$');

        // creating transition table using data from the file.
        for(int i = 0; i < states.size(); i++)
        {
            for(int j = 0; j <= atoi(argv[3]); j++) 
            {
                fin >> temp;
                if(temp.size() == 1)
                    Table[states.at(i)].push_back(vector<string>{temp});
                else
                {
                    Table[states.at(i)].push_back(vector<string>{string(1, temp.at(0))});
                    for(int k = 2; k < temp.size(); k += 2)
                    {
                        Table[states.at(i)].at(j).push_back(string(1, temp.at(k)));
                    }
                }   
            }
        }

        // Close the table.txt file.
        fin.close();
        
        // Formatting the output to show the Transition table of NFA.
        cout << "Given NFA:" << endl;
        cout << "     ";
        for(int i = 0; i < inputAlphabet.size() - 1; i++)
            cout << inputAlphabet.at(i) << "   ";
        cout << '$' << endl << "-------------------------" << endl;

        for(auto it = Table.begin(); it != Table.end(); it++)
        {
            cout << it->first << " : ";
            for(auto it2 = it->second.begin(); it2 != it->second.end(); it2++)
            {
                if(it2->at(0) != "^")
                    cout << "{";
                for(auto it3 = it2->begin(); it3 != it2->end(); it3++)
                {
                    cout << *it3;
                    if(it3 != it2->end() - 1)
                        cout << ',';
                }
                if(it2->at(0) != "^")
                    cout << "}";
                cout << "  ";
            }
            cout << endl;
        }
        cout << "-------------------------" << endl;
        cout << "NOTE : The columns are not properly aligned, but the order of 'next states' in the table(for a given present state) is same as the order of input symbols" << endl << endl;

        // creating DFA by calling subsetConstruct() function.
        map<char, vector<char>> DTrans;
        unordered_set<char> DFinalStates;
        subsetConstruct(Table, DTrans, DFinalStates, inputAlphabet, finalStates, states.at(0));

        // open strings.txt and simulate the strings through the obtained DFA.
        fin.open("strings.txt");
        while(fin >> temp)
        {
            char state = DTrans.begin()->first; 
            for(int i = 0; i < temp.size(); i++)
            {
                state = DTrans.at(state).at(find(inputAlphabet.begin(), inputAlphabet.end(), temp.at(i)) - inputAlphabet.begin());
            }

            if(DFinalStates.find(state) == DFinalStates.end())
                cout << "no" << endl;
            else
                cout << "yes" << endl;
        }

        fin.close();
    }
    else
        cout << "Enter all the required command line arguments." << endl;
    
    return 0;
}

void subsetConstruct(const map<string, vector<vector<string>>> &Table, map<char, vector<char>> &DTrans, unordered_set<char> &DFinalStates, const vector<char> &inputAlphabet, const unordered_set<string> &finalStates, const string &init_state)
{
    stack<unordered_set<string>> DStates;
    unordered_set<char> Visited;
    unordered_set<string> T, U;
    vector<unordered_set<string>> StateNames;
    T.insert(init_state);
    Eclosure(Table, T);
    DStates.push(T);
    StateNames.push_back(T);

    while(!DStates.empty())
    {
        T = DStates.top();
        DStates.pop();

        if(Visited.find((char)((find(StateNames.begin(), StateNames.end(), T) - StateNames.begin()) + 65)) == Visited.end())
        {
            Visited.insert((char)((find(StateNames.begin(), StateNames.end(), T) - StateNames.begin()) + 65));
            
            for(int i = 0; i < inputAlphabet.size() - 1; i++)
            {
                for(auto it2 = T.begin(); it2 != T.end(); it2++)
                {
                    vector<string> NextStates = Table.find(*it2)->second.at(i);

                    if(NextStates.at(0) == "^")
                        continue;

                    for(int j = 0; j < NextStates.size(); j++)
                        U.insert(NextStates.at(j));

                    Eclosure(Table, U);
                }

                if(find(StateNames.begin(), StateNames.end(), U) == StateNames.end())
                {
                    StateNames.push_back(U);
                    DStates.push(U);

                    for(auto it = U.begin(); it != U.end(); it++)
                    {
                        if(finalStates.find(*it) != finalStates.end())
                        {
                            DFinalStates.insert((char)((find(StateNames.begin(), StateNames.end(), U) - StateNames.begin()) + 65));
                            break;
                        }
                    }
                }

                DTrans[(char)((find(StateNames.begin(), StateNames.end(), T) - StateNames.begin()) + 65)].push_back((char)((find(StateNames.begin(), StateNames.end(), U) - StateNames.begin()) + 65));
                U.clear();
            }
        }
    }

    // Formatting the output to print the transition table of obtained DFA.
    cout << endl << "Corresponding DFA:" << endl;
    cout << "    ";
    for(int i = 0; i < inputAlphabet.size() - 1; i++)
        cout << inputAlphabet.at(i) << ' ';
    cout << endl << "-------------------------" << endl;

    for(auto it = DTrans.begin(); it != DTrans.end(); it++)
    {
        cout << it->first << " : ";
        for(auto it2 = it->second.begin(); it2 != it->second.end(); it2++)
        {
            cout << *it2 << ' ';
        }
        cout << endl;
    }
    cout << "-------------------------" << endl << endl;

    cout << "Final States: " << endl;
    for(auto it = DFinalStates.begin(); it != DFinalStates.end(); it++)
        cout << *it << ' ';
    cout << endl << endl;

    bool flag = false;
    for(int i = 0; i < StateNames.size(); i++)
        if(StateNames.at(i).size() == 0)
        {
            if(flag == false)
            {
                cout << "Trap States: " << endl;
                flag = true;
            }
            cout << (char)(65 + i) << ' ';
        }
    if(flag == true)
        cout << endl << endl;

    cout << "where " << endl;
    for(int i = 0; i < StateNames.size(); i++)
    {
        cout << (char)(65 + i) << " = {";
        for(auto it = StateNames.at(i).begin(); it != StateNames.at(i).end(); it++)
        {
            cout << *it << ',';
        }
        cout << "}  " << endl;
    }
    cout << endl;
}

void Eclosure(const map<string, vector<vector<string>>> &Table, unordered_set<string> &T)
{
    stack<string> closure;

    for(auto it = T.begin(); it != T.end(); it++)
        closure.push(*it);
    
    Eclosure(Table, T, closure);
}

void Eclosure(const map<string, vector<vector<string>>> &Table, unordered_set<string> &Visited, stack<string> &closure)
{
    while(!closure.empty())
    {
        string t = closure.top();
        closure.pop();

        vector<string> V = Table.find(t)->second.back();

        if(V.at(0) == "^")
            continue;

        for(int i = 0; i < V.size(); i++)
        {
            if(Visited.find(V.at(i)) == Visited.end())
            {
                Visited.insert(V.at(i));
                closure.push(V.at(i));
            }
        }
    }
}