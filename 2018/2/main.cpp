#include <string>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>

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

void runPart2()
{
    std::vector<std::string> lines;
    readFile("data.txt", lines);

    for (std::vector<std::string>::iterator v = lines.begin(); v != lines.end(); ++v)
    {
        std::string vv = *v;
        for (std::vector<std::string>::iterator w = lines.begin(); w != lines.end(); ++w)
        {
            std::string ww = *w;

            int diff = 0;
            for (int i = 1; i < vv.length(); i++)
            {
                if (vv[i] != ww[i])
                {
                    diff++;
                }
            }

            if (diff == 1)
            {
                //std::cout << "v: " << vv << std::endl;
                //std::cout << "w: " << ww << std::endl;
                std::string matches = "";

                for (int i = 0; i < vv.length(); i++)
                {
                    if (vv[i] == ww[i])
                    {
                        matches += vv[i];
                    }
                }
                std::cout << "matches: " << matches << std::endl;
                return;
            }
        }
    }
}

void runPart1()
{
    int counterTwoTimes = 0;
    int counterThreeTimes = 0;

    std::vector<std::string> lines;
    readFile("data.txt", lines);

    for (std::vector<std::string>::iterator it = lines.begin(); it != lines.end(); ++it)
    {
        std::string word = *it;
        std::sort(word.begin(), word.end());
        // std::cout << word << std::endl;

        int repCount = 1;
        char cursor = word[0];
        bool alreadyEncounteredTwoTimes = false;
        bool alreadyEncounteredThreeTimes = false;
        for (int i = 1; i < word.length(); i++)
        {
            bool wasIn = false;
            if (word[i] == cursor)
            {
                repCount++;
            }
            else
            {

                if (repCount == 2 && !alreadyEncounteredTwoTimes)
                {
                    alreadyEncounteredTwoTimes = true;
                    counterTwoTimes++;
                }
                else if (repCount == 3 && !alreadyEncounteredThreeTimes)
                {
                    alreadyEncounteredThreeTimes = true;
                    counterThreeTimes++;
                }
                cursor = word[i];
                repCount = 1;
            }
        }

        if (repCount == 2 && !alreadyEncounteredTwoTimes)
        {
            counterTwoTimes++;
        }
        else if (repCount == 3 && !alreadyEncounteredThreeTimes)
        {
            counterThreeTimes++;
        }
    }

    std::cout << "2 times count: " << counterTwoTimes << std::endl;
    std::cout << "3 times count: " << counterThreeTimes << std::endl;
    std::cout << "Checksum: " << counterTwoTimes * counterThreeTimes << std::endl;
}

int main (int argc, char *argv[])
{
    std::string task = argv[1];
    if(task.compare("1") == 0) {
        std::cout << "Running Part 1" << std::endl;
        runPart1();
    } else {
        std::cout << "Running Part 2" << std::endl;
        runPart2();
    }
    return 0;
}