module tb;

    reg clk, rst = 0;
    reg [31:0] in_x;
    reg [31:0] in_num;
    reg [31:0] in_sum;
    reg addr_stage1, addr_stage2, addr_stage3, addr_stage4;
    reg sel_sum_stage1, sel_sum_stage2, sel_sum_stage3, sel_sum_stage4;
    reg overflow_flag_stage1 = 0;

    wire [31:0] out_sum;
    wire [31:0] out_num;
    wire [31:0] out_x;
    wire overflow_flag;

    always @(posedge clk) begin
        addr_stage2 <= addr_stage1;
        addr_stage3 <= addr_stage2;
        addr_stage4 <= addr_stage3;
    end

    pipe_4_stage uut (
        .clk(clk),
        .rst(rst),
        .in_x(in_x),
        .in_num(in_num),
        .in_sum(in_sum),
        .in_overflow(overflow_flag_stage1),
        .out_sum(out_sum),
        .out_num(out_num),
        .out_x(out_x),
        .overflow_out(overflow_flag),
        .addr_stage1(addr_stage1),
        .addr_stage2(addr_stage2),
        .addr_stage3(addr_stage3),
        .addr_stage4(addr_stage4),
        .sel_sum_stage1(sel_sum_stage1),
        .sel_sum_stage2(sel_sum_stage2),
        .sel_sum_stage3(sel_sum_stage3),
        .sel_sum_stage4(sel_sum_stage4)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        {sel_sum_stage1, sel_sum_stage2, sel_sum_stage3, sel_sum_stage4} = 4'b0;
        addr_stage1 = 1'b0;
        in_x = {3'b111, 29'b0};
        in_num = 32'h7FFFFFFF;
        in_sum = 32'h0;
        
        #30;
        in_x = out_x;
        in_num = out_num;
        in_sum = out_sum;
        addr_stage1 = 1'b1;


        #30 $stop;
    end

endmodule
