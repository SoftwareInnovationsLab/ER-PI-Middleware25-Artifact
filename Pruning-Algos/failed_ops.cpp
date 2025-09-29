#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <algorithm>

using namespace std;

struct Event
{
    int id;
    bool operator<(const Event &other) const
    {
        return id < other.id;
    }
    bool operator==(const Event &other) const
    {
        return id == other.id;
    }
};

vector<vector<Event>> read_interleavings(const string &filename)
{
    ifstream file(filename);
    vector<vector<Event>> interleavings;
    if (!file.is_open())
    {
        throw runtime_error("Could not open file for reading.");
    }
    string line;
    while (getline(file, line))
    {
        vector<Event> interleaving;
        istringstream ss(line);
        int id;
        while (ss >> id)
        {
            interleaving.push_back(Event{id});
        }
        interleavings.push_back(interleaving);
    }
    file.close();
    return interleavings;
}

vector<Event> read_events(const string &filename)
{
    ifstream file(filename);
    vector<Event> events;
    if (!file.is_open())
    {
        throw runtime_error("Could not open file for reading.");
    }
    string line;
    while (getline(file, line))
    {
        istringstream ss(line);
        int id;
        while (ss >> id)
        {
            events.push_back(Event{id});
        }
    }
    file.close();
    return events;
}

vector<int> find_event_indices(const vector<Event> &events, const vector<Event> &interleaving)
{
    vector<int> indices;
    for (const auto &event : events)
    {
        auto it = find(interleaving.begin(), interleaving.end(), event);
        if (it != interleaving.end())
        {
            indices.push_back(distance(interleaving.begin(), it));
        }
    }
    return indices;
}

vector<int> concat(const vector<int> &v1, const vector<int> &v2)
{
    vector<int> result = v1;
    result.insert(result.end(), v2.begin(), v2.end());
    return result;
}

vector<vector<Event>> exclude(const vector<vector<Event>> &ILs,
                                        const map<vector<int>, vector<vector<Event>>> &grouped_by_indices)
{
    vector<vector<Event>> result = ILs;
    for (const auto &pair : grouped_by_indices)
    {
        for (const auto &il : pair.second)
        {
            auto it = remove(result.begin(), result.end(), il);
            if (it != result.end())
            {
                result.erase(it, result.end());
            }
        }
    }
    return result;
}

void write_interleavings(const string &filename, const vector<vector<Event>> &interleavings)
{
    ofstream file(filename);
    if (!file.is_open())
    {
        throw runtime_error("Could not open file for writing.");
    }
    for (const auto &il : interleavings)
    {
        for (const auto &e : il)
        {
            file << e.id << " ";
        }
        file << endl;
    }
    file.close();
}

int main()
{
    try
    {
        const string interleavings_file = "interleavings.txt";
        const string predecessor_events_file = "predecessor_events.txt";
        const string successor_events_file = "successor_events.txt";
        const string output_file = "failed_ops.dl";

        vector<vector<Event>> ILs = read_interleavings(interleavings_file);
        vector<Event> PEvents = read_events(predecessor_events_file);
        vector<Event> SEvents = read_events(successor_events_file);

        map<vector<int>, vector<vector<Event>>> grouped_by_indices;

        vector<vector<Event>> FI;

        for (const auto &il : ILs)
        {
            vector<int> pIdx = find_event_indices(PEvents, il);

            vector<int> sIdx = find_event_indices(SEvents, il);

            bool valid = true;
            for (const auto &p : pIdx)
            {
                bool found = false;
                for (const auto &s : sIdx)
                {
                    if (p < s)
                    {
                        found = true;
                        break;
                    }
                }
                if (!found)
                {
                    valid = false;
                    break;
                }
            }

            if (valid)
            {
                for (size_t i = 0; i < pIdx.size() - 1; ++i)
                {
                    if (pIdx[i] >= pIdx[i + 1] || sIdx[i] >= sIdx[i + 1])
                    {
                        valid = false;
                        break;
                    }
                }
            }

            if (valid)
            {
                vector<int> concatenated = concat(pIdx, sIdx);
                if (grouped_by_indices.find(concatenated) == grouped_by_indices.end())
                {
                    grouped_by_indices[concatenated] = {};
                }
                grouped_by_indices[concatenated].push_back(il);
            }
        }

        FI = exclude(ILs, grouped_by_indices);

        write_interleavings(output_file, FI);
        cout << "Failed operations have been written to " << output_file << endl;
    }
    catch (const exception &e)
    {
        cerr << "Error: " << e.what() << endl;
        return 1;
    }

    return 0;
}