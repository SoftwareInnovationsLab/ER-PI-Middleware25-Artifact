#include <iostream>
#include <vector>
#include <algorithm>
#include <sstream>

using namespace std;

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        cerr << "Usage: " << argv[0] << " <value of n>\n";
        return 1;
    }

    int n = atoi(argv[1]);

    // Declare a vector to store numbers from 1 to n
    vector<int> numbers;
    for (int i = 1; i <= n; ++i)
    {
        numbers.push_back(i);
    }

    // vector<string> eventNames;
    for (int i = 1; i <= n; ++i)
    {
        ostringstream oss;
        oss << ".decl event" << i << "(lc : number)";
        cout << oss.str() << endl;
    }
    cout << ".decl il(";
    for (int i = 1; i <= n; ++i)
    {
        cout << "e" << i << ": number";
        ;
        if (i != n)
            cout << ", ";
    }
    cout << ")\n";
    cout << ".decl cr(";
    for (int i = 1; i <= n; ++i)
    {
        cout << "e" << i << ": number";
        ;
        if (i != n)
            cout << ", ";
    }
    cout << ")\n";
    for (int i = 1; i <= n; ++i)
    {
        for (int j = 1; j <= n; ++j)
        {
            ostringstream oss;
            oss << "event" << i;
            oss << "(" << j << ").";
            cout << oss.str() << endl;
        }
    }
    // Generate and output all permutations
    do
    {
        cout << "il(";
        for (int i = 0; i < n; ++i)
        {
            ostringstream oss;
            cout << oss.str() << numbers[i];
            if (i != n - 1)
            {
                cout << ", ";
            }
        }
        cout << ").\n";
    } while (next_permutation(numbers.begin(), numbers.end()));

    // Write the rules to prune
    cout << "cr(";
    for (int i = 1; i <= n; ++i)
    {
        cout << "N" << i;
        if (i != n)
            cout << ", ";
    }
    cout << ") :- ";
    cout << "il(";
    for (int i = 1; i <= n; ++i)
    {
        cout << "N" << i;
        if (i != n)
            cout << ", ";
    }
    cout << "), ";
    
    cout << "N1 < N2, N3 > N4, N6 = 6.\n";
    cout << ".output cr";

    return 0;
}
