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
#include <unordered_set>
#include <set>

using namespace std;

struct Edge
{
  char from; // dependency task
  char to;   // dependent task
};

struct Task
{
  unordered_map<char, vector<char>> implications;
  unordered_map<char, vector<char>> dependencies;
  unordered_map<char, bool> used;
  vector<char> starts;
  vector<Edge> edges;
};

void printMap(unordered_map<char, vector<char>> map)
{
  unordered_map<char, vector<char>>::iterator it;
  for (it = map.begin(); it != map.end(); it++)
  {
    vector<char> chars = it->second;
    string str = "";
    for (unsigned k = 0; k < chars.size(); k++)
    {
      str += " " + string(1, chars[k]);
    }
    cout << it->first << " => " <<  str << endl;
  }
}

Task readFile(const char *filename)
{
  vector<Edge> edges;
  edges.clear();
  ifstream file(filename);
  string s;
  unordered_map<char, vector<char>> implications;
  unordered_map<char, vector<char>> dependencies;
  unordered_map<char, bool> used;

  string p1 = " m";
  string p2 = " c";
  int pos;
  unordered_set<char> allTasks;

  while (getline(file, s))
  {
    Edge e = Edge();

    pos = s.find(p1);
    string dependency = s.substr(0, pos).erase(0, pos - 1);
    e.from = dependency[0];

    pos = s.find(p2);
    string task = s.substr(0, pos).erase(0, pos - 1);
    e.to = task[0];

    // cout << "from: " << e.from << " to: " << e.to << endl;
    // cout << "adding " << e.to << " to " << e.from << endl;
    implications[e.from].push_back(e.to);
    dependencies[e.to].push_back(e.from);

    allTasks.insert(e.from);
    allTasks.insert(e.to);
    used[e.from] = false;
    used[e.to] = false;

    edges.push_back(e);
  }

  // start is the the node without any dependencies
  vector<char> starts;
  unordered_set<char>::iterator it;
  for (it = allTasks.begin(); it != allTasks.end(); it++)
  {
    if (dependencies.find(*it) == dependencies.end())
    {
      cout << "start: " << *it << endl;
      starts.push_back(*it);
    }
  }

  cout << "[N] implies [M]" << endl;
  printMap(implications);

  cout << endl;

  cout << "[N] depends on [M]:" << endl;
  printMap(dependencies);

  Task task = Task();
  task.starts = starts;
  task.edges = edges;
  task.implications = implications;
  task.dependencies = dependencies;
  task.used = used;

  return task;
}

bool foo(char a, char b)
{
  return a < b;
}

void printVector(vector<char> *v)
{
  for (unsigned k = 0; k < v->size(); k++)
  {
    cout << v->at(k) << ' ';

  }
  cout << endl;
}

bool hasElement(vector<char> *v, char e)
{
  return find(v->begin(), v-> end(), e) != v->end();
}

unordered_set<char> extendAvailables(vector<char> *availables,
                                     unordered_map<char, vector<char>> *implications,
                                     unordered_map<char, vector<char>> *dependencies
                                     )
{
  unordered_set<char> newAvailables;
  for (unsigned k = 0; k < availables->size(); k++)
  {
    char value = availables->at(k);
    //cout << "looking up dependency: " << value << endl;

    if (implications->find(value) == implications->end()) continue;


    vector<char> visibles = implications->at(value);
    for (unsigned t = 0; t < visibles.size(); t++)
    {

      if (!hasElement(availables, visibles.at(t)))
      {
        // inster only if all dependencies are met
          // cout << "inserting " << visibles.at(t) << endl;
          newAvailables.insert(visibles.at(t));
      }
    }
  }

  return newAvailables;

}

char findBestVisible(vector<char> visibles, vector<char> visited, unordered_map<char, vector<char>> dependencies)
{

  sort(visibles.begin(), visibles.end());
  for (unsigned k = 0; k < visibles.size(); k++)
  {
    char c = visibles.at(k);
    // TODO handle inexistent dependencies

    vector<char> dependenciesOfChar = dependencies[c];
    bool dependenciesMet = true;
    for (unsigned t = 0; t < dependenciesOfChar.size(); t++)
    {
      char depChar = dependenciesOfChar.at(t);
      if (!hasElement(&visited, depChar))
      {
        dependenciesMet = false;
        break;
      }
    }

    if (dependenciesMet)
    {
      return c;
    }
  }
  return '1';
}

void runPart1()
{
  Task t = readFile("data.txt");
  vector<char> visited;
  vector<char> visibles = t.starts;

  string str = "";
  vector<char>::iterator it;

  while (str.length() < t.used.size())
  {
    char bestChar = findBestVisible(visibles, visited, t.dependencies);

    // obtain new availables
    unordered_set<char> newAvailables = extendAvailables(
      &visibles, &t.implications, &t.dependencies
    );

    // REMOVE FROM SET
    it = find(visibles.begin(), visibles.end(), bestChar);
    visibles.erase(it);

    // add new found available chars to visible list
    unordered_set<char>::iterator it;
    for (it = newAvailables.begin(); it != newAvailables.end(); it++)
    {
      if (!t.used[*it])
      {

        visibles.push_back(*it);
      }
      // cout << "new available: " << *it << endl;
    }
    t.used[bestChar] = true;

    // add best char to list of visited chars
    visited.push_back(bestChar);

    str += string(1, bestChar);
  }

  cout << "word: " << str << endl;
}

void runPart2()
{
}

int main(int argc, char *argv[])
{
  //std::string task = argv[1];
  runPart1();
  // if (task.compare("1") == 0)
  // {
  //   std::cout << "Running Part 1" << std::endl;
  // }
  // else
  // {
  //   std::cout << "Running Part 2" << std::endl;
  //   runPart2();
  // }
  return 0;
}
