#include <string>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <regex>
#include <unordered_map>
#include <cstdio>

using namespace std;

char downcased(char in) {
  if(in <= 'Z' && in >= 'A') {
    return in - ('Z' - 'z');
  }
  return in;
}


void readFile(const char *filename, std::vector<std::string> &lines)
{
  lines.clear();
  std::ifstream file(filename);
  std::string s;
  while (getline(file, s))
  {
    lines.push_back(s);
  }
}

bool reacting(char a, char b) {
  return downcased(a) == downcased(b) && a != b;
}

string polymerAfterReaction(string str) {
  // string str = "DcAbBaC";
  cout << "initial len: " << str.size() << endl;

  string finalString;
  string tmp = "";
  while(true) {
    tmp = "";

    unsigned idx = 0;
    while(idx < str.size())  {
      // for (int idx = 0; idx < str.size() - 1; idx++) {
      char a = str[idx];
      char b = str[idx + 1];

      if (reacting(a, b)) {
        idx += 2;
      } else {
        tmp += a;
        idx++;
      }

      // cout << "orig a: " << a << " downcased " << downcased(a) << endl;
      // cout << "orig b: " << b << " downcased " << downcased(b) << endl;
      // cout << "reacting: a, b: " << reacting(a, b) << endl;
      // cout << "reacting: b, a: " << reacting(b, a) << endl;
      // cout << "reacting: a, a: " << reacting(a, a) << endl;
      // cout << "reacting: b, b: " << reacting(b, b) << endl;

    }
    // cout << "Iter: " << tmp << endl;

    if (!str.compare(tmp)) {
      // cout << "str = " << str << " tmp = " << tmp << endl;
      finalString = tmp;
      break;
    }
    str = tmp;
    }

    return finalString;
}

void runPart1() {
  std::vector<std::string> lines;
  readFile("data.txt", lines);
  string str = lines.at(0);
  string finalString = polymerAfterReaction(str);
  cout << "final len: " << finalString.size() << endl;
}

void runPart2() {
  std::vector<std::string> lines;
  readFile("data.txt", lines);
  string polymer = lines.at(0);

  char chars[26] = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
    'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
    'u', 'v', 'w', 'x', 'y', 'z'
  };

  unsigned minLen = polymer.size() + 1;
  for (int k = 0; k < 26; k++) {
    string subPoly = "";
    char c = chars[k];

    for(int idx = 0; idx < polymer.size(); idx++) {
      if (downcased(polymer[idx]) != c) {
        subPoly += polymer[idx];
      }
    }
    string finalString = polymerAfterReaction(subPoly);
    cout << "length: " << finalString.size() << endl;
    if (finalString.size() < minLen) {
      minLen = finalString.size();
    }
  }
  cout << "min length: " << minLen << endl;
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

