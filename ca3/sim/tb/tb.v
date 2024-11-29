module tb ();
    reg clk = 0;
    reg rst = 0;
    reg start = 0;
    reg [15:0] in1;
    reg [15:0] in2;
    wire [31:0] out;
    wire done;

    initial begin
        in1 = 16'b1010011010101001;
        in2 = 16'b0010010001000110;
        rst = 1;
        #10 rst = 0;
        #10 start = 1;
        #10 start = 0;
        
        #1000 $finish;
    end
    always #5 clk = ~clk;

    // adder #(.WIDTH(16)) adder_inst(.in1(in1), .in2(in2), .cin(1'b0), .out(out));

    top_module tm (
        .clk(clk),
        .rst(rst),
        .start(start),
        .in1(in1),
        .in2(in2),
        .result(out),
        .done(done)
    );
endmodule