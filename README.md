# 32-Bit Single-Cycle RISC-V (RV32I) Processor Core

A synthesizable, single-cycle 32-bit RISC-V CPU core designed in **SystemVerilog** implementing the base **RV32I Instruction Set Architecture (ISA)**. 

The core has been verified in **Icarus Verilog** by running a custom, in-place **Selection Sort assembly program** that executes across 200+ clock cycles in simulation.

---

## 🏛️ Architecture Overview
The core follows a classic single-cycle datapath architecture where every instruction fetches, decodes, executes, accesses memory, and writes back within a single clock cycle ($20\text{ ns}$ at $50\text{ MHz}$).

```text
[ Program Counter ] ---> [ Instruction Mem ] ---> [ Control / ALU Decoder ]
         |                                                 |
         v                                                 v
[ Register File (32x32) ] ---> [ Immediate Gen ] ---> [ ALU Engine ]
         |                                                 |
         +-------------------------------------------------+ ---> [ Data RAM ]

```

### Key Hardware Features

* **Data Path:** 32-bit internal buses formatted in Little-Endian.
* **Register File:** 32 general-purpose 32-bit registers (`x0` hardwired to `0`).
* **ALU Engine:** Supports arithmetic (`ADD`, `SUB`), logical (`AND`, `OR`, `XOR`), bitwise shifts (`SLL`, `SRL`, `SRA`), and signed/unsigned comparison (`SLT`, `SLTU`).
* **Control Logic:** Decodes opcodes, `funct3`, and `funct7` bits to steer register writebacks, immediate selection, and branch/jump routing.
* **Immediate Generator:** Extends sign bits across I-Type, S-Type, B-Type, U-Type, and J-Type formats.
* **Memory Subsystem:** Word-aligned instruction and data memory units (`pc[31:2]` index conversion).

---

## ⚙️ Supported Instruction Set

* **R-Type:** `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu`
* **I-Type:** `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu`, `lw`, `jalr`
* **S-Type:** `sw`
* **B-Type:** `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
* **U-Type:** `lui`, `auipc`
* **J-Type:** `jal`

---

## 📂 Repository Structure

```text
riscv-rv32i-core/
├── asm/                        # Assembly Programs
│   └── SelectionSort.asm
├── hex/                        # Machine Code (Loaded via $readmemh)
│   └── SelectionSort.hex
├── rtl/                        # Synthesizable SystemVerilog RTL Modules
│   ├── alu.sv
│   ├── control_unit.sv
│   ├── data_mem.sv
│   ├── imm_gen.sv
│   ├── instruction_mem.sv
│   ├── program_counter.sv
│   ├── register_file.sv
│   └── riscv_core.sv
├── tb/                         # Verification Testbenches
│   └── tb_riscv_core.sv
├── docs/                       # Diagrams and Waveform Screenshots
│   └── waveform.png
├── .gitignore                  # Filters binaries (*.vcd, cpu_sim)
├── Makefile                    # Build & Simulation Automation
└── README.md                   # Project Documentation

```

---

## 🧪 Verification: In-Place Selection Sort

The core is verified using an automated SystemVerilog testbench (`tb_riscv_core.sv`) running an in-place **Selection Sort assembly program** (`asm/SelectionSort.asm`). The program reads an unsorted array from Data Memory, sorts the elements in-place, and outputs the result upon completion.

### Simulation Terminal Output

```text
==========================================================================
          STARTING RISC-V CORE SELECTION SORT VERIFICATION                
==========================================================================
[25 ns] Reset released. Core executing program from PC = 0x00000000...
==========================================================================
                       SIMULATION COMPLETE                                
==========================================================================
 Memory Address | Array Index | Data Value | Expected Value 
 ---------------|-------------|------------|----------------
   0x04 (RAM[1]) |   Array[0]  | -3         | -3
   0x08 (RAM[2]) |   Array[1]  | -1         | -1
   0x0C (RAM[3]) |   Array[2]  | 3          | 3
   0x10 (RAM[4]) |   Array[3]  | 7          | 7
   0x14 (RAM[5]) |   Array[4]  | 20         | 20
   0x18 (RAM[6]) |   Array[5]  | 24         | 24
--------------------------------------------------------------------------
 [ STATUS ]: *** PASSED *** Array successfully sorted in-place!
==========================================================================

```

---

## 🚀 How to Run the Simulation

### Prerequisites

* **Icarus Verilog (`iverilog`)**: HDL Compiler & Simulator Engine
* **Surfer**: Waveform Trace Viewer

### Simulation Commands

```bash
# 1. Compile RTL + Testbench and run simulation
make

# 2. Open Surfer to inspect signal traces (.vcd)
make waves

# 3. Clean generated binaries and trace logs
make clean

```

```