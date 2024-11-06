module tb ();
    reg clk = 0;
    reg rst = 0;
    reg [7:0] data_in [3:0];
    reg write_enable = 0;
    reg read_enable = 0;
    wire [7:0] data_out [3:0];
    wire full;
    wire empty;
    wire valid;
    wire ready;

    initial begin
        #10 write_enable = 1;
        data_in[0] = 8'd1;
        data_in[1] = 8'd2;
        data_in[2] = 8'd3;
        data_in[3] = 8'd4;

        #10 write_enable = 1;
        read_enable = 1;
        data_in[0] = 8'd8;
        data_in[1] = 8'd7;
        data_in[2] = 8'd6;
        data_in[3] = 8'd5;
        
        #10 write_enable = 1;
        read_enable = 1;
        data_in[0] = 8'd10;
        data_in[1] = 8'd14;
        data_in[2] = 8'd16;
        data_in[3] = 8'd19;

        #10 write_enable = 1;
        read_enable = 1;
        data_in[0] = 8'd10;
        data_in[1] = 8'd14;
        data_in[2] = 8'd16;
        data_in[3] = 8'd19;

        #10 write_enable = 1;
        read_enable = 1;
        data_in[0] = 8'd10;
        data_in[1] = 8'd14;
        data_in[2] = 8'd16;
        data_in[3] = 8'd19;

        #10 write_enable = 1;
        read_enable = 1;
        data_in[0] = 8'd10;
        data_in[1] = 8'd14;
        data_in[2] = 8'd16;
        data_in[3] = 8'd19;

        #10 write_enable = 1;
        read_enable = 1;
        data_in[0] = -1;
        data_in[1] = -2;
        data_in[2] = -3;
        data_in[3] = -4;

        #10 write_enable = 1;
        read_enable = 1;
        data_in[0] = -1;
        data_in[1] = -2;
        data_in[2] = -3;
        data_in[3] = -4;

        #10 write_enable = 1;
        read_enable = 1;
        data_in[0] = -1;
        data_in[1] = -2;
        data_in[2] = -3;
        data_in[3] = -4;

        #10 write_enable = 1;
        read_enable = 0;
        data_in[0] = -1;
        data_in[1] = -2;
        data_in[2] = -3;
        data_in[3] = -4;

        #10 write_enable = 0;
        read_enable = 0;
        data_in[0] = -1;
        data_in[1] = -2;
        data_in[2] = -3;
        data_in[3] = -4;

        #10 write_enable = 0;
        read_enable = 1;

        #10 write_enable = 0;
        read_enable = 1;

        #10 write_enable = 0;
        read_enable = 1;

        #10 write_enable = 0;
        read_enable = 1;


    end

    // initial begin
    //     rst = 1;
    //     #10 rst = 0;

    //     data_in[0] = 8'b10101010;
    //     data_in[1] = 8'b11111111;
    //     data_in[2] = 8'b00000000;
    //     data_in[3] = 8'b01010101;
        
    //     #10 write_enable = 1;
    //     #10 write_enable = 0;
    //     #30 write_enable = 1;
    //     #10 write_enable = 0;
    //     #10 read_enable = 1;
    //     #10 read_enable = 0;
    //     #30 read_enable = 1;
    //     #10 read_enable = 0;
        
    //     #1000 $finish;
    // end
    always #5 clk = ~clk;

    fifo_buffer #(
        .DATA_WIDTH(8),
        .SIZE(8),
        .PAR_WRITE(4),
        .PAR_READ(1)
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