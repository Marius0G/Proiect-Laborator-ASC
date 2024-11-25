.data
    nr_operatii: .space 4
    cod_operatie: .space 4 # 1 = ADD, 2 = GET, 3 = DELETE, 4 = DEFRAG

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
    movl (%edi, %ecx, 4), %eax 
    push %ecx
    push %eax
    push $formatAfisareDebug
    call printf
    add $8, %esp        
    pop %ecx
    inc %ecx
    jmp loopAfisareArrayDebug1

exitAfisareArrayDebug1:
    pop %ebx
    pop %ebp
    ret

main:
    lea memorie, %edi #edi = adresa de inceput a memoriei, o las asa definitiv momentan

//Citim numarul de operatii
// push $nr_operatii
// push $formatCitireGet
// call scanf
// addl $8, %esp

// push nr_operatii
// push $formatAfisareGet
// call printf
// addl $8, %esp

#Testare debug: afisareArrayDebug
mov $0, %ecx
call afisareArrayDebug

et_exit: # iesirea din program
mov $1, %eax
xor %ebx, %ebx
int $0x80
    