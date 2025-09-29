#include <iostream>
#include <vector>
#include <tuple>
#include <algorithm>
#include <fstream>
#include <sstream>

using namespace std;

struct Event {
    int fromReplicaId;
    int toReplicaId;
    string type;
};

vector<Event> read_events(const string& filename) {
    vector<Event> events;
    ifstream infile(filename);
    string line;

    while (getline(infile, line)) {
        stringstream ss(line);
        int fromReplicaId, toReplicaId;
        string type;
        ss >> fromReplicaId >> toReplicaId >> type;
        events.push_back({fromReplicaId, toReplicaId, type});
    }

    return events;
}

vector<tuple<Event, Event>> read_specified_groups(const string& filename) {
    vector<tuple<Event, Event>> groups;
    ifstream infile(filename);
    string line;

    while (getline(infile, line)) {
        stringstream ss(line);
        int fromReplicaId1, toReplicaId1, fromReplicaId2, toReplicaId2;
        string type1, type2;
        ss >> fromReplicaId1 >> toReplicaId1 >> type1;
        ss >> fromReplicaId2 >> toReplicaId2 >> type2;

        groups.push_back({{fromReplicaId1, toReplicaId1, type1}, {fromReplicaId2, toReplicaId2, type2}});
    }

    return groups;
}

vector<vector<Event>> permute(const vector<Event>& events,
                                        const vector<tuple<Event, Event>>& grouped_events) {
    vector<vector<Event>> interleavings;
    for (const auto& event : events) {
        interleavings.push_back({event});
    }
    return interleavings;
}

void save_interleavings(const vector<vector<Event>>& interleavings, const string& filename) {
    ofstream outfile(filename);

    for (const auto& interleaving : interleavings) {
        for (const auto& event : interleaving) {
            outfile << event.fromReplicaId << " " << event.toReplicaId << " " << event.type << " ";
        }
        outfile << endl;
    }
}

int main() {
    vector<Event> events = read_events("events.dl"); 
    vector<tuple<Event, Event>> spec_group = read_specified_groups("groups.dl"); 
    vector<tuple<Event, Event>> grouped_events;
    vector<vector<Event>> GI; 

    
    for (const auto& event_i : events) {
        for (const auto& event_j : events) {
            if ((event_i.type == "sync_req" && event_j.type == "exec_sync") ||
                (event_j.type == "sync_req" && event_i.type == "exec_sync")) {

                if (event_i.fromReplicaId == event_j.fromReplicaId &&
                    event_i.toReplicaId == event_j.toReplicaId) {
                    grouped_events.emplace_back(event_i, event_j);
                }
            }
        }
    }

    
    for (const auto& group : spec_group) {
        grouped_events.push_back(group);
    }

    GI = permute(events, grouped_events);

    save_interleavings(GI, "GI.dl");

    return 0;
}
