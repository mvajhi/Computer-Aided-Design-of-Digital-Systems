module dp_reg (
    input         clk,
    input         rst,
    input  [31:0] in_x,
    input  [31:0] in_num,
    input  [31:0] in_sum,
    input         in_overflow,
    input  [2:0]  in_i,
    input         in_flag_next,
    input         in_valid,
    output reg [31:0] out_x,
    output reg [31:0] out_num,
    output reg [31:0] out_sum,
    output reg        out_overflow,
    output reg [2:0]  out_i,
    output reg        out_flag_next,
    output reg        out_valid
);
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            out_x <= 32'b0;
            out_num <= 32'b0;
            out_sum <= 32'b0;
            out_overflow <= 1'b0;
            out_i <= 3'b0;
            out_flag_next <= 1'b0;
            out_valid <= 1'b0;
        end else begin
            out_x <= in_x;
            out_num <= in_num;
            out_sum <= in_sum;
            out_overflow <= in_overflow;
            out_i <= in_i;
            out_flag_next <= in_flag_next;
            out_valid <= in_valid;
        end
    end
endmodule