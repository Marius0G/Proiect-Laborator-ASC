.data
    # Variabile pentru loop ul principal(de baza)
    nrOperatii: .space 4
    operatieCurenta: .long 0
    codOperatie: .space 4 # 1 = ADD, 2 = GET, 3 = DELETE, 4 = DEFRAG
    # Variabila pentru array ul de memorie
    memorie: .space 4096

    # Variabile pentru operatia ADD

    # Variabile pentru operatia GET
    descriptorGet: .space 4
    getStartPos: .space 4
    getFinPos: .space 4

    # Variabile de afisare
    formatAfisareDebug: .asciz "%d "
    formatCitireGet: .asciz "%d"
    formatAfisareGet: .asciz "(%d, %d)\n"
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
        mov operatieCurenta, %ecx
        cmp nrOperatii, %ecx
        je exitLoopPrincipal
        inc %ecx
        mov %ecx, operatieCurenta

        # Citire cod operatie curent
        push %edi
        push $codOperatie
        push $formatCitireGet
        call scanf
        addl $8, %esp
        pop %edi

        # Verific daca codul operatiei este 1(ADD)
        cmp $1, codOperatie
        je operatieAdd
        jmp verificareCodOperatieGet
        operatieAdd:

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
            jmp exitOperatie
            #SFARSIT OPERATIE DELETE

        # Verific daca codul operatiei este 4(DEFRAG)
        verificareCodOperatieDefrag:
        cmp $4, codOperatie
        je operatieDefrag
        jmp exitOperatie
        operatieDefrag:
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
    