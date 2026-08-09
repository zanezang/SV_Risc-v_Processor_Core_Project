module imm_gen (
    input  logic [31:0] inst,
    output logic [31:0] imm_ext
);

    logic [6:0] opcode;
    assign opcode = inst[6:0];

    always_comb begin
        case (opcode)
            // --- I-TYPE (addi, andi, lw, jalr, slti) ---
            7'b0010011, 7'b0000011, 7'b1100111: begin
                imm_ext = {{20{inst[31]}}, inst[31:20]};
            end

            // --- S-TYPE (sw) ---
            7'b0100011: begin
                imm_ext = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end

            // --- B-TYPE (beq, bne, blt, bge, bltu, bgeu) ---
            7'b1100011: begin
                imm_ext = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            end

            // --- U-TYPE (lui, auipc) ---
            7'b0110011, 7'b0010011: begin
                imm_ext = {inst[31:12], 12'b0};
            end

            // --- J-TYPE (jal) ---
            7'b1101111: begin
                imm_ext = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end

            default: imm_ext = 32'd0;
        endcase
    end

endmodule