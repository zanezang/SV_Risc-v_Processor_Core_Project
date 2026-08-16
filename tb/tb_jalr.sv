`timescale 1ns/1ps

module tb_jalr;

    logic clk;
    logic rst_n;

    riscv_core #(
        .HEX_FILE("tests/hex/test_jalr.hex")
    ) uut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    always #10 clk = ~clk;

    initial begin
        clk   = 0;
        rst_n = 0;

        repeat (2) @(posedge clk);
        rst_n = 1;

        repeat (30) @(posedge clk);

        // x1 = 16
        if (uut.u_register_file.rf[1] !== 32'd16)
            $display("FAIL: x1 expected 16, got %0d",
                     uut.u_register_file.rf[1]);
        else
            $display("PASS: x1 = 16");

        // JALR link address
        if (uut.u_register_file.rf[5] !== 32'd8)
            $display("FAIL: JALR link: x5 expected 8, got %0d",
                     uut.u_register_file.rf[5]);
        else
            $display("PASS: JALR link");

        // Target instruction executed
        if (uut.u_register_file.rf[6] !== 32'd30)
            $display("FAIL: JALR target: x6 expected 30, got %0d",
                     uut.u_register_file.rf[6]);
        else
            $display("PASS: JALR target");

        // Instructions after JALR were skipped
        if (uut.u_register_file.rf[10] !== 32'd0)
            $display("FAIL: skipped instruction executed: x10 = %0d",
                     uut.u_register_file.rf[10]);
        else
            $display("PASS: skipped instruction x10");

        if (uut.u_register_file.rf[11] !== 32'd0)
            $display("FAIL: skipped instruction executed: x11 = %0d",
                     uut.u_register_file.rf[11]);
        else
            $display("PASS: skipped instruction x11");

        $display("----------------------------");
        $display("JALR TEST COMPLETE");
        $display("----------------------------");

        $finish;
    end

endmodule