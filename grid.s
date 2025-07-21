        .section .rodata
dot_ch:     .asciz "."           # printed for byte==0
emp_ch:     .asciz " "           # printed for byte!=0
nl_ch:      .asciz "\n"
intro:      .asciz "Let's print a grid:\n"

        .section .data
grid:           .byte 1,1,0,0,0,0,0,1
                .byte 1,0,0,0,0,0,1,0
                .byte 0,0,0,0,1,0,0,0
                .byte 0,0,0,1,0,0,0,0
                .byte 0,0,1,0,0,0,0,0
                .byte 0,1,0,0,0,0,0,0
                .byte 1,0,0,0,0,0,0,0
                .byte 0,1,0,0,0,0,0,0

        .section .text
        .globl _start
_start:
        # --- print intro -----------------------------------
        li      a0, 1              # fd = stdout
        la      a1, intro
        li      a2, 20             # length of intro string
        li      a7, 64             # write
        ecall

        la      a1, grid           # a1 = pointer to first row
        call    print_grid

        # --- exit(0) ---------------------------------------
        li      a0, 0
        li      a7, 93             # exit
        ecall                       # never returns

print_grid:
        mv      s0, a1             # s0 = current row pointer
        li      t5, 8              # rows remaining

row_loop:
        mv      t2, s0             # t2 = walker inside row
        li      t0, 8              # columns remaining

col_loop:
        lb      t4, 0(t2)          # load cell byte
        addi    t2, t2, 1          # advance pointer

        la      a1, dot_ch         # default ‘0’
        beqz    t4, emit
        la      a1, emp_ch         # if non-zero → ‘1’
emit:
        li      a0, 1
        li      a2, 1
        li      a7, 64
        ecall

        addi    t0, t0, -1
        bnez    t0, col_loop

        # newline after a row
        li      a0, 1
        la      a1, nl_ch
        li      a2, 1
        li      a7, 64
        ecall

        addi    s0, s0, 8          # next row
        addi    t5, t5, -1
        bnez    t5, row_loop
        ret
