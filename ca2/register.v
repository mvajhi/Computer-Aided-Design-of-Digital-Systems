module register #(
    parameter DATA_WIDTH = 8
) (
    input  wire clk,
    input  wire rst,
    input  wire ld,
    input  wire [DATA_WIDTH-1:0] in,
    output reg  [DATA_WIDTH-1:0] out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= {DATA_WIDTH{1'b0}};
        else if (ld)
            out <= in;
    end

endmodule
