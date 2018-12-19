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


void run()
{
  int rc = 633601;

  vector<int> receipes = {3, 7};
  int cursor1 = 0;
  int cursor2 = 1;
  int n = 10;

  while (true)
  {
    string sum = to_string(receipes.at(cursor1) + receipes.at(cursor2));
    for (unsigned k = 0; k < sum.length(); ++k)
    {
      auto v = (sum.at(k));
      auto vi = atoi(&v);
      receipes.push_back(vi);
    }

    cursor1 = (cursor1 + 1 + receipes.at(cursor1)) % receipes.size();
    cursor2 = (cursor2 + 1 + receipes.at(cursor2)) % receipes.size();

    if ((int) receipes.size() >= rc + n)
    {
      for (int k = rc; k < rc + n; k++)
      {
        cout << receipes.at(k);
      }
      cout << endl;
      break;
    }
  }
}

int main()
{
  run();
  return 0;
}
