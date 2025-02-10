`default_nettype none

module design_top #(
    parameter FILT_ADDR_LEN,
    parameter IF_ADDR_LEN,
    parameter IF_SCRATCH_DEPTH,
    parameter IF_SCRATCH_WIDTH,
    parameter FILT_SCRATCH_DEPTH,
    parameter FILT_SCRATCH_WIDTH,
    parameter IF_par_write,
    parameter filter_par_write,
    parameter outbuf_par_read,
    parameter IF_BUFFER_DEPTH,
    parameter FILT_BUFFER_DEPTH,
    parameter OUT_BUFFER_DEPTH,
    parameter PSUM_SC_ADDR_LEN,
    parameter PSUM_SC_DEPTH,
    parameter INPUT_PSUM_WIDTH,
    parameter INPUT_PSUM_DEPTH)
    (
    input wire clk,
    input wire rst,
    input wire start,
    input wire IF_wen,
    input wire [IF_par_write * (IF_SCRATCH_WIDTH + 2) - 1 : 0] IF_din,
    input wire filter_wen,
    input wire [filter_par_write * FILT_SCRATCH_WIDTH - 1 : 0] filter_din,
    input wire outbuf_ren,
    output wire [outbuf_par_read * (IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH + 1) - 1 : 0] outbuf_dout,
    output wire IF_full,
    output wire IF_empty,
    output wire filter_full,
    output wire filter_empty,
    output wire outbuf_full,
    output wire outbuf_empty,
    input wire[1:0] mode,
    input wire outbuf_write_flag,
    input wire inpsum_buf_wen,
    input wire [FILT_ADDR_LEN - 1:0] filt_len,
    input wire [IF_ADDR_LEN - 1:0] stride_len,
    input wire [INPUT_PSUM_WIDTH - 1:0] inpsum_buf_inval,
    output wire inpsum_buf_full,
    output wire ready_to_get,
    output wire [FILT_SCRATCH_WIDTH + IF_SCRATCH_WIDTH:0] psum_sc_out,
    input wire [PSUM_SC_ADDR_LEN - 1:0] see_inside_psum_sc_counter,
    input wire inside_psum_sc_flag
);

// Internal wires
wire IF_read_start, filter_read_start, regs_clr, start_rd_gen, reset_all;
wire IF_buf_read, filter_buf_read, full_done, psum_sc_done;
wire stride_count_flag, outbuf_write;
wire [IF_SCRATCH_WIDTH + 1:0] IF_buf_inp;
wire [FILT_SCRATCH_WIDTH - 1:0] filter_buf_inp;
wire [IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH:0] module_outval;
wire inpsum_buf_ren;
wire [INPUT_PSUM_WIDTH - 1:0] inpsum_buf_outval;
wire inpsum_buf_empty;

// IF Buffer
Fifo_buffer #(
    .DATA_WIDTH(IF_SCRATCH_WIDTH + 2),
    .PAR_WRITE(IF_par_write),
    .PAR_READ(1),
    .DEPTH(IF_BUFFER_DEPTH)
) IF_buffer (
    .clk(clk),
    .rstn(~rst),
    .clear(1'b0),
    .ren(IF_buf_read),
    .wen(IF_wen),
    .din(IF_din),
    .dout(IF_buf_inp),
    .full(IF_full),
    .empty(IF_empty)
);

// Filter Buffer
Fifo_buffer #(
    .DATA_WIDTH(FILT_SCRATCH_WIDTH),
    .PAR_WRITE(filter_par_write),
    .PAR_READ(1),
    .DEPTH(FILT_BUFFER_DEPTH)
) filter_buffer (
    .clk(clk),
    .rstn(~rst),
    .clear(1'b0),
    .ren(filter_buf_read),
    .wen(filter_wen),
    .din(filter_din),
    .dout(filter_buf_inp),
    .full(filter_full),
    .empty(filter_empty)
);

// Output Buffer
Fifo_buffer #(
    .DATA_WIDTH(IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH + 1),
    .PAR_WRITE(1),
    .PAR_READ(outbuf_par_read),
    .DEPTH(OUT_BUFFER_DEPTH)
) out_buffer (
    .clk(clk),
    .rstn(~rst),
    .clear(1'b0),
    .ren(outbuf_ren),
    .wen(outbuf_write),
    .din(module_outval),
    .dout(outbuf_dout),
    .full(outbuf_full),
    .empty(outbuf_empty)
);

// input psum Buffer
Fifo_buffer #(
    .DATA_WIDTH(INPUT_PSUM_WIDTH),
    .PAR_WRITE(1),
    .PAR_READ(1),
    .DEPTH(INPUT_PSUM_DEPTH)
) inpsum_buffer (
    .clk(clk),
    .rstn(~rst),
    .clear(1'b0),
    .ren(inpsum_buf_ren),
    .wen(inpsum_buf_wen),
    .din(inpsum_buf_inval),
    .dout(inpsum_buf_outval),
    .full(inpsum_buf_full),
    .empty(inpsum_buf_empty)
);

// Datapath
design_datapath #(
    .FILT_ADDR_LEN(FILT_ADDR_LEN),
    .IF_ADDR_LEN(IF_ADDR_LEN),
    .IF_SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
    .IF_SCRATCH_WIDTH(IF_SCRATCH_WIDTH),
    .FILT_SCRATCH_DEPTH(FILT_SCRATCH_DEPTH),
    .FILT_SCRATCH_WIDTH(FILT_SCRATCH_WIDTH),
    .PSUM_SC_ADDR_LEN(PSUM_SC_ADDR_LEN),
    .PSUM_SC_DEPTH(PSUM_SC_DEPTH),
    .INPUT_PSUM_WIDTH(INPUT_PSUM_WIDTH)
) datapath (
    .clk(clk),
    .rst(rst | reset_all),
    .IF_read_start(IF_read_start),
    .filter_read_start(filter_read_start),
    .regs_clr(regs_clr),
    .IF_buf_empty_flag(IF_empty),
    .filt_buf_empty(filter_empty),
    .start_rd_gen(start_rd_gen),
    .outbuf_full(outbuf_full),
    .mode(mode), // Placeholder for new argument
    .outbuf_write_flag(outbuf_write_flag), // Placeholder for new argument
    .input_psum_val(inpsum_buf_outval), // Placeholder for new argument
    .filt_len(filt_len),
    .stride_len(stride_len),
    .IF_buf_inp(IF_buf_inp),
    .filt_buf_inp(filter_buf_inp),
    .module_outval(module_outval),
    .IF_buf_read(IF_buf_read),
    .filt_buf_read(filter_buf_read),
    .full_done(full_done),
    .psum_sc_done(psum_sc_done),
    .stride_count_flag(stride_count_flag),
    .outbuf_write(outbuf_write),
    .read_inp_sum_buf(inpsum_buf_ren), // Placeholder for new argument
    .ready_to_get(ready_to_get), 
    .inpsum_buf_empty(inpsum_buf_empty),
    .psum_sc_out(psum_sc_out),
    .see_inside_psum_sc_counter(see_inside_psum_sc_counter),
    .inside_psum_sc_flag(inside_psum_sc_flag)
);


// Controller

design_controller #(
    .FILT_ADDR_LEN(FILT_ADDR_LEN),
    .IF_ADDR_LEN(IF_ADDR_LEN),
    .SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
    .SCRATCH_WIDTH(IF_SCRATCH_WIDTH)
) controller (
    .clk(clk),
    .rst(rst),
    .start(start), 
    .full_done(full_done),
    .psum_done(psum_sc_done),
    .stride_count_flag(stride_count_flag),
    .reset_all(reset_all),
    .IF_read_start(IF_read_start),
    .filter_read_start(filter_read_start),
    .clear_regs(regs_clr),
    .start_rd_gen(start_rd_gen),
    .ready_to_get(ready_to_get)
);

endmodule
