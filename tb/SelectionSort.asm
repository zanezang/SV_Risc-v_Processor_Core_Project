.data
ArraySize: .word 6
Array: .word 24, -1, -3, 3, 7, 20

.text
.globl _start
_start:

# a0 = ArraySize 
# a1 = Array[]
# s0 = i (outer loop counter)
# s1 = innerAndOuter stop 
# s3 = min
# s4 = minIdx
# t0 = j (inner loop counter)
# t4 = curr/temp 

# init
la t0, ArraySize
lw a0, 0(t0)
la a1, Array
add s0, a1, zero # i = Array[]

addi t4, a0, -1
slli t4, t4, 2
add s1, s0, t4 # outer stop = i + 4 * (size - 1) (Last Item)

OutLoopStart:
lw s3, 0(s1) # min = arr[lastIdx]
add s4, s1, zero # minIdx - lastIdx
add t0, s0, zero # i = j

InnerLoopStart: 
lw t4, 0(t0) # temp = arr[i]
bge t4, s3, NotNewMin # skip if arr[i] >= min

add s3, t4, zero # min = arr[i]
add s4, t0, zero # minIdx = i 
NotNewMin:

addi t0, t0, 4 # i++ (incre before)
blt t0, s1, InnerLoopStart # loop if i < s1

# swap
lw t4, 0(s0) # temp = arr[i]
sw s3, 0(s0) # arr[i] = min
sw t4, 0(s4) # arr[minIdx] = temp

addi s0, s0, 4
blt s0, s1, OutLoopStart 

Done: 
j Done