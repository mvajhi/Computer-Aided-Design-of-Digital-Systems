module tb ();

    reg [31:0] in_x;
    reg [31:0] in_num;
    reg [31:0] in_sum;
    reg        addr;
    reg        sel_sum;
    reg        in_overflow = 0;
    wire [31:0] out_sum;
    wire [31:0] out_num;
    wire [31:0] out_x;
    wire        overflow_flag;

    pipe_slice_dp #(
        .RAM_VALUE_0(32'h7FFFFFFF),
        .RAM_VALUE_1(32'hC0000000)
    ) pipe_slice_dp_instance (
        .in_x(in_x),
        .in_num(in_num),
        .in_sum(in_sum),
        .addr(addr),
        .sel_sum(sel_sum),
        .in_overflow(in_overflow),
        .out_sum(out_sum),
        .out_num(out_num),
        .out_x(out_x),
        .out_overflow(overflow_flag)
    );

    initial begin
        in_x = 32'h40000000;
        in_num = 32'h40000000;
        in_sum = 32'h0;
        addr = 1;
        sel_sum = 0;

        #10 in_x = 32'h7FFFFFFF;
        in_num = 32'h7FFFFFFF;
        in_sum = 32'h7FFFFFFF;
        addr = 0;
        sel_sum = 0;

        #10 in_x = 32'hC0000000;
        in_num = 32'h7FFFFFFF;
        in_sum = 32'h00000000;
        addr = 0;
        sel_sum = 0;

        #10 $finish;
    end
endmodule