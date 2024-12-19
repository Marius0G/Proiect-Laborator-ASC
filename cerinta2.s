.data
memorie: .space 4194304 # 1024 * 1024 * 4

# Variabile pentru loop ul principal(de baza)
nrOperatii: .space 4
operatieCurentaLoopPrincipal: .long 0
codOperatie: .space 4 # 1 = ADD, 2 = GET, 3 = DELETE, 4 = DEFRAG

# Variabile de afisare
formatCitireGet: .asciz "%d"

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

        jmp exitOperatie
        #SFARSIT OPERATIE ADD

    # Verific daca codul operatiei este 2(GET)
    verificareCodOperatieGet:
    cmp $2, codOperatie
    je operatieGet
    jmp verificareCodOperatieDelete
    operatieGet:
        
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
    