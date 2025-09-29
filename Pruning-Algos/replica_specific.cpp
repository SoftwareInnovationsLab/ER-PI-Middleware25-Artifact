#include <iostream>
#include <vector>
#include <map>
#include <tuple>
#include <fstream>
#include <sstream>
#include <algorithm>

using namespace std;

struct Event
{
    int replicaId;
    string type;
};

vector<vector<Event>> read_interleavings(const string &filename)
{
    vector<vector<Event>> interleavings;
    ifstream infile(filename);
    string line;

    while (getline(infile, line))
    {
        vector<Event> interleaving;
        stringstream ss(line);
        int replicaId;
        string type;

        while (ss >> replicaId >> type)
        {
            interleaving.push_back({replicaId, type});
        }

        interleavings.push_back(interleaving);
    }

    return interleavings;
}

vector<int> index_in_interleaving(int rID, const vector<Event> &il)
{
    vector<int> indices;
    for (int i = 0; i < il.size(); ++i)
    {
        if (il[i].replicaId == rID)
        {
            indices.push_back(i);
        }
    }
    return indices;
}

vector<Event> events_after_indices(const vector<Event> &il, const vector<int> &idx)
{
    vector<Event> remaining_events;
    for (int i : idx)
    {
        for (int j = i + 1; j < il.size(); ++j)
        {
            remaining_events.push_back(il[j]);
        }
    }
    return remaining_events;
}

bool containsAll(const vector<Event> &il, const vector<Event> &ge)
{
    for (const auto &e : ge)
    {
        auto it = find_if(il.begin(), il.end(), [&](const Event &ev)
                          { return ev.replicaId == e.replicaId && ev.type == e.type; });
        if (it == il.end())
            return false;
    }
    return true;
}

vector<vector<Event>> exclude(const vector<vector<Event>> &ils,
                              const vector<vector<Event>> &grouped_events)
{
    vector<vector<Event>> pruned_interleavings;
    for (const auto &il : ils)
    {
        bool include = true;
        for (const auto &ge : grouped_events)
        {
            if (containsAll(il, ge))
            {
                include = false;
                break;
            }
        }
        if (include)
        {
            pruned_interleavings.push_back(il);
        }
    }
    return pruned_interleavings;
}

void save_interleavings(const vector<vector<Event>> &interleavings, const string &filename)
{
    ofstream outfile(filename);

    for (const auto &il : interleavings)
    {
        for (const auto &event : il)
        {
            outfile << event.replicaId << " " << event.type << " ";
        }
        outfile << endl;
    }
}

int main()
{
    int rID;
    cin >> rID;
    vector<vector<Event>> ILs = read_interleavings("events.dl");
    map<vector<int>, vector<vector<Event>>> grouped_by_indices;
    vector<vector<Event>> grouped_events;
    vector<vector<Event>> RI;

    for (const auto &il : ILs)
    {
        vector<int> indices = index_in_interleaving(rID, il);

        if (grouped_by_indices.find(indices) == grouped_by_indices.end())
        {
            grouped_by_indices[indices] = {};
        }
        grouped_by_indices[indices].push_back(il);
    }

    for (const auto &[idx, ils] : grouped_by_indices)
    {
        vector<Event> evs = events_after_indices(ils[0], idx);
        grouped_events.push_back(evs);
    }

    RI = exclude(ILs, grouped_events);

    save_interleavings(RI, "RI.dl");

    return 0;
}
