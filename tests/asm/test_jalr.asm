.section .text
.globl _start

_start:

    # x1 = address of jalr_target (0x10)
    addi x1, x0, 16

    # Jump to address in x1
    # x5 gets the return address (PC + 4)
    jalr x5, 0(x1)

    # Should NOT execute
    addi x10, x0, 99

    # Should NOT execute
    addi x11, x0, 88

jalr_target:

    # Should execute
    addi x6, x0, 30

done:
    beq x0, x0, done