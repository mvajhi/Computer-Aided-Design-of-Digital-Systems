module pipe_4_stage #(
    parameter RAM_VALUE_0_STAGE1 = 32'h7FFFFFFF,
    parameter RAM_VALUE_1_STAGE1 = 32'h0,
    parameter RAM_VALUE_0_STAGE2 = 32'hC0000000,
    parameter RAM_VALUE_1_STAGE2 = 32'h0,
    parameter RAM_VALUE_0_STAGE3 = 32'h2AAAAAAA,
    parameter RAM_VALUE_1_STAGE3 = 32'b0,
    parameter RAM_VALUE_0_STAGE4 = 32'hE0000000,
    parameter RAM_VALUE_1_STAGE4 = 32'b0
) (
    input         clk,
    input  [31:0] in_x,
    input  [31:0] in_num,
    input  [31:0] in_sum,
    input         addr,
    input         sel_sum,
    output [31:0] out_sum,
    output [31:0] out_num,
    output [31:0] out_x,
    output        overflow_flag_stage4
);

    wire [31:0] stage1_out_x, stage1_out_num, stage1_out_sum;
    wire [31:0] stage2_out_x, stage2_out_num, stage2_out_sum;
    wire [31:0] stage3_out_x, stage3_out_num, stage3_out_sum;
    reg [31:0] stage1_reg_x, stage1_reg_num, stage1_reg_sum;
    reg [31:0] stage2_reg_x, stage2_reg_num, stage2_reg_sum;
    reg [31:0] stage3_reg_x, stage3_reg_num, stage3_reg_sum;
    wire        overflow_flag_stage1, overflow_flag_stage2, overflow_flag_stage3;

    pipe_slice_dp #(
        .RAM_VALUE_0(RAM_VALUE_0_STAGE1),
        .RAM_VALUE_1(RAM_VALUE_1_STAGE1)
    ) stage1 (
        .in_x(in_x),
        .in_num(in_num),
        .in_sum(in_sum),
        .addr(addr),
        .sel_sum(sel_sum),
        .out_sum(stage1_out_sum),
        .out_num(stage1_out_num),
        .out_x(stage1_out_x),
        .overflow_flag(overflow_flag_stage1)
    );

    always @(posedge clk) begin
        stage1_reg_x <= stage1_out_x;
        stage1_reg_num <= stage1_out_num;
        stage1_reg_sum <= stage1_out_sum;
    end

    pipe_slice_dp #(
        .RAM_VALUE_0(RAM_VALUE_0_STAGE2),
        .RAM_VALUE_1(RAM_VALUE_1_STAGE2)
    ) stage2 (
        .in_x(stage1_reg_x),
        .in_num(stage1_reg_num),
        .in_sum(stage1_reg_sum),
        .addr(addr),
        .sel_sum(sel_sum),
        .out_sum(stage2_out_sum),
        .out_num(stage2_out_num),
        .out_x(stage2_out_x),
        .overflow_flag(overflow_flag_stage2)
    );

    always @(posedge clk) begin
        stage2_reg_x <= stage2_out_x;
        stage2_reg_num <= stage2_out_num;
        stage2_reg_sum <= stage2_out_sum;
    end

    pipe_slice_dp #(
        .RAM_VALUE_0(RAM_VALUE_0_STAGE3),
        .RAM_VALUE_1(RAM_VALUE_1_STAGE3)
    ) stage3 (
        .in_x(stage2_reg_x),
        .in_num(stage2_reg_num),
        .in_sum(stage2_reg_sum),
        .addr(addr),
        .sel_sum(sel_sum),
        .out_sum(stage3_out_sum),
        .out_num(stage3_out_num),
        .out_x(stage3_out_x),
        .overflow_flag(overflow_flag_stage3)
    );

    always @(posedge clk) begin
        stage3_reg_x <= stage3_out_x;
        stage3_reg_num <= stage3_out_num;
        stage3_reg_sum <= stage3_out_sum;
    end

    pipe_slice_dp #(
        .RAM_VALUE_0(RAM_VALUE_0_STAGE4),
        .RAM_VALUE_1(RAM_VALUE_1_STAGE4)
    ) stage4 (
        .in_x(stage3_reg_x),
        .in_num(stage3_reg_num),
        .in_sum(stage3_reg_sum),
        .addr(addr),
        .sel_sum(sel_sum),
        .out_sum(out_sum),
        .out_num(out_num),
        .out_x(out_x),
        .overflow_flag(overflow_flag_stage4)
    );

endmodule
