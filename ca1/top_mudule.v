module top_module (
    input clk,
    input rst,
    input start,
    output done
);
    // counter
    wire cntr_ld_init;
    wire cntr_ld_en;
    wire cntr_sh_en;
    wire cntr_sh_ld;
    wire cntr_sh1_en;
    wire cntr_sh2_en;

    // shift
    wire en_sh_16bit;
    wire sh_result_ld;
    wire sh_result_shift;

    // ram
    wire wr_out_ram;

    wire lsb_cnt;

    wire co_cnt_sh;
    wire co_cntr_ld; 
    wire cntr_sh1_init;
    wire cntr_sh2_init;

    wire end_shift1;
    wire end_shift2;

    datapath dp
    (
        .clk(clk),
        .rst(rst),

        // input
        .cntr_ld_init(cntr_ld_init),
        .cntr_ld_en(cntr_ld_en),
        .cntr_sh_en(cntr_sh_en),
        .cntr_sh_ld(cntr_sh_ld),
        .cntr_sh1_en(cntr_sh1_en),
        .cntr_sh2_en(cntr_sh2_en),

        .en_sh_16bit(en_sh_16bit),
        .sh_result_ld(sh_result_ld),
        .sh_result_shift(sh_result_shift),

        .wr_out_ram(wr_out_ram),

        // output
        .lsb_cnt(lsb_cnt),

        .co_cnt_sh(co_cnt_sh),
        .co_cntr_ld(co_cntr_ld), 
        .cntr_sh1_init(cntr_sh1_init),
        .cntr_sh2_init(cntr_sh2_init),

        .end_shift1(end_shift1),
        .end_shift2(end_shift2) 
    );

    controller ctrl
    (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),

        .lsb_cnt(lsb_cnt),
        .end_shift1(end_shift1),
        .end_shift2(end_shift2),
        .co_cnt_sh(co_cnt_sh),

        .initial_cnt_load(cntr_ld_init),
        .initial_cnt_sh(cntr_sh_en),
        .initial_cnt_sh1(cntr_sh1_init),
        .initial_cnt_sh2(cntr_sh2_init),
        .load_shift_16(en_sh_16bit),
        .en_cnt_load(cntr_ld_en),
        .en_cnt_sh1(cntr_sh1_en),
        .en_cnt_sh2(cntr_sh2_en),
        .load_result(sh_result_ld),
        .shift_result(sh_result_shift),
        .wr_ram(wr_out_ram)
    );

endmodule