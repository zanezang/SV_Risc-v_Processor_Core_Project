module riscv_core (
    input logic clk,
    input logic rst_n
);

    // ==========================================
    // 1. INTERNAL WIRE DECLARATIONS (The Copper)
    // ==========================================
    // Program Counter Wires
    logic [31:0] pc_current;
    logic [31:0] pc_next;
    logic [31:0] pc_plus4;
    logic [31:0] pc_target;

    // Instruction Bus
    logic [31:0] inst;

    // Control Unit Output Signals
    logic       reg_write;
    logic       alu_src;        // Fixed: Changed from 2-bit to 1-bit
    logic       mem_write;
    logic [1:0] reg_write_src;  // 00 = ALU, 01 = RAM, 10 = PC+4
    logic [1:0] pc_src;         // Fixed: Added missing pc_src routing bus
    logic       branch;
    logic [3:0] alu_ctrl;

    // Register File Wires
    logic [31:0] reg_data1;
    logic [31:0] reg_data2;
    logic [31:0] reg_write_data;

    // Immediate Generator Output
    logic [31:0] imm_ext;

    // ALU Wires
    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;
    logic        alu_zero;
    logic        alu_less;      // Added for BLT/BGE comparisons

    // Data Memory Wires
    logic [31:0] mem_read_data;

    // Branch Decision Logic
    logic        take_branch;


    // ==========================================
    // 2. MODULE INSTANTIATIONS (The Silicon Blocks)
    // ==========================================

    // --- Program Counter (PC) Register ---
    program_counter u_program_counter (
        .clk     (clk),
        .rst_n   (rst_n),
        .pc_next (pc_next),
        .pc_out  (pc_current)
    );


    // --- PC Target Calculations ---
    assign pc_plus4  = pc_current + 32'd4;
    assign pc_target = pc_current + imm_ext;


    // --- Instruction Memory ---
    instruction_mem u_instruction_mem (
        .pc_addr     (pc_current),
        .instruction (inst)
    );


    // --- Control Unit ---
    control_unit u_control_unit (
        .opcode        (inst[6:0]),
        .funct3        (inst[14:12]),
        .funct7_b5     (inst[30]),
        .reg_write     (reg_write),
        .alu_src       (alu_src),
        .mem_write     (mem_write),
        .reg_write_src (reg_write_src),
        .pc_src        (pc_src),        // Connected pc_src
        .branch        (branch),
        .alu_ctrl      (alu_ctrl)
    );


    // --- Register File ---
    register_file u_register_file (
        .clk        (clk),
        .rst_n      (rst_n),
        .reg_write  (reg_write),
        .raddr1     (inst[19:15]),      // rs1
        .raddr2     (inst[24:20]),      // rs2 
        .waddr      (inst[11:7]),       // rd
        .write_data (reg_write_data),   // Output of Writeback Mux
        .read_data1 (reg_data1),
        .read_data2 (reg_data2)
    );


    // --- Immediate Generator ---
    imm_gen u_imm_gen (
        .inst    (inst),
        .imm_ext (imm_ext)
    );


    // --- Arithmetic Logic Unit (ALU) ---
    alu u_alu (
        .a        (reg_data1),
        .b        (alu_operand_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (alu_zero),
        .less     (alu_less)
    );


    // --- Data Memory (RAM) ---
    data_mem u_data_mem (
        .clk        (clk),
        .mem_write  (mem_write),
        .addr       (alu_result),
        .write_data (reg_data2),
        .read_data  (mem_read_data)
    );


    // ==========================================
    // 3. DATAPATH STEERING SWITCHES (Multiplexers)
    // ==========================================

    // ALU Operand B Source Mux: 0 = Register Data 2, 1 = Sign-Extended Immediate
    assign alu_operand_b = alu_src ? imm_ext : reg_data2;

    // Branch Condition Decoder (Maps funct3 to ALU output flags)
    always_comb begin
        case (inst[14:12])
            3'b000:  take_branch = alu_zero;   // BEQ
            3'b001:  take_branch = !alu_zero;  // BNE
            3'b100:  take_branch = alu_less;   // BLT
            3'b101:  take_branch = !alu_less;  // BGE
            3'b110:  take_branch = alu_less;   // BLTU
            3'b111:  take_branch = !alu_less;  // BGEU
            default: take_branch = 1'b0;
        endcase
    end

    // Next PC Multiplexer
    always_comb begin
        case (pc_src)
            2'b00:   pc_next = pc_plus4;                                  // Normal PC + 4
            2'b01:   pc_next = take_branch ? pc_target : pc_plus4;        // Conditional Branch
            2'b10:   pc_next = pc_target;                                 // JAL Target
            2'b11:   pc_next = alu_result & 32'hFFFF_FFFE;                // JALR Target (rs1 + imm)
            default: pc_next = pc_plus4;
        endcase
    end

    // Register Writeback Multiplexer
    always_comb begin
        case (reg_write_src)
            2'b00:   reg_write_data = alu_result;     // ALU Math / Pass-through
            2'b01:   reg_write_data = mem_read_data;  // Load from Data Memory
            2'b10: reg_write_data = pc_plus4; // Save return address for JAL/JALR
            default: reg_write_data = alu_result;
        endcase
    end

endmodule