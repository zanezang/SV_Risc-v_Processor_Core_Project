`timescale 1ns/1ps

module tb_branch;

    logic clk;
    logic rst_n;

    riscv_core #(
        .HEX_FILE("tests/hex/test_jal.hex")
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

        if (uut.u_register_file.rf[1] !== 32'd4)
            $display("FAIL: JAL link: x1 expected 4, got %0d",
                    uut.u_register_file.rf[1]);
        else
            $display("PASS: JAL link");

        if (uut.u_register_file.rf[2] !== 32'd20)
            $display("FAIL: JAL target: x2 expected 20, got %0d",
                    uut.u_register_file.rf[2]);
        else
            $display("PASS: JAL target");

        if (uut.u_register_file.rf[10] !== 32'd0)
            $display("FAIL: JAL skipped instruction executed: x10 = %0d",
                    uut.u_register_file.rf[10]);
        else
            $display("PASS: JAL skipped instruction");

        $display("----------------------------");
        $display("JAL TEST COMPLETE");
        $display("----------------------------");

        $finish;
    end

endmodule