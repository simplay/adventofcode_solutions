#include <string>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <regex>
#include <unordered_map>
#include <cstdio>
#include <stack>

using namespace std;

struct Point
{
  int x;
  int y;
};


struct GridData
{
  vector<Point> points;
  int xLen;
  int yLen;
};

GridData readFile(const char *filename)
{
  vector<Point> points;

  points.clear();
  std::ifstream file(filename);
  std::string s;
  int minX = 10000;
  int minY = 10000;
  int maxX = -1;
  int maxY = -1;
  while (getline(file, s))
  {
    Point p = Point();

    int pos = s.find(", ");
    p.x = stoi(s.substr(0, pos));
    s.erase(0, pos + 2);
    p.y = stoi(s);

    if (minX > p.x) {
      minX = p.x;
    }

    if (minY > p.y) {
      minY = p.y;
    }

    if (maxX < p.x) {
      maxX = p.x;
    }

    if (maxY < p.y) {
      maxY = p.y;
    }

    points.push_back(p);
  }

  // cout << "minX = " << minX << " minY = " << minY << endl;
  int xLen = maxX - minX;
  int yLen = maxY - minY;

  for (unsigned k = 0; k < points.size(); k++) {
    points.at(k).x -= minX;
    points.at(k).y -= minY;
  }

  GridData g = GridData();

  g.points = points;
  g.xLen = xLen;
  g.yLen = yLen;


  return g;
}

void runPart1() {
  GridData g = readFile("data.txt");
  vector<Point> points = g.points;

  for (unsigned k = 0; k < points.size(); k++) {
    Point p = points.at(k);
    // cout << "(" << p.x << ", " << p.y << ")" << endl;
  }
}

void runPart2() {
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
