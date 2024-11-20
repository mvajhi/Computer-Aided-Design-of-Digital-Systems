module top #(
    parameter N = 3'b111
) (
    input         clk,
    input         rst,
    input  [7:0]  in_x_input,
    input         start,
    output        ready,
    output        out_valid_final,
    output        error,
    output        overflow,
    output [31:0] out_sum
);

    wire        out_valid;
    wire        out_flag_next_controller, in_flag_next_controller;
    wire        sel_i, sel_x, sel_num, sel_sum, sel_overflow;

    dp #(
        .N(N)
    ) pipe_instance (
        .clk(clk),
        .rst(rst),
        .in_x_input(in_x_input),
        .in_valid(out_valid),
        .in_flag_next(out_flag_next_controller),
        .sel_x(sel_x),
        .sel_num(sel_num),
        .sel_sum(sel_sum),
        .sel_i(sel_i),
        .sel_overflow(sel_overflow),
        .out_flag_next(in_flag_next_controller),
        .out_sum(out_sum),
        .out_overflow(overflow),
        .out_valid_final(out_valid_final)
    );

    controller #(
        .N(N)
    ) controller_instance (
        .clk(clk),
        .rst(rst),
        .start(start),
        .in_flag_next(in_flag_next_controller),
        .ready(ready),
        .out_valid(out_valid),
        .error(error),
        .sel_x(sel_x),
        .sel_num(sel_num),
        .sel_sum(sel_sum),
        .sel_i(sel_i),
        .sel_overflow(sel_overflow),
        .out_flag_next(out_flag_next_controller)
    );

endmodule