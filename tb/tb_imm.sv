`timescale 1ns/1ps

module tb_alu;

    logic clk;
    logic rst_n;

    riscv_core #(
        .HEX_FILE("tests/hex/test_imm.hex")
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

        if (uut.u_register_file.rf[1] !== 32'd10)
            $display("FAIL: ADDI x1");
        else
            $display("PASS: ADDI x1");

        if (uut.u_register_file.rf[2] !== 32'd3)
            $display("FAIL: ADDI x2");
        else
            $display("PASS: ADDI x2");

        if (uut.u_register_file.rf[3] !== 32'd8)
            $display("FAIL: ADDI negative");
        else
            $display("PASS: ADDI negative");

        if (uut.u_register_file.rf[4] !== 32'd2)
            $display("FAIL: ANDI");
        else
            $display("PASS: ANDI");

        if (uut.u_register_file.rf[5] !== 32'd8)
            $display("FAIL: ORI");
        else
            $display("PASS: ORI");

        if (uut.u_register_file.rf[6] !== 32'd11)
            $display("FAIL: XORI");
        else
            $display("PASS: XORI");

        if (uut.u_register_file.rf[7] !== 32'd1)
            $display("FAIL: SLTI");
        else
            $display("PASS: SLTI");

        $display("----------------------------");
        $display("IMMEDIATE TEST COMPLETE");
        $display("----------------------------");

        $finish;
    end

endmodule