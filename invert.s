#######################################################################
#  Blink the 8×8 bitmap:                                           #
#     ­– show ORIGINAL, wait,                                       #
#     ­– cursor ↑8, invert in-place, show INVERTED, wait,           #
#     ­– cursor ↑8, invert back … repeat forever.                   #
#                                                                   #
#     Works under spike+pk, QEMU, or any VT100-capable terminal.    #
#######################################################################

        .section .rodata
dot_ch: .asciz "."
emp_ch: .asciz " "
nl_ch:  .asciz "\n"
intro:  .asciz "Blinking 8×8 grid (orig ↔ inv)\n"
up8:    .asciz "\x1b[8A"             # ESC[8A – move cursor up 8 lines

        .section .data
grid:   .byte 1,1,0,0,0,0,0,1
        .byte 1,0,0,0,0,0,1,0
        .byte 0,0,0,0,1,0,0,0
        .byte 0,0,0,1,0,0,0,0
        .byte 0,0,1,0,0,0,0,0
        .byte 0,1,0,0,0,0,0,0
        .byte 1,0,0,0,0,0,0,0
        .byte 0,1,0,0,0,0,0,0

        .section .text
        .globl _start

.equ DELAY_CYCLES, 80000000          # tune for ≈ ½ s on your target

########################################################################
#  _start
########################################################################
_start:
        # one-time intro
        li      a0, 1
        la      a1, intro
        li      a2, 35               # strlen(intro)
        li      a7, 64
        ecall

blink_loop:
        # 1) show current bitmap
        la      a1, grid
        call    print_grid

        li      a0, DELAY_CYCLES
        call    busy_wait

        # 2) move cursor up 8, invert, show inverted
        li      a0, 1
        la      a1, up8
        li      a2, 4
        li      a7, 64
        ecall

        call    invert_grid_inplace
        la      a1, grid
        call    print_grid

        li      a0, DELAY_CYCLES
        call    busy_wait

        # 3) move cursor up again, invert back, loop
        li      a0, 1
        la      a1, up8
        li      a2, 4
        li      a7, 64
        ecall

        call    invert_grid_inplace
        j       blink_loop           # never returns

########################################################################
#  void print_grid(uint8_t* ptr)
########################################################################
print_grid:
        addi    sp, sp, -8
        sd      s0, 0(sp)

        mv      s0, a1               # row pointer
        li      t5, 8                # rows

row_loop:
        mv      t2, s0               # column walker
        li      t0, 8                # columns
col_loop:
        lbu     t3, 0(t2)
        addi    t2, t2, 1
        la      a1, dot_ch
        beqz    t3, out_byte
        la      a1, emp_ch
out_byte:
        li      a0, 1
        li      a2, 1
        li      a7, 64
        ecall

        addi    t0, t0, -1
        bnez    t0, col_loop

        # newline
        li      a0, 1
        la      a1, nl_ch
        li      a2, 1
        li      a7, 64
        ecall

        addi    s0, s0, 8
        addi    t5, t5, -1
        bnez    t5, row_loop

        ld      s0, 0(sp)
        addi    sp, sp, 8
        ret

########################################################################
#  void invert_grid_inplace(void)
########################################################################
invert_grid_inplace:
        la      t0, grid
        li      t2, 64
1:
        lbu     t3, 0(t0)
        xori    t3, t3, 1
        sb      t3, 0(t0)
        addi    t0, t0, 1
        addi    t2, t2, -1
        bnez    t2, 1b
        ret

########################################################################
#  void busy_wait(uint32 loops)
########################################################################
busy_wait:
        mv      t0, a0
1:      addi    t0, t0, -1
        bnez    t0, 1b
        ret
