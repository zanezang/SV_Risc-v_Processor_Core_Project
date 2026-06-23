module imm_gen (
    input  logic [31:0] inst,       // Raw 32-bit instruction from memory
    output logic [31:0] imm_ext     // 32-bit sign-extended constant output
);

    always_comb begin
        case (inst[6:0]) // Read the 7-bit opcode to see how the bits are arranged
            
            // --- I-TYPE (addi, lw) ---
            // Immediates are cleanly packed in bits [31:20]
            7'b0010011, // addi
            7'b0000011: begin // lw
                imm_ext = { {20{inst[31]}}, inst[31:20] };
            end

            // --- S-TYPE (sw) ---
            // Immediates are split into [31:25] and [11:7]
            7'b0100011: begin
                imm_ext = { {20{inst[31]}}, inst[31:25], inst[11:7] };
            end

            // --- B-TYPE (beq) ---
            // Scrambled layout: inst[31]=sign, inst[7]=bit 11, inst[30:25]=bits 10:5, inst[11:8]=bits 4:1
            // Note: Conditional branches always jump by multiples of 2, so bit 0 is implicitly 1'b0!
            7'b1100011: begin
                imm_ext = { {19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 };
            end

            // --- DEFAULT FALLBACK ---
            default: begin
                imm_ext = 32'h0000_0000; // Safe zero fallback to prevent latches
            end
        endcase
    end

endmodule