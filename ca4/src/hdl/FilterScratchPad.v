module FilterScraratchPad #(
    parameter FILTER_WIDTH = 16,
    parameter FILTER_ROW = 12
) (
    input clk,
    input rst,
    input [FILTER_WIDTH-1:0] din,
    input [clog2(FILTER_ROW)-1:0] raddr,
    input [clog2(FILTER_ROW)-1:0] waddr,
    input ren,
    input wen,
    input chip_en,

    output [FILTER_WIDTH-1:0] dout
);

reg [FILTER_WIDTH-1:0] mem [FILTER_ROW-1:0];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (integer i = 0; i < FILTER_ROW; i = i + 1) begin
            mem[i] <= 0;
        end
    end
    else if (chip_en) begin
        if (wen) begin
            mem[waddr] <= din;
        end
        if (ren) begin
            dout <= mem[raddr];
        end
    end    
    else begin
        if (ren) begin
            dout <= mem[raddr];
        end
        else if (wen) begin
            mem[waddr] <= din;
        end
    end 
end

endmodule