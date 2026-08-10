module register_file (
  input  logic        clk,         // System Clock
  input  logic        rst_n,       // Active-Low Reset
  input  logic        reg_write,   // Write Enable control bit (1 = Write data, 0 = Freeze)
  input  logic [4:0]  raddr1,         // 5-bit Source Register 1 Address Pointer
  input  logic [4:0]  raddr2,         // 5-bit Source Register 2 Address Pointer
  input  logic [4:0]  waddr,          // 5-bit Destination Register Address Pointer
  input  logic [31:0] write_data,  // 32-bit data vector waiting to be stored
  output logic [31:0] read_data1,  // 32-bit data currently inside raddr1
  output logic [31:0] read_data2   // 32-bit data currently inside raddr2
);

  // Unpacked Array: 32 rows, each 32-bits wide
  logic [31:0] rf [0:31];

  // --- READ PORTS (Pure Combinational Logic) ---
  assign read_data1 = (raddr1 == 5'b00000) ? 32'b0 : rf[raddr1];
  assign read_data2 = (raddr2 == 5'b00000) ? 32'b0 : rf[raddr2];


  // --- WRITE PORT (Clocked Sequential Logic) ---
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 1; i < 32; i++) begin
        rf[i] <= 32'h0000_0000;
      end
    end else begin     
      if (write_data && waddr != 5'b0) begin 
        rf[waddr] <= write_data;
      end
    end
  end

endmodule