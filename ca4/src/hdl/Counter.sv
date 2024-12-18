module Counter #(
    parameter WIDTH = 8
) (
    input clk,
    input rst,
    input en,
    output reg [WIDTH-1:0] counter
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
        end
        else if (en) begin
            counter <= counter + 1;
        end
    end
endmodule