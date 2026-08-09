module alu (
    input  logic [31:0] a,          // Operand A (from Register File rs1)
    input  logic [31:0] b,          // Operand B (from Register File rs2 or Immediate)
    input  logic [3:0]  alu_ctrl,   // 4-bit control code from Control Unit
    output logic [31:0] result,     // Calculated output
    output logic        zero,       // High (1) if result is exactly 0
    output logic        less        // High (1) if Operand A < Operand B
);

    // Isolated lower 5 bits of 'b' for shift operations
    logic [4:0] shift_amt;
    assign shift_amt = b[4:0];

    // Combinational multiplexer logic block
    always_comb begin
        case (alu_ctrl)
            // --- ARITHMETIC ---
            4'b0010: result = a + b;                                // ADD (add, addi, lw, sw, auipc, jalr)
            4'b0110: result = a - b;                                // SUB (sub, beq, bne)
            
            // --- LOGICALS ---
            4'b0000: result = a & b;                                // Bitwise AND (and, andi)
            4'b0001: result = a | b;                                // Bitwise OR (or, ori)
            4'b0011: result = a ^ b;                                // Bitwise XOR (xor, xori)
            
            // --- SHIFTS ---
            4'b0100: result = a << shift_amt;                       // SLL (Shift Left Logical / sll, slli)
            4'b0101: result = a >> shift_amt;                       // SRL (Shift Right Logical / srl, srli)
            4'b1101: result = $unsigned($signed(a) >>> shift_amt);  // SRA (Shift Right Arithmetic / sra, srai)

            // --- COMPARISONS (SET LESS THAN) ---
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT / SLTI / Signed Compare
            4'b1000: result = (a < b)                   ? 32'd1 : 32'd0; // SLTU / SLTIU / Unsigned Compare

            // --- DEFAULT FALLBACK ---
            default: result = 32'h0000_0000;                        // Prevents accidental latch synthesis
        endcase
    end

    // Continuous assignment for branch evaluation flags
    assign zero = (result == 32'h0000_0000);

    // Driven flag for BLT/BGE/BLTU/BGEU conditional branches
    assign less = (alu_ctrl == 4'b0111) ? ($signed(a) < $signed(b)) :
                  (alu_ctrl == 4'b1000) ? (a < b) : 1'b0;

endmodule