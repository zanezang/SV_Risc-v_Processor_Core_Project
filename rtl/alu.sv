module alu (
    input  logic [31:0] a,          // Operand A (from Register File rs1)
    input  logic [31:0] b,          // Operand B (from Register File rs2 or Immediate)
    input  logic [3:0]  alu_ctrl,   // 4-bit control menu from the Control Unit
    output logic [31:0] result,     // Calculated output
    output logic        zero        // High (1) if result is exactly 0
);

    // Clean compile fix: Extract the lower 5 bits of 'b' into an isolated wire
    // to stop the simulator from crying about constant-select processes.
    logic [4:0] shift_amt;
    assign shift_amt = b[4:0];

    // Combinational multiplexer logic block
    always_comb begin
        case (alu_ctrl)
            // --- ARITHMETIC ---
            4'b0010: result = a + b;                        // ADD (Used by add, addi, lw, sw)
            4'b0110: result = a - b;                        // SUB (Used by sub, beq)
            
            // --- LOGICALS ---
            4'b0000: result = a & b;                        // Bitwise AND (and, andi)
            4'b0001: result = a | b;                        // Bitwise OR (or, ori)
            4'b0011: result = a ^ b;                        // Bitwise XOR (xor, xori)
            
            // --- SHIFTS ---
            4'b0100: result = a << shift_amt;               // SLL (Shift Left Logical / sll, slli)
            4'b0101: result = a >> shift_amt;               // SRL (Shift Right Logical / srl, srli)
            
            // Note: We cast 'a' to signed here so the >>> operator replicates the sign bit (bit 31)
            // instead of filling vacated spots with zeros.
            4'b1101: result = $unsigned(signed'(a) >>> shift_amt); // SRA (Shift Right Arithmetic / sra, srai)

            // --- DEFAULT FALLBACK ---
            default: result = 32'h0000_0000;                // Prevents accidental latch synthesis
        endcase
    end

    // Continuous assignment for the branch evaluation flag
    assign zero = (result == 32'h0000_0000);

endmodule