.data
memorie: .space 4194304 # 1024 * 1024 * 4

# Variabile pentru loop ul principal(de baza)
nrOperatii: .space 4
operatieCurentaLoopPrincipal: .long 0
codOperatie: .space 4 # 1 = ADD, 2 = GET, 3 = DELETE, 4 = DEFRAG

# Variabile pentru ADD
nAdd: .space 4
operatieCurentaAdd: .long 0
descriptorAdd: .space 4
spatiuAddKb: .space 4
spatiuAddBlocuri: .space 4
foundSpaceAdd: .long 0
countAdd: .long 0
counterLoopAdd4: .long 0    # counter pentru loop ul 4 din ADD

# Variabile pentru GET
descriptorGet: .space 4
foundGet: .long 0
startGet: .long 0
endGet: .long 0

# Variabile pentru DELETE
descriptorDelete: .space 4
startAfisareDelete: .long 0
endAfisareDelete: .long 0
descriptorAfisareDelete: .long 0

# Variabile pentru DEFRAG
vectorDefragDescriptori: .space 4096
vectorDefragSpatii: .space 4096
nrDescriptoriDefrag: .long 0
descriptorAnterior: .long 1025
spatiuCurent: .long 0
lDefrag: .long 0

# Variabile pentru CONCRETE
filepath: .space 256
fds: .space 4
fd: .space 4
size: .space 4
statbuf: .space 128
# Variabile de afisare
formatCitireGet: .asciz "%d"
formatAfisareAdd: .asciz "%d: ((%d, %d), (%d, %d))\n"
formatAfisareGet: .asciz "((%d, %d), (%d, %d))\n"
formatAfisareDelete: .asciz "%d: ((%d, %d), (%d, %d))\n"

fdebug: .asciz "%s\n"
.text
.global main
main:
#setez toata memoria cu 0
mov $0, %ecx
mov $1024, %ebx
lea memorie, %edi

loopInitializareMemorie1:
    cmp %ebx, %ecx
    je exitLoopInitializareMemorie1

    mov $0, %edx
    loopInitializareMemorie2:
        cmp %ebx, %edx
        je exitLoopInitializareMemorie2

        mov %ecx, %eax
        imul $1024, %eax
        add %edx, %eax
        mov $0, (%edi, %eax, 4)

        inc %edx
        jmp loopInitializareMemorie2
    exitLoopInitializareMemorie2:
    inc %ecx
    jmp loopInitializareMemorie1
exitLoopInitializareMemorie1:

# Citire numar de operatii
    push $nrOperatii
    push $formatCitireGet
    call scanf
    addl $8, %esp

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
        # Am calculat spatiuAddBlocuri adica cate blocuri de 8KB avem nevoie

        mov $0, foundSpaceAdd
        #for (int i = 0; i < 1024 && foundSpaceAdd == 0; i++)
        # ecx = i si edx = j
        mov $0, %ecx
            loopAdd2:
            cmp $1024, %ecx
            je exitLoopAdd2
            cmp $0, foundSpaceAdd
            jne exitLoopAdd2

            mov $0, countAdd
            #for (int j = 0; j < 1024; j++) // parcurgem coloanele
            mov $0, %edx
                loopAdd3:
                lea memorie, %edi
                cmp $1024, %edx
                je exitLoopAdd3

                #(memorie[i * 1024 + j] == 0)
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                #acum eax e i * 1024 + j
                mov (%edi, %eax, 4), %eax
                cmp $0, %eax
                je ifAdd1
                jmp ifAdd1Else
                ifAdd1:
                mov countAdd, %eax
                inc %eax
                mov %eax, countAdd

                #(count == spatiuAddBlocuri)
                cmp spatiuAddBlocuri, %eax
                je ifAdd2
                jmp exitIfAdd2
                    ifAdd2:
                    lea memorie, %edi
                    #inseamna ca am gasit un bloc sufieicent de mare
                    #for (int m = j - spatiuAddBlocuri + 1; m <= j; m++)
                    mov %edx, %eax
                    sub spatiuAddBlocuri, %eax
                    inc %eax
                    mov %eax, counterLoopAdd4
                        loopAdd4:
                        mov counterLoopAdd4, %eax
                        cmp %edx, %eax
                        jg exitLoopAdd4
                        # memorie[i * 1024 + m] = descriptorAdd;
                        mov %ecx, %eax
                        imul $1024, %eax
                        add counterLoopAdd4, %eax
                        mov descriptorAdd, %ebx
                        mov %ebx, (%edi, %eax, 4)

                        mov counterLoopAdd4, %eax
                        inc %eax
                        mov %eax, counterLoopAdd4
                        jmp loopAdd4
                    exitLoopAdd4:
                    mov $1, foundSpaceAdd
                    #Facem afisarea
                    push %eax
                    push %ebx
                    push %ecx
                    push %edx
                    push %edx
                    push %ecx
                    #(j - spatiuAddBlocuri + 1)
                    mov %edx, %eax
                    sub spatiuAddBlocuri, %eax
                    inc %eax
                    push %eax
                    push %ecx
                    push descriptorAdd
                    push $formatAfisareAdd
                    call printf
                    add $24, %esp
                    pop %edx
                    pop %ecx
                    pop %ebx
                    pop %eax
                    lea memorie, %edi
                    jmp exitLoopAdd3
                    jmp exitIfAdd2
                exitIfAdd2:
                jmp exitIfAdd1
                ifAdd1Else:
                mov $0, countAdd
                jmp exitIfAdd1
                exitIfAdd1:
                inc %edx
                jmp loopAdd3
            exitLoopAdd3:
            inc %ecx
            jmp loopAdd2
        exitLoopAdd2:
        cmp $0, foundSpaceAdd
        jne ifAdd3
        push %eax
        push %ebx
        push %ecx
        push %edx
        push $0
        push $0
        push $0
        push $0
        push descriptorAdd
        push $formatAfisareAdd
        call printf
        add $24, %esp
        pop %edx
        pop %ecx
        pop %ebx
        pop %eax
        ifAdd3:

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

        mov $0, foundGet
        #for (int i = 0; i < 1024 && foundGet == 0; i++)
        mov $0, %ecx
        loopGet1:
        cmp $1024, %ecx
        je exitLoopGet1
        cmp $0, foundGet
        jne exitLoopGet1
        #for (int j = 0; j < 1024; j++) // parcurgem coloanele
        mov $0, %edx
            loopGet2:
            lea memorie, %edi
            cmp $1024, %edx
            je exitLoopGet2
            #(memorie[i * 1024 + j] == descriptorGet)
            mov %ecx, %eax
            imul $1024, %eax
            add %edx, %eax
            mov (%edi, %eax, 4), %eax
            cmp descriptorGet, %eax
            jne continuareGet2
                mov %edx, startGet
                #while (j < 1024 && memorie[i * 1024 + j] == descriptor)
                whileLoopGet1:
                cmp $1024, %edx
                je exitWhileLoopGet1
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                mov (%edi, %eax, 4), %eax
                cmp descriptorGet, %eax
                jne exitWhileLoopGet1
                inc %edx
                jmp whileLoopGet1
                exitWhileLoopGet1:
                dec %edx
                mov %edx, endGet
                mov $1, foundGet
                #Facem afisarea i, startGet, i, endGet
                push endGet
                push %ecx
                push startGet
                push %ecx
                push $formatAfisareGet
                call printf
                add $20, %esp
                jmp exitLoopGet2
            continuareGet2:
            inc %edx
            jmp loopGet2
        exitLoopGet2:
        inc %ecx
        jmp loopGet1
        exitLoopGet1:
        # daca foundGet == 0, atunci printf"((0, 0), (0, 0))\n";
        cmp $0, foundGet
        jne continuareGet1
        push $0
        push $0
        push $0
        push $0
        push $formatAfisareGet
        call printf
        add $20, %esp
        continuareGet1:
        jmp exitOperatie
        #SFARSIT OPERATIE GET

    # Verific daca codul operatiei este 3(DELETE)
    verificareCodOperatieDelete:
    cmp $3, codOperatie
    je operatieDelete
    jmp verificareCodOperatieDefrag
    operatieDelete:
        push $descriptorDelete
        push $formatCitireGet
        call scanf
        add $8, %esp

        #for (int i = 0; i < 1024; i++)
        mov $0, %ecx
        loopDelete1:
        cmp $1024, %ecx
        je exitLoopDelete1
        #for (int j = 0; j < 1024; j++) // parcurgem coloanele
        mov $0, %edx
            loopDelete2:
            lea memorie, %edi
            cmp $1024, %edx
            je exitLoopDelete2
            #(memorie[i * 1024 + j] == descriptorDelete)
            mov %ecx, %eax
            imul $1024, %eax
            add %edx, %eax
            mov (%edi, %eax, 4), %eax
            cmp descriptorDelete, %eax
            jne continueDelete1
                lea memorie, %edi
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                mov $0, %ebx
                mov %ebx, (%edi, %eax, 4)
            continueDelete1:
            inc %edx
            jmp loopDelete2
            exitLoopDelete2:
        inc %ecx
        jmp loopDelete1
        exitLoopDelete1:

        # Afisare toata memoria sub forma filedescriptor: ((linieStart, coloanaStart), (linieEnd, coloanaEnd))
        mov $0, %ecx
        loopAfisareMemorie1:
        cmp $1024, %ecx
        je exitLoopAfisareMemorie1

        mov $0, %edx
            loopAfisareMemorie2:
            # while (j < 1024)
            cmp $1024, %edx
            je exitLoopAfisareMemorie2
            # (memorie[i * 1024 + j] != 0)
            lea memorie, %edi
            mov %ecx, %eax
            imul $1024, %eax
            add %edx, %eax
            mov (%edi, %eax, 4), %eax
            cmp $0, %eax
            jne ifAfisareMemorie1
            jmp ifAfisareMemorie1Else
            ifAfisareMemorie1:
            mov %edx, startAfisareDelete
            # descriptorAfisareDelete = memorie[i * 1024 + j]
            mov %ecx, %eax
            imul $1024, %eax
            add %edx, %eax
            mov (%edi, %eax, 4), %eax
            mov %eax, descriptorAfisareDelete
            # while (j < 1024 && memorie[i * 1024 + j] == descriptorAfisareDelete)
            whileAfisareMemorie1:
            cmp $1024, %edx
            je exitWhileAfisareMemorie1
            lea memorie, %edi
            mov %ecx, %eax
            imul $1024, %eax
            add %edx, %eax
            mov (%edi, %eax, 4), %eax
            cmp descriptorAfisareDelete, %eax
            jne exitWhileAfisareMemorie1
            inc %edx
            jmp whileAfisareMemorie1
            exitWhileAfisareMemorie1:
            dec %edx
            mov %edx, endAfisareDelete
            inc %edx
            # Afisare
            push %eax
            push %ebx
            push %ecx
            push %edx
            push endAfisareDelete
            push %ecx
            push startAfisareDelete
            push %ecx
            push descriptorAfisareDelete
            push $formatAfisareDelete
            call printf
            add $24, %esp
            pop %edx
            pop %ecx
            pop %ebx
            pop %eax
            #end afisare
            jmp ifAfisareMemorie1Exit
            ifAfisareMemorie1Else:
            inc %edx
            jmp ifAfisareMemorie1Exit
            ifAfisareMemorie1Exit:
            jmp loopAfisareMemorie2
            exitLoopAfisareMemorie2:
        inc %ecx
        jmp loopAfisareMemorie1
        exitLoopAfisareMemorie1:
        # STOP AFISARE MEMORIE
        jmp exitOperatie
        #SFARSIT OPERATIE DELETE

    # Verific daca codul operatiei este 4(DEFRAG)
    verificareCodOperatieDefrag:
        cmp $4, codOperatie
        je operatieDefrag
        jmp verificareCodOperatieConcrete
    operatieDefrag:
        mov $0, nrDescriptoriDefrag
        mov $1025, descriptorAnterior
        #for (int i = 0; i < 1024; i++)
        mov $0, %ecx
        loopDefrag1:
        cmp $1024, %ecx
        je exitLoopDefrag1
        #vectorDefragDescriptori[i] = 0;
        mov %ecx, %eax
        lea vectorDefragDescriptori, %edi
        mov $0, %ebx
        mov %ebx, (%edi, %eax, 4)
        inc %ecx
        jmp loopDefrag1
        exitLoopDefrag1:
        mov $0, %ecx
        loopDefrag2:
        cmp $1024, %ecx
        je exitLoopDefrag2
        #vectorDefragDescriptori[i] = 0;
        mov %ecx, %eax
        lea vectorDefragSpatii, %edi
        mov $0, %ebx
        mov %ebx, (%edi, %eax, 4)
        inc %ecx
        jmp loopDefrag2
        exitLoopDefrag2:

        #for (int i = 0; i < 1024; i++)
        mov $0, %ecx
        loopDefrag3:
        cmp $300, %ecx
        je exitLoopDefrag3

        mov $0, %edx
        #while (j < 1024)
            loopDefrag4:
            cmp $1024, %edx
            je exitLoopDefrag4

            mov $0, spatiuCurent
            #(descriptorAnterior == 1025 && memorie[i * 1024 + j] != 0)
            lea memorie, %edi
            mov %ecx, %eax
            imul $1024, %eax
            add %edx, %eax
            lea memorie, %edi
            mov (%edi, %eax, 4), %eax
            cmp $0, %eax
            je elseIfDefrag1
            cmp $1025, descriptorAnterior
            jne elseIfDefrag1
            ifDefrag1:
                lea memorie, %edi
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                mov %eax, descriptorAnterior
                lea vectorDefragDescriptori, %edi
                mov nrDescriptoriDefrag, %eax
                mov descriptorAnterior, %ebx
                mov %ebx, (%edi, %eax, 4)
                #while (j < 1024 && memorie[i * 1024 + j] != 0)
                whileDefrag1:
                cmp $1024, %edx
                je exitWhileDefrag1
                lea memorie, %edi
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                mov (%edi, %eax, 4), %eax
                cmp descriptorAnterior, %eax
                jne exitWhileDefrag1
                
                mov spatiuCurent, %eax
                inc %eax
                mov %eax, spatiuCurent
                inc %edx
                jmp whileDefrag1
                exitWhileDefrag1:
                lea vectorDefragSpatii, %edi
                mov nrDescriptoriDefrag, %eax
                mov spatiuCurent, %ebx
                mov %ebx, (%edi, %eax, 4)
                mov nrDescriptoriDefrag, %eax
                inc %eax
                mov %eax, nrDescriptoriDefrag
                jmp exitIfDefrag1
            elseIfDefrag1:
                #(memorie[i * 1024 + j] != descriptorAnterior && memorie[i * 1024 + j] != 0)
                lea memorie, %edi
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                mov (%edi, %eax, 4), %eax
                cmp descriptorAnterior, %eax
                je elseIfDefrag2
                cmp $0, %eax
                je elseIfDefrag2
                ifDefrag2:
                lea memorie, %edi
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                mov (%edi, %eax, 4), %eax
                mov %eax, descriptorAnterior
                lea vectorDefragDescriptori, %edi
                mov nrDescriptoriDefrag, %eax
                mov descriptorAnterior, %ebx
                mov %ebx, (%edi, %eax, 4)
                #while (j < 1024 && memorie[i * 1024 + j] != 0)
                whileDefrag2:
                cmp $1024, %edx
                je exitWhileDefrag2
                lea memorie, %edi
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                mov (%edi, %eax, 4), %eax
                cmp descriptorAnterior, %eax
                jne exitWhileDefrag2

                mov spatiuCurent, %eax
                inc %eax
                mov %eax, spatiuCurent
                inc %edx

                jmp whileDefrag2
                exitWhileDefrag2:
                lea vectorDefragSpatii, %edi
                mov nrDescriptoriDefrag, %eax
                mov spatiuCurent, %ebx
                mov %ebx, (%edi, %eax, 4)
                mov nrDescriptoriDefrag, %eax
                inc %eax
                mov %eax, nrDescriptoriDefrag
                jmp exitIfDefrag2
                elseIfDefrag2:
                inc %edx
                jmp exitIfDefrag2
                exitIfDefrag2:
            jmp exitIfDefrag1
            exitIfDefrag1:
        jmp loopDefrag4
        exitLoopDefrag4:
        inc %ecx
        jmp loopDefrag3
        exitLoopDefrag3:

        mov $0, %ecx
        loopDefrag5:
        cmp $1024, %ecx
        je exitLoopDefrag5
        mov $0, %edx
        loopDefrag6:
        cmp $1024, %edx
        je exitLoopDefrag6
        lea memorie, %edi
        mov %ecx, %eax
        imul $1024, %eax
        add %edx, %eax
        mov $0, (%edi, %eax, 4)
        inc %edx
        jmp loopDefrag6
        exitLoopDefrag6:
        inc %ecx
        jmp loopDefrag5
        exitLoopDefrag5:

        mov $1, lDefrag
        mov lDefrag, %ecx
        loopDefrag7:
        mov lDefrag, %ecx
        mov nrDescriptoriDefrag, %ebx
        cmp %ebx, %ecx
        je exitLoopDefrag7

        lea vectorDefragDescriptori, %edi
        mov lDefrag, %eax
        mov (%edi, %eax, 4), %eax
        mov %eax, descriptorAdd

        lea vectorDefragSpatii, %edi
        mov lDefrag, %eax
        mov (%edi, %eax, 4), %eax
        mov %eax, spatiuAddBlocuri
        # Am calculat spatiuAddBlocuri adica cate blocuri de 8KB avem nevoie

        mov $0, foundSpaceAdd
        #for (int i = 0; i < 1024 && foundSpaceAdd == 0; i++)
        # ecx = i si edx = j
        mov $0, %ecx
            loopAdd2d:
            cmp $1024, %ecx
            je exitLoopAdd2d
            cmp $0, foundSpaceAdd
            jne exitLoopAdd2d

            mov $0, countAdd
            #for (int j = 0; j < 1024; j++) // parcurgem coloanele
            mov $0, %edx
                loopAdd3d:
                lea memorie, %edi
                cmp $1024, %edx
                je exitLoopAdd3d

                #(memorie[i * 1024 + j] == 0)
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                #acum eax e i * 1024 + j
                mov (%edi, %eax, 4), %eax
                cmp $0, %eax
                je ifAdd1d
                jmp ifAdd1Elsed
                ifAdd1d:
                mov countAdd, %eax
                inc %eax
                mov %eax, countAdd

                #(count == spatiuAddBlocuri)
                cmp spatiuAddBlocuri, %eax
                je ifAdd2d
                jmp exitIfAdd2d
                    ifAdd2d:
                    lea memorie, %edi
                    #inseamna ca am gasit un bloc sufieicent de mare
                    #for (int m = j - spatiuAddBlocuri + 1; m <= j; m++)
                    mov %edx, %eax
                    sub spatiuAddBlocuri, %eax
                    inc %eax
                    mov %eax, counterLoopAdd4
                        loopAdd4d:
                        mov counterLoopAdd4, %eax
                        cmp %edx, %eax
                        jg exitLoopAdd4d
                        # memorie[i * 1024 + m] = descriptorAdd;
                        mov %ecx, %eax
                        imul $1024, %eax
                        add counterLoopAdd4, %eax
                        mov descriptorAdd, %ebx
                        mov %ebx, (%edi, %eax, 4)

                        mov counterLoopAdd4, %eax
                        inc %eax
                        mov %eax, counterLoopAdd4
                        jmp loopAdd4d
                    exitLoopAdd4d:
                    mov $1, foundSpaceAdd
                    #Facem afisarea
                    push %eax
                    push %ebx
                    push %ecx
                    push %edx
                    push %edx
                    push %ecx
                    #(j - spatiuAddBlocuri + 1)
                    mov %edx, %eax
                    sub spatiuAddBlocuri, %eax
                    inc %eax
                    push %eax
                    push %ecx
                    push descriptorAdd
                    push $formatAfisareAdd
                    call printf
                    add $24, %esp
                    pop %edx
                    pop %ecx
                    pop %ebx
                    pop %eax
                    lea memorie, %edi
                    jmp exitLoopAdd3d
                    jmp exitIfAdd2d
                exitIfAdd2d:
                jmp exitIfAdd1d
                ifAdd1Elsed:
                mov $0, countAdd
                jmp exitIfAdd1d
                exitIfAdd1d:
                inc %edx
                jmp loopAdd3d
            exitLoopAdd3d:
            inc %ecx
            jmp loopAdd2d
        exitLoopAdd2d:
        cmp $0, foundSpaceAdd
        jne ifAdd3d
        push %eax
        push %ebx
        push %ecx
        push %edx
        push $0
        push $0
        push $0
        push $0
        push descriptorAdd
        push $formatAfisareAdd
        call printf
        add $24, %esp
        pop %edx
        pop %ecx
        pop %ebx
        pop %eax
        ifAdd3d:

        mov lDefrag, %ecx
        inc %ecx
        mov %ecx, lDefrag
        jmp loopDefrag7
        exitLoopDefrag7:

        jmp exitOperatie
        #SFARSIT OPERATIE DEFRAG
    
    verificareCodOperatieConcrete:
        cmp $5, codOperatie
        je operatieConcrete
        jmp exitOperatie
    operatieConcrete:
    # sys_read
    movl $3, %eax            
    movl $0, %ebx            
    movl $filepath, %ecx       
    movl $255, %edx          
    int $0x80

    movl    filepath, %eax
    subl    $8, %esp
    pushl   $0
    pushl   %eax
    call    open
    addl    $16, %esp
    movl    %eax, fds

    mov fds, %eax
    movl $255, %ebx
    xor %edx, %edx
    div %ebx
    mov %edx, %eax
    inc %eax
    mov %eax, fd

    mov $108, %eax
    mov fds, %ebx
    lea statbuf, %ecx
    int $0x80

    lea statbuf, %ecx
    movl 0x8(%ecx), %eax
    mov $1024, %ebx
    xor %edx, %edx
    div %ebx
    mov %eax, size

    mov fd, %eax
    mov %eax, descriptorAdd
    mov size, %eax
    mov %eax, spatiuAddKb
    xor %edx, %edx
    mov spatiuAddKb, %eax
    mov $8, %ebx
    div %ebx
    inc %eax
    mov %eax, spatiuAddBlocuri

    mov $0, foundSpaceAdd
        #for (int i = 0; i < 1024 && foundSpaceAdd == 0; i++)
        # ecx = i si edx = j
        mov $0, %ecx
            loopAdd2c:
            cmp $1024, %ecx
            je exitLoopAdd2c
            cmp $0, foundSpaceAdd
            jne exitLoopAdd2c

            mov $0, countAdd
            #for (int j = 0; j < 1024; j++) // parcurgem coloanele
            mov $0, %edx
                loopAdd3c:
                lea memorie, %edi
                cmp $1024, %edx
                je exitLoopAdd3c

                #(memorie[i * 1024 + j] == 0)
                mov %ecx, %eax
                imul $1024, %eax
                add %edx, %eax
                #acum eax e i * 1024 + j
                mov (%edi, %eax, 4), %eax
                cmp $0, %eax
                je ifAdd1c
                jmp ifAdd1Elsec
                ifAdd1c:
                mov countAdd, %eax
                inc %eax
                mov %eax, countAdd

                #(count == spatiuAddBlocuri)
                cmp spatiuAddBlocuri, %eax
                je ifAdd2c
                jmp exitIfAdd2c
                    ifAdd2c:
                    lea memorie, %edi
                    #inseamna ca am gasit un bloc sufieicent de mare
                    #for (int m = j - spatiuAddBlocuri + 1; m <= j; m++)
                    mov %edx, %eax
                    sub spatiuAddBlocuri, %eax
                    inc %eax
                    mov %eax, counterLoopAdd4
                        loopAdd4c:
                        mov counterLoopAdd4, %eax
                        cmp %edx, %eax
                        jg exitLoopAdd4c
                        # memorie[i * 1024 + m] = descriptorAdd;
                        mov %ecx, %eax
                        imul $1024, %eax
                        add counterLoopAdd4, %eax
                        mov descriptorAdd, %ebx
                        mov %ebx, (%edi, %eax, 4)

                        mov counterLoopAdd4, %eax
                        inc %eax
                        mov %eax, counterLoopAdd4
                        jmp loopAdd4c
                    exitLoopAdd4c:
                    mov $1, foundSpaceAdd
                    #Facem afisarea
                    push %eax
                    push %ebx
                    push %ecx
                    push %edx
                    push %edx
                    push %ecx
                    #(j - spatiuAddBlocuri + 1)
                    mov %edx, %eax
                    sub spatiuAddBlocuri, %eax
                    inc %eax
                    push %eax
                    push %ecx
                    push descriptorAdd
                    push $formatAfisareAdd
                    call printf
                    add $24, %esp
                    pop %edx
                    pop %ecx
                    pop %ebx
                    pop %eax
                    lea memorie, %edi
                    jmp exitLoopAdd3c
                    jmp exitIfAdd2c
                exitIfAdd2c:
                jmp exitIfAdd1c
                ifAdd1Elsec:
                mov $0, countAdd
                jmp exitIfAdd1c
                exitIfAdd1c:
                inc %edx
                jmp loopAdd3c
            exitLoopAdd3c:
            inc %ecx
            jmp loopAdd2c
        exitLoopAdd2c:
        cmp $0, foundSpaceAdd
        jne ifAdd3c
        push %eax
        push %ebx
        push %ecx
        push %edx
        push $0
        push $0
        push $0
        push $0
        push descriptorAdd
        push $formatAfisareAdd
        call printf
        add $24, %esp
        pop %edx
        pop %ecx
        pop %ebx
        pop %eax
        ifAdd3c: 
    exitOperatie:

    #Final loop principal
    jmp loopPrincipal
exitLoopPrincipal:
et_exit: # iesirea din program
    pushl $0
    call fflush
    popl %eax
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
    