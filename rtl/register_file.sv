module register_file (
  input  logic        clk,         // System Clock
  input  logic        rst_n,       // Active-Low Reset
  input  logic        reg_write,   // Write Enable control bit (1 = Write data, 0 = Freeze)
  input  logic [4:0]  rs1,         // 5-bit Source Register 1 Address Pointer
  input  logic [4:0]  rs2,         // 5-bit Source Register 2 Address Pointer
  input  logic [4:0]  rd,          // 5-bit Destination Register Address Pointer
  input  logic [31:0] write_data,  // 32-bit data vector waiting to be stored
  output logic [31:0] read_data1,  // 32-bit data currently inside rs1
  output logic [31:0] read_data2   // 32-bit data currently inside rs2
);

  // Unpacked Array: 32 rows, each 32-bits wide
  logic [31:0] rf [0:31];

  // --- READ PORTS (Pure Combinational Logic) ---
  // TODO: Implement the absolute law of Register 0 using a ternary operator.
  // If rs1 is pointing to 5'b00000, force read_data1 to output a clean 32-bit zero.
  // Otherwise, extract rf[rs1]. Repeat the exact same rule for read_data2.
  
  // WRITE YOUR READ OPERATORS HERE:
  assign read_data1 = (rs1 == 5'b00000) ? 32'b0 : rf[rs1];
  assign read_data2 = (rs2 == 5'b00000) ? 32'b0 : rf[rs2];


  // --- WRITE PORT (Clocked Sequential Logic) ---
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Optional: Clear registers on reset loop (skipping index 0 since it's hardwired)
      for (int i = 1; i < 32; i++) begin
        rf[i] <= 32'h0000_0000;
      end
    end else begin
      // TODO: Implement the write logic path.
      // A write occurs ONLY IF:
      //   1. 'reg_write' is asserted high AND
      //   2. The target destination register 'rd' is NOT register 0.
      // Remember to use a non-blocking assignment (<=) to update the array cell.
      
      // WRITE YOUR WRITE LOGIC HERE:
      if (write_data && rd != 5'b0) begin 
        rf[rd] <= write_data;
      end

    end
  end

endmodule