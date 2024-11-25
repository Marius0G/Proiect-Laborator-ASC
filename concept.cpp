#include <iostream>
using namespace std;

int memorie[1024] = {0}; //  initializez memoria cu 0
//vom declara in assembly fiecare element din array ca fiind de spatiu de 1 byte
//iar in C++ vom folosi un array de 1024 de elemente de tip char

void afisareArrayDebug()
{
    for(int i=0; i<20; i++) {
        cout << memorie[i] << " ";
    }
    cout << endl;
}

void get(int descriptor) {
    int getStartPos = 0;
    int getFinPos = 0;

    for(int i=0; i<1024; i++) {
        if(memorie[i] == descriptor && getStartPos == 0) {
            getStartPos = i;
        }
        if(memorie[i] == descriptor && getStartPos != 0) {
            getFinPos = i;
        }
    }

    cout << getStartPos << " " << getFinPos << endl;
}



int main() {

    //setare array pentru test
    memorie[1] = 3;
    memorie[2] = 7;
    memorie[3] = 7;
    memorie[4] = 7;
    // Implementare GET

    int descriptor; // descriptorul fisierului
    cin >> descriptor; // citim descriptorul fisierului(test, normal va fi din fisier)

    

    for(int i=0; i<=100; i++) {
        cout << memorie[i] << " ";
    }
    cout << endl;
    get(descriptor);
    return 0;
}