// Compile: g++ main.cpp -o main
// Run: ./main

#include <sstream>
#include <string>
#include <fstream>
#include <iostream>
#include <set>
#include <iterator>
#include <vector>

void readFile(const char* filename, std::vector<std::string>& lines) {
  lines.clear();
  std::ifstream file(filename);
  std::string s;
  while (getline(file, s)) {
    lines.push_back(s);
  }
}

int main() {
    std::ifstream infile("data.txt");

    std::set<int, std::greater<int>> foundTotalFreq;

    int totalFreq = 0;
    foundTotalFreq.insert(totalFreq);
    bool firstFreqReachedTwiceFound = false;
    std::string line;

    std::vector<std::string> lines;
    readFile("data.txt", lines);

    int lineCount = lines.size();
    int idx = 0;
    int finalFreq;
    bool freqAlreadyEncountered;
    bool firstRoundFinished = false;

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
                finalFreq = totalFreq;
            }

            if (firstFreqReachedTwiceFound)
                break;
        }
    }

    std::cout << "Part1: " << std::endl;
    std::cout << "Resulting frequency is: " << finalFreq << std::endl;

    return 0;
}
