module TB ();
    reg rst=0;
    reg clk=0;
    reg [(16 + 2) * 7 - 1:0] data_in;
    reg [16 * 3 - 1:0] filter_in;
    wire [15:0] data_out;

    always #5 clk = ~clk;

    initial begin
        rst = 1;
        #20 rst = 0;

        data_in = {{2'b10, 16'd1}, {2'b00, 16'd2}, {2'b00, 16'd3},
                    {2'b00, 16'd3}, {2'b00, 16'd4}, {2'b00, 16'd5}, {2'b01, 16'd6}};

        filter_in = {{16'd1, 16'd2, 16'd3}, {16'd3, 16'd4, 16'd5}, {16'd5, 16'd6, 16'd7}};

    end 
endmodule