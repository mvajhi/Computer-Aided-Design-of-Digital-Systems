module tb ();

    reg clk = 0, rst = 0;
    reg [7:0] x;
    reg start;
    wire ready;
    wire valid;
    wire error;
    wire overflow;
    wire [31:0] out_sum;

    top #(
        .N(3'b010)
    ) uut (
        .clk(clk),
        .rst(rst),
        .in_x_input(x),
        .start(start),
        .ready(ready),
        .out_valid_final(valid),
        .error(error),
        .overflow(overflow),
        .out_sum(out_sum)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        // x = {3'b111, 5'b0};
        // x = 8'b01111111;
        x = 8'h06;
        #10;

        rst = 0;
        start = 1;
        #5 start = 0;
        // #10 x = 8'h01;
        // #10 x = 8'h00;
        // #10 x = 8'h05;
        #10 x = 8'h0f;
        #10 x = 8'h01;
        #10 x = 8'h00;

        #100 $stop;
    end

endmodule