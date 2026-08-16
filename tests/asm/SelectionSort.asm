# ==============================================================================
# PROGRAM: Selection Sort
# TARGET CORE: RV32I Processor Core
#
# HARDWARE EXPECTATIONS / PRELOADED DATA MEMORY (data_mem.sv):
# This program expects the array data to be preloaded into Data RAM before
# execution starts (e.g., inside an initial block in data_mem.sv):
#
# ------------------------------------------------------------------------------
# Byte Addr | RAM Word Index | Initial Value | Description
# ------------------------------------------------------------------------------
#  0x00     | RAM[0]         |  6            | Array Length N = 6
#  0x04     | RAM[1]         |  24           | Array[0] (Base Pointer Start)
#  0x08     | RAM[2]         | -1            | Array[1]
#  0x0C     | RAM[3]         | -3            | Array[2]
#  0x10     | RAM[4]         |  3            | Array[3]
#  0x14     | RAM[5]         |  7            | Array[4]
#  0x18     | RAM[6]         |  20           | Array[5] (End Pointer Target)
# ------------------------------------------------------------------------------
#
# REGISTER ALLOCATION:
# a0 = ArraySize 
# a1 = Array[]
# s0 = i (outer loop counter)
# s1 = innerAndOuter stop 
# s3 = min
# s4 = minIdx
# t0 = j (inner loop counter)
# t4 = curr/temp 
#
# EXPECTED TESTBENCH RESULT:
# Array sorted in-place in RAM[1..6] -> [-3, -1, 3, 7, 20, 24]
# ==============================================================================

.text
.globl _start
_start:

# init
addi a0, zero, 6 # a0 = ArraySize = 6
addi a1, zero, 4 # a0 = arr
add s0, a1, zero # i = arr

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