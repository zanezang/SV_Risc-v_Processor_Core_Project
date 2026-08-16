.section .text
.globl _start

_start:

    # ADDI
    addi x1, x0, 10
    addi x2, x0, 3
    addi x3, x1, -2

    # ANDI
    andi x4, x1, 7

    # ORI
    ori x5, x0, 8

    # XORI
    xori x6, x5, 3

    # SLTI
    slti x7, x2, 5

done:
    beq x0, x0, done