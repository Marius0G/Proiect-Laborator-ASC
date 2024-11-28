.data
    nrOperatii: .space 4
    operatieCurenta: .long 0
    codOperatie: .space 4 # 1 = ADD, 2 = GET, 3 = DELETE, 4 = DEFRAG

    memorie: .space 4096

    formatAfisareDebug: .asciz "%d "
    formatCitireGet: .asciz "%d"
    formatAfisareGet: .asciz "(%d)\n"
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
    mov $1024, %ecx
    loopInitializareMemorie:
        mov $0, (%edi, %ecx, 4)
        loop loopInitializareMemorie

    # Loop mare(iteram de nrOperatii ori)
    loopNrOperatii:
        mov operatieCurenta, %ecx
        cmp nrOperatii, %ecx
        je exitLoopNrOperatii
        inc %ecx
        mov %ecx, operatieCurenta

        call afisareArrayDebug

        jmp loopNrOperatii


exitLoopNrOperatii:

et_exit: # iesirea din program
mov $1, %eax
xor %ebx, %ebx
int $0x80
    