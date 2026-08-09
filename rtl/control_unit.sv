module control_unit (
    input  logic [6:0] opcode,      // instruction[6:0]
    input  logic [2:0] funct3,      // instruction[14:12]
    input  logic       funct7_b5,   // instruction[30] (Differentiates ADD/SUB, SRL/SRA)
    
    // Control Routing Signals
    output logic       reg_write,   // 1 = Write to Register File
    output logic       alu_src,     // 0 = Use Reg Data 2; 1 = Use Immediate
    output logic       mem_write,   // 1 = Write to Data Memory (sw)
    output logic [1:0] reg_write_src,  // 00: ALU, 01: RAM, 10: PC + 4
    output logic [1:0] pc_src,         // 00: PC + 4, 01: Branch Mux, 10: JAL Mux, 11: JALR Mux
    output logic       branch,      // 1 = Branch instruction active
    
    // ALU Specific Output
    output logic [3:0] alu_ctrl     // 4-bit code sent directly to your ALU
);

    // Internal tracking wire:
    // 2'b00 = Force ADD
    // 2'b01 = Branch Decode
    // 2'b10 = R-Type Math Decode
    // 2'b11 = I-Type Math Decode
    logic [1:0] alu_op;

    // ==========================================
    // 1. MAIN DECODER BLOCK
    // ==========================================
    always_comb begin
        // Set safe defaults to prevent latches
        reg_write     = 1'b0;
        alu_src       = 1'b0;
        mem_write     = 1'b0;
        reg_write_src = 2'b00;
        branch        = 1'b0;
        pc_src        = 2'b00;
        alu_op        = 2'b00;

        case (opcode)
            // --- R-TYPE Instructions (add, sub, and, or, xor, sll, srl, sra, slt, sltu) ---
            7'b0110011: begin
                reg_write     = 1'b1;
                alu_src       = 1'b0; // Register Data 2
                mem_write     = 1'b0;
                reg_write_src = 2'b00; // Result from ALU
                branch        = 1'b0;
                pc_src        = 2'b00;
                alu_op        = 2'b10; // R-type decode via funct3/funct7
            end

            // --- I-TYPE Math Instructions (addi, andi, ori, xori, slli, srli, srai, slti, sltiu) ---
            7'b0010011: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1; // Use Immediate
                mem_write     = 1'b0;
                reg_write_src = 2'b00; // Result from ALU
                branch        = 1'b0;
                pc_src        = 2'b00;
                alu_op        = 2'b11; // I-type decode via funct3/funct7
            end

            // --- I-TYPE Load Instructions (lw) ---
            7'b0000011: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1; // Immediate offset
                mem_write     = 1'b0;
                reg_write_src = 2'b01; // Data Memory output
                branch        = 1'b0;
                pc_src        = 2'b00;
                alu_op        = 2'b00; // Force ADD for base address calculation
            end

            // --- S-TYPE Store Instructions (sw) ---
            7'b0100011: begin
                reg_write     = 1'b0;
                alu_src       = 1'b1; // Immediate offset
                mem_write     = 1'b1; // Write to RAM
                reg_write_src = 2'b00;
                branch        = 1'b0;
                pc_src        = 2'b00;
                alu_op        = 2'b00; // Force ADD for base address calculation
            end

            // --- B-TYPE Branch Instructions (beq, bne, blt, bge, bltu, bgeu) ---
            7'b1100011: begin
                reg_write     = 1'b0;
                alu_src       = 1'b0; // Reg Data 2
                mem_write     = 1'b0;
                reg_write_src = 2'b00;
                branch        = 1'b1; // Assert branch flag
                pc_src        = 2'b01; // Select Branch Mux target
                alu_op        = 2'b01; // Branch decode
            end

            // --- JAL (Jump and Link) ---
            7'b1101111: begin
                reg_write     = 1'b1;
                alu_src       = 1'b0;
                mem_write     = 1'b0;
                reg_write_src = 2'b10; // Write PC+4 to rd
                branch        = 1'b0;
                pc_src        = 2'b10; // Select JAL target
                alu_op        = 2'b00;
            end

            // --- JALR (Jump and Link Register) ---
            7'b1100111: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1; // Immediate offset
                mem_write     = 1'b0;
                reg_write_src = 2'b10; // Write PC+4 to rd
                branch        = 1'b0;
                pc_src        = 2'b11; // Select JALR target (ALU result)
                alu_op        = 2'b00; // Force ADD (rs1 + imm)
            end

            // --- LUI (Load Upper Immediate) ---
            7'b0110111: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1;
                mem_write     = 1'b0;
                reg_write_src = 2'b00;
                branch        = 1'b0;
                pc_src        = 2'b00;
                alu_op        = 2'b10; // Pass immediate through ALU
            end

            // --- AUIPC (Add Upper Immediate to PC) ---
            7'b0010111: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1;
                mem_write     = 1'b0;
                reg_write_src = 2'b00;
                branch        = 1'b0;
                pc_src        = 2'b00;
                alu_op        = 2'b00; // ADD immediate to PC
            end

            default: ;
        endcase
    end


    // ==========================================
    // 2. ALU DECODER BLOCK
    // ==========================================
    always_comb begin
        alu_ctrl = 4'b0010; // Default fallback to ADD

        case (alu_op)
            2'b00: alu_ctrl = 4'b0010; // Force ADD (lw, sw, auipc, jalr)

            2'b01: begin // Branch Decodes
                case (funct3)
                    3'b000, 3'b001: alu_ctrl = 4'b0110; // BEQ / BNE (SUB)
                    3'b100, 3'b101: alu_ctrl = 4'b0111; // BLT / BGE (Signed Compare)
                    3'b110, 3'b111: alu_ctrl = 4'b1000; // BLTU / BGEU (Unsigned Compare)
                    default:        alu_ctrl = 4'b0110;
                endcase
            end

            2'b10, 2'b11: begin // R-Type (2'b10) and I-Type (2 me_op = 2'b11) Math Decodes
                case (funct3)
                    3'b000: begin
                        // R-Type SUB uses funct7_b5; I-Type ADDI always performs ADD
                        if (alu_op == 2'b10 && funct7_b5) 
                            alu_ctrl = 4'b0110; // SUB
                        else           
                            alu_ctrl = 4'b0010; // ADD
                    end
                    
                    3'b001: alu_ctrl = 4'b0100; // SLL / SLLI (Shift Left Logical)
                    3'b010: alu_ctrl = 4'b0111; // SLT / SLTI (Set Less Than Signed)
                    3'b011: alu_ctrl = 4'b1000; // SLTU / SLTIU (Set Less Than Unsigned)
                    3'b100: alu_ctrl = 4'b0011; // XOR / XORI
                    
                    3'b101: begin
                        if (funct7_b5)
                            alu_ctrl = 4'b1101; // SRA / SRAI (Shift Right Arithmetic)
                        else
                            alu_ctrl = 4'b0101; // SRL / SRLI (Shift Right Logical)
                    end
                    
                    3'b110: alu_ctrl = 4'b0001; // OR / ORI
                    3'b111: alu_ctrl = 4'b0000; // AND / ANDI
                    
                    default: alu_ctrl = 4'b0010;
                endcase
            end

            default: alu_ctrl = 4'b0010;
        endcase
    end

endmodule