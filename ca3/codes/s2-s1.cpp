#include <iostream>
#include <fstream>
#include <fcntl.h>
#include <unistd.h>
#include <sys/file.h>

int main() {
    int fd = open("da.txt", O_RDWR | O_CREAT, 0666);
    if (fd == -1) {
        std::cerr << "Error opening the file!";
        return 1;
    }

    if (flock(fd, LOCK_EX) == -1) {
        std::cerr << "Error locking the file!";
        close(fd);
        return 1;
    }

    std::ifstream f("da.txt");
    if (!f.is_open()) {
        std::cerr << "Error opening the file!";
        flock(fd, LOCK_UN); 
        close(fd);
        return 1;
    }

    std::string s;
    getline(f, s);
    f.close();

    int number = std::stoi(s);
    number += 13;

    std::ofstream MyFile("da.txt", std::ios::trunc);
    MyFile << number;
    MyFile.close();

    flock(fd, LOCK_UN);
    close(fd);

    return 0;
}
