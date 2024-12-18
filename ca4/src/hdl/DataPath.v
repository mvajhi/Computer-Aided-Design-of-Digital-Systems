module dp #(
    parameter IFMAP_BUFFER_WIDTH = 18,
    parameter IFMAP_POINTER_SIZE = 8,
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
wire IFMap_empty;

Fifo_buffer #(
    .DATA_WIDTH(IFMAP_BUFFER_WIDTH),
    .PAR_WRITE(PAR_WRITE_IFMAP),
    .PAR_READ(1),
    .DEPTH(FILTER_BUFFER_DEPTH)
) IFMap_buffer (
    .clk(clk),
    .rstn(rst),
    .clear(clear_sum),
    .ren(/**/),
    .wen(wen_IFMap),
    .din(IFMap_in),
    .dout(IFMap_buffer_out),
    .empty(IFMap_empty)
);


Read_Controller_IFMap #(
    .POINTER_SIZE(IFMAP_POINTER_SIZE),
    .STRIDE_SIZE(STRIDE_SIZE)
) IFMap_controller (
    .read_pointer(/**/),
    .write_pointer(/**/),
    .next_row(next_row),
    .end_row(IFMap_buffer_out[IFMAP_BUFFER_WIDTH-2]),
    .co_filter(co_filter),
    .len_counter(/**/),
    .av_input(!IFMap_empty),

    .av_data(av_data),
    .end_of_row(end_of_row),
    .ld_start_row(/**/),
    .write_counter_en(/**/),
    .stride(stride_IFMap_cntl_out),
    .inc_len(/**/),
    .dec_len(/**/),
    .write_en_src_pad(/**/)
);

wire [IFMAP_POINTER_SIZE-1:0] IFMap_read_pointer;

ReadAddressGeneratorIF #(
    .POINTER_SIZE(IFMAP_POINTER_SIZE),
    .FILTER_SIZE_REG_SIZE(FILTER_SIZE_REG_SIZE),
    .STRIDE_SIZE(STRIDE_SIZE)
) IFMap_address_generator (
    .clk(clk),
    .rst(rst),
    .stride(stride_IFMap_cntl_out),
    .filter_size(filter_size_out),
    .next_row(next_row),
    .put_data(put_data),

    .read_pointer(IFMap_read_pointer)
);

wire [IFMAP_POINTER_SIZE-1:0] IFMap_write_pointer;

Counter #(.WIDTH(IFMAP_POINTER_SIZE)
) IFMap_write_cntr (
    .clk(clk),
    .rst(rst),
    .en(/**/),
    .counter(IFMap_write_pointer)
);



endmodule