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
    // 4. TEST CONTROL & SORTING VERIFICATION
    // ==========================================
    initial begin
        $display("==========================================================================");
        $display("          STARTING RISC-V CORE SELECTION SORT VERIFICATION                ");
        $display("==========================================================================");
        
        // Initialize signals
        clk   = 0;
        rst_n = 0; 
        
        // Hold reset for 25ns, then release cleanly on falling clock edge
        #25;
        @(negedge clk);
        rst_n = 1; 
        $display("[%0t ns] Reset released. Core executing program from PC = 0x00000000...", $time);

        // Extended simulation time (5000ns = 250 clock cycles for nested sorting loops)
        #5000;

        $display("==========================================================================");
        $display("                       SIMULATION COMPLETE                                ");
        $display("==========================================================================");
        
        // DISPLAY SORTED DATA MEMORY CONTENTS
        $display(" Memory Address | Array Index | Data Value | Expected Value ");
        $display(" ---------------|-------------|------------|----------------");
        $display("   0x04 (RAM[1]) |   Array[0]  | %-10d | 3",  uut.u_data_mem.ram_array[1]);
        $display("   0x08 (RAM[2]) |   Array[1]  | %-10d | 10", uut.u_data_mem.ram_array[2]);
        $display("   0x0C (RAM[3]) |   Array[2]  | %-10d | 12", uut.u_data_mem.ram_array[3]);
        $display("   0x10 (RAM[4]) |   Array[3]  | %-10d | 27", uut.u_data_mem.ram_array[4]);
        $display("   0x14 (RAM[5]) |   Array[4]  | %-10d | 42", uut.u_data_mem.ram_array[5]);
        $display("   0x18 (RAM[6]) |   Array[5]  | %-10d | 88", uut.u_data_mem.ram_array[6]);
        $display("--------------------------------------------------------------------------");

        // AUTOMATED SELF-CHECKING ASSERTION
        if (uut.u_data_mem.ram_array[1] == 32'd3  && 
            uut.u_data_mem.ram_array[2] == 32'd10 && 
            uut.u_data_mem.ram_array[3] == 32'd12 && 
            uut.u_data_mem.ram_array[4] == 32'd27 && 
            uut.u_data_mem.ram_array[5] == 32'd42 && 
            uut.u_data_mem.ram_array[6] == 32'd88) begin
            $display(" [ STATUS ]: *** PASSED *** Array successfully sorted in-place!");
        end else begin
            $display(" [ STATUS ]: *** FAILED *** Array is not sorted correctly. Check loop logic & memory swaps.");
        end
        
        $display("==========================================================================");
        $finish;
    end

    // ==========================================
    // 5. REAL-TIME MONITOR
    // ==========================================
    initial begin
        $monitor("Time=%-6t ns | PC=0x%08h | Inst=0x%08h | MemWrite=%b | Addr=0x%08h | WriteData=%-4d | ALU_Res=%-4d", 
                 $time, 
                 uut.pc_current, 
                 uut.inst, 
                 uut.mem_write,
                 uut.u_data_mem.addr,
                 uut.u_data_mem.write_data,
                 uut.alu_result
        );
    end

    // ==========================================
    // 6. GTKWAVE VCD WAVEFORM GENERATOR
    // ==========================================
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_riscv_core);
    end

endmodule