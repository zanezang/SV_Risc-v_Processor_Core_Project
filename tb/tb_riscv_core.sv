`timescale 1ns/1ps

module tb_riscv_core;

    // 1. Declare clock and reset signals
    logic clk;
    logic rst_n;

    // 2. Instantiate your top-level CPU Core
    riscv_core uut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // 3. Clock Generator (100MHz clock: ticks every 5ns)
    always begin
        #5 clk = ~clk;
    end

    // 4. Test Stimulation Sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0; // Assert reset active low

        // Wait 20ns, then release reset
        #20 rst_n = 1;

        // Run simulation for a few clock cycles to let electricity settle
        #40;

        // Stop the simulation safely
        $display("--- Simulation Completed Successfully ---");
        $finish;
    end

    // 5. Real-Time Monitor: Print diagnostic variables directly to terminal
    // We spy inside the uut instance using hierarchical paths (uut.variable_name)
    initial begin
        $monitor("Time=%0t | PC=%h | Inst=%h | ALU Ctrl=%b | ALU Result=%d | Reg Write=%b", 
                 $time, uut.pc_current, uut.inst, uut.alu_ctrl, uut.alu_result, uut.reg_write);
    end

    // 6. Optional: Generate Waveform Dumps for GTKWave
    initial begin
        $dumpfile("cpu_simulation.vcd");
        $dumpvars(0, tb_riscv_core);
    end

endmodule