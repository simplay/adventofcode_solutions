#include <string>
#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>

using namespace std;

vector<int> readFile(const char *filename) {
  ifstream file(filename);
  string s;
  getline(file, s);
  istringstream is(s);

  vector<int> ns;
  int n;
  while (is >> n)
  {
    ns.push_back(n);
  }
  return ns;
}

struct Node {
  vector<Node> children;
  vector<int> metadata;
};

int readValue(vector<int>* ns, int* i)
{
  return ns->at((*i)++);
}

Node readTree(vector<int>* ns, int* i)
{
  int nc = readValue(ns, i);
  int meta = readValue(ns, i);

  vector<Node> children;
  for (int k = 0; k < nc; k++)
  {
    children.push_back(readTree(ns, i));
  }

  vector<int> metadata;
  for (int k = 0; k < meta ; k++)
  {
    metadata.push_back(readValue(ns, i));
  }

  Node n;
  n.children = children;
  n.metadata = metadata;

  return n;
}

int sumMetadata(Node* node)
{
  int sum = 0;
  auto nodeMetadata = node->metadata;
  for (unsigned k = 0; k < nodeMetadata.size(); k++)
  {
    sum += nodeMetadata.at(k);
  }

  auto nodeChildren = node->children;
  for (unsigned k = 0; k < nodeChildren.size(); k++)
  {
    sum += sumMetadata(&nodeChildren.at(k));
  }

  return sum;
}

int value(Node* node)
{
  auto nodeMetadata = node->metadata;
  auto nodeChildren = node->children;
  // If a node has no child nodes, its value is the sum of its metadata entries
  if (nodeChildren.size() == 0)
  {
    int sum = 0;
    for (unsigned k = 0; k < nodeMetadata.size(); k++)
    {
      sum += nodeMetadata.at(k);
    }
    return sum;
  } else {
    int sum = 0;
    for (unsigned k = 0; k < nodeMetadata.size(); k++)
    {
      unsigned meta = nodeMetadata.at(k);

      // If a referenced child node does not exist, that reference is skipped.
      // A metadata entry of 0 does not refer to any child node
      if (meta >= 1 && meta <= node->children.size())
      {
        // A metadata entry of 1 refers to the first child node, 2 to the
        // second, 3 to the third, and so on
        sum += value(&nodeChildren.at(meta - 1));
      }
    }
    return sum;
  }
}

void runPart1()
{
  vector<int> ns = readFile("data.txt");
  int i = 0;
  Node root = readTree(&ns, &i);
  cout << "sum of all metadata entries: " << sumMetadata(&root) << endl;
}

void runPart2()
{
  vector<int> ns = readFile("data.txt");
  int i = 0;
  Node root = readTree(&ns, &i);
  cout << "value of root node: " << value(&root) << endl;
}

int main(int argc, char *argv[])
{
  string task = argv[1];
  if (task.compare("1") == 0)
  {
    cout << "Running Part 1" << endl;
    runPart1();
  }
  else
  {
    cout << "Running Part 2" << endl;
    runPart2();
  }
  return 0;
}
