`timescale 1ns / 100ps

module tb_register_file;
  logic        t_clk = 0;
  logic        t_rst_n;
  logic        t_we;
  logic [4:0]  t_rs1, t_rs2, t_rd;
  logic [31:0] t_wdata;
  logic [31:0] t_rdata1, t_rdata2;

  // Instantiate the design element
  register_file uut (
    .clk(t_clk), .rst_n(t_rst_n), .reg_write(t_we),
    .rs1(t_rs1), .rs2(t_rs2), .rd(t_rd), .write_data(t_wdata),
    .read_data1(t_rdata1), .read_data2(t_rdata2)
  );

  always #5 t_clk = ~t_clk;

  initial begin
    $display("=== Launching Register File Stress Test ===");
    t_rst_n = 0; t_we = 0; t_rs1 = 0; t_rs2 = 0; t_rd = 0; t_wdata = 0;
    #12; t_rst_n = 1; // Release system reset safely

    // Cycle 1: Write 0xABCD_1234 into Register x1
    t_rd    = 5'd1;
    t_wdata = 32'hABCD_1234;
    t_we    = 1'b1;
    @(posedge t_clk); // Wait for write edge

    // Cycle 2: Write 0x5555_AAAA into Register x2
    t_rd    = 5'd2;
    t_wdata = 32'h5555_AAAA;
    @(posedge t_clk);

    // Cycle 3: Attempt a forbidden write of 0xFFFF_FFFF into hardwired Register x0
    t_rd    = 5'd0;
    t_wdata = 32'hFFFF_FFFF;
    @(posedge t_clk);

    // Stop writing! Disable write-enable and check our work
    t_we = 1'b0;

    // Set Read Pointers: rs1 points to x1, rs2 points to x2
    t_rs1 = 5'd1;
    t_rs2 = 5'd2;
    #1; // Immediate combinational settle delay
    $display("Time = %0dns | Read x1 = 0x%h (Expected: abcd1234)", $time, t_rdata1);
    $display("Time = %0dns | Read x2 = 0x%h (Expected: 5555aaaa)", $time, t_rdata2);

    // Set Read Pointers: Check if x0 safely rejected the write flag
    t_rs1 = 5'd0;
    #1;
    $display("Time = %0dns | Read x0 = 0x%h (Expected: 00000000 - Hardwired Guard Active)", $time, t_rdata1);

    $display("=== Register File Test Complete ===");
    $finish;
  end
endmodule