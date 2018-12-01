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

int main() {
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

    std::cout << "Part1: " << std::endl;
    std::cout << "Resulting frequency is: " << totalFreqAfterFirstRound << std::endl;

    return 0;
}
