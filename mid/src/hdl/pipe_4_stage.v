module pipe_4_stage #(
    parameter RAM_VALUE_0_STAGE1 = 32'h7FFFFFFF,
    parameter RAM_VALUE_1_STAGE1 = 32'h19999999,
    parameter RAM_VALUE_0_STAGE2 = 32'hC0000000,
    parameter RAM_VALUE_1_STAGE2 = 32'hF5555555,
    parameter RAM_VALUE_0_STAGE3 = 32'h2AAAAAAA,
    parameter RAM_VALUE_1_STAGE3 = 32'h12492800,
    parameter RAM_VALUE_0_STAGE4 = 32'hE0000000,
    parameter RAM_VALUE_1_STAGE4 = 32'hF0000000,
    parameter N = 3'b111
) (
    input         clk,
    input         rst,
    input  [31:0] in_x,
    input  [31:0] in_num,
    input  [31:0] in_sum,
    input         in_overflow,
    input  [2:0]       in_i,
    input         in_valid,
    input         in_flag_next,
    output        out_flag_next,
    output        out_valid,
    output [2:0]       out_i,
    output [31:0] out_sum,
    output [31:0] out_num,
    output [31:0] out_x,
    output        out_overflow
);
    wire [2:0]  state1_out_i, state2_out_i, state3_out_i, state4_out_i;
    wire [2:0]  state1_reg_i, state2_reg_i, state3_reg_i, state4_reg_i;
    wire        state1_reg_valid, state2_reg_valid, state3_reg_valid, state4_reg_valid;
    wire        state1_flag_next, state2_flag_next, state3_flag_next, state4_flag_next;
    wire [31:0] stage1_out_x, stage1_out_num, stage1_out_sum;
    wire [31:0] stage2_out_x, stage2_out_num, stage2_out_sum;
    wire [31:0] stage3_out_x, stage3_out_num, stage3_out_sum;
    wire        out_overflow_stage1, out_overflow_stage2, out_overflow_stage3;
    wire [31:0] stage1_reg_x, stage1_reg_num, stage1_reg_sum;
    wire [31:0] stage2_reg_x, stage2_reg_num, stage2_reg_sum;
    wire [31:0] stage3_reg_x, stage3_reg_num, stage3_reg_sum;
    wire stage1_reg_overflow, stage2_reg_overflow, stage3_reg_overflow;

    pipe_slice_dp #(
        .RAM_VALUE_0(RAM_VALUE_0_STAGE1),
        .RAM_VALUE_1(RAM_VALUE_1_STAGE1),
        .N(N)
    ) stage1 (
        .in_x(in_x),
        .in_num(in_num),
        .in_sum(in_sum),
        .in_overflow(in_overflow),
        .out_sum(stage1_out_sum),
        .out_num(stage1_out_num),
        .out_x(stage1_out_x),
        .out_overflow(out_overflow_stage1),
        .in_i(in_i),
        .out_i(state1_out_i)
    );

    dp_reg S1to2 (
        .clk(clk),
        .rst(rst),
        .in_x(stage1_out_x),
        .in_num(stage1_out_num),
        .in_sum(stage1_out_sum),
        .in_overflow(out_overflow_stage1),
        .out_x(stage1_reg_x),
        .out_num(stage1_reg_num),
        .out_sum(stage1_reg_sum),
        .out_overflow(stage1_reg_overflow),
        .in_i(state1_out_i),
        .out_i(state1_reg_i),
        .in_flag_next(in_flag_next),
        .in_valid(in_valid),
        .out_flag_next(state2_flag_next),
        .out_valid(state2_reg_valid)
    );

    pipe_slice_dp #(
        .RAM_VALUE_0(RAM_VALUE_0_STAGE2),
        .RAM_VALUE_1(RAM_VALUE_1_STAGE2),
        .N(N)
    ) stage2 (
        .in_x(stage1_reg_x),
        .in_num(stage1_reg_num),
        .in_sum(stage1_reg_sum),
        .in_overflow(stage1_reg_overflow),
        .out_sum(stage2_out_sum),
        .out_num(stage2_out_num),
        .out_x(stage2_out_x),
        .out_overflow(out_overflow_stage2),
        .in_i(state1_reg_i),
        .out_i(state2_out_i)
    );

    dp_reg S2to3 (
        .clk(clk),
        .rst(rst),
        .in_x(stage2_out_x),
        .in_num(stage2_out_num),
        .in_sum(stage2_out_sum),
        .in_overflow(out_overflow_stage2),
        .out_x(stage2_reg_x),
        .out_num(stage2_reg_num),
        .out_sum(stage2_reg_sum),
        .out_overflow(stage2_reg_overflow),
        .in_i(state2_out_i),
        .out_i(state2_reg_i),
        .in_flag_next(state2_flag_next),
        .in_valid(state2_reg_valid),
        .out_flag_next(state3_flag_next),
        .out_valid(state3_reg_valid)
    );

    pipe_slice_dp #(
        .RAM_VALUE_0(RAM_VALUE_0_STAGE3),
        .RAM_VALUE_1(RAM_VALUE_1_STAGE3),
        .N(N)
    ) stage3 (
        .in_x(stage2_reg_x),
        .in_num(stage2_reg_num),
        .in_sum(stage2_reg_sum),
        .in_overflow(stage2_reg_overflow),
        .out_sum(stage3_out_sum),
        .out_num(stage3_out_num),
        .out_x(stage3_out_x),
        .out_overflow(out_overflow_stage3),
        .in_i(state2_reg_i),
        .out_i(state3_out_i)
    );

    dp_reg S3to4 (
        .clk(clk),
        .rst(rst),
        .in_x(stage3_out_x),
        .in_num(stage3_out_num),
        .in_sum(stage3_out_sum),
        .in_overflow(out_overflow_stage3),
        .out_x(stage3_reg_x),
        .out_num(stage3_reg_num),
        .out_sum(stage3_reg_sum),
        .out_overflow(stage3_reg_overflow),
        .in_i(state3_out_i),
        .out_i(state3_reg_i),
        .in_flag_next(state3_flag_next),
        .in_valid(state3_reg_valid),
        .out_flag_next(out_flag_next),
        .out_valid(out_valid)
    );

    pipe_slice_dp #(
        .RAM_VALUE_0(RAM_VALUE_0_STAGE4),
        .RAM_VALUE_1(RAM_VALUE_1_STAGE4),
        .N(N)
    ) stage4 (
        .in_x(stage3_reg_x),
        .in_num(stage3_reg_num),
        .in_sum(stage3_reg_sum),
        .in_overflow(stage3_reg_overflow),
        .out_sum(out_sum),
        .out_num(out_num),
        .out_x(out_x),
        .out_overflow(out_overflow),
        .in_i(state3_reg_i),
        .out_i(out_i)
    );

endmodule
