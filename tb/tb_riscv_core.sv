`timescale 1ns/1ps

module tb_riscv_core;

    // ==========================================
    // 1. SYSTEM SIGNALS
    // ==========================================
    logic clk;
    logic rst_n;

    // ==========================================
    // 2. INSTANTIATE CPU CORE
    // ==========================================
    riscv_core uut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // ==========================================
    // 3. CLOCK GENERATOR (50MHz -> 20ns period)
    // ==========================================
    always begin
        #10 clk = ~clk;
    end

    // ==========================================
    // 4. TEST CONTROL & AUTOMATED VERIFICATION
    // ==========================================
    initial begin
        $display("==========================================================================");
        $display("             STARTING RISC-V CORE CLOSED-LOOP VERIFICATION                ");
        $display("==========================================================================");
        
        // Initialize signals
        clk   = 0;
        rst_n = 0; 
        
        // Hold reset for 25ns, then release cleanly on falling clock edge
        #25;
        @(negedge clk);
        rst_n = 1; 
        $display("[%0t ns] Reset released. Core executing from PC = 0x00000000...", $time);

        // Extended simulation time: 600ns gives enough cycles to run 30+ instructions
        #600;

        $display("==========================================================================");
        $display("                       SIMULATION COMPLETE                                ");
        $display("==========================================================================");
        
        // AUTOMATED SELF-CHECKING ASSERTION
        // Checks register x14 or RAM[1] (Address 0x04) for the test completion status
        if (uut.u_register_file.rf[14] == 32'h00000001 || uut.u_data_mem.ram_array[1] == 32'h00000001) begin
            $display(" [ STATUS ]: *** PASSED *** All Instructions, Branches, & Jumps Succeeded!");
            $display("             Final Checkpoint Output: x14 = %0d | RAM[1] = %0d", 
                     uut.u_register_file.rf[14], uut.u_data_mem.ram_array[1]);
        end else if (uut.u_register_file.rf[14] == 32'h00000BAD) begin
            $display(" [ STATUS ]: *** FAILED *** Hit Failure Trap! Check Branch/Jump Logic.");
        end else begin
            $display(" [ STATUS ]: *** WARNING *** Program did not reach final checkpoint.");
            $display("             Current State: PC = 0x%0h | x14 = 0x%0h | RAM[1] = 0x%0h", 
                     uut.pc_current, uut.u_register_file.rf[14], uut.u_data_mem.ram_array[1]);
        end
        
        $display("==========================================================================");
        $finish;
    end

    // ==========================================
    // 5. REAL-TIME MONITOR
    // ==========================================
    initial begin
        $monitor("Time=%-6t ns | PC=0x%08h | Inst=0x%08h | ALU_Res=%-4d | RegW=%b | x1=%-2d | x2=%-2d | x3=%-2d | x14=%-2d", 
                 $time, 
                 uut.pc_current, 
                 uut.inst, 
                 uut.alu_result, 
                 uut.reg_write,
                 uut.u_register_file.rf[1],   // LUI Target
                 uut.u_register_file.rf[2],   // Operand Reg 1
                 uut.u_register_file.rf[3],   // Operand Reg 2
                 uut.u_register_file.rf[14]   // Pass/Fail Trap Signal
        );
    end

    // ==========================================
    // 6. GTKWAVE VCD WAVEFORM GENERATOR
    // ==========================================
    initial begin
        $dumpfile("cpu_simulation.vcd");
        $dumpvars(0, tb_riscv_core);
    end

endmodule

/*
`timescale 1ns/1ps

module tb_riscv_core;

    // 1. System Signals
    logic clk;
    logic rst_n;

    // 2. Instantiate the Upgraded CPU Core
    riscv_core uut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // 3. Clock Generator (50MHz Clock -> Toggles every 10ns, 20ns period)
    always begin
        #10 clk = ~clk;
    end

    // 4. Test Control Sequence
    initial begin
        $display("==========================================================================");
        $display("             STARTING RISC-V CORE CLOSED-LOOP VERIFICATION                ");
        $display("==========================================================================");
        
        // Initialize and force Reset
        clk = 0;
        rst_n = 0; 
        
        // Hold reset for 25ns to let clocks align across a edge transition
        #25;
        rst_n = 1; // Release reset, execution begins at PC 0x00000000

        // Run the simulation for 6 full clock cycles (120ns) to step through our program
        #120;

        $display("==========================================================================");
        $display("                       SIMULATION COMPLETE                                ");
        $display("==========================================================================");
        $finish;
    end

    // 5. Advanced Hierarchical Real-Time Monitor
    // NOTE: If your register file array is named something other than 'rf' (like 'registers' or 'mem'),
    // change uut.u_reg_file.rf[...] to match your exact internal array variable name!
    initial begin
        $monitor("Time=%-10t | PC=%h | Inst=%h | ALU_Res=%-3d | RegW=%b | MemToReg = %-2d | mem_write = %d | x1=%-2d | x3=%-2d | x5=%-2d | RAM[4]=%-2d | RAM[2]=%d | arrindex=%d", 
                 $time, 
                 uut.pc_current, 
                 uut.inst, 
                 uut.alu_result, 
                 uut.reg_write,
                 uut.reg_write_src,
                 uut.mem_write,
                 uut.u_register_file.rf[1],  // Hierarchical spy: Destination register
                 uut.u_register_file.rf[3],  // Hierarchical spy: Comparison register
                 uut.u_register_file.rf[5],  // Hierarchical spy: Store data register
                 uut.u_data_mem.ram_array[4], // Hierarchical spy: RAM address 4 (word index 1)
                 uut.u_data_mem.ram_array[2],
                 uut.u_data_mem.addr[31:2]
        );
    end

    // 6. Automatically generate VCD Waveform log files for GTKWave
    initial begin
        $dumpfile("cpu_simulation.vcd");
        $dumpvars(0, tb_riscv_core);
    end

endmodule
*/

/*
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
*/