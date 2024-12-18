module FilterScraratchPad #(
    parameter FILTER_WIDTH = 32,
) (
    input clk,
    input rst,
    input [FILTER_WIDTH-1:0] din,
    input raddr,
    input waddr,
    input ren,
    input wen,
    input chip_en,

    output [FILTER_WIDTH-1:0] dout
);

endmodule