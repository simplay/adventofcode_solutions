// Compile: g++ main.cpp -o main
// Run: ./main

#include <sstream>
#include <string>
#include <fstream>
#include <iostream>
#include <set>
#include <vector>

void readFile(const char *filename, std::vector<std::string> &lines) {
    lines.clear();
    std::ifstream file(filename);
    std::string s;
    while (getline(file, s)) {
        lines.push_back(s);
    }
}

void runPart1() {
  std::vector<std::string> lines;
  readFile("data.txt", lines);
  unsigned totalFreq = 0;
  for (unsigned k = 0; k < lines.size(); k++) {
    totalFreq += std::stoi(lines[k]);
  }

  std::cout << "total frequency is: " << totalFreq << std::endl;
}

void runPart2() {
  std::vector<std::string> lines;
  readFile("data.txt", lines);

  int lineCount = lines.size();
  int idx = 0;
  int totalFreqAfterFirstRound;
  int totalFreq = 0;

  bool firstFreqReachedTwiceFound = false;
  bool freqAlreadyEncountered;
  bool firstRoundFinished = false;

  std::set<int, std::greater<int>> foundTotalFreq;
  foundTotalFreq.insert(totalFreq);

  while (true) {
    std::istringstream iss(lines[idx]);
    int freq;
    if (!(iss >> freq)) {
      break;
    }

    totalFreq += freq;

    freqAlreadyEncountered = foundTotalFreq.find(totalFreq) != foundTotalFreq.end();
    if (freqAlreadyEncountered && !firstFreqReachedTwiceFound) {
      firstFreqReachedTwiceFound = true;
      std::cout << "Part2: " << std::endl;
      std::cout << "First frequency reached twice is: " << totalFreq << std::endl;
    }

    foundTotalFreq.insert(totalFreq);

    idx++;
    if (idx == lineCount) {
      idx = idx % lineCount;
      if (!firstRoundFinished) {
        firstRoundFinished = true;
        totalFreqAfterFirstRound = totalFreq;
      }

      if (firstFreqReachedTwiceFound)
        break;
    }
  }
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
