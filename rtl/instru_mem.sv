module instruction_mem (
    input  logic [31:0] pc_addr,
    output logic [31:0] instruction
);

    // Create an unpacked array to act as storage slots (e.g., 64 words deep)
    logic [31:0] mem_array [0:63];

    // Read the compiled machine code text file automatically at simulation startup
    initial begin
        $readmemh("hex/SelectionSort.hex", mem_array);
    end

    // Word-addressing alignment layout: 
    // Because the PC increments by 4 bytes per instruction, we drop the bottom 
    // two bits (shift right by 2) to align the address with our array indexes.
    assign instruction = mem_array[pc_addr[31:2]];

endmodule