`timescale 1ns/1ps
module multicycle_shifter32_tb ();
reg clk;
reg rst;
reg start;
reg [31:0] data_in;
reg [4:0] shamt;
reg [1:0] mode;
wire [31:0] data_out;
wire busy;
wire done;

multicycle_shifter32 uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(data_in),
    .shamt(shamt),
    .mode(mode),
    .data_out(data_out),
    .busy(busy),
    .done(done)
);

always #5 clk = ~clk;
initial begin
    clk = 1'b0;
    rst = 1'b1;
    start = 0;
    shamt = 5'd5;
    data_in = 32'hCAFEFECA;
    #10;
    //Mode 1: SLL
    rst = 1'b0;
    mode = 2'b00;
    start = 1'b1;
    #10;
    start = 1'b0;
    #100;
    //Mode 2: SRL
    rst = 1'b0;
    mode = 2'b01;
    start = 1'b1;
    #10;
    start = 1'b0;
    #100;
    //Mode 3: SRA
    rst = 1'b0;
    mode = 2'b10;
    start = 1'b1;
    #10;
    start = 1'b0;
    #100;
    $stop;
end
endmodule