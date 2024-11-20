module dp #(
    parameter N = 3'b111
) (
    input         clk,
    input         rst,
    input  [7:0]  in_x_input,
    input         in_valid,
    input         in_flag_next,
    input         sel_x,
    input         sel_num,
    input         sel_sum,
    input         sel_i,
    input         sel_overflow,
    output        out_flag_next,
    output [31:0] out_sum,
    output        out_overflow,
    output        out_valid_final
);

    wire        out_valid;
    wire [2:0] out_i;
    wire [31:0]       out_x, out_num;

    // mux
    wire [31:0] in_x = sel_x ? out_x : {in_x_input, 24'b0};
    wire [31:0] in_num = sel_num ? out_num : 32'h7FFFFFFF;
    wire [31:0] in_sum = sel_sum ? out_sum : 32'h0;
    wire in_overflow = sel_overflow ? out_overflow : 1'b0;
    wire [2:0] in_i = sel_i ? out_i : 3'b0;

    pipe_4_stage #(
        .N(N)
    ) pipe (
        .clk(clk),
        .rst(rst),
        .in_x(in_x),
        .in_num(in_num),
        .in_sum(in_sum),
        .in_overflow(in_overflow),
        .in_i(in_i),
        .in_valid(in_valid),
        .in_flag_next(in_flag_next),
        .out_flag_next(out_flag_next),
        .out_valid(out_valid),
        .out_i(out_i),
        .out_sum(out_sum),
        .out_num(out_num),
        .out_x(out_x),
        .out_overflow(out_overflow)
    );

    assign out_valid_final = out_valid && !out_overflow;

endmodule