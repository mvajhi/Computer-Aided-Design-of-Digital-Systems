module tb ();
    reg clk = 0;
    reg rst = 0;
    reg start = 0;
    wire done;

    initial begin
        rst = 1;
        #10 rst = 0;
        #10 start = 1;
        #10 start = 0;
        
        #1000 $finish;
    end
    always #5 clk = ~clk;

    top_module dut (
        .clk(clk),
        .rst(rst),  
        .start(start),
        .done(done),
    );
endmodule