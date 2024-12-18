module len_check #(parameter WIDTH = 4) (
    input wire clk,
    input wire rst,
    input wire up_enable,
    input wire down_enable,
    output reg [WIDTH-1:0] count
);

    wire [WIDTH-1:0] count_inc = up_enable ? count + 1'b1 : count;
    wire [WIDTH-1:0] count_dec = down_enable ? count_inc - 1'b1 : count_inc;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else begin
            count <= count_dec;
        end
    end

endmodule
