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
            int nrFisiere;
            cin >> nrFisiere; // se citeste nr de fisiere
            for (int k = 0; k < nrFisiere; k++)
            {
                int descriptor;
                int spatiu;
                cin >> descriptor >> spatiu; // se citeste descriptorul si spatiul
                int spatiuBlocuri = spatiu / 8;
                if (spatiu % 8 != 0)
                {
                    spatiuBlocuri++;
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
                            if (count == spatiuBlocuri)
                            {
                                // Am găsit un bloc suficient de mare
                                for (int m = j - spatiuBlocuri + 1; m <= j; m++)
                                {
                                    memorie[i * 1024 + m] = descriptor;
                                }
                                foundSpace = true;
                                cout << descriptor << ": ((" << i << ", " << (j - spatiuBlocuri + 1) << "), (" << i << ", " << j << "))\n";
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
                    cout << descriptor << ": ((0, 0), (0, 0))\n";
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
            for (int i = 0; i < 1023; i++) // parcurgem liniile, până la penultima linie
            {
                int k = 0; // index pentru a ține evidența poziției de inserare pe linia curentă
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

                // Mutăm valorile nenule de pe linia următoare, dacă există spațiu
                int nextLineIndex = (i + 1) * 1024;
                for (int j = 0; j < 1024;)
                {
                    if (memorie[nextLineIndex + j] != 0)
                    {
                        int descriptor = memorie[nextLineIndex + j];
                        int count = 0;
                        while (j + count < 1024 && memorie[nextLineIndex + j + count] == descriptor)
                        {
                            count++;
                        }

                        if (k + count <= 1024) // Verificăm dacă întregul descriptor încape pe linia curentă
                        {
                            for (int l = 0; l < count; l++)
                            {
                                memorie[i * 1024 + k] = memorie[nextLineIndex + j];
                                memorie[nextLineIndex + j] = 0;
                                k++;
                                j++;
                            }
                        }
                        else
                        {
                            break; // Renunțăm la mutare dacă primul descriptor nu încape
                        }
                    }
                    else
                    {
                        j++;
                    }
                }
            }

            // Ultima linie
            int k = 0;
            for (int j = 0; j < 1024; j++)
            {
                if (memorie[1023 * 1024 + j] != 0)
                {
                    memorie[1023 * 1024 + k] = memorie[1023 * 1024 + j];
                    if (k != j)
                    {
                        memorie[1023 * 1024 + j] = 0;
                    }
                    k++;
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