`timescale 1ns/1ps

module booth_multiplier32 (
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed [31:0] multiplicand,
    input wire signed [31:0] multiplier,

    output reg signed [63:0] product,
    output reg busy,
    output reg done
);
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam CALC = 2'b10;
    localparam DONE = 2'b11;

    reg [1:0] state;
    reg [5:0] count;

    reg signed [32:0] acc;
    reg signed [32:0] m_reg;
    reg [31:0] q_reg;
    reg q_minus1;

    reg signed [32:0] acc_next;
    reg signed [65:0] combined_next;

    always @(*) begin
        acc_next = acc;

        case ({q_reg[0], q_minus1})
            2'b01: acc_next = acc + m_reg;
            2'b10: acc_next = acc - m_reg; 
            default: acc_next = acc;
        endcase

        combined_next = $signed({acc_next, q_reg, q_minus1}) >>> 1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            count     <= 6'd0;
            acc       <= 33'd0;
            m_reg     <= 33'd0;
            q_reg     <= 32'd0;
            q_minus1  <= 1'b0;
            product   <= 64'd0;
            busy      <= 1'b0;
            done      <= 1'b0;
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
                    acc      <= 33'd0;
                    m_reg    <= {multiplicand[31], multiplicand};
                    q_reg    <= multiplier;
                    q_minus1 <= 1'b0;
                    count    <= 6'd0;
                    busy     <= 1'b1;
                    done     <= 1'b0;
                    state    <= CALC;
                end

                CALC: begin
                    busy <= 1'b1;
                    done <= 1'b0;

                    if (count == 6'd32) begin
                        product <= {acc[31:0], q_reg};
                        state   <= DONE;
                    end else begin
                        acc      <= combined_next[65:33];
                        q_reg    <= combined_next[32:1];
                        q_minus1 <= combined_next[0];
                        count    <= count + 1'b1;
                    end
                end

                DONE: begin
                    busy  <= 1'b0;
                    done  <= 1'b1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                    busy  <= 1'b0;
                    done  <= 1'b0;
                end

            endcase
        end
    end  
endmodule