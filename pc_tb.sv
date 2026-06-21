`timescale 1ns / 100ps

module tb_fetch_loop;
  logic        t_clk = 0;
  logic        t_rst_n;
  
  // Interconnect Wires: These connect the modules together behind the scenes
  logic [31:0] wire_pc_to_adder;
  logic [31:0] wire_adder_to_pc;

  // 1. Instantiate the Program Counter register
  program_counter pc_reg_inst (
    .clk   (t_clk),
    .rst_n (t_rst_n),
    // TODO: Wire up the target inputs and outputs using our interconnect logic tracks
    .pc_next(wire_adder_to_pc), 
    .pc_out (wire_pc_to_adder)
  );

  // 2. Instantiate the Combinational Adder unit
  pc_adder pc_calc_inst (
    // TODO: Connect the adder ports so it reads from the PC register output
    // and sends its calculated value back to the PC register input track.
    
    // WRITE PORT CONNECTIONS HERE:
    .pc_curr(wire_pc_to_adder),
    .pc_next(wire_adder_to_pc)
  );

  // Background Software Loop: Clock Generator pulses every 5ns
  always #5 t_clk = ~t_clk;

  // Sequential Stimulus: Boot the system and watch it run on its own!
  initial begin
    $display("=== Booting Hardware Single-Cycle Fetch Loop ===");
    
    t_rst_n = 0; // Hold the system in reset state
    #12;         // Wait for 12ns to clear the first clock cycle safely
    
    t_rst_n = 1; // Release reset! The loop is now live.

    // Let the clock run for 5 full cycles automatically
    repeat (5) @(posedge t_clk);
    
    #1; // Brief pause to settle paths before checking results
    $display("Simulation complete. Check your waveforms or logs!");
    $finish;
  end

  // Monitor monitor block: Prints out data every time the clock rises
  always @(posedge t_clk) begin
    if (t_rst_n) begin
      #1; // Settle time to let registers update
      $display("Time = %0dns | Clock Cycle | Current PC Address = 0x%h | Next Predicted = 0x%h", 
               $time, wire_pc_to_adder, wire_adder_to_pc);
    end
  end

endmodule