.section .text
.globl _start

_start:

    # x1 = 42
    addi x1, x0, 42

    # x2 = 100 (byte address)
    addi x2, x0, 100

    # Store 42 at address 100
    sw x1, 0(x2)

    # Store 42 at address 104
    sw x1, 4(x2)

    # Load both values back
    lw x3, 0(x2)
    lw x4, 4(x2)

done:
    beq x0, x0, done