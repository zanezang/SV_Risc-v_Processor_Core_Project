`timescale 1ns/1ps

module tb_branch;

    logic clk;
    logic rst_n;

    riscv_core #(
        .HEX_FILE("tests/hex/test_branch.hex")
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

        if (uut.u_register_file.rf[3] !== 32'd10)
            $display("FAIL: BEQ taken: x3 expected 10, got %0d",
                    uut.u_register_file.rf[3]);
        else
            $display("PASS: BEQ taken");

        if (uut.u_register_file.rf[10] !== 32'd0)
            $display("FAIL: BEQ: skipped instruction executed: x10 = %0d",
                    uut.u_register_file.rf[10]);
        else
            $display("PASS: BEQ skipped instruction");

        if (uut.u_register_file.rf[6] !== 32'd20)
            $display("FAIL: BNE taken: x6 expected 20, got %0d",
                    uut.u_register_file.rf[6]);
        else
            $display("PASS: BNE taken");

        if (uut.u_register_file.rf[11] !== 32'd0)
            $display("FAIL: BNE: skipped instruction executed: x11 = %0d",
                    uut.u_register_file.rf[11]);
        else
            $display("PASS: BNE skipped instruction");

        if (uut.u_register_file.rf[9] !== 32'd30)
            $display("FAIL: BLT taken: x9 expected 30, got %0d",
                    uut.u_register_file.rf[9]);
        else
            $display("PASS: BLT taken");

        if (uut.u_register_file.rf[12] !== 32'd0)
            $display("FAIL: BLT: skipped instruction executed: x12 = %0d",
                    uut.u_register_file.rf[12]);
        else
            $display("PASS: BLT skipped instruction");

        if (uut.u_register_file.rf[16] !== 32'd40)
            $display("FAIL: BGE taken: x16 expected 40, got %0d",
                    uut.u_register_file.rf[16]);
        else
            $display("PASS: BGE taken");

        if (uut.u_register_file.rf[15] !== 32'd0)
            $display("FAIL: BGE: skipped instruction executed: x15 = %0d",
                    uut.u_register_file.rf[15]);
        else
            $display("PASS: BGE skipped instruction");

        $display("----------------------------");
        $display("BRANCH TEST COMPLETE");
        $display("----------------------------");

        $finish;
    end

endmodule