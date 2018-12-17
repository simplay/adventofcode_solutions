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
#include <limits>

using namespace std;

struct Star {
  float px;
  float py;
  float vx;
  float vy;
};

vector<Star> readInput(const char* filename)
{
  vector<Star> stars;
  ifstream file(filename);
  string s;
  while (getline(file, s))
  {
    Star it;
    sscanf(s.c_str(), "position=<%f,%f> velocity=<%f,%f>", &it.px, &it.py, &it.vx, &it.vy);
    stars.push_back(it);
  }

  return stars;
}

bool cmpPx(Star a, Star b)
{
  return a.px < b.px;
}

bool cmpPy(Star a, Star b)
{
  return a.py < b.py;
}

bool hasStar(Star s, int m, int n)
{
  return s.px == m && s.py == n;
}

void printStars(vector<Star> stars, float xmin, float xmax, float ymin, float ymax)
{
  vector<Star>::iterator it;
  for (it = stars.begin(); it != stars.end(); it++) {
    it->px -= xmin;
    it->py -= ymin;
  }

  for (int n = 0; n <= ymax - ymin; n++)
  {
    for (int m = 0; m <= xmax - xmin; m++)
    {
      bool has = false;
      for (unsigned k = 0; k < stars.size(); k++)
      {
        bool h = hasStar(stars.at(k), m, n);
        if (h) {
          has = h;
          break;
        }
      }
      if (has)
      {
        cout << "0";
      } else {
        cout << " ";
      }
    }
    cout << endl;
  }

  cout << endl;

}

void run()
{
  vector<Star> stars = readInput("data.txt");
  vector<Star> oldStars;
  float minArea = numeric_limits<float>::max();
  int seconds = 1;
  while(true)
  {
    vector<Star> oldStars(stars);

    vector<Star>::iterator it;
    for (it = stars.begin(); it != stars.end(); it++) {
      it->px = it->px + it->vx;
      it->py = it->py + it->vy;
    }

    auto xmin = min_element(begin(stars), end(stars), cmpPx)->px;
    auto xmax = max_element(begin(stars), end(stars), cmpPx)->px;
    auto ymin = min_element(begin(stars), end(stars), cmpPy)->py;
    auto ymax = max_element(begin(stars), end(stars), cmpPy)->py;

    auto area = (xmax - xmin) * (ymax - ymin);
    if (area < minArea)
    {
      minArea = area;
    } else {
      auto xmin = min_element(begin(oldStars), end(oldStars), cmpPx)->px;
      auto xmax = max_element(begin(oldStars), end(oldStars), cmpPx)->px;
      auto ymin = min_element(begin(oldStars), end(oldStars), cmpPy)->py;
      auto ymax = max_element(begin(oldStars), end(oldStars), cmpPy)->py;
      printStars(oldStars, xmin, xmax, ymin, ymax);
      break;
    }

    seconds++;
  }

  cout << "Seconds passed: " << seconds << endl;
}

int main()
{
  run();
  return 0;
}
