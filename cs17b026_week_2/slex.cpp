#include<unordered_map>
#include<unordered_set>
#include<algorithm>
#include<iostream>
#include<fstream>
#include<vector>
#include<string>

using namespace std;

int main(int argc, char **argv)
{
    if(argc == 4)      // process only if number of arguments are 4.
    {
        unordered_map<string, vector<string>> Table;  // Transition table.
        unordered_set<string> finalStates;            // Set of final states.
        vector<char> inputAlphabet;                   // Array of input alphabet.
        vector<string> states;                        // Array of states in a given 'order'.
        string curr_state, init_state;                // variables which hold the current state and initial state.
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
            curr_state = init_state;
            for(int i = 0; i < temp.size(); i++)
            {
                curr_state = Table[curr_state].at(find(inputAlphabet.begin(), inputAlphabet.end(), temp.at(i)) - inputAlphabet.begin());
            }

            if(finalStates.find(curr_state) != finalStates.end())
                cout << "yes" << endl;
            else
                cout << "no" << endl;
        }

        fin.close();     // Close strings.txt file.
    }
    else
        cout << "Enter all the required command line arguments." << endl;
    
    return 0;
}