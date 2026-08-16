.section .text
.globl _start

_start:

    # ------------------------------------------------
    # BEQ: taken
    # ------------------------------------------------
    addi x1, x0, 5
    addi x2, x0, 5

    beq x1, x2, beq_taken

    # Should NOT execute
    addi x10, x0, 99

beq_taken:
    addi x3, x0, 10


    # ------------------------------------------------
    # BNE: taken
    # ------------------------------------------------
    addi x4, x0, 5
    addi x5, x0, 6

    bne x4, x5, bne_taken

    # Should NOT execute
    addi x11, x0, 99

bne_taken:
    addi x6, x0, 20


    # ------------------------------------------------
    # BLT: taken
    # ------------------------------------------------
    addi x7, x0, 3
    addi x8, x0, 5

    blt x7, x8, blt_taken

    # Should NOT execute
    addi x12, x0, 99

blt_taken:
    addi x9, x0, 30


    # ------------------------------------------------
    # BGE: taken
    # ------------------------------------------------
    addi x13, x0, 5
    addi x14, x0, 5

    bge x13, x14, bge_taken

    # Should NOT execute
    addi x15, x0, 99

bge_taken:
    addi x16, x0, 40


done:
    beq x0, x0, done