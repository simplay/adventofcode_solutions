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
        cout << year << " " << month << " " << day << " " << hour << " " << timestamp << endl;
        r.key = std::stol(year + month + day + hour + timestamp);

        records.push_back(r);
    }
    // cout << records.size() << endl;
    sort(records.begin(), records.end(), sortByKey);

    return records;
}

void runPart1()
{

    vector<Record> records = readFile("data.txt");
    Record r = records.at(1);
    for (std::vector<Record>::iterator v = records.begin(); v != records.end(); ++v)
    {
        cout << v->timestamp << " " << v->message << endl;
    }
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