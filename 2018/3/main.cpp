#include <string>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <regex>
#include <unordered_map>

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

// extractCoordinates("#1 @ 1,3: 4x4");
// #=> [1, 3, 4, 4]
int *extractCoordinatesSlow(std::string coordinateString)
{

    std::regex rgx("[#@,:x]");
    std::sregex_token_iterator iter(
        coordinateString.begin(),
        coordinateString.end(),
        rgx,
        -1);
    std::sregex_token_iterator end;

    static int coords[5];

    int count = 0;
    for (; iter != end; ++iter)
    {
        if (count > 0 && count < 6)
        {
            // std::cout << count << " => " << *iter << std::endl;
            coords[count - 1] = std::stoi(*iter);
        }
        count++;
    }
    return coords;
}

int *extractCoordinates(std::string str)
{

    int idx = -1;
    std::string tmp = "";
    int static coords[5];
    for (std::string::size_type i = 0; i < str.size(); ++i)
    {
        if (
            str[i] == '[' ||
            str[i] == '#' ||
            str[i] == '@' ||
            str[i] == ',' ||
            str[i] == ':' ||
            str[i] == 'x')
        {
            if (idx > -1)
            {
                coords[idx] = std::stoi(tmp);
            }
            tmp = "";
            idx++;
        }
        else
        {
            tmp += str[i];
        }
    }
    coords[idx] = std::stoi(tmp);
    return coords;
}

void runPart1()
{
    std::vector<std::string> lines;
    readFile("data.txt", lines);
    std::unordered_map<std::string, int> hits;

    for (std::vector<std::string>::iterator v = lines.begin(); v != lines.end(); ++v)
    {
        int *coordinates = extractCoordinates(*v);
        int startX = coordinates[1] + 1;
        int startY = coordinates[2] + 1;

        int endX = startX + coordinates[3];
        int endY = startY + coordinates[4];

        for (int x = startX; x < endX; x++)
        {
            for (int y = startY; y < endY; y++)
            {
                std::string c = std::to_string(x) + "x" + std::to_string(y);

                if (hits.find(c) == hits.end())
                {
                    hits[c] = 1;
                }
                else
                {
                    hits[c] += 1;
                }
            }
        }
    }
    int sq = 0;
    std::unordered_map<std::string, int>::iterator itr;
    for (itr = hits.begin(); itr != hits.end(); itr++)
    {
        if (itr->second > 1)
            sq++;
    }
    std::cout << "square inch: " << sq << std::endl;
}
struct RectBitmap
{
    int id;
    bool hasIntersection;
};

struct Rec2
{
    int id;
    int x;
    int y;
    int width;
    int height;
};

bool hasIntersection(float x1, float y1, float width1, float height1, float x2, float y2, float width2, float height2)
{
    return !(x1 > x2 + width2 || x1 + width1 < x2 || y1 > y2 + height2 || y1 + height1 < y2);
}

void runPart2()
{
    std::vector<std::string> lines;
    readFile("data.txt", lines);
    RectBitmap rectangles[lines.size()];
    Rec2 rs[lines.size()];

    int recCount = 0;
    for (std::vector<std::string>::iterator v = lines.begin(); v != lines.end(); ++v)
    {
        int *coordinates = extractCoordinates(*v);
        int startX = coordinates[1] + 1;
        int startY = coordinates[2] + 1;

        RectBitmap r;
        r.id = coordinates[0];
        r.hasIntersection = false;
        rectangles[recCount] = r;

        Rec2 rr;
        rr.id = coordinates[0];
        rr.x = startX;
        rr.y = startY;
        rr.width = coordinates[3];
        rr.height = coordinates[4];
        rs[recCount] = rr;

        recCount++;
    }

    for (int i = 0; i < recCount; i++)
    {
        Rec2 a = rs[i];
        for (int j = i + 1; j < recCount; j++)
        {
            if (i == j)
                continue;

            Rec2 b = rs[j];
            bool intersect;

            intersect = hasIntersection(
                a.x, a.y, a.width, a.height,
                b.x, b.y, b.width, b.height);

            if (intersect)
            {
                rectangles[i].hasIntersection = true;
                rectangles[j].hasIntersection = true;
                continue;
            }
        }
    }

    for (int i = 0; i < recCount; i++)
    {
        RectBitmap r = rectangles[i];
        if (!r.hasIntersection)
        {
            std::cout << "no intersection rule: " << r.id << std::endl;
            return;
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