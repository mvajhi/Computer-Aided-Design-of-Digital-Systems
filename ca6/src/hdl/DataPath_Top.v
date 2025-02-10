module DataPath_Top # (
    // PE
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
    parameter INPUT_PSUM_DEPTH,

    // SRAM
    parameter ADDR_WIDTH_SRAM = 8,
    parameter DATA_WIDTH_SRAM = 16,
    parameter INIT_FILE_SRAM = ""
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire start_PE,
    input wire [31:0] inData,
    output wire [31:0] outData
);
    
    // SRAM
    wire [ADDR_WIDTH_SRAM-1:0] read_addr_SRAM;
    wire [DATA_WIDTH_SRAM-1:0] read_data_SRAM;
    wire [ADDR_WIDTH_SRAM-1:0] write_addr_SRAM;
    wire write_enable_SRAM;
    wire [DATA_WIDTH_SRAM-1:0] write_data_SRAM;

    SRAM #(
        .ADDR_WIDTH(ADDR_WIDTH_SRAM),
        .DATA_WIDTH(DATA_WIDTH_SRAM),
        .INIT_FILE(INIT_FILE_SRAM),
    ) SRAM (
        .read_addr(read_addr_SRAM),
        .read_data(read_data_SRAM),
        .write_addr(write_addr_SRAM),
        .write_enable(write_enable_SRAM),
        .write_data(write_data_SRAM),
        .clk(clk)
    );

    

    // PE 1
    wire [outbuf_par_read * (IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH + 1) - 1 : 0] outbuf_dout_PE1;

    PE PE1 #(
        .FILT_ADDR_LEN(FILT_ADDR_LEN),
        .IF_ADDR_LEN(IF_ADDR_LEN),
        .IF_SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
        .IF_SCRATCH_WIDTH(IF_SCRATCH_WIDTH),
        .FILT_SCRATCH_DEPTH(FILT_SCRATCH_DEPTH),
        .FILT_SCRATCH_WIDTH(FILT_SCRATCH_WIDTH),
        .IF_par_write(IF_par_write),
        .filter_par_write(filter_par_write),
        .outbuf_par_read(outbuf_par_read),
        .IF_BUFFER_DEPTH(IF_BUFFER_DEPTH),
        .FILT_BUFFER_DEPTH(FILT_BUFFER_DEPTH),
        .OUT_BUFFER_DEPTH(OUT_BUFFER_DEPTH),
        .PSUM_SC_ADDR_LEN(PSUM_SC_ADDR_LEN),
        .PSUM_SC_DEPTH(PSUM_SC_DEPTH),
        .INPUT_PSUM_WIDTH(INPUT_PSUM_WIDTH),
        .INPUT_PSUM_DEPTH(INPUT_PSUM_DEPTH)
    ) (
        .clk(clk),
        .rst(rst),
        .start(start_PE),

        .IF_wen(/**/),
        .IF_din(read_data_SRAM),
        .filter_wen(1'b0),
        .filter_din(read_data_SRAM),

        .outbuf_ren(1'b0),
        .outbuf_dout(1'b0),

        .IF_full(1'b0),
        .IF_empty(1'b0),
        .filter_full(1'b0),
        .filter_empty(1'b0),

        .outbuf_full(1'b0),
        .outbuf_empty(1'b0),

        .mode(1'b0),
        .outbuf_write_flag(1'b0),

        .inpsum_buf_wen(inpsum_buf_wen),
        .filt_len(filt_len),
        .stride_len(stride_len),
        .inpsum_buf_inval(inpsum_buf_inval),
        .inpsum_buf_full(inpsum_buf_full),
        .ready_to_get(ready_to_get),
        .psum_sc_out(psum_sc_out),
        .see_inside_psum_sc_counter(see_inside_psum_sc_counter),
        .inside_psum_sc_flag(inside_psum_sc_flag)
    );

endmodule