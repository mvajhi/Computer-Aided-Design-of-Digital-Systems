#include <windows.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <bits/stdc++.h>
LPWSTR stringToLPWSTR(const std::string& str) {
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, NULL, 0);
    LPWSTR wstr = new WCHAR[size_needed];
    MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, wstr, size_needed);
    return wstr;
}
int main() {
    
    HANDLE mutex = CreateMutexW(NULL, false, stringToLPWSTR("Hatef"));
    DWORD waitResult = WaitForSingleObject(mutex, INFINITE);
    if (waitResult == WAIT_OBJECT_0)
    {
        std::ifstream f("da.txt");

    // Check if the file is successfully opened
    if (!f.is_open()) {
        std::cerr << "Error opening the file!";
        return 1;
    }

    // String variable to store the read data
    std::string s;
    getline(f, s);
    int number = std::stoi(s);
        number+=13;
    std::ofstream MyFile("da.txt",std::ios::trunc);
    MyFile<<number;
    f.close();
    ReleaseMutex(mutex);

    }
}