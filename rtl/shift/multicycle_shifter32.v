module multicycle_shifter32 (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] data_in,
    input wire [4:0] shamt,
    input wire [1:0] mode,
    output reg [31:0] data_out,
    output reg busy,
    output reg done
);
    localparam MODE_SLL = 2'b00;
    localparam MODE_SRL = 2'b01;
    localparam MODE_SRA = 2'b10;

    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam SHIFT = 2'b10;
    localparam DONE = 2'b11;

    reg [1:0] state;
    reg [4:0] count;
    reg [31:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            count <= 5'd0;
            shift_reg <= 32'd0;
            data_out <= 32'd0;
            busy <= 1'b0;
            done <= 1'b0;
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
                    shift_reg <= data_in;
                    count <= shamt;
                    busy <= 1'b1;
                    done <= 1'b0;
                    state <= SHIFT;
                end
                SHIFT: begin
                    busy <= 1'b1;
                    done <= 1'b0;

                    if (count == 5'd0) begin
                        data_out <= shift_reg;
                        state <= DONE;
                    end else begin // Đã sửa: else if begin -> else begin
                        case (mode)
                            MODE_SLL: shift_reg <= shift_reg << 1;
                            MODE_SRL: shift_reg <= shift_reg >> 1;
                            MODE_SRA: shift_reg <= {shift_reg[31], shift_reg[31:1]};
                            default:  shift_reg <= shift_reg; 
                        endcase
                        count <= count - 1;
                    end
                end
                DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end 
            endcase
        end
    end
endmodule