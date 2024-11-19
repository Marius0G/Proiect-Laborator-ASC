.section .data
msg:
    .ascii "z\n"

.section .text
.global _start

_start:
    # Write the message to stdout
    movl $4, %eax        # syscall number for sys_write
    movl $1, %ebx        # file descriptor 1 is stdout
    movl $msg, %ecx      # pointer to the message
    movl $2, %edx        # message length
    int $0x80            # call kernel

    # Exit the program
    movl $1, %eax        # syscall number for sys_exit
    xorl %ebx, %ebx      # exit code 0
    int $0x80            # call kernel