`timescale 1ns/1ps

module shift_add_multiplier32_tb;

    reg clk;
    reg rst;
    reg start;
    reg [31:0] multiplicand;
    reg [31:0] multiplier;

    wire [63:0] product;
    wire busy;
    wire done;

    shift_add_multiplier32 dut (
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

    initial begin
        $display("======================================");
        $display(" Shift-and-Add Multiplier Testbench");
        $display("======================================");

        clk = 0;
        rst = 1;
        start = 0;
        multiplicand = 32'd0;
        multiplier = 32'd0;

        #20;
        rst = 0;

        // Test 1: 11 * 5 = 55
        multiplicand = 32'd11;
        multiplier = 32'd5;

        start = 1;
        #10;
        start = 0;

        wait(done);
        #1;
        $display("MUL: %0d * %0d = %0d, hex=%h, expected=55",
                 multiplicand, multiplier, product, product);

        #20;

        // Test 2: 0x80000000 * 2 = 0x00000001_00000000
        multiplicand = 32'h8000_0000;
        multiplier = 32'h0000_0002;

        start = 1;
        #10;
        start = 0;

        wait(done);
        #1;
        $display("MUL: %h * %h = %h, expected=0000000100000000",
                 multiplicand, multiplier, product);

        #20;

        // Test 3: multiply by zero
        multiplicand = 32'hFFFF_FFFF;
        multiplier = 32'h0000_0000;

        start = 1;
        #10;
        start = 0;

        wait(done);
        #1;
        $display("MUL: %h * %h = %h, expected=0000000000000000",
                 multiplicand, multiplier, product);

        #20;

        // Test 4: multiply by one
        multiplicand = 32'h1234_5678;
        multiplier = 32'h0000_0001;

        start = 1;
        #10;
        start = 0;

        wait(done);
        #1;
        $display("MUL: %h * %h = %h, expected=0000000012345678",
                 multiplicand, multiplier, product);

        #20;

        $display("======================================");
        $display(" Simulation finished");
        $display("======================================");

        $finish;
    end

endmodule