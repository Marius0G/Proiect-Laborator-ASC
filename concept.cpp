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


int main() {

    //setare array pentru test
    memorie[1] = 3;
    memorie[4] = 7;
    memorie[5] = 7;
    memorie[6] = 7;
    // Implementare GET

    // int descriptor; // descriptorul fisierului
    // cin >> descriptor; // citim descriptorul fisierului(test, normal va fi din fisier)
    // // afisareArrayDebug();
    // // Operatia GET
    // int getStartPos = 0;
    // int getFinPos = 0;

    // for(int i=0; i<1024; i++) {
    //     if(memorie[i] == descriptor && getStartPos == 0) {
    //         getStartPos = i;
    //     }
    //     if(memorie[i] == descriptor && getStartPos != 0) {
    //         getFinPos = i;
    //     }
    // }

    // cout << getStartPos << " " << getFinPos;
    afisareArrayDebug();
    //Implementare ADD
    int nAdd;
    int descriptorAdd;
    int spatiuAddKb;
    int spatiuAddBlocuri;
    cin >> nAdd;
    for(int i=0; i<nAdd; i++) {
        cin >> descriptorAdd;
        cin >> spatiuAddKb;
        //se calculeaaza nr de spatii de care avem nevoie
        if(spatiuAddKb % 8 == 0)
        {
            spatiuAddBlocuri = spatiuAddKb / 8;
        }
        else
        {
            spatiuAddBlocuri = spatiuAddKb / 8 + 1;
        }

        // se cauta un spatiu liber, se vede unde se poate adauga
        int addStartPos = 0;
        int addFinPos = 0;
        int addNrBlocuriLibere = 0;
        for(int i=0; i<1024; i++) {
            if(addNrBlocuriLibere != 0 && memorie[i] == 0) {
                addNrBlocuriLibere++;
            }
            if(addNrBlocuriLibere == 0 && memorie[i] == 0) {
                addStartPos = i;
                addNrBlocuriLibere++;
            }
            if(addNrBlocuriLibere != 0 && memorie[i] != 0) {
                addNrBlocuriLibere = 0;
            }
            if(addNrBlocuriLibere == spatiuAddBlocuri) {
                addFinPos = i;
                break;
            }
        }
        for(int i=addStartPos; i<=addFinPos; i++) {
            memorie[i] = descriptorAdd;
        }
        afisareArrayDebug();    
    }

    return 0;
}