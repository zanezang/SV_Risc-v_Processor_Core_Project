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

    // Instruction Bus
    logic [31:0] inst;

    // Control Unit Output Signals
    logic       reg_write;
    logic       alu_src;
    logic       mem_write;
    logic       mem_to_reg;
    logic       branch;
    logic [3:0] alu_ctrl;

    // Register File Wires
    logic [31:0] reg_data1;
    logic [31:0] reg_data2;
    logic [31:0] reg_write_data;

    // Immediate Generator Output
    logic [31:0] imm_ext;

    // ALU Wires
    logic [31:0] alu_operand_b; // Output of the Hour 3 Mux
    logic [31:0] alu_result;
    logic        alu_zero;

    // Data Memory Wires
    logic [31:0] mem_read_data;


    // ==========================================
    // 2. MODULE INSTANTIATIONS (The Silicon Blocks)
    // ==========================================

    // --- Placeholder: Program Counter (PC) Register ---
    program_counter u_program_counter (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc_out(pc_current)
    );
    // It should update 'pc_current <= pc_next' on clk edge when rst_n is high.


    // --- PC Adder ---
    assign pc_plus4 = pc_current + 32'd4;


    // --- Placeholder: Instruction Memory ---
    instruction_mem u_instruction_mem (
        .pc_addr(pc_current),
        .instruction(inst)
    );
    // Input: pc_current, Output: inst


    // --- Control Unit ---
    control_unit u_control_unit (
        .opcode     (inst[6:0]),
        .funct3     (inst[14:12]),
        .funct7_b5  (inst[30]),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .alu_ctrl   (alu_ctrl)
    );


    // --- Register File ---
    // Assuming a standard port layout: clk, reg_write, rs1, rs2, rd, write_data, read_data1, read_data2
    register_file u_register_file (
        .clk        (clk),
        .rst_n      (rst_n),
        .reg_write  (reg_write),
        .raddr1     (inst[19:15]),      // rs1
        .raddr2     (inst[24:20]),      // rs2 
        .waddr      (inst[11:7]),       // rd
        .write_data      (reg_write_data),   // Comes from the Writeback Mux
        .read_data1     (reg_data1),
        .read_data2     (reg_data2)
    );


    // --- Immediate Generator ---
    imm_gen u_imm_gen (
        .inst       (inst),
        .imm_ext    (imm_ext)
    );


    // --- Arithmetic Logic Unit (ALU) ---
    alu u_alu (
        .a          (reg_data1),
        .b          (alu_operand_b),    // Fed by the ALU source multiplexer
        .alu_ctrl   (alu_ctrl),
        .result     (alu_result),
        .zero       (alu_zero)
    );


    // --- Placeholder: Data Memory (RAM) ---
    // TODO: Connect your Data Memory block here later
    // Inputs: clk, alu_result (addr), reg_data2 (write data), mem_write (we)
    // Output: mem_read_data

    // ==========================================
    // 3. DATAPATH STEERING SWITCHES (Multiplexers)
    // ==========================================
    
    // Next PC Mux: If (Branch Instruction AND ALU says inputs equal), jump! Otherwise PC + 4
    assign pc_next = (branch & alu_zero) ? (pc_current + imm_ext) : pc_plus4; //??? eq check with logical unit and not subtract normally?

    // ALU Input Source Mux: 0 = Use Register Data 2, 1 = Use Sign-Extended Immediate
    assign alu_operand_b = alu_src ? reg_data2 : imm_ext;

    // Register Writeback Mux: 0 = Save ALU Math, 1 = Save Data Memory Read
    assign reg_write_data = mem_to_reg ? mem_read_data : alu_result;

    // Temporary Data Memory Tie-off (Keeps compiler happy until you build RAM)
    assign mem_read_data = 32'h0000_0000;


endmodule