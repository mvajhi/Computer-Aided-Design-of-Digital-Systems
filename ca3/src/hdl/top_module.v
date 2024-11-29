module top_module (
    input clk,
    input rst,
    input start,

    input [15:0] in1,
    input [15:0] in2,

    output [31:0] result,
    output done
);

    wire cntr_3bit_en;
    wire cntr_dual_en;
    wire cntr_dual_end;

    wire load_shift1;
    wire load_shift2;
    wire en_shift1;
    wire en_shift2;
    wire sel_sh1;
    wire sel_insh2;
    wire sel_sh2;

    wire cntr_dual_co;
    wire end_shift1;
    wire end_shift2;

    datapath dp (
        .clk(clk),
        .rst(rst),
        .in1(in1),
        .in2(in2),

        .cntr_3bit_en(cntr_3bit_en),
        .cntr_dual_en(cntr_dual_en),
        .cntr_dual_end(cntr_dual_end),

        .load_shift1(load_shift1),
        .load_shift2(load_shift2),
        .en_shift1(en_shift1),
        .en_shift2(en_shift2),
        .sel_sh1(sel_sh1),  
        .sel_insh2(sel_insh2),
        .sel_sh2(sel_sh2),

        .cntr_dual_co(cntr_dual_co),
        .end_shift1(end_shift1),
        .end_shift2(end_shift2),

        .result(result)
    );

    controller ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),

        .cntr_dual_co(cntr_dual_co),
        .end_shift1(end_shift1),
        .end_shift2(end_shift2),

        .cntr_3bit_en(cntr_3bit_en),
        .cntr_dual_en(cntr_dual_en),    
        .cntr_dual_end(cntr_dual_end),

        .load_shift1(load_shift1),
        .load_shift2(load_shift2),
        .en_shift1(en_shift1),
        .en_shift2(en_shift2),
        .sel_sh1(sel_sh1),
        .sel_insh2(sel_insh2),
        .sel_sh2(sel_sh2),

        .done(done)
    );

endmodule