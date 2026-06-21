module program_counter (
  input  logic        clk,       // System Clock
  input  logic        rst_n,     // Active-Low Asynchronous Reset
  input  logic [31:0] pc_next,   // 32-bit target address calculated by the CPU
  output logic [31:0] pc_out     // 32-bit current instruction pointer address
);

  // 'always_ff' creates physical D-Flip-Flop registers
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // TODO: When reset hits, your CPU must boot up at address 0.
      // Clear pc_out to a 32-bit zero literal.
      pc_out <= 32'b0;
      
    end else begin
      // TODO: On the rising edge of the clock, latch the calculated
      // next address into your memory register.
      pc_out <= pc_next;
    end
  end

endmodule


module pc_adder (
  input logic [31:0] pc_curr,
  output logic [31:0] pc_next
);
  
  always_comb begin
    pc_next = pc_curr + 32'd4;
  end
  
endmodule