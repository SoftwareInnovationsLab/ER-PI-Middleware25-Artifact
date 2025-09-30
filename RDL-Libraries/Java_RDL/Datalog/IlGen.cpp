#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include <string>
#include <sstream>
#include <sys/stat.h>
#include <sys/types.h>

using namespace std;

void Create_Directory()
{
    struct stat st = {0};
    if (stat("interleavings/", &st) == -1)
    {
        mkdir("interleavings/", 0700);
    }
    // outputFile.open(fileName, ios_base::app);
}

unordered_map<int, string> mapEvents(const string &eventsFile)
{
    ifstream file(eventsFile);

    if (!file)
    {
        cerr << "Error: Could not open Facts file." << endl;
    }
    unordered_map<int, string> eventMap;
    string event;
    int count = 1;
    while (file >> event)
    {
        eventMap[count] = event;
        count++;
    }
    return eventMap;
}

// Function to replace numbers in a line of cr.csv with their corresponding events
string replaceNumbers(const string &line, const unordered_map<int, string> &eventMap)
{
    stringstream ss(line);
    int num;
    string result = "";
    int l_time = 1;
    while (ss >> num)
    {
        for (const auto &pair : eventMap)
        {
            if (pair.first == num)
            {
                result += pair.second + "_" + to_string(l_time++) + "\n";
                break;
            }
        }
    }
    return result;
}

int main()
{
    string eventsFile = "Events/events.facts";
    string csvFile = "cr.csv";

    // Step 1: Map events to serial numbers
    unordered_map<int, string> eventMap = mapEvents(eventsFile);

    // Step 2: Read the cr.csv file, replace numbers with events, and generate text files
    ifstream csv(csvFile);
    if (!csv)
    {
        cerr << "Error: Could not open Datalog file." << endl;
        return 1;
    }
    string line;
    int fileCount = 1;
    while (getline(csv, line))
    {
        string outputFile = "interleavings/ils_" + to_string(fileCount) + ".txt";
        Create_Directory();
        ofstream output(outputFile);
        if (!output)
        {
            cerr << "Error: Could not create output file " << outputFile << endl;
            return 1;
        }
        output << replaceNumbers(line, eventMap);
        output.close();
        fileCount++;
    }

    // cout << "Exhaustive interleavings generated successfully!" << endl;

    return 0;
}