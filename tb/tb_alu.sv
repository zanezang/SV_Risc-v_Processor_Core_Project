`timescale 1ns/1ps

module tb_alu;

    logic clk;
    logic rst_n;

    riscv_core #(
        .HEX_FILE("tests/hex/test_alu.hex")
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
        // Check ALU results
        // -----------------------------

        if (uut.u_register_file.rf[3] !== 32'd7)
            $display("FAIL: ADD   expected 7,  got %0d",
                     uut.u_register_file.rf[3]);
        else
            $display("PASS: ADD");

        if (uut.u_register_file.rf[6] !== 32'd3)
            $display("FAIL: SUB   expected 3,  got %0d",
                     uut.u_register_file.rf[6]);
        else
            $display("PASS: SUB");

        if (uut.u_register_file.rf[9] !== 32'd7)
            $display("FAIL: AND   expected 7,  got %0d",
                     uut.u_register_file.rf[9]);
        else
            $display("PASS: AND");

        if (uut.u_register_file.rf[12] !== 32'd15)
            $display("FAIL: OR    expected 15, got %0d",
                     uut.u_register_file.rf[12]);
        else
            $display("PASS: OR");

        if (uut.u_register_file.rf[15] !== 32'd10)
            $display("FAIL: XOR   expected 10, got %0d",
                     uut.u_register_file.rf[15]);
        else
            $display("PASS: XOR");

        if (uut.u_register_file.rf[18] !== 32'd1)
            $display("FAIL: SLT   expected 1,  got %0d",
                     uut.u_register_file.rf[18]);
        else
            $display("PASS: SLT");

        $display("----------------------------");
        $display("ALU TEST COMPLETE");
        $display("----------------------------");

        $finish;
    end

endmodule