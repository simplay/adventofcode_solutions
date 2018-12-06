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

char downcased(char in)
{
  if (in <= 'Z' && in >= 'A')
  {
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

bool reacting(char a, char b)
{
  return downcased(a) == downcased(b) && a != b;
}

void showstack(stack <char> s)
{
  while (!s.empty())
  {
    cout << '\t' << s.top();
    s.pop();
  }
  cout << '\n';
}

stack<char> polymerAfterReaction(string str, char ch)
{
  // string str = "DcAbBaC";
  // cout << "initial len: " << str.size() << endl;
  stack<char> stack;
  stack.push(str[0]);

  string finalString = "";
  string tmp = "";
  unsigned idx = 1;
  unsigned n = str.size();
  // cout << str << endl;
  while (true)
  {
    char a = stack.empty() ? '_' : stack.top();
    char b = str[idx];

    // if (ch == 'o') cout << "a = " << a << " b = " << b << endl;
    // if (ch == 'o') cout << "stack.size() = " << stack.size() << endl;
    // if (ch == 'o') cout << "stack.empty() = " << stack.empty() << endl;

    if (reacting(a, b))
    {
      // if (ch == 'o') cout << "stack.top() = " << stack.top() << endl;
      if (!stack.empty()) stack.pop();
      // if (ch == 'o') cout << "done" << endl;
    }
    else
    {
      // if (ch == 'o') cout << "pushing b = " << b << endl;
      stack.push(b);
    }
    idx++;

    // cout << "orig a: " << a << " downcased " << downcased(a) << endl;
    // cout << "orig b: " << b << " downcased " << downcased(b) << endl;
    // cout << "reacting: a, b: " << reacting(a, b) << endl;
    // cout << "reacting: b, a: " << reacting(b, a) << endl;
    // cout << "reacting: a, a: " << reacting(a, a) << endl;
    // cout << "reacting: b, b: " << reacting(b, b) << endl;
    if (idx == n) {
      break;
    }
  }
  // cout << "Iter: " << tmp << endl;


  // showstack(stack);
  // cout << stack.size() << endl;
  return stack;
}

void runPart1()
{
  std::vector<std::string> lines;
  readFile("data.txt", lines);
  string str = lines.at(0);
  // str = "acBbCA";
  stack<char> finalParts = polymerAfterReaction(str, 'c');
  cout << "final len: " << finalParts.size() << endl;
}

void runPart2()
{
  std::vector<std::string> lines;
  readFile("data.txt", lines);
  string polymer = lines.at(0);
  stack<char> finalString;

  char chars[26] = {
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
      'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
      'u', 'v', 'w', 'x', 'y', 'z'};

  unsigned minLen = polymer.size() + 1;
  for (int k = 0; k < 26; k++)
  {
    string subPoly = "";
    char c = chars[k];

    for (int idx = 0; idx < polymer.size(); idx++)
    {
      if (downcased(polymer[idx]) != c)
      {
        subPoly += polymer[idx];
      }
    }
    // cout << "iter k = " << k << " letter " << c << endl;
    finalString = polymerAfterReaction(subPoly, c);
    // cout << "length: " << finalString.size() << endl;
    if (finalString.size() < minLen)
    {
      minLen = finalString.size();
    }
    // cout << "AFTER iter k = " << k << " letter " << c << endl;
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
