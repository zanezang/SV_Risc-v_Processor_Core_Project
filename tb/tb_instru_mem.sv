module tb_fetch_instruction;
  logic        t_clk = 0;
  logic        t_rst_n;
  
  logic [31:0] wire_pc_to_adder_and_rom;
  logic [31:0] wire_adder_to_pc;
  logic [31:0] wire_instruction_out; // Interconnect wire for the instruction word

  // 1. Program Counter Register
  program_counter pc_reg_inst (
    .clk    (t_clk),
    .rst_n  (t_rst_n),
    .pc_next(wire_adder_to_pc), 
    .pc_out (wire_pc_to_adder_and_rom)
  );

  // 2. PC Adder Calculator
  pc_adder pc_calc_inst (
    .pc_curr(wire_pc_to_adder_and_rom),   
    .pc_next(wire_adder_to_pc)
  );

  // 3. Instantiate the Instruction Memory block
  instruction_mem imem_inst (
    // TODO: Connect the memory ports to read from the PC wire 
    // and output into your new instruction interconnect track
    
    // WRITE PORT CONNECTIONS HERE:
    .pc_addr(wire_pc_to_adder_and_rom),
    .instruction(wire_instruction_out)
  );

  always #5 t_clk = ~t_clk;

  initial begin
    $display("=== Launching Full CPU Fetch Stage Simulation ===");
    t_rst_n = 0; 
    #12;         
    t_rst_n = 1; 

    // Sweep through 6 instruction fetches automatically
    repeat (6) @(posedge t_clk);
    
    #1; 
    $display("=== Fetch Stage Test Complete ===");
    $finish;
  end

  // Advanced Visual Logging Monitor
  always @(posedge t_clk) begin
    if (t_rst_n) begin
      #1; 
      $display("Time = %0dns | PC Address = 0x%h | Fetched Machine Code = 0x%h", 
               $time, wire_pc_to_adder_and_rom, wire_instruction_out);
    end
  end

endmodule