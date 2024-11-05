module configurable_counter #(parameter WIDTH = 4, parameter STEP = 1) (
    input wire clk,
    input wire rst,
    input wire enable,
    output reg [WIDTH-1:0] count
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else if (enable) begin
            count <= count + STEP;
        end
    end

endmodule
