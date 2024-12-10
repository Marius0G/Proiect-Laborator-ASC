.data
    # Variabile pentru loop ul principal(de baza)
    nrOperatii: .space 4
    operatieCurentaLoopPrincipal: .long 0
    codOperatie: .space 4 # 1 = ADD, 2 = GET, 3 = DELETE, 4 = DEFRAG
    # Variabila pentru array ul de memorie
    memorie: .space 4100

    # Variabile pentru operatia ADD
    nAdd: .space 4
    descriptorAdd: .space 4
    spatiuAddKb: .space 4
    spatiuAddBlocuri: .space 4
    addStartPos: .long 0
    addFinPos: .long 0
    addNrBlocuriLibere: .long 0
    operatieCurentaAdd: .long 0
    formatAfisareAdd: .asciz "%d: (%d, %d)\n"
    # Variabile pentru operatia GET
    descriptorGet: .space 4
    getStartPos: .space 4
    getFinPos: .space 4

    # Variabile pentru operatia DELETE
    descriptorDelete: .space 4
    deleteStartPos: .space 4
    deleteFinPos: .space 4

    startAfisareVector: .long 0
    endAfisareVector: .long 0

    # Variabile pentru operatia DEFRAG

    # Variabile de afisare
    formatAfisareDebug: .asciz "%d "
    formatCitireGet: .asciz "%d"
    formatAfisareGet: .asciz "(%d, %d)\n"
    formatAfisareVector: .asciz "%d: (%d, %d)\n"
.text
.global main

afisareArrayDebug: #afisare primele 20 de elemente din array ca sa imi dau seama ce am acolo
    push %ebp
    mov %esp, %ebp #aici pot sa accesez primul parametru cu 8(%ebp)
    push %ebx
    mov $0, %ecx
    mov $20, %ebx #numarul de elemente pe care vreau sa le afisez 

loopAfisareArrayDebug1: #folosesc ecx pt index, ebx pt unde sa ma opresc, eax ca sa vad ce sa afisez
    cmp %ecx, %ebx
    je exitAfisareArrayDebug1
    mov (%edi, %ecx, 4), %eax 
    push %ecx
    push %eax
    push $formatAfisareDebug
    call printf
    add $8, %esp        
    pop %ecx
    push %ecx
    push $0
    call fflush # asta ca sa afisez fara endline
    add $4, %esp
    pop %ecx
    inc %ecx
    jmp loopAfisareArrayDebug1

exitAfisareArrayDebug1:
    pop %ebx
    pop %ebp
    ret

main:
    lea memorie, %edi #edi = adresa de inceput a memoriei, o las asa definitiv momentan

    # Citire numar de operatii
    push $nrOperatii
    push $formatCitireGet
    call scanf
    addl $8, %esp


    # Initializarea tuturor elementelor din memorie cu 0
    lea memorie, %edi
    mov $1023, %ecx
    loopInitializareMemorie:
        mov $0, (%edi, %ecx, 4)
        loop loopInitializareMemorie


    # Loop principal(iteram de nrOperatii ori)
    loopPrincipal:
        mov operatieCurentaLoopPrincipal, %ecx
        cmp nrOperatii, %ecx
        je exitLoopPrincipal
        inc %ecx
        mov %ecx, operatieCurentaLoopPrincipal

        # Citire cod operatie curent
        push %edi
        push $codOperatie
        push $formatCitireGet
        call scanf
        addl $8, %esp
        pop %edi

        # Verific daca codul operatiei este 1(ADD)
        verificareCodOperatieAdd:
        cmp $1, codOperatie
        je operatieAdd
        jmp verificareCodOperatieGet
        operatieAdd:
            #Citesc de cate ori se adauga ceva
            push $nAdd
            push $formatCitireGet
            call scanf
            add $8, %esp

            #Fac un loop care se executa de nAdd ori
            mov $0, operatieCurentaAdd
            loopAdd1:
            mov operatieCurentaAdd, %ecx
            cmp nAdd, %ecx
            je exitLoopAdd1
            inc %ecx
            mov %ecx, operatieCurentaAdd
            #Citesc descriptorul
            push $descriptorAdd
            push $formatCitireGet
            call scanf
            add $8, %esp
            #Citesc spatiul in KB
            push $spatiuAddKb
            push $formatCitireGet
            call scanf
            add $8, %esp
            #Calculez nr de spatii de care avem nevoie
            #Calculez restul impartirii lui spatiuAddKb la 8
            xor %edx, %edx
            mov spatiuAddKb, %eax
            mov $8, %ebx
            div %ebx
            # Acum EAX conține rezultatul împărțirii, iar EDX conține restul
            # Daca restul este 0, atunci spatiuAddBlocuri = EAX
            cmp $0, %edx
            je calculeazaSpatiuAddBlocuri
            # Daca restul nu este 0, atunci spatiuAddBlocuri = EAX + 1
            inc %eax
            calculeazaSpatiuAddBlocuri:
            mov %eax, spatiuAddBlocuri

            #se cauta un spatiu liber, se vede unde se poate adauga
            lea memorie, %edi
            mov $0, addStartPos
            mov $0, addFinPos
            mov $0, addNrBlocuriLibere
            mov $0, %ecx
            mov $1024, %ebx
            loopAdd2:
            cmp %ecx, %ebx
            je cazSpecialAdd

            #DE FACUT CAZ EXCEPTIE DACA NU POATE FI ADAUGAT

            addIf1:  # addNrBlocuriLibere != 0 && memorie[i] == 0
            mov addNrBlocuriLibere, %eax
            cmp $0, %eax
            je addIf2
            mov (%edi, %ecx, 4), %eax
            cmp $0, %eax
            jne addIf2
            # adunam 1 la addNrBlocuriLibere
            mov addNrBlocuriLibere, %eax
            inc %eax
            mov %eax, addNrBlocuriLibere

            addIf2:  # addNrBlocuriLibere == 0 && memorie[i] == 0
            mov addNrBlocuriLibere, %eax
            cmp $0, %eax
            jne addIf3
            mov (%edi, %ecx, 4), %eax
            cmp $0, %eax
            jne addIf3
            # setam addStartPos cu i
            mov %ecx, addStartPos
            # adun 1 la addNrBlocuriLibere
            mov addNrBlocuriLibere, %eax
            inc %eax
            mov %eax, addNrBlocuriLibere

            addIf3: # addNrBlocuriLibere != 0 && memorie[i] != 0
            mov addNrBlocuriLibere, %eax
            cmp $0, %eax
            je addIf4
            mov (%edi, %ecx, 4), %eax
            cmp $0, %eax
            je addIf4
            mov $0, addNrBlocuriLibere

            addIf4:  #addNrBlocuriLibere == spatiuAddBlocuri
            mov addNrBlocuriLibere, %eax
            cmp spatiuAddBlocuri, %eax
            jne exitAddIf
            # setam addFinPos cu i
            mov %ecx, addFinPos
            # iesim din loop
            jmp exitLoopAdd2
            exitAddIf:
            inc %ecx
            jmp loopAdd2

            cazSpecialAdd:
            mov $0, addStartPos
            mov $0, addFinPos
            
            jmp exitLoopAdd3
            exitLoopAdd2: #MODIFICAREA ARRAY-ULUI
            lea memorie, %edi
            mov addStartPos, %ecx
            mov addFinPos, %ebx
            inc %ebx
            loopAdd3:
            cmp %ebx, %ecx
            je exitLoopAdd3
            mov descriptorAdd, %eax
            mov %eax, (%edi, %ecx, 4)
            inc %ecx
            jmp loopAdd3
            exitLoopAdd3:
            # Afisare rezultat
            push addFinPos
            push addStartPos
            push descriptorAdd
            push $formatAfisareAdd
            call printf
            add $16, %esp

            # afisareArrayDebug
            lea memorie, %edi
            // call afisareArrayDebug
            jmp loopAdd1
            exitLoopAdd1:

            jmp exitOperatie
            #SFARSIT OPERATIE ADD

        # Verific daca codul operatiei este 2(GET)
        verificareCodOperatieGet:
        cmp $2, codOperatie
        je operatieGet
        jmp verificareCodOperatieDelete
        operatieGet:
            # Citire descriptor
            push %edi
            push $descriptorGet
            push $formatCitireGet
            call scanf
            addl $8, %esp
            pop %edi # Am verificat, descriptorul se citeste corect
            #Initializez getStartPos si getFinPos
            mov $0, getStartPos
            mov $0, getFinPos
            lea memorie, %edi
            #Intru in for (for(int i=0; i<1024; i++) )
            mov $0, %ecx
            mov $1024, %ebx
            loopGet1:
            cmp %ecx, %ebx
            je exitLoopGet1
            # Incarc in eax valoarea de la indexul curent din array
            mov (%edi, %ecx, 4), %eax
            # Verific daca descriptorul este egal cu valoarea din array
            cmp descriptorGet, %eax
            jne nextIterationGet1
            # Verific daca getStartPos este 0
            cmp $0, getStartPos
            jne loopGetSetFinPos
            # Daca getStartPos este 0, atunci il setez pe acesta cu indexul curent
            mov %ecx, getStartPos
            jmp nextIterationGet1
            #Daca getStartPos este diferit de 0, atunci il setez pe getFinPos cu indexul curent
            loopGetSetFinPos:
            mov %ecx, getFinPos


            nextIterationGet1:
            inc %ecx
            jmp loopGet1
            exitLoopGet1:
            # Afisare rezultat
            push getFinPos
            push getStartPos
            push $formatAfisareGet
            call printf
            add $12, %esp
            jmp exitOperatie
            #SFARSIT OPERATIE GET

        # Verific daca codul operatiei este 3(DELETE)
        verificareCodOperatieDelete:
        cmp $3, codOperatie
        je operatieDelete
        jmp verificareCodOperatieDefrag
        operatieDelete:
            # Citire descriptor care trebuie sters
            push $descriptorDelete
            push $formatCitireGet
            call scanf
            add $8, %esp

            # Cautare descriptor in memorie
            #Intru in for (for(int i=0; i<1024; i++) )
            lea memorie, %edi
            mov $0, deleteStartPos
            mov $0, deleteFinPos
            mov $0, %ecx
            mov $1024, %ebx
            loopDelete1:
            cmp %ecx, %ebx
            je exitLoopDelete1
            # memorie[i] == descriptorDelete 
            mov (%edi, %ecx, 4), %eax
            cmp descriptorDelete, %eax
            jne iteratieDelete1
            # deleteStartPos == 0
            mov deleteStartPos, %eax
            cmp $0, %eax
            jne iteratieDelete2
            # setez deleteStartPos cu i
            mov %ecx, deleteStartPos
            iteratieDelete2:
            # setez deleteFinPos cu i
            mov %ecx, deleteFinPos
            iteratieDelete1:

            inc %ecx
            jmp loopDelete1
            exitLoopDelete1:
            # Acum sterg efectiv valorile
            mov deleteFinPos, %edx
            inc %edx
            mov %edx, deleteFinPos
            mov deleteStartPos, %ecx
            mov deleteFinPos, %ebx
            loopDelete2:
            cmp %ebx, %ecx
            je exitLoopDelete2
            mov $0, (%edi, %ecx, 4)
            inc %ecx
            jmp loopDelete2
            exitLoopDelete2:

            # Afisare tot vectorul
            lea memorie, %edi
            # Loop de la 0 la 1023
            mov $0, %ecx
            mov $1024, %ebx
            loopAfisareVector1:
                lea memorie, %edi
                cmp %ecx, %ebx
                je exitLoopAfisareVector1
                # Verific daca elementul curent este diferit de 0
                mov (%edi, %ecx, 4), %eax
                cmp $0, %eax
                je iteratieAfisareVector1
                # Definesc start si end cu ecx
                mov %ecx, startAfisareVector
                mov %ecx, endAfisareVector
                # Cat timp memorie[end] == memorie[start], incrementez end
                loopAfisareVector2:
                    mov (%edi, %ecx, 4), %eax
                    mov endAfisareVector, %edx
                    cmp %eax, (%edi, %edx, 4)
                    jne exitLoopAfisareVector2
                    mov endAfisareVector, %edx
                    inc %edx
                    mov %edx, endAfisareVector
                    jmp loopAfisareVector2
                exitLoopAfisareVector2:
                    mov endAfisareVector, %edx
                    dec %edx
                    mov %edx, endAfisareVector
                    push endAfisareVector
                    push startAfisareVector
                    push (%edi, %ecx, 4)
                    push $formatAfisareVector
                    call printf
                    add $16, %esp
                    mov endAfisareVector, %edx
                    mov %edx, %ecx

                iteratieAfisareVector1:
                inc %ecx
                jmp loopAfisareVector1
                # AM TERMINAT DE AFISAT VECTORUL

            exitLoopAfisareVector1:
            jmp exitOperatie
            #SFARSIT OPERATIE DELETE

        # Verific daca codul operatiei este 4(DEFRAG)
        verificareCodOperatieDefrag:
        cmp $4, codOperatie
        je operatieDefrag
        jmp exitOperatie
        operatieDefrag:
            # De fiecare data cand intalnesc 0, mut tot ce e dupa el cu o pozitie in fata
            #for de la 0 la 1023
            lea memorie, %edi
            mov $0, %ecx
            mov $1024, %ebx
            loopDefrag1:
            cmp %ecx, %ebx
            je exitLoopDefrag1
            # Daca elementul curent este diferit de 0, sar peste
            mov (%edi, %ecx, 4), %eax
            cmp $0, %eax
            jne iteratieDefrag1
            # for(int j=i+1; j<1024; j++)
            mov %ecx, %edx
            inc %edx
            mov $1024, %ebx
            loopDefrag2:
            cmp %ebx, %edx
            je exitLoopDefrag2
            # Daca elementul curent este egal cu 0, sar peste
            mov (%edi, %edx, 4), %eax
            cmp $0, %eax
            je iteratieDefrag2
            mov (%edi, %edx, 4), %eax
            mov %eax, (%edi, %ecx, 4)
            mov $0, (%edi, %edx, 4)
            jmp exitLoopDefrag2
            iteratieDefrag2:
            inc %edx
            jmp loopDefrag2
            exitLoopDefrag2:
            iteratieDefrag1:
            inc %ecx
            jmp loopDefrag1
            exitLoopDefrag1:
            # Afisare tot vectorul
            lea memorie, %edi
            # Loop de la 0 la 1023
            mov $0, %ecx
            mov $1024, %ebx
            loopAfisareVector1defrag:
                lea memorie, %edi
                cmp %ecx, %ebx
                je exitLoopAfisareVector1defrag
                # Verific daca elementul curent este diferit de 0
                mov (%edi, %ecx, 4), %eax
                cmp $0, %eax
                je iteratieAfisareVector1defrag
                # Definesc start si end cu ecx
                mov %ecx, startAfisareVector
                mov %ecx, endAfisareVector
                # Cat timp memorie[end] == memorie[start], incrementez end
                loopAfisareVector2defrag:
                    mov (%edi, %ecx, 4), %eax
                    mov endAfisareVector, %edx
                    cmp %eax, (%edi, %edx, 4)
                    jne exitLoopAfisareVector2defrag
                    mov endAfisareVector, %edx
                    inc %edx
                    mov %edx, endAfisareVector
                    jmp loopAfisareVector2defrag
                exitLoopAfisareVector2defrag:
                    mov endAfisareVector, %edx
                    dec %edx
                    mov %edx, endAfisareVector
                    push endAfisareVector
                    push startAfisareVector
                    push (%edi, %ecx, 4)
                    push $formatAfisareVector
                    call printf
                    add $16, %esp
                    mov endAfisareVector, %edx
                    mov %edx, %ecx

                iteratieAfisareVector1defrag:
                inc %ecx
                jmp loopAfisareVector1defrag
                exitLoopAfisareVector1defrag:
                jmp exitOperatie
                # AM TERMINAT DE AFISAT VECTORUL

            jmp exitOperatie
            #SFARSIT OPERATIE DEFRAG
        
        exitOperatie:

        #Final loop principal
        jmp loopPrincipal


exitLoopPrincipal:

et_exit: # iesirea din program
mov $1, %eax
xor %ebx, %ebx
int $0x80
    