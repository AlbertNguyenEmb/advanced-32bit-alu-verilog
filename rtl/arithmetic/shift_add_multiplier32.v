`timescale 1ns/1ps
module shift_add_multiplier32 (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] multiplicand,
    input wire [31:0] multiplier,

    output reg [63:0] product,
    output reg busy,
    output reg done
);
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam CALC = 2'b10;
    localparam DONE = 2'b11;

    reg [1:0] state;
    reg [5:0] count;
    reg [63:0] product_reg;
    reg [63:0] multiplicand_reg;
    reg [31:0] multiplier_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            count <= 6'd0;
            product_reg <= 64'd0;
            multiplicand_reg <= 64'd0;
            multiplier_reg <= 64'd0;
            product <= 64'd0;
            busy <= 1'b0;
            done <= 1'd0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    done <= 1'b0;

                    if (start) begin
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    product_reg <= 64'd0;
                    multiplicand_reg <= {32'd0, multiplicand};
                    multiplier_reg <= multiplier;
                    count <= 6'd0;
                    busy <= 1'b1;
                    done <= 1'b0;
                    state <= CALC;
                end
                CALC: begin
                    busy <= 1'b1;
                    done <= 1'b0;

                    if (count == 6'd32) begin
                        product <= product_reg;
                        state <= DONE;
                    end else begin
                        if (multiplier_reg[0]) begin
                            product_reg <= product_reg + multiplicand_reg;
                        end

                        multiplicand_reg <= multiplicand_reg << 1;
                        multiplier_reg <= multiplier_reg >> 1;
                        count <= count + 1'b1;
                    end
                end
                DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                    busy <= 1'b0;
                    done <= 1'b0;
                end
            endcase
        end
    end
endmodule