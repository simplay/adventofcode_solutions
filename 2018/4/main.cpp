#include <string>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <regex>
#include <unordered_map>
#include <cstdio>

using namespace std;
struct Record
{
    string timestamp;
    string message;
    int minute;
    long key;
};

bool sortByKey(Record a, Record b)
{
    return a.key < b.key;
}

vector<Record> readFile(const char *filename)
{
    vector<Record> records;
    std::string delimiter = "] ";
    std::ifstream file(filename);
    std::string s;
    while (getline(file, s))
    {
        int pos = s.find(delimiter);
        string timestamp = s.substr(1, pos - 1);
        s.erase(0, pos + delimiter.length());
        Record r = Record();

        // [1518-11-04 00:46]
        r.timestamp = timestamp;
        r.message = s;

        pos = timestamp.find("-");
        string year = timestamp.substr(0, pos);
        timestamp.erase(0, pos + 1);

        pos = timestamp.find("-");
        string month = timestamp.substr(0, pos);
        timestamp.erase(0, pos + 1);

        pos = timestamp.find(" ");
        string day = timestamp.substr(0, pos);
        timestamp.erase(0, pos + 1);

        pos = timestamp.find(":");
        string hour = timestamp.substr(0, pos);
        timestamp.erase(0, pos + 1);

        // used for sorter
        // cout << year << " " << month << " " << day << " " << hour << " " << timestamp << endl;
        r.minute = stoi(timestamp);
        r.key = std::stol(year + month + day + hour + timestamp);

        records.push_back(r);
    }
    // cout << records.size() << endl;
    sort(records.begin(), records.end(), sortByKey);

    return records;
}

unordered_map<int, vector<int>> guardSchedules()
{
    unordered_map<int, vector<int>> schedule;

    vector<Record> records = readFile("data.txt");
    int fallAsleepMin;
    int wokeUpMin;

    for (std::vector<Record>::iterator v = records.begin(); v != records.end(); ++v)
    {
        vector<int> minutes_sleeping;
        int id, pos1, pos2;
        //cout << "message: " << v->message << " " << v->key << endl;
        switch (v->message[0])
        {
        case 'G':
            pos1 = (v->message).find("#");
            pos2 = (v->message).find(" ");
            id = stoi(v->message.substr(pos1 + 1, pos2 - 2));

            // todo: dont assign a boolean
            if (schedule.find(id) == schedule.end())
            {
                schedule[id] = minutes_sleeping;
            }

            //cout << "id " << id << endl;
            break;
        case 'f':
            fallAsleepMin = v->minute;
            break;
        case 'w':

            wokeUpMin = v->minute;
            //cout << id << " push min " << fallAsleepMin << " -> " << wokeUpMin - 1 << endl;
            for (int k = fallAsleepMin; k < wokeUpMin; k++)
            {
                //cout << "id push: " << id << " k = " << k << endl;
                schedule[id].push_back(k);
                //cout << "count for id = " << id << ": " << schedule[id].size() << endl;
            }
            break;
        }
    }
    return schedule;
}

void runPart1()
{
    unordered_map<int, vector<int>> schedules = guardSchedules();
    
    //cout << "count 10:" << schedule[10].size() << endl;
    int maxCount = -1;
    int maxId;
    unordered_map<int, vector<int>>::iterator itr;
    for (itr = schedules.begin(); itr != schedules.end(); itr++)
    {
        int c = itr->second.size();
        //cout << "id: " << itr->first << " count: " << c << endl;
        if (c > maxCount)
        {
            maxCount = c;
            maxId = itr->first;
        }
    }

    // Find largest overlap in schedule
    vector<int> scheduleMostSleepyGuard = schedules[maxId];
    int sleepCountPerMinute[60];
    for (int i = 0; i < 60; i++)
    {
        sleepCountPerMinute[i] = 0;
    }

    for (int i = 0; i < scheduleMostSleepyGuard.size(); i++)
    {
        int idx = scheduleMostSleepyGuard.at(i);
        sleepCountPerMinute[idx]++;
    }

    int maxSleepCount = -1;
    int mostFallenAsleepMinute;

    for (unsigned i = 0; i < 60; i++)
    {
        // cout << "min = " << i << " hits: " << sleepCountPerMinute[i] << endl;
        if (sleepCountPerMinute[i] > maxSleepCount)
        {
            maxSleepCount = sleepCountPerMinute[i];
            mostFallenAsleepMinute = i;
        }
    }

    cout << "Fallen asleep the most in minute: " << mostFallenAsleepMinute << endl;
    cout << "Id if most sleeping guard: " << maxId << endl;
    cout << "checksum: " << mostFallenAsleepMinute * maxId << endl;
}

void runPart2()
{
}

int main(int argc, char *argv[])
{
    std::string task = argv[1];
    if (task.compare("1") == 0)
    {
        std::cout << "Running Part 1" << std::endl;
        runPart1();
    }
    else
    {
        std::cout << "Running Part 2" << std::endl;
        runPart2();
    }
    return 0;
}