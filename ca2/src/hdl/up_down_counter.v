module up_down_counter #(parameter WIDTH = 4, parameter UP_STEP = 1, parameter DOWN_STEP = 1) (
    input wire clk,
    input wire rst,
    input wire up_enable,
    input wire down_enable,
    output reg [WIDTH-1:0] count
);

    wire [WIDTH-1:0] count_inc = up_enable ? count + UP_STEP : count;
    wire [WIDTH-1:0] count_dec = down_enable ? count_inc - DOWN_STEP : count_inc;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else begin
            count <= count_dec;
        end
    end

endmodule
