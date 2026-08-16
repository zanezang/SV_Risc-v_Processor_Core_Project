`timescale 1ns/1ps

module tb_data_mem;

    logic clk;
    logic rst_n;

    riscv_core #(
        .HEX_FILE("tests/hex/test_data_mem.hex")
    ) uut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    always #10 clk = ~clk;

    initial begin
        clk   = 0;
        rst_n = 0;

        // Hold reset for 2 clock cycles
        repeat (2) @(posedge clk);
        rst_n = 1;

        // Let the CPU execute test_alu.S
        repeat (30) @(posedge clk);

        // -----------------------------
        // Check results
        // -----------------------------

        if (uut.u_register_file.rf[1] !== 32'd42)
            $display("FAIL: x1 expected 42, got %0d", uut.u_register_file.rf[1]);
        else
            $display("PASS: x1 = 42");

        if (uut.u_register_file.rf[2] !== 32'd100)
            $display("FAIL: x2 expected 100, got %0d", uut.u_register_file.rf[2]);
        else
            $display("PASS: x2 = 100");

        if (uut.u_register_file.rf[3] !== 32'd42)
            $display("FAIL: LW x3 expected 42, got %0d", uut.u_register_file.rf[3]);
        else
            $display("PASS: LW x3 = 42");

        if (uut.u_register_file.rf[4] !== 32'd42)
            $display("FAIL: LW x4 expected 42, got %0d", uut.u_register_file.rf[4]);
        else
            $display("PASS: LW x4 = 42");

        if (uut.u_data_mem.ram_array[25] !== 32'd42)
            $display("FAIL: MEM[25] expected 42, got %0d", uut.u_data_mem.ram_array[25]);
        else
            $display("PASS: MEM[25] = 42");

        if (uut.u_data_mem.ram_array[26] !== 32'd42)
            $display("FAIL: MEM[26] expected 42, got %0d", uut.u_data_mem.ram_array[26]);
        else
            $display("PASS: MEM[26] = 42");

        $display("----------------------------");
        $display("Data Memory TEST COMPLETE");
        $display("----------------------------");

        $finish;
    end

endmodule