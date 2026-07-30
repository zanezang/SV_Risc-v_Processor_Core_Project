module control_unit (
    input  logic [6:0] opcode,      // instruction[6:0]
    input  logic [2:0] funct3,      // instruction[14:12]
    input  logic       funct7_b5,   // instruction[30] (Differentiates ADD/SUB, SRL/SRA)
    
    // Control Routing Signals
    output logic       reg_write,   // 1 = Write to Register File
    output logic       alu_src,     // 0 = Use Reg Data 2; 1 = Use Immediate
    output logic       mem_write,   // 1 = Write to Data Memory (sw)
    output logic [1:0]     reg_write_src,  // 00 = ALU Output; 01 = Memory; 10 = PC+4 (jal)
    output logic [1:0]      pc_src,      // 00 = pc+4; 01 = branch; 10 = jal; 11 = jalr (alu)
    
    // ALU Specific Output
    output logic [3:0] alu_ctrl     // 4-bit code sent directly to your ALU
);

    // Internal tracking wire to pass info from Main Decoder to ALU Decoder
    logic [1:0] alu_op;

    // ==========================================
    // 1. MAIN DECODER BLOCK
    // ==========================================
    always_comb begin
        // Set defaults to prevent dangerous hardware latches
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        reg_write_src = 2'b00;
        pc_src     = 2'b00;
        alu_op     = 2'b00;

        case (opcode)
            // --- R-TYPE Instructions (add, sub, xor, etc.) ---
            7'b0110011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b0; // Use register data 2
                mem_write  = 1'b0;
                reg_write_src = 2'b00; // Take result from ALU
                pc_src     = 2'b00;
                alu_op     = 2'b10; // "Look at funct3/funct7 to decide math"
            end

            // --- I-TYPE Load Instructions (lw) ---
            7'b0000011: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                mem_write = 1'b0;
                reg_write_src = 2'b01;
                pc_src = 2'b00;
                alu_op = 2'b00;
                // Think: Does a load write to registers? Does it use an immediate?
            end

            // --- I-TYPE Immediate Math Instructions (addi, andi, ori, xori) ---
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                mem_write = 1'b0;
                reg_write_src = 2'b00;
                pc_src = 2'b00;
                alu_op = 2'b00;
            end

            // --- S-TYPE Store Instructions (sw) ---
            7'b0100011: begin
                reg_write = 1'b0;
                alu_src = 1'b1;
                mem_write = 1'b1;
                reg_write_src = 2'b01;
                pc_src = 2'b00;
                alu_op = 2'b00;
                // Think: Does a store write to registers? Does it write to memory?
            end

            // --- B-TYPE pc_src Instructions (beq) ---
            7'b1100011: begin
                reg_write = 1'b0;
                alu_src = 1'b0;
                mem_write = 1'b0;
                reg_write_src = 2'b00; // don't care
                pc_src = 2'b01; //branch
                // Think: Does it perform a subtraction to check for equality?
                alu_op     = 2'b01; // "Force a subtraction"
            end

            // --- JAL (Jump and Link) Unconditional Jump ---
            7'b1101111: begin
                reg_write     = 1'b1;   // YES: Save return address to rd (usually x1/ra)
                alu_src       = 1'b0;   // Don't care
                mem_write     = 1'b0;   // NO RAM interactions
                reg_write_src = 2'b10;  // CRITICAL: Direct writeback multiplexer to select PC + 4
                pc_src        = 2'b10;  // CRITICAL: Force PC to select the JAL target address calculation
                alu_op        = 2'b00;
            end

            // --- JALR (Jump and Link Register) Dynamic Jump ---
            7'b1100111: begin
                reg_write     = 1'b1;   // YES: Save return address to rd
                alu_src       = 1'b1;   // YES: Use immediate value to offset base address
                mem_write     = 1'b0;   // NO RAM interactions
                reg_write_src = 2'b10;  // CRITICAL: Select PC + 4 for destination register
                pc_src        = 2'b11;  // CRITICAL: Force PC to select the calculated Register offset address
                alu_op        = 2'b00;  // Force ALU to perform addition (rs1 + immediate)
            end

            default: begin
                // Keep defaults if opcode is unknown
            end
        endcase
    end


    // ==========================================
    // 2. ALU DECODER BLOCK
    // ==========================================
    always_comb begin
        // Default to a safe fallback operation (e.g., ADD)
        alu_ctrl = 4'b0010; 

        case (alu_op)
            2'b00: alu_ctrl = 4'b0010; // Force ADD (Used for address calculations in lw/sw)
            
            2'b01: alu_ctrl = 4'b0110; // Force SUB (Used for pc_srces like beq)
            
            2'b10: begin // R-Type Instructions: Must closely inspect funct3 and funct7
                case (funct3)
                    3'b000: begin
                        if (funct7_b5) 
                            alu_ctrl = 4'b0110; // SUB
                        else           
                            alu_ctrl = 4'b0010; // ADD
                    end
                    
                    3'b100: alu_ctrl = 4'b0011; // XOR
                    3'b110: alu_ctrl = 4'b0001; // OR
                    3'b111: alu_ctrl = 4'b0000; // AND
                    
                    // --- SHIFTS ---
                    3'b001: alu_ctrl = 4'b0100; // SLL (Shift Left Logical)
                    3'b101: begin
                        if (funct7_b5)
                            alu_ctrl = 4'b1101; // SRA (Shift Right Arithmetic)
                        else
                            alu_ctrl = 4'b0101; // SRL (Shift Right Logical)
                    end
                    
                    default: alu_ctrl = 4'b0010;
                endcase
            end
            
            default: alu_ctrl = 4'b0010;
        endcase
    end

endmodule