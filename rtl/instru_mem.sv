module instruction_mem (
    input  logic [31:0] pc_addr,
    output logic [31:0] instruction
);

    // Create an unpacked array to act as storage slots (e.g., 64 words deep)
    logic [31:0] mem_array [0:63];

    // Read the compiled machine code text file automatically at simulation startup
    initial begin
        $readmemh("program.hex", mem_array);
    end

    // Word-addressing alignment layout: 
    // Because the PC increments by 4 bytes per instruction, we drop the bottom 
    // two bits (shift right by 2) to align the address with our array indexes.
    assign instruction = mem_array[pc_addr[31:2]];

endmodule





/*
module instruction_mem (
  input  logic [31:0] pc_addr,     // 32-bit read pointer address from the PC register
  output logic [31:0] instruction  // 32-bit machine code payload sent to the processor
);

  // An unpacked array of 8 memory rows, each 32-bits wide
  logic [31:0] rom [0:7];

  // Hardcode a tiny dummy program into memory at boot time
  initial begin
    rom[0] = 32'h0123_4567; // Instruction 0 (at byte address 0)
    rom[1] = 32'h89AB_CDEF; // Instruction 1 (at byte address 4)
    rom[2] = 32'hAAAA_BBBB; // Instruction 2 (at byte address 8)
    rom[3] = 32'hCCCC_DDDD; // Instruction 3 (at byte address 12)
    rom[4] = 32'h1111_2222; // Instruction 4 (at byte address 16)
    rom[5] = 32'h3333_4444; // Instruction 5 (at byte address 20)
    rom[6] = 32'h5555_6666; // Instruction 6 (at byte address 24)
    rom[7] = 32'h7777_8888; // Instruction 7 (at byte address 28)
  end

  // TODO: Write a continuous assignment line to output the instruction.
  // Extract the row index from pc_addr by dropping the lowest 2 bits using a vector slice!
  // Hint: Use rom[pc_addr[??:??]]
  
  assign instruction = rom[pc_addr[4:2]];
  
  // WRITE YOUR CODE HERE:


endmodule
*/

/*
module instruction_mem (
    input  logic [31:0] pc_addr,
    output logic [31:0] instruction
);

    always_comb begin
        if (pc_addr == 32'h0000_0000) begin
            instruction = 32'h0050_0093; // addi x1, x0, 5
        end else begin
            instruction = 32'h0000_0013; // NOP (addi x0, x0, 0) for all other cycles
        end
    end

endmodule
*/