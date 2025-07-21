#######################################################################
# Conway's Game of Life — 8×8 glider (RV64I, no M extension needed)
# Prints intro once, saves cursor, then repeatedly restores cursor,
# prints grid, waits, computes next generation, and repeats.
#######################################################################

        .option norelax              # so `la` uses auipc/addi (no gp needed)

        .section .rodata
dot_ch:     .asciz "."
emp_ch:     .asciz " "
nl_ch:      .asciz "\n"
intro:      .asciz "Conway's Game of Life 8x8\n"
save_pos:   .asciz "\x1b[s"          # ESC[s save cursor position
rest_pos:   .asciz "\x1b[u"          # ESC[u restore cursor position

        .section .data
# Glider pattern
grid:   .byte 0,1,0,0,0,0,0,0
        .byte 1,1,1,0,1,0,0,0
        .byte 1,1,1,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0

# Next generation buffer (64 zeros)
next_grid:
        .rept 64
        .byte 0
        .endr

        .section .text
        .globl _start

.equ DELAY_CYCLES, 100000000          # adjust for your simulator

#######################################################################
# _start
#######################################################################
_start:
        # Print intro
        li      a0, 1
        la      a1, intro
        li      a2, 25
        li      a7, 64
        ecall

        # Print an extra blank line so the grid starts one line lower
        li      a0, 1
        la      a1, nl_ch
        li      a2, 1
        li      a7, 64
        ecall

        # Now save cursor at start of the *blank* line
        li      a0, 1
        la      a1, save_pos
        li      a2, 3
        li      a7, 64
        ecall

loop:
        # Restore cursor to grid start
        li      a0, 1
        la      a1, rest_pos
        li      a2, 3
        li      a7, 64
        ecall

        # Print current grid
        la      a1, grid
        call    print_grid

        # Delay
        li      a0, DELAY_CYCLES
        call    busy_wait

        # Compute next generation (also copies back)
        call    compute_next_generation
        j       loop

#######################################################################
# void print_grid(uint8_t* ptr)
#######################################################################
print_grid:
        addi    sp, sp, -8
        sd      s0, 0(sp)

        mv      s0, a1               # row base
        li      t5, 8                # rows
row_loop:
        mv      t2, s0
        li      t0, 8                # cols
col_loop:
        lbu     t3, 0(t2)
        addi    t2, t2, 1
        la      a1, emp_ch
        beqz    t3, emit
        la      a1, dot_ch
emit:   li      a0, 1
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

#######################################################################
# void compute_next_generation(void)
#######################################################################
compute_next_generation:
        addi    sp, sp, -32
        sd      s0, 0(sp)
        sd      s1, 8(sp)
        sd      s2, 16(sp)
        sd      s3, 24(sp)

        la      t6, grid
        la      t5, next_grid
        li      s0, 0                  # y
outer_y:
        li      s1, 0                  # x
outer_x:
        li      t0, 0                  # neighbour count
        li      s2, -1                 # dy
dy_loop:
        li      s3, -1                 # dx
dx_loop:
        or      t1, s2, s3
        beqz    t1, skip_nb            # skip self
        add     t1, s0, s2             # ny
        add     t2, s1, s3             # nx
        bltz    t1, skip_nb
        bltz    t2, skip_nb
        li      t3, 8
        bge     t1, t3, skip_nb
        bge     t2, t3, skip_nb
        slli    t1, t1, 3              # ny*8
        add     t1, t1, t2             # offset
        add     t1, t1, t6
        lbu     t1, 0(t1)
        add     t0, t0, t1
skip_nb:
        addi    s3, s3, 1
        li      t1, 2
        blt     s3, t1, dx_loop
        addi    s2, s2, 1
        blt     s2, t1, dy_loop

        # offset = y*8 + x
        slli    t2, s0, 3
        add     t2, t2, s1
        add     t3, t6, t2
        lbu     t3, 0(t3)              # current cell
        li      t4, 0                  # next=dead
        li      t1, 1
        bne     t3, t1, dead_check
        li      t1, 2
        beq     t0, t1, alive
        li      t1, 3
        beq     t0, t1, alive
        j       store
dead_check:
        li      t1, 3
        bne     t0, t1, store
alive:  li      t4, 1
store:  add     t2, t5, t2
        sb      t4, 0(t2)

        addi    s1, s1, 1
        li      t1, 8
        blt     s1, t1, outer_x

        addi    s0, s0, 1
        blt     s0, t1, outer_y

        # copy next_grid -> grid
        li      t0, 64
        la      t1, grid
        la      t2, next_grid
cpy_loop:
        lbu     t3, 0(t2)
        sb      t3, 0(t1)
        addi    t1, t1, 1
        addi    t2, t2, 1
        addi    t0, t0, -1
        bnez    t0, cpy_loop

        ld      s3, 24(sp)
        ld      s2, 16(sp)
        ld      s1, 8(sp)
        ld      s0, 0(sp)
        addi    sp, sp, 32
        ret

#######################################################################
# void busy_wait(uint64 loops)
#######################################################################
busy_wait:
        mv      t0, a0
1:      addi    t0, t0, -1
        bnez    t0, 1b
        ret
