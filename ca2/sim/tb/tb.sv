module tb ();
    reg clk = 0;
    reg rst = 0;
    reg [7:0] data_in [3:0];
    reg write_enable = 0;
    reg read_enable = 4'b0100;
    wire [7:0] data_out [3:0];
    wire full;
    wire empty;
    wire valid;
    wire ready;

    initial begin
        rst = 1;
        #10 rst = 0;

        data_in[0] = 8'b10101010;
        data_in[1] = 8'b11111111;
        data_in[2] = 8'b00000000;
        data_in[3] = 8'b01010101;
        
        #10 write_enable = 1;
        #10 write_enable = 0;
        #10 read_enable = 1;
        #10 read_enable = 0;
        
        #1000 $finish;
    end
    always #5 clk = ~clk;

    fifo_buffer #(
        .DATA_WIDTH(8),
        .SIZE(8),
        .PAR_WRITE(4),
        .PAR_READ(4)
    )
    dp (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .data_out(data_out),
        .full(full),
        .empty(empty),
        .valid(valid),
        .ready(ready)
    );

endmodule