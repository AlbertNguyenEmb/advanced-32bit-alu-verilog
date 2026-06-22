`timescale 1ns/1ps

module booth_multiplier32_tb;

    reg clk;
    reg rst;
    reg start;
    reg signed [31:0] multiplicand;
    reg signed [31:0] multiplier;

    wire signed [63:0] product;
    wire busy;
    wire done;

    booth_multiplier32 dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    task run_test;
        input signed [31:0] a;
        input signed [31:0] b;
        input signed [63:0] expected;
        begin
            multiplicand = a;
            multiplier   = b;

            start = 1;
            #10;
            start = 0;

            wait(done);
            #1;

            if (product === expected) begin
                $display("PASS: %0d * %0d = %0d, hex=%h",
                         a, b, product, product);
            end else begin
                $display("FAIL: %0d * %0d = %0d, expected=%0d, got_hex=%h, expected_hex=%h",
                         a, b, product, expected, product, expected);
            end

            #20;
        end
    endtask

    initial begin
        $display("======================================");
        $display(" Booth Multiplier Testbench");
        $display("======================================");

        clk = 0;
        rst = 1;
        start = 0;
        multiplicand = 0;
        multiplier = 0;

        #20;
        rst = 0;

        run_test(32'sd5,    32'sd3,    64'sd15);
        run_test(-32'sd5,   32'sd3,   -64'sd15);
        run_test(32'sd5,   -32'sd3,   -64'sd15);
        run_test(-32'sd5,  -32'sd3,    64'sd15);

        run_test(32'sd0,    32'sd123,  64'sd0);
        run_test(32'sd1,   -32'sd99,  -64'sd99);
        run_test(-32'sd1,   32'sd99,  -64'sd99);

        run_test(32'sd12345, -32'sd7, -64'sd86415);

        $display("======================================");
        $display(" Simulation finished");
        $display("======================================");

        $finish;
    end

endmodule