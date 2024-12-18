module Pipeline1 #(
    parameter DATA_WIDTH = 8
) (
    input  wire clk,
    input  wire rst,
    input  wire stall,
    input  wire [DATA_WIDTH-1:0] in,
    output reg  [DATA_WIDTH-1:0] out,
    output reg  stall_out,
);

    
endmodule