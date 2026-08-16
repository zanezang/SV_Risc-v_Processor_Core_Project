.section .text
.globl _start

_start:

    # ------------------------------------------------
    # JAL: jump forward and save return address
    # ------------------------------------------------

    jal x1, jal_target

    # Should NOT execute
    addi x10, x0, 99

jal_target:
    # x2 = 20
    addi x2, x0, 20


    # ------------------------------------------------
    # JALR: jump to address in register
    # ------------------------------------------------

    # x4 = address of jalr_target
    la x4, jalr_target

    # Jump to x4, save return address in x5
    jalr x5, 0(x4)

    # Should NOT execute
    addi x11, x0, 99

jalr_target:
    # x6 = 30
    addi x6, x0, 30


done:
    beq x0, x0, done