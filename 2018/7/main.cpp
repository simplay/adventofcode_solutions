#include <string>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <regex>
#include <unordered_map>
#include <cstdio>
#include <stack>
#include <cmath>

using namespace std;

struct Edge
{
  char from; // dependency task
  char to;   // dependent task
};

struct Task
{
  unordered_map<char, vector<char>> successorMap;
  unordered_map<char, vector<char>> dependencies;
  vector<Edge> edges;
};

Task readFile(const char *filename)
{
  vector<Edge> edges;
  edges.clear();
  ifstream file(filename);
  string s;
  unordered_map<char, vector<char>> successorMap;
  unordered_map<char, vector<char>> dependencies;

  string p1 = " m";
  string p2 = " c";
  int pos;
  while (getline(file, s))
  {
    Edge e = Edge();

    pos = s.find(p1);
    string dependency = s.substr(0, pos).erase(0, pos - 1);
    e.from = dependency[0];

    pos = s.find(p2);
    string task = s.substr(0, pos).erase(0, pos - 1);
    e.to = task[0];

    if (successorMap.find(e.from) != successorMap.end())
    {
      successorMap[e.from].push_back(e.to);

    } else {
      successorMap[e.from] = vector<char>();
    }

    if (dependencies.find(e.to) != dependencies.end())
    {
      dependencies[e.to].push_back(e.from);

    } else {
      dependencies[e.to] = vector<char>();
    }

    // cout << "from: " << e.from << " to: " << e.to << endl;

    edges.push_back(e);
  }

  // vector<char> chars = successorMap['K'];
  // for (unsigned k = 0; k < chars.size(); k++ )
  // {
  //   cout << chars.at(k) << endl;
  // }
  Task task = Task();
  task.edges = edges;
  task.successorMap = successorMap;
  task.dependencies = dependencies;

  return task;
}

void runPart1()
{
  Task t = readFile("data.txt");
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
