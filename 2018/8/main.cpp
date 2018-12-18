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
  while(is >> n)
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
  for(int k = 0; k < nc; k++)
  {
    children.push_back(readTree(ns, i));
  }

  vector<int> metadata;
  for(int k = 0; k < meta ; k++)
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

void runPart1()
{
  vector<int> ns = readFile("data.txt");
  int i = 0;
  Node root = readTree(&ns, &i);
  cout << "metadata sum: " << sumMetadata(&root) << endl;
}

int main()
{
  runPart1();
  return 0;
}
