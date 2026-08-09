module data_mem (
    input logic clk,
    input logic mem_write,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);

    // Create a data RAM array storage block (64 memory slots deep)
    logic [31:0] ram_array [0:63];

    // PRE-LOAD UNSORTED TEST ARRAY INTO RAM
    initial begin
        ram_array[0] = 32'd6;   // RAM[0] (Addr 0x00): Array length N = 6
        ram_array[1] = 32'd42;  // RAM[1] (Addr 0x04): Array[0]
        ram_array[2] = 32'd12;  // RAM[2] (Addr 0x08): Array[1]
        ram_array[3] = 32'd88;  // RAM[3] (Addr 0x0C): Array[2]
        ram_array[4] = 32'd3;   // RAM[4] (Addr 0x10): Array[3]
        ram_array[5] = 32'd27;  // RAM[5] (Addr 0x14): Array[4]
        ram_array[6] = 32'd10;  // RAM[6] (Addr 0x18): Array[5]
    end

    always_ff @(posedge clk) begin
        if (mem_write) begin
            ram_array[addr[31:2]] <= write_data;
        end
    end

    // Asynchronous Combinational Reads: RAM constantly exposes the target data
    assign read_data = ram_array[addr[31:2]];
    

endmodule