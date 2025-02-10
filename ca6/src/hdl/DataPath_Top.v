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
    parameter INIT_FILE_SRAM = "",

    // OFSET
    parameter OFFSET_RESALRG = 0,
    parameter OFFSET_IFG = 0,
    parameter OFFSET_FILTER = 0,    

    // FOR_CO
    parameter FOR_CO_RESALRG = 3,
    parameter FOR_CO_IFG = 3,
    parameter FOR_CO_FILTER = 3,

    // ADDR_GEN
    parameter IFG_CNT = 1,
    parameter FILTER_CNT = 1
    

) (
    input wire clk,
    input wire rst,

    input wire start,
    input wire start_PE,

    input wire mode,
    input wire [2:0] ifmap_wen,

    input wire filt_len,
    input wire stride_len,

    input wire sel_addr_SRAM,

    input wire [31:0] inData,

    output wire [31:0] outData,
    output wire done_all,

    output wire co_ifG,
    output wire co_onehot
);
    
    // SRAM
    wire [ADDR_WIDTH_SRAM-1:0] read_addr_SRAM;
    wire [DATA_WIDTH_SRAM-1:0] read_data_SRAM;
    wire [ADDR_WIDTH_SRAM-1:0] write_addr_SRAM;

    SRAM #(
        .ADDR_WIDTH(ADDR_WIDTH_SRAM),
        .DATA_WIDTH(DATA_WIDTH_SRAM),
        .INIT_FILE(INIT_FILE_SRAM),
    ) SRAM (
        .read_addr(read_addr_SRAM),
        .read_data(read_data_SRAM),
        .write_addr(write_addr_SRAM),
        .write_enable(~result_empty[2]),
        .write_data(outbuf_dout),
        .clk(clk)
    );

    
    wire [2:0] filter_wen;

    // PE
    wire [outbuf_par_read * (IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH + 1) - 1 : 0] outbuf_dout [2:0];
    wire result_ren [1:0];
    wire result_empty [2:0];
    wire inpsum_buf_full [2:0];
    wire done [2:0];


    // PE 1
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
        // input
        .clk(clk),
        .rst(rst),
        .start(start_PE),

        .IF_wen(ifmap_wen[0]),           // if_wen
        .IF_din(read_data_SRAM), // ifdata
        .filter_wen(filter_wen[0]),         // filt_wen
        .filter_din(read_data_SRAM), // filtdata

        .outbuf_ren(result_ren[0]),          // res_Ren

        // output
        .outbuf_dout(outbuf_dout[0]),        // res_out

        .IF_full(/**/),
        .IF_empty(/**/),
        .filter_full(/**/),
        .filter_empty(/**/),

        .outbuf_full(),
        .outbuf_empty(result_empty[0]),       // res_empty

        // input
        .mode(mode),
        .outbuf_write_flag(1'b0),

        .inpsum_buf_wen(~inpsum_buf_full[0]),
        .filt_len(filt_len),
        .stride_len(stride_len),
        .inpsum_buf_inval({{INPUT_PSUM_WIDTH - 1}'b0}),

        // output
        .inpsum_buf_full(inpsum_buf_full[0]),
        .ready_to_get(done[0]),
        .psum_sc_out(/**/),

        // input
        .see_inside_psum_sc_counter(1'b0),
        .inside_psum_sc_flag(1'b0)
    );


    // PE 2
    PE PE2 #(
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
        // input
        .clk(clk),
        .rst(rst),
        .start(start_PE),

        .IF_wen(ifmap_wen[1]),           // if_wen
        .IF_din(read_data_SRAM), // ifdata
        .filter_wen(filter_wen[1]),         // filt_wen
        .filter_din(read_data_SRAM), // filtdata

        .outbuf_ren(result_ren[1]),          // res_Ren

        // output
        .outbuf_dout(outbuf_dout[1]),        // res_out

        .IF_full(/**/),
        .IF_empty(/**/),
        .filter_full(/**/),
        .filter_empty(/**/),

        .outbuf_full(),
        .outbuf_empty(result_empty[1]),       // res_empty

        // input
        .mode(mode),
        .outbuf_write_flag(1'b0),

        .inpsum_buf_wen(result_ren[0]),
        .filt_len(filt_len),
        .stride_len(stride_len),
        .inpsum_buf_inval(outbuf_dout[0]),

        // output
        .inpsum_buf_full(inpsum_buf_full[1]),
        .ready_to_get(done[1]),
        .psum_sc_out(/**/),

        // input
        .see_inside_psum_sc_counter(1'b0),
        .inside_psum_sc_flag(1'b0)
    );

    // PE 3
    PE PE3 #(
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
        // input
        .clk(clk),
        .rst(rst),
        .start(start_PE),

        .IF_wen(ifmap_wen[2]),           // if_wen
        .IF_din(read_data_SRAM), // ifdata
        .filter_wen(filter_wen[2]),         // filt_wen
        .filter_din(read_data_SRAM), // filtdata

        .outbuf_ren(~result_empty[2]),          // res_Ren

        // output
        .outbuf_dout(outbuf_dout[2]),        // res_out

        .IF_full(/**/),
        .IF_empty(/**/),
        .filter_full(/**/),
        .filter_empty(/**/),

        .outbuf_full(/**/),
        .outbuf_empty(result_empty[2]),       // res_empty

        // input
        .mode(mode),
        .outbuf_write_flag(1'b0),

        .inpsum_buf_wen(result_ren[1]),
        .filt_len(filt_len),
        .stride_len(stride_len),
        .inpsum_buf_inval(outbuf_dout[1]),

        // output
        .inpsum_buf_full(inpsum_buf_full[2]),
        .ready_to_get(done[2]),
        .psum_sc_out(/**/),

        // input
        .see_inside_psum_sc_counter(1'b0),
        .inside_psum_sc_flag(1'b0)
    );


    // resalrG
    AddressCounter #(
        .ADDR_WIDTH(ADDR_WIDTH_SRAM),
        .OFFSET(OFFSET_RESALRG),
        .FOR_CO(FOR_CO_RESALRG)
    ) resalrG (
        .clk(clk),
        .reset(rst),
        .enable(~result_empty[2]),
        .addr(write_addr_SRAM)
    );


    // IFG
    wire [ADDR_WIDTH_SRAM-1:0] out_IFG;
    wire IFG_co;
    AddressCounter #(
        .ADDR_WIDTH(ADDR_WIDTH_SRAM),
        .OFFSET(OFFSET_IFG),
        .FOR_CO(FOR_CO_IFG)
    ) IFG (
        .clk(clk),
        .reset(rst),
        .enable(IFG_CNT),
        .addr(out_IFG),
        .co(IFG_co)
    );

    // FILTER
    wire [ADDR_WIDTH_SRAM-1:0] out_FILTERG;
    wire FILTERG_co;

    AddressCounter #(
        .ADDR_WIDTH(ADDR_WIDTH_SRAM),
        .OFFSET(OFFSET_FILTER),
        .FOR_CO(FOR_CO_FILTER)
    ) FILTERG (
        .clk(clk),
        .reset(rst),
        .enable(FILTER_CNT),
        .addr(out_FILTER),
        .co(FILTERG_co)
    );

    assign read_addr_SRAM = (sel_addr_SRAM) ? out_IFG : out_FILTERG;


    // OneHotCounter
    OneHotCounter #(
        .WIDTH(3)
    ) onehot (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .count(FILTERG_co),
        .one_hot(filter_wen),

        .co(co_onehot)
    );

    assign done_all = done[0] && done[1] && done[2];
    assign co_ifG = IFG_co;

endmodule