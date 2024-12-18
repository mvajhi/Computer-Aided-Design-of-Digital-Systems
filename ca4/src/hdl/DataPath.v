module dp #(
    parameter IFMAP_BUFFER_WIDTH = 18,
    parameter FILTER_BUFFER_DEPTH = 16,
    parameter FILTER_WIDTH = 8,
    parameter FILTER_SIZE_REG_SIZE = 8,
    parameter STRIDE_SIZE = 3,
    parameter PAR_WRITE_IFMAP = 1,
    parameter PAR_WRITE_FILTER = 1
) (
    input clk,
    input rst,
    input start,
    input [STRIDE_SIZE-1:0] stride,
    input [FILTER_SIZE_REG_SIZE-1:0] filter_size,
    input [IFMAP_BUFFER_WIDTH-1:0] IFMap_in,
    input [FILTER_WIDTH-1:0] Filter_in,

    input wen_IFMap,
    input wen_Filter,

    // controller
    input ld_stride,
    input ld_fileSize,
    input put_data,
    input put_filter,
    input clear_sum,
    input store_buffer,
    input next_filter,
    input next_row,

    output av_data,
    output av_filter,
    output co_filter,
    output end_of_row,
    output end_of_filter,

    output [IFMAP_BUFFER_WIDTH-1:0] Psum_out,
    output done
);

wire [STRIDE_SIZE-1:0] stride_reg_out;
wire [FILTER_SIZE_REG_SIZE-1:0] filter_size_out;

Register #(STRIDE_SIZE) stride_reg(clk, rst, ld_stride, stride, stride_reg_out);
Register #(FILTER_SIZE_REG_SIZE) filter_reg(clk, rst, ld_fileSize, filter_size, filter_size_out);

// IFMap

wire [IFMAP_BUFFER_WIDTH-1:0] IFMap_buffer_out;

Fifo_buffer #(
    .DATA_WIDTH(IFMAP_BUFFER_WIDTH),
    .PAR_WRITE(PAR_WRITE_IFMAP),
    .PAR_READ(1),
    .DEPTH(FILTER_BUFFER_DEPTH)
) (
    .clk(clk),
    .rstn(rst),
    .clear(clear_sum),
    .ren(/**/),
    .wen(wen_IFMap),
    .din(IFMap_in),
    .dout(IFMap_buffer_out),
);

endmodule