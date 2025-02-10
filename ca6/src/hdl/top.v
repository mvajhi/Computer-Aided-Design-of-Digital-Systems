module top #(
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
    parameter FILTER_CNT = 1,
    
    // CONTROLLER
    parameter PE_COUNT = 3

) (
    input clk,
    input rst,
    input start
)
    
    reg co_onehot, co_ifG, done_all;
    reg rst_dp, sel_addr, en_onehot, cnt_filtG, start_pe, cnt_ifG, ifwen, mod;
    
    controller_top #(.PE_COUNT(PE_COUNT)) controller_inst (
        // input
        .clk(clk),
        .rst(rst),
        .start(start),
        .co_onehot(co_onehot),
        .co_ifG(co_ifG),
        .done_all(done_all),

        // output
        .rst_dp(rst_dp),
        .sel_addr(sel_addr),
        .en_onehot(en_onehot),
        .cnt_filtG(cnt_filtG),
        .start_pe(start_pe),
        .cnt_ifG(cnt_ifG),
        .ifwen(ifwen),
        .mod(mod)
    );

    DataPath_Top #(
        .IF_BUFFER_DEPTH(IF_BUFFER_DEPTH),
        .FILT_BUFFER_DEPTH(FILT_BUFFER_DEPTH),
        .OUT_BUFFER_DEPTH(OUT_BUFFER_DEPTH),
        .PSUM_SC_ADDR_LEN(PSUM_SC_ADDR_LEN),
        .PSUM_SC_DEPTH(PSUM_SC_DEPTH),
        .INPUT_PSUM_WIDTH(INPUT_PSUM_WIDTH),
        .INPUT_PSUM_DEPTH(INPUT_PSUM_DEPTH),

        // SRAM
        .ADDR_WIDTH_SRAM(ADDR_WIDTH_SRAM),
        .DATA_WIDTH_SRAM(DATA_WIDTH_SRAM),
        .INIT_FILE_SRAM(INIT_FILE_SRAM),

        // OFSET
        .OFFSET_RESALRG(OFFSET_RESALRG),
        .OFFSET_IFG(OFFSET_IFG),
        .OFFSET_FILTER(OFFSET_FILTER),    

        // FOR_CO
        .FOR_CO_RESALRG(FOR_CO_RESALRG),
        .FOR_CO_IFG(FOR_CO_IFG),
        .FOR_CO_FILTER(FOR_CO_FILTER),

        // ADDR_GEN
        .IFG_CNT(IFG_CNT),
        .FILTER_CNT(FILTER_CNT)
    ) DataPath_Top_inst (
        // input
        .clk(clk),
        .rst(rst),
        .start(start),
        .start_PE(start_pe),
        .mode(mod),
        .ifmap_wen(ifwen),
        .filt_len(filt_len),
        .stride_len(stride_len),
        .sel_addr_SRAM(sel_addr),
        .inData(inData),

        // output
        .outData(outData),
        .done_all(done_all)

        .co_ifG(co_ifG),
        .co_onehot(co_onehot)
    );
endmodule