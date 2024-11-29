#include <iostream>
#include <fstream>
#include <fcntl.h>
#include <unistd.h>
#include <sys/file.h>

int main() {
    // فایل را باز کرده و قفل ایجاد می‌کنیم
    int fd = open("da.txt", O_RDWR | O_CREAT, 0666);
    if (fd == -1) {
        std::cerr << "Error opening the file!";
        return 1;
    }

    // قفل اختصاصی روی فایل
    if (flock(fd, LOCK_EX) == -1) {
        std::cerr << "Error locking the file!";
        close(fd);
        return 1;
    }

    // خواندن داده از فایل
    std::ifstream f("da.txt");
    if (!f.is_open()) {
        std::cerr << "Error opening the file!";
        flock(fd, LOCK_UN); // آزادسازی قفل
        close(fd);
        return 1;
    }

    std::string s;
    getline(f, s);
    f.close();

    // پردازش داده
    int number = std::stoi(s);
    number += 11;

    // نوشتن داده در فایل
    std::ofstream MyFile("da.txt", std::ios::trunc);
    MyFile << number;
    MyFile.close();

    // آزادسازی قفل و بستن فایل
    flock(fd, LOCK_UN);
    close(fd);

    return 0;
}
