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
  int xMin;
  int yMin;
  int xMax;
  int yMax;
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

    if (minX > p.x)
    {
      minX = p.x;
    }

    if (minY > p.y)
    {
      minY = p.y;
    }

    if (maxX < p.x)
    {
      maxX = p.x;
    }

    if (maxY < p.y)
    {
      maxY = p.y;
    }

    points.push_back(p);
  }

  // cout << "minX = " << minX << " minY = " << minY << endl;
  int xLen = maxX - minX + 1;
  int yLen = maxY - minY + 1;

  // for (unsigned k = 0; k < points.size(); k++)
  // {
  //   points.at(k).x -= minX;
  //   points.at(k).y -= minY;
  // }

  GridData g = GridData();

  g.points = points;
  g.xLen = xLen;
  g.yLen = yLen;
  g.xMax = maxX;
  g.xMin = minX;
  g.yMax = maxY;
  g.yMin = minY;

  return g;
}

int dist1(Point a, int x, int y)
{
  return abs(a.x - x) + abs(a.y - y);
}

void runPart1()
{
  GridData g = readFile("data.txt");
  vector<Point> points = g.points;


  int pointCount = points.size();
  int ownerCount[pointCount];
  bool isInfinite[pointCount];

  for (unsigned k = 0; k < pointCount; k++) {
    ownerCount[k] = 0;
    isInfinite[k] = false;
  }
  
  cout << "x len = " << g.xLen << endl;
  cout << "y len = " << g.yLen << endl;
  
  // if best_dist along boundary, then fail

  for (unsigned xx = g.xMin; xx <= g.xMax; xx++)
  {
    bool onBoundaryX = (xx == g.xMin) || (xx == g.xMax );
    // cout << "xx = " << xx << endl;
    for (unsigned yy = g.yMin; yy <= g.yMax; yy++)
    {
      // cout << "yy = " << yy << endl;
      bool onBoundaryY = (yy == g.yMin) || (yy == g.yMax );
      // cout << "yy = " << yy << " on yB = " << onBoundaryY << endl;
      // cout << "xx = " << xx << " on xB = " << onBoundaryX << endl << endl;

      int bestDist = 10000;
      // vector<int> ownerDistances;
      unsigned bestIdx = -1;

      for (unsigned k = 0; k < pointCount; k++)
      {
        Point p = points.at(k);
        int dist = dist1(p, xx, yy);

        // cout << "pid = " << k << " dist = " << dist << endl;
        //ownerDistances.push_back(dist);
        //if (dist == 0) continue;

        if (dist < bestDist)
        {
          bestIdx = k;
          bestDist = dist;
        } else if (dist == bestDist) {
          bestIdx = -1;
        }

       // for (unsigned k = 0; k < pointCount; k++)
       //{
          //if (ownerDistances[bestIdx] == bestDist) {

          //}
      //  }
      }

      // for (unsigned k = 0; k < pointCount; k++) {

      //cout << "best dist = " << bestDist << " inf = " << (onBoundaryX || onBoundaryY) << endl;
      if (bestIdx == -1) continue;
      if (onBoundaryX || onBoundaryY)
      {
        isInfinite[bestIdx] = true;
      }
      else
      {
        ownerCount[bestIdx]++;
      }
    }
  }

  int maxCount = -1;
  for (unsigned k = 0; k < pointCount; k++) {
    if (!isInfinite[k])
    {
      if (ownerCount[k] > maxCount) 
      {
        maxCount = ownerCount[k];
      }
    }
  }

  cout << "max count: " << maxCount << endl;
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
