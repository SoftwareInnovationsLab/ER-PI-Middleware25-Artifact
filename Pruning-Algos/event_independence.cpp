#include <iostream>
#include <vector>
#include <map>
#include <tuple>
#include <set>
#include <algorithm>
#include <fstream>
#include <sstream>

using namespace std;

struct Event {
    int id;
    string type;

    bool operator<(const Event& other) const {
        return tie(id, type) < tie(other.id, other.type);
    }

    bool operator==(const Event& other) const {
        return tie(id, type) == tie(other.id, other.type);
    }
};

vector<vector<Event>> read_interleavings(const string& filename) {
    vector<vector<Event>> interleavings;
    ifstream file(filename);
    string line;
    while (getline(file, line)) {
        vector<Event> interleaving;
        istringstream iss(line);
        int id;
        string type;
        while (iss >> id >> type) {
            interleaving.push_back({id, type});
        }
        interleavings.push_back(interleaving);
    }
    return interleavings;
}

set<Event> read_independent_events(const string& filename) {
    set<Event> independent_events;
    ifstream file(filename);
    int id;
    string type;
    while (file >> id >> type) {
        independent_events.insert({id, type});
    }
    return independent_events;
}

vector<int> independent_events_indices(const set<Event>& independent_events, const vector<Event>& interleaving) {
    vector<int> indices;
    for (size_t i = 0; i < interleaving.size(); ++i) {
        if (independent_events.find(interleaving[i]) != independent_events.end()) {
            indices.push_back(static_cast<int>(i));
        }
    }
    return indices;
}

vector<vector<Event>> exclude(const vector<vector<Event>>& interleavings, const vector<vector<Event>>& to_exclude) {
    vector<vector<Event>> result;
    for (const auto& il : interleavings) {
        if (find(to_exclude.begin(), to_exclude.end(), il) == to_exclude.end()) {
            result.push_back(il);
        }
    }
    return result;
}

int main() {
    vector<vector<Event>> ILs = read_interleavings("interleavings.dl");

    set<Event> IEvs = read_independent_events("independent_events.dl");

    vector<vector<Event>> grouped_interleavings;
    map<vector<int>, vector<vector<Event>>> grouped_by_indices;

    vector<vector<Event>> EI;

    for (const auto& il : ILs) {
        vector<int> indices = independent_events_indices(IEvs, il);
        if (grouped_by_indices.find(indices) == grouped_by_indices.end()) {
            grouped_by_indices[indices] = {};
        }
        grouped_by_indices[indices].push_back(il);
    }

    for (const auto& [idx, interleavings] : grouped_by_indices) {
        int index_first = idx[0];
        int index_last = idx.back();

        for (const auto& il : interleavings) {
            vector<Event> Evs(il.begin() + index_first, il.begin() + index_last + 1);

            bool all_independent = true;
            for (const auto& ev : Evs) {
                for (const auto& iev : IEvs) {
                    if (!(ev == iev)) {
                        all_independent = false;
                        break;
                    }
                }
                if (!all_independent) break;
            }

            if (all_independent) {
                grouped_interleavings.push_back(il);
            }
        }
    }

    EI = exclude(ILs, grouped_interleavings);

    ofstream outfile("independent_interleavings.dl");
    for (const auto& il : EI) {
        for (const auto& event : il) {
            outfile << event.id << " " << event.type << " ";
        }
        outfile << "\n";
    }
    outfile.close();

    return 0;
}
