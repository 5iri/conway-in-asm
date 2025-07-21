        .section .rodata            # read-only data (const strings)
msg:    .asciz "Hello, RISC-V world!\n"

        .section .text
        .globl _start               # entry symbol expected by pk
_start:
        # --- write(fd=1, buf=&msg, len=22) -----------------------------
        li      a0, 1               # a0 = 1 → stdout
        la      a1, msg             # a1 = pointer to message
        li      a2, 22              # a2 = length
        li      a7, 64              # a7 = syscall 64 = write  (pk ABI)
        ecall                       # jump into pk, print string

        # --- exit(0) ---------------------------------------------------
        li      a0, 0               # status = 0
        li      a7, 93              # syscall 93 = exit
        ecall                       # pk terminates simulation
