module topmodule #(
    parameter PSUM_DEPTH = 8,
    parameter IFMAP_WIDTH = 18,
    parameter IFMAP_BUFFER_DEPTH = 16,
    parameter IFMAP_POINTER_SIZE = 8,
    parameter IFMAP_SPAD_ROW = 12,
    parameter FILTER_SPAD_ROW = 12,
    parameter FILTER_BUFFER_DEPTH = 16,
    parameter FILTER_WIDTH = 8,
    parameter FILTER_SIZE_REG_SIZE = 8,
    parameter FILTER_POINTER_SIZE = 8,
    parameter STRIDE_SIZE = 3,
    parameter PAR_WRITE_IFMAP = 1,
    parameter PAR_WRITE_FILTER = 1
) (
    input clk,
    input rst,
    input start,
    input [STRIDE_SIZE - 1:0] stride,
    input [FILTER_SIZE_REG_SIZE - 1:0] filter_size,
    input [(IFMAP_WIDTH * PAR_WRITE_IFMAP) - 1:0] IFMap_in,
    input [(FILTER_WIDTH * PAR_WRITE_FILTER) - 1:0] Filter_in,

    input wen_IFMap_buffer,
    input wen_Filter_buffer,
    input ren_Psum_buffer,
    input chip_en,

    output [(IFMAP_WIDTH - 2)-1:0] Psum_out,
    output done
);

    wire ld_stride;
    wire ld_fileSize;
    wire put_data;
    wire put_filter;
    wire clear_sum;
    wire store_buffer;
    wire next_filter;
    wire next_row;

    wire av_data;
    wire av_filter;
    wire co_filter;
    wire end_of_row;
    wire end_of_filter;


dp #(
    .PSUM_DEPTH(PSUM_DEPTH),
    .IFMAP_WIDTH(IFMAP_WIDTH),
    .IFMAP_BUFFER_DEPTH(IFMAP_BUFFER_DEPTH),
    .IFMAP_POINTER_SIZE(IFMAP_POINTER_SIZE),
    .IFMAP_SPAD_ROW(IFMAP_SPAD_ROW),
    .FILTER_SPAD_ROW(FILTER_SPAD_ROW),
    .FILTER_BUFFER_DEPTH(FILTER_BUFFER_DEPTH),
    .FILTER_WIDTH(FILTER_WIDTH),
    .FILTER_SIZE_REG_SIZE(FILTER_SIZE_REG_SIZE),
    .FILTER_POINTER_SIZE(FILTER_POINTER_SIZE),
    .STRIDE_SIZE(STRIDE_SIZE),
    .PAR_WRITE_IFMAP(PAR_WRITE_IFMAP),
    .PAR_WRITE_FILTER(PAR_WRITE_FILTER)
) dp (
    .clk(clk),
    .rst(rst),
    .stride(stride),
    .filter_size(filter_size),
    .IFMap_in(IFMap_in),
    .Filter_in(Filter_in),

    .wen_IFMap_buffer(wen_IFMap_buffer),
    .wen_Filter_buffer(wen_Filter_buffer),
    .ren_Psum_buffer(ren_Psum_buffer),
    .chip_en(chip_en),

    .ld_stride(ld_stride),
    .ld_fileSize(ld_fileSize),
    .put_data(put_data),
    .put_filter(put_filter),
    .clear_sum(clear_sum),
    .store_buffer(store_buffer),
    .next_filter(next_filter),
    .next_row(next_row),

    .av_data(av_data),
    .av_filter(av_filter),
    .co_filter(co_filter),
    .end_of_row(end_of_row),
    .end_of_filter(end_of_filter),

    .Psum_out(Psum_out),
    .done(done)
);


main_controller fuck_you (
    .clk(clk),
    .rst(rst),
    .start(start),
    .av_data(av_data),
    .av_filter(av_filter),
    .co_filter(co_filter),
    .end_of_row(end_of_row),    
    .end_of_filter(end_of_filter),

    .ld_stride(ld_stride),            
    .ld_fileSize(ld_fileSize),             
    .put_data(put_data),
    .put_filter(put_filter),
    .clear_sum(clear_sum),
    .store_buffer(store_buffer),
    .next_filter(next_filter),
    .next_row(next_row)
);


endmodule