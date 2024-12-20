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
# Variabile de afisare
formatCitireGet: .asciz "%d"
formatAfisareAdd: .asciz "%d: ((%d, %d), (%d, %d))\n"
formatAfisareGet: .asciz "((%d, %d), (%d, %d))\n"

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
    pushl $0
    call fflush
    popl %eax
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
    