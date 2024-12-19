module dp #(
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
    input [STRIDE_SIZE-1:0] stride,
    input [FILTER_SIZE_REG_SIZE-1:0] filter_size,
    input [(IFMAP_WIDTH * PAR_WRITE_IFMAP)-1:0] IFMap_in,
    input [(FILTER_WIDTH * PAR_WRITE_FILTER)-1:0] Filter_in,

    input wen_IFMap_buffer,
    input wen_Filter_buffer,
    input ren_Psum_buffer,
    input chip_en,

    // controller
    input ld_stride,
    input ld_filterSize,
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

    output [(IFMAP_WIDTH - 2)-1:0] Psum_out,
    output done
);

wire [IFMAP_WIDTH-1:0] IFMap_scratch_pad_out;
wire [IFMAP_POINTER_SIZE-1:0] IFMap_read_pointer;
wire [IFMAP_POINTER_SIZE-1:0] IFMap_write_pointer;
wire [IFMAP_POINTER_SIZE-1:0] len_counter_out;
wire [STRIDE_SIZE-1:0] stride_IFMap_cntl_out;
wire inc_len, dec_len;
wire wen_IFMap_cntr, wen_IFMap_src_pad;

wire [STRIDE_SIZE-1:0] stride_reg_out;
wire [FILTER_SIZE_REG_SIZE-1:0] filter_size_out;

Register #(STRIDE_SIZE) stride_reg(clk, rst, ld_stride, stride, stride_reg_out);
Register #(FILTER_SIZE_REG_SIZE) filter_reg(clk, rst, ld_filterSize, filter_size, filter_size_out);

// IFMap

wire [IFMAP_WIDTH-1:0] IFMap_buffer_out;
wire av_input, IFMap_full;

// Fifo_buffer #(
//     .DATA_WIDTH(IFMAP_WIDTH),
//     .PAR_WRITE(PAR_WRITE_IFMAP),
//     .PAR_READ(1),
//     .DEPTH(IFMAP_BUFFER_DEPTH)
// ) IFMap_buffer (
//     .clk(clk),
//     .rstn(!rst),
//     .clear(clear_sum),
//     .ren(wen_IFMap_src_pad),
//     .wen(wen_IFMap_buffer),
//     .din(IFMap_in),
//     .dout(IFMap_buffer_out),
//     .empty(IFMap_empty),
//     .full(IFMap_full)
// );

FIFOBuf2 #(
    .ADDR_WIDTH(50),
    .DATA_WIDTH(IFMAP_WIDTH),
    .DEPTH(IFMAP_BUFFER_DEPTH),
    .PAR_WRITE(PAR_WRITE_IFMAP),
    .PAR_READ(1)
) IFMap_buffer (
    .clk(clk),
    .rst(rst),
    .read_enable(wen_IFMap_src_pad),
    .write_enable(wen_IFMap_buffer),
    .din(IFMap_in),
    .ready(IFMap_full),
    .valid(av_input),
    .dout(IFMap_buffer_out)
);

wire ld_start_row;
wire stride_en;

Read_Controller_IFMap #(
    .POINTER_SIZE(IFMAP_POINTER_SIZE),
    .STRIDE_SIZE(STRIDE_SIZE),
    .IFMAP_SIZE(IFMAP_SPAD_ROW)
) IFMap_controller (
    .read_pointer(IFMap_read_pointer),
    .write_pointer(IFMap_write_pointer),
    .next_row(next_row),
    .end_row(IFMap_scratch_pad_out[IFMAP_WIDTH - 2]),
    .co_filter(co_filter),
    .len_counter(len_counter_out),
    .av_input(av_input),

    .av_data(av_data),
    .end_of_row(end_of_row),
    .ld_start_row(ld_start_row),
    .write_counter_en(wen_IFMap_cntr),
    .stride_en(stride_en),
    .inc_len(inc_len),
    .dec_len(dec_len),
    .write_en_src_pad(wen_IFMap_src_pad)
);

wire [IFMAP_POINTER_SIZE-1:0] start_row_reg_out;
Register #(IFMAP_POINTER_SIZE) start_row_reg (clk, rst, ld_start_row, IFMap_read_pointer, start_row_reg_out);

ReadAddressGeneratorIF #(
    .POINTER_SIZE(IFMAP_POINTER_SIZE),
    .FILTER_SIZE_REG_SIZE(FILTER_SIZE_REG_SIZE),
    .STRIDE_SIZE(STRIDE_SIZE)
) IFMap_address_generator (
    .clk(clk),
    .rst(rst),
    .stride(stride_reg_out),
    .filter_size(filter_size_out),
    .next_row(next_row),
    .put_data(put_data),
    .start_row(start_row_reg_out),
    .end_of_row(end_of_row),

    .read_pointer(IFMap_read_pointer)
);

Counter #(.WIDTH(IFMAP_POINTER_SIZE)
) IFMap_write_cntr (
    .clk(clk),
    .rst(rst),
    .en(wen_IFMap_cntr),
    .counter(IFMap_write_pointer)
);


IFMapSratchPad #(
    .IFMAP_SPAD_WIDTH(IFMAP_WIDTH),
    .IFMAP_SPAD_ROW(IFMAP_SPAD_ROW)
) IFMap_scratch_pad (
    .clk(clk),
    .rst(rst),
    .din(IFMap_buffer_out),  
    .raddr(IFMap_read_pointer),
    .waddr(IFMap_write_pointer),
    .wen(wen_IFMap_src_pad),

    .dout(IFMap_scratch_pad_out)
);


len_check #(
    .WIDTH(IFMAP_POINTER_SIZE)
) lencheck (
    .clk(clk),
    .rst(rst),
    .up_enable(inc_len),
    .down_enable(dec_len),

    .count(len_counter_out)
);

wire [IFMAP_WIDTH-3:0] IFMap_scratch_pad_reg_out;
wire stall_line0;
wire done_line0;
wire co_filter_line0;
Pipeline1 #(
    .DATA_WIDTH(IFMAP_WIDTH - 2)
) line0 (
    .clk(clk),
    .rst(rst),
    .stall_in(!put_data),
    .done_in(end_of_row && end_of_filter),
    .in(IFMap_scratch_pad_out[IFMAP_WIDTH - 3:0]),
    .co_filter(co_filter),

    .out(IFMap_scratch_pad_reg_out),
    .stall_out(stall_line0),
    .done_out(done_line0),
    .co_filter_out(co_filter_line0)
);

/////////////////////////////////////////////////////////////////////////////////////////


// Filter

wire [FILTER_WIDTH-1:0] Filter_buffer_out;
wire Filter_empty, Filter_full;

// Fifo_buffer #(
//     .DATA_WIDTH(FILTER_WIDTH),
//     .PAR_WRITE(PAR_WRITE_FILTER),
//     .PAR_READ(1),
//     .DEPTH(FILTER_BUFFER_DEPTH)
// ) Filter_buffer (
//     .clk(clk),
//     .rstn(!rst),
//     .clear(clear_sum),
//     .ren(wen_Filter_src_pad),
//     .wen(wen_Filter_buffer),
//     .din(Filter_in),
//     .dout(Filter_buffer_out),
//     .empty(Filter_empty),
//     .full(Filter_full)
// );

wire ready_Filter, valid_Filter;
assign Filter_empty = !ready_Filter;
assign Filter_full = !valid_Filter;

FIFOBuf2 #(
    .ADDR_WIDTH(50),
    .DATA_WIDTH(FILTER_WIDTH),
    .DEPTH(FILTER_BUFFER_DEPTH),
    .PAR_WRITE(PAR_WRITE_FILTER),
    .PAR_READ(1)
) Filter_buffer (
    .clk(clk),
    .rst(rst),
    .read_enable(wen_Filter_src_pad),
    .write_enable(wen_Filter_buffer),
    .din(Filter_in),
    .ready(ready_Filter),
    .valid(valid_Filter),
    .dout(Filter_buffer_out)
);


wire [FILTER_POINTER_SIZE-1:0] Filter_write_pointer;
wire [FILTER_POINTER_SIZE-1:0] Filter_read_pointer;

Read_Controller_Filter #(
    .SP_SIZE(FILTER_WIDTH),
    .FILTER_SIZE_REG_SIZE(FILTER_SIZE_REG_SIZE),
    .POINTER_SIZE(FILTER_POINTER_SIZE)
) Filter_controller (
    .co_filter(co_filter),
    .av_input(valid_Filter),
    .filter_size(filter_size_out),
    .write_pointer(Filter_write_pointer),
    .read_pointer(Filter_read_pointer),

    .write_en_src_pad(wen_Filter_src_pad),
    .write_counter_en(wen_Filter_cntr),
    .end_of_filter(end_of_filter),
    .av_filter(av_filter)
);

Counter #(.WIDTH(FILTER_POINTER_SIZE)) Filter_write_cntr (
    .clk(clk),
    .rst(rst),
    .en(wen_Filter_cntr),
    .counter(Filter_write_pointer)
);


wire [FILTER_WIDTH-1:0] Filter_scratch_pad_out;
FilterScraratchPad #(
    .FILTER_WIDTH(FILTER_WIDTH),
    .FILTER_ROW(FILTER_SPAD_ROW)
) Filter_scratch_pad (
    .clk(clk),
    .rst(rst),
    .din(Filter_buffer_out),
    .raddr(Filter_read_pointer),
    .waddr(Filter_write_pointer),
    .ren(put_filter),
    .wen(wen_Filter_src_pad),
    .chip_en(chip_en),

    .dout(Filter_scratch_pad_out)
);

ReadAddressGeneratorFilter #(
    .SP_SIZE(FILTER_WIDTH),
    .FILTER_SIZE_REG_SIZE(FILTER_SIZE_REG_SIZE),
    .POINTER_SIZE(FILTER_POINTER_SIZE)
) Filter_address_generator (
    .clk(clk),
    .rst(rst),
    .filter_size(filter_size_out),
    .put_filter(put_filter),
    .next_filter(next_filter),
    .end_of_filter(end_of_filter),

    .co_filter(co_filter),
    .read_pointer(Filter_read_pointer)  
);

////////////////////////////////////////////////////////////////////////////////////////

wire [IFMAP_WIDTH + FILTER_WIDTH - 3:0] mult_out;
assign mult_out = Filter_scratch_pad_out * IFMap_scratch_pad_reg_out;

wire [IFMAP_WIDTH-3:0] out_line1;
wire stall_line1;
wire done_line1;
wire co_filter_line1;
Pipeline1 #(
    .DATA_WIDTH(IFMAP_WIDTH - 2)
) line1 (
    .clk(clk),
    .rst(rst),
    .stall_in(stall_line0),
    .done_in(done_line0),
    .in(mult_out[IFMAP_WIDTH - 3:0]),
    .co_filter(co_filter_line0),

    .out(out_line1),
    .stall_out(stall_line1),
    .done_out(done_line1),
    .co_filter_out(co_filter_line1)
);

wire [IFMAP_WIDTH-3:0] out_line2;

wire [IFMAP_WIDTH-3:0] out_sum;
assign out_sum = out_line1 + out_line2;

wire stall_line2;
wire done_line2;
wire co_filter_line2;
Pipeline2 #(
    .DATA_WIDTH(IFMAP_WIDTH-2)
) line2 (
    .clk(clk),
    .rst(rst),
    .stall_in(stall_line1),
    .done_in(done_line1),
    .in(out_sum),
    .co_filter(co_filter_line1),

    .out(out_line2),
    .stall_out(stall_line2),
    .done_out(done_line2),
    .co_filter_out(co_filter_line2)
);

wire sum_empty, sum_full;

// Fifo_buffer #(
//     .DATA_WIDTH(IFMAP_WIDTH-2),
//     .PAR_WRITE(1),
//     .PAR_READ(1),
//     .DEPTH(PSUM_DEPTH)
// ) Sum_buffer (
//     .clk(clk),
//     .rstn(!rst),
//     .clear(clear_sum),
//     .ren(ren_Psum_buffer),
//     .wen(co_filter_line2),
//     .din(out_line2),

//     .dout(Psum_out),
//     .empty(sum_empty),
//     .full(sum_full)
// );

wire ready_sum, valid_sum;
assign sum_empty = !ready_sum;
assign sum_full = !valid_sum;

FIFOBuf2 #(
    .ADDR_WIDTH(50),
    .DATA_WIDTH(IFMAP_WIDTH-2),
    .DEPTH(PSUM_DEPTH),
    .PAR_WRITE(1),
    .PAR_READ(1)
) Sum_buffer (
    .clk(clk),
    .rst(rst),
    .read_enable(ren_Psum_buffer),
    .write_enable(co_filter_line2),
    .din(out_line2),
    .ready(ready_sum),
    .valid(valid_sum),
    .dout(Psum_out)
);

endmodule