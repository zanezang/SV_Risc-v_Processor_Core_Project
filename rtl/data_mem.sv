module data_mem (
    input logic clk,
    input logic mem_write,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);

    // Create a data RAM array storage block (64 memory slots deep)
    logic [31:0] ram_array [0:63];


    always_ff @(posedge clk) begin
        if (mem_write) begin
            ram_array[addr[31:2]] <= write_data;
        end
    end

    // Asynchronous Combinational Reads: RAM constantly exposes the target data
    assign read_data = ram_array[addr[31:2]];
    

endmodule