module IFMapSratchPad #(
    parameter IFMAP_SPAD_WIDTH = 16,
    parameter IFMAP_SPAD_ROW = 12
) (
    input clk,
    input rst,
    input [IFMAP_BUFFER_WIDTH-1:0] din,
    input raddr,
    input waddr,
    input wen,

    output dout
);

reg [IFMAP_SPAD_WIDTH-1:0] mem [IFMAP_SPAD_ROW-1:0];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (integer i = 0; i < IFMAP_SPAD_ROW; i = i + 1) begin
            mem[i] <= 0;
        end
    end
    else if (wen) begin
        mem[waddr] <= din;
    end
end

assign dout = ren ? mem[raddr] : 0;

endmodule