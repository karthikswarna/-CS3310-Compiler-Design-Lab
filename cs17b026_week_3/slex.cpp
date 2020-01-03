#include<unordered_map>
#include<unordered_set>
#include<algorithm>
#include<iostream>
#include<fstream>
#include<vector>
#include<string>
#include<stack>

using namespace std;

// Function which finds Eclosure of a given state and adds it into the stack.
void Eclosure(const unordered_map<string, vector<vector<string>>> &, stack<string> &, const string &);

// A utility function to find Eclosure.
void addState(const unordered_map<string, vector<vector<string>>> &, stack<string> &, unordered_set<string> &, const string &);

int main(int argc, char **argv)
{
    if(argc == 5)                                                   // process only if number of arguments are 5.
    {
        if(atoi(argv[4]) == 0)                                      // If it is NFA.
        {
            unordered_map<string, vector<vector<string>>> Table;    // Transition table.
            unordered_set<string> finalStates;                      // Set of final states.
            unordered_set<string> isPresent;                        // Set of states which are present in 'nextStates'(used to check the occurance).
            vector<char> inputAlphabet;                             // Array of input alphabet.
            vector<string> states;                                  // Array of states in a given order.
            stack<string> nextStates, currentStates;                // Stack which stores current set of states and next set of states in NFA.
            string temp, tempState;
            bool flag;

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

            // Close the table.txt file and open strings.txt.
            fin.close();
            fin.open("strings.txt");

            // Take strings one-by-one and simulate them through DFA.
            while(fin >> temp)
            {
                flag = false;

                Eclosure(Table, currentStates, states.at(0));  // Eclosure of initial state.
                for(int i = 0; i < temp.size(); i++)
                {
                    while(!currentStates.empty())
                    {
                        tempState = currentStates.top();
                        currentStates.pop();

                        vector<string> V = Table[tempState].at(find(inputAlphabet.begin(), inputAlphabet.end(), temp.at(i)) - inputAlphabet.begin());
                        if((V.size() == 1) && (V.at(0) == "^"))
                            continue;
                        
                        for(auto it = V.begin(); it != V.end(); it++)
                        {
                            if(isPresent.find(*it) == isPresent.end())
                                addState(Table, nextStates, isPresent, *it);
                        }
                    }

                    while(!nextStates.empty())          // copy all elements of nextStates to currentStates and continue.
                    {
                        tempState = nextStates.top();
                        nextStates.pop();
                        currentStates.push(tempState);
                    }

                    isPresent.clear();                  // no element in nextStates, so clear it.
                }

                while(!currentStates.empty())
                {
                    tempState = currentStates.top();
                    currentStates.pop();
                    if(finalStates.find(tempState) != finalStates.end())
                    {
                        cout << "yes" << endl;
                        flag = true;
                        break;
                    }
                }

                if(flag == false)
                    cout << "no" << endl;
            }

            fin.close();
        }
        else if(atoi(argv[4]) == 1)
        {
            unordered_map<string, vector<string>> Table;  // Transition table.
            unordered_set<string> finalStates;            // Set of final states.
            vector<char> inputAlphabet;                   // Array of input alphabet.
            vector<string> states;                        // Array of states in a given 'order'.
            string tempState, init_state;                 // variables which hold the current state and initial state.
            string temp; 

            ifstream fin;
            fin.open("table.txt");
            
            // taking a line from the file and inserting states into transition table.
            for(int i = 1; i <= atoi(argv[1]); i++) 
            { 
                fin >> temp;
                Table.insert({temp, vector<string>()});
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

            // creating transition table using data from the file.
            for(int i = 0; i < states.size(); i++)
            {
                for(int j = 1; j <= atoi(argv[3]); j++) 
                {
                    fin >> temp;
                    Table[states.at(i)].push_back(temp);
                }
            }

            init_state = states.at(0);
            fin.close();          // Close the table.txt file.
            states.clear();
            
            // Take strings one-by-one and simulate them through DFA.
            fin.open("strings.txt");
            while(fin >> temp)
            {
                tempState = init_state;
                for(int i = 0; i < temp.size(); i++)
                {
                    tempState = Table[tempState].at(find(inputAlphabet.begin(), inputAlphabet.end(), temp.at(i)) - inputAlphabet.begin());
                }

                if(finalStates.find(tempState) != finalStates.end())
                    cout << "yes" << endl;
                else
                    cout << "no" << endl;
            }

            fin.close();     // Close strings.txt file.
        }
    }
    else
        cout << "Enter all the required command line arguments." << endl;
    
    return 0;
}

void Eclosure(const unordered_map<string, vector<vector<string>>> &Table, stack<string> &States, const string &current)
{
    unordered_set<string> visited;
    addState(Table, States, visited, current);
    return;
}

void addState(const unordered_map<string, vector<vector<string>>> &Table, stack<string> &States, unordered_set<string> &visited, const string &current)
{
    States.push(current);
    visited.insert(current);

    vector<string> V = Table.find(current)->second.back();
    if(V.size() == 1 && V.at(0) == "^")
        return;
    
    for(auto it = V.begin(); it != V.end(); it++)
    {
        if(visited.find(*it) == visited.end())
            addState(Table, States, visited, *it);
    }
}