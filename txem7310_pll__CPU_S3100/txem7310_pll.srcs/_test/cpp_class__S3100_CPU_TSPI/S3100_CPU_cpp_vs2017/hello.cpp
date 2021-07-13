#include <iostream>
#include <vector>
#include <string>

//#include <winsock2.h> 
// located in C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\x86_64-w64-mingw32\include
// or in D:\Windows Kits\10\Include\10.0.19041.0\um
// or in D:\prog\mingw-w64\mingw32\i686-w64-mingw32\include 
// or in C:\MinGW\include
//#pragma comment(lib, "ws2_32") //$$ to revise

#include "_lan_interface.h"

using namespace std;

int main()
{
    cout << "Hello World" << endl;

    vector<string> msg {"Hello", "C++", "World", "from", "VS Code", "and the C++ extension!"};
    
    for (const string& word : msg)
    {
        cout << word << " ";
    }
    cout << endl;

    // test class EPS_Dev
    EPS_Dev dev;

    dev._test();

}