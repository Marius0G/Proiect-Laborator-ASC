.section .data
hello:
    .string "Hello, World!\n"

.section .text
.global _start

_start:
    # Write "Hello, World!" to stdout
    movl $4, %eax        # syscall number for sys_write
    movl $1, %ebx        # file descriptor 1 is stdout
    movl $hello, %ecx    # pointer to the hello message
    movl $14, %edx       # number of bytes to write
    int $0x80            # call kernel

    et_exit:
    # Exit the program
    movl $1, %eax        # syscall number for sys_exit
    xorl %ebx, %ebx      # exit code 0
    int $0x80            # call kernel