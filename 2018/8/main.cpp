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


void readInput()
{
  vector<star> result;
  for(string line;getline(cin, line);){
    star it;
    sscanf(line.c_str(), "position=<%f,%f> velocity=<%f,%f>", &it.m_vertex.position.x, &it.m_vertex.position.y, &it.m_vel.x, &it.m_vel.y);
    result.push_back(it);
  }
}

void runPart1()
{

}

int main(int argc, char *argv[])
{
  //std::string task = argv[1];
  runPart1();
  return 0;
}
