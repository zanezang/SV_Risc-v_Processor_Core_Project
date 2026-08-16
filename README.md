# 32-Bit Single-Cycle RISC-V (RV32I) Processor Core

A **32-bit single-cycle RISC-V processor core** designed in **SystemVerilog**, implementing the base **RV32I ISA**.

**Verified** through targeted instruction-level tests and an integrated Selection Sort test written in RISC-V Assembly.

The project includes a modular datapath, parameterized instruction memory, **automated RISC-V assembly-to-HEX generation**, and a **Makefile-driven simulation and verification** workflow.


## Architecture

```text
                    ┌──────────────────┐
                    │ Program Counter  │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Instruction Mem  │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │    Controller    │
                    └────────┬─────────┘
                             │
             ┌───────────────┼───────────────┐
             ▼               ▼               ▼
      ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
      │ Register    │ │ Immediate   │ │ Branch /    │
      │ File        │ │ Generator   │ │ Jump Logic  │
      └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
             └───────────────┼───────────────┘
                             ▼
                       ┌───────────┐
                       │    ALU    │
                       └─────┬─────┘
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
             ┌─────────────┐   ┌─────────────┐
             │ Data Memory │-->│  Writeback  │
             └─────────────┘   └─────────────┘
```

## Supported RV32I Instructions

| Type | Instructions                                           |
| ---- | ------------------------------------------------------ |
| R    | `ADD SUB AND OR XOR SLL SRL SRA SLT SLTU`              |
| I    | `ADDI ANDI ORI XORI SLLI SRLI SRAI SLTI SLTIU LW JALR` |
| S    | `SW`                                                   |
| B    | `BEQ BNE BLT BGE BLTU BGEU`                            |
| U    | `LUI AUIPC`                                            |
| J    | `JAL`                                                  |

## Verification

The core is verified using both **targeted instruction-level tests** and an **integration test**.

| Test              | Coverage                   |
| ----------------- | -------------------------- |
| `test_alu`        | ALU operations             |
| `test_imm`        | Immediate operations       |
| `test_data_mem`   | Load/store and data memory |
| `test_branch`     | Conditional branches       |
| `test_jal`        | `JAL`                      |
| `test_jalr`       | `JALR`                     |
| `test_riscv_core` | Full processor integration |

### Full Processor Integration Test 

A custom RISC-V assembly program performs an in-place Selection Sort using the processor's datapath, register file, ALU, branches, and data memory.

```text
Input:    [7, -3, 24, 3, 20, -1]
Expected: [-3, -1, 3, 7, 20, 24]
```

The SystemVerilog testbench verifies the final contents of data memory.

```text
[ STATUS ]: *** PASSED *** Array successfully sorted in-place!
```

> The instruction set above describes the implemented RV32I functionality. Not every implemented instruction currently has an individual dedicated test; some are also exercised through the integration program.

## Automated Test Flow

Assembly tests are automatically converted into machine-code HEX files:

```text
.asm → .o → .elf → .bin → .hex → simulation
```

For example:

```bash
make test_jalr
```

automatically builds and runs:

```text
tests/asm/test_jalr.asm
        ↓
tests/bin/test_jalr.*
        ↓
tests/hex/test_jalr.hex
        ↓
tb/tb_jalr.sv
```

## Repository Structure

```text
.
├── Makefile                    # Build, assembly conversion, and simulation automation
├── README.md                   # Project documentation
├── docs/
│   └── waveform.png            # Example simulation waveform
├── rtl/                        # Synthesizable SystemVerilog RTL
│   ├── alu.sv
│   ├── control_unit.sv
│   ├── data_mem.sv
│   ├── imm_gen.sv
│   ├── instru_mem.sv
│   ├── pc.sv
│   ├── register_file.sv
│   └── riscv_core.sv           # Top-level CPU module
├── tb/                         # SystemVerilog verification testbenches
│   ├── tb_alu.sv
│   ├── tb_branch.sv
│   ├── tb_data_mem.sv
│   ├── tb_imm.sv
│   ├── tb_jal.sv
│   ├── tb_jalr.sv
│   └── tb_riscv_core.sv        # End-to-end Selection Sort test
└── tests/
    ├── asm/                    # RISC-V assembly test programs
    ├── bin/                    # Generated object, ELF, and binary files
    ├── hex/                    # Generated machine-code HEX files
    └── tools/                  # Test/build utilities
        └── bin_to_hex.py       # Converts binary machine code to HEX
```

## Tools

* **SystemVerilog** — RTL and verification
* **Icarus Verilog** — simulation
* **RISC-V GNU Toolchain** — assembly and binary generation
* **Python** — binary-to-HEX conversion
* **Surfer** — waveform viewing
* **Make** — build and test automation

## Running

### Run the default Selection Sort test

```bash
make
```

### Compile only

```bash
make compile
```

### Compile and run

```bash
make run
```

### Run an individual test

```bash
make test_alu
make test_imm
make test_data_mem
make test_branch
make test_jal
make test_jalr
```

### Open waveforms

```bash
make waves
```

### Clean generated files

```bash
make clean
```
