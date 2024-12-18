module IFMapSratchPad #(
    parameter IFMAP_SPAD_WIDTH = 32,
) (
    input clk,
    input rst,
    input [IFMAP_BUFFER_WIDTH-1:0] din,
    input raddr,
    input waddr,
    input wen,

    output dout
);
endmodule