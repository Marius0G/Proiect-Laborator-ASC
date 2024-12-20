#include <iostream>
#include <fstream>

using namespace std;

int memorie[1024 * 1024] = {0}; // initializez memoria cu 0, simulez o matrice de 1024 pe 1024

int main()
{
    int nrOperatii;
    cin >> nrOperatii; // se citeste nr de operatii

    for (int l = 1; l <= nrOperatii; l++)
    {
        int operatie;
        cin >> operatie; // se citeste operatia

        if (operatie == 1) // ADD
        {
            int nAdd;
            cin >> nAdd; // se citeste nr de fisiere
            for (int k = 0; k < nAdd; k++)
            {
                int descriptorAdd;
                int spatiuAddKb;
                cin >> descriptorAdd >> spatiuAddKb; // se citeste descriptorul si spatiul
                int spatiuAddBlocuri = spatiuAddKb / 8;
                if (spatiuAddKb % 8 != 0)
                {
                    spatiuAddBlocuri++;
                }

                bool foundSpace = false;

                for (int i = 0; i < 1024 && !foundSpace; i++) // parcurgem liniile
                {
                    int count = 0;
                    for (int j = 0; j < 1024; j++) // parcurgem coloanele
                    {
                        if (memorie[i * 1024 + j] == 0)
                        {
                            count++;
                            if (count == spatiuAddBlocuri)
                            {
                                // Am găsit un bloc suficient de mare
                                for (int m = j - spatiuAddBlocuri + 1; m <= j; m++)
                                {
                                    memorie[i * 1024 + m] = descriptorAdd;
                                }
                                foundSpace = true;
                                cout << descriptorAdd << ": ((" << i << ", " << (j - spatiuAddBlocuri + 1) << "), (" << i << ", " << j << "))\n";
                                break;
                            }
                        }
                        else
                        {
                            count = 0; // resetăm contorul dacă găsim un element diferit de 0
                        }
                    }
                }

                if (!foundSpace)
                {
                    // Nu am găsit spațiu suficient
                    cout << descriptorAdd << ": ((0, 0), (0, 0))\n";
                }
            }
        }
        if (operatie == 2) // GET
        {
            // Implementare GET
            int descriptor;
            cin >> descriptor; // se citeste descriptorul

            bool found = false;
            for (int i = 0; i < 1024 && !found; i++) // parcurgem liniile
            {
                for (int j = 0; j < 1024; j++) // parcurgem coloanele
                {
                    if (memorie[i * 1024 + j] == descriptor)
                    {
                        int start = j;
                        while (j < 1024 && memorie[i * 1024 + j] == descriptor)
                        {
                            j++;
                        }
                        int end = j - 1;
                        cout << "((" << i << ", " << start << "), (" << i << ", " << end << "))\n";
                        found = true;
                        break;
                    }
                }
            }

            if (!found)
            {
                // Nu am găsit descriptorul
                cout << "((0, 0), (0, 0))\n";
            }
        }
        if (operatie == 3) // DELETE
        {
            // Implementare DELETE
            int descriptor;
            cin >> descriptor; // se citeste descriptorul
            for (int i = 0; i < 1024; i++) // parcurgem liniile
            {
                for (int j = 0; j < 1024; j++) // parcurgem coloanele
                {
                    if (memorie[i * 1024 + j] == descriptor)
                    {
                        memorie[i * 1024 + j] = 0;
                    }
                }
            }

            // Afisare toata memoria sub forma filedescriptor: ((linieStart, coloanaStart), (linieEnd, coloanaEnd))
            // Afișare toată memoria sub forma ((linieStart, coloanaStart), (linieEnd, coloanaEnd))
            for (int i = 0; i < 1024; i++) // parcurgem liniile
            {
                int j = 0;
                while (j < 1024)
                {
                    if (memorie[i * 1024 + j] != 0)
                    {
                        int start = j;
                        int descriptor = memorie[i * 1024 + j];
                        while (j < 1024 && memorie[i * 1024 + j] == descriptor)
                        {
                            j++;
                        }
                        int end = j - 1;
                        cout <<descriptor << ": ((" << i << ", " << start << "), (" << i << ", " << end << "))\n";
                    }
                    else
                    {
                        j++;
                    }
                }
            }
        }
        if (operatie == 4) // DEFRAG
        {
            // Implementare DEFRAG
            for (int i = 0; i < 1023; i++) // Parcurgem liniile, până la penultima linie
            {
                int k = 0; // Index pentru poziția de inserare pe linia curentă
                // Compactăm valorile nenule pe linia curentă
                for (int j = 0; j < 1024; j++)
                {
                    if (memorie[i * 1024 + j] != 0)
                    {
                        memorie[i * 1024 + k] = memorie[i * 1024 + j];
                        if (k != j)
                        {
                            memorie[i * 1024 + j] = 0;
                        }
                        k++;
                    }
                }

                // Mutăm valorile din liniile următoare pe linia curentă
                for (int l = i + 1; l < 1024; l++) // Iterăm toate liniile de dedesubt
                {
                    int nextLineIndex = l * 1024;
                    for (int j = 0; j < 1024;)
                    {
                        if (memorie[nextLineIndex + j] != 0)
                        {
                            int descriptor = memorie[nextLineIndex + j];
                            int count = 0;

                            // Determinăm lungimea grupului (descriptorului)
                            while (j + count < 1024 && memorie[nextLineIndex + j + count] == descriptor)
                            {
                                count++;
                            }

                            // Verificăm dacă întreg grupul încape pe linia curentă
                            if (k + count <= 1024)
                            {
                                for (int m = 0; m < count; m++)
                                {
                                    memorie[i * 1024 + k] = memorie[nextLineIndex + j];
                                    memorie[nextLineIndex + j] = 0;
                                    k++;
                                    j++;
                                }
                            }
                            else
                            {
                                break; // Dacă nu încape întregul grup, oprim mutarea
                            }
                        }
                        else
                        {
                            j++;
                        }
                    }

                    // Dacă linia curentă este plină, ieșim din buclă
                    if (k == 1024)
                    {
                        break;
                    }
                }
            }

        // afisare dupa defrag
        // Afișare toată memoria sub forma ((linieStart, coloanaStart), (linieEnd, coloanaEnd))
            for (int i = 0; i < 1024; i++) // parcurgem liniile
            {
                int j = 0;
                while (j < 1024)
                {
                    if (memorie[i * 1024 + j] != 0)
                    {
                        int start = j;
                        int descriptor = memorie[i * 1024 + j];
                        while (j < 1024 && memorie[i * 1024 + j] == descriptor)
                        {
                            j++;
                        }
                        int end = j - 1;
                        cout <<descriptor << ": ((" << i << ", " << start << "), (" << i << ", " << end << "))\n";
                    }
                    else
                    {
                        j++;
                    }
                }
            }
        }
    }

    return 0;
}