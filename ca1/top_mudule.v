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
    );

    controller ctrl
    (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done)
    );

endmodule