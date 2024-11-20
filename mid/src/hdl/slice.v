module pipe_slice_dp #(
    parameter RAM_VALUE_0 = 32'b0,
    parameter RAM_VALUE_1 = 32'b0,
    parameter N = 3'b111
) (
    input signed  [31:0] in_x,
    input signed  [31:0] in_num,
    input signed  [31:0] in_sum,
    input         addr,
    input         in_overflow,
    input  [2:0]  in_i,
    output signed [31:0] out_sum,
    output signed [31:0] out_num,
    output signed [31:0] out_x,
    output        out_overflow,
    output [2:0]  out_i
);

    wire signed [31:0] term;
    wire signed [31:0] add;
    wire signed [31:0] coefficient;
    wire signed [63:0] mult1;
    wire signed [63:0] mult2;
    wire        overflow_flag;
    wire         sel_sum;

    assign out_x = in_x;

    assign mult1 = in_x * in_num;
    assign out_num = mult1[62:31];

    assign mult2 = coefficient * out_num;
    assign term = mult2[62:31];

    adder adder_instance (
        .a(term),
        .b(in_sum),
        .sum(add),
        .overflow(overflow_flag)
    );
    assign out_overflow = in_overflow | overflow_flag;

    assign out_sum = sel_sum ? in_sum : add;

    ram #(
        .RAM_VALUE_0(RAM_VALUE_0),
        .RAM_VALUE_1(RAM_VALUE_1)
    ) ram_instance (
        .addr(addr),
        .data_out(coefficient)
    );

    assign out_i = in_i + 1'b1;
    assign addr = in_i[2];
    assign sel_sum = in_i > N;

endmodule
