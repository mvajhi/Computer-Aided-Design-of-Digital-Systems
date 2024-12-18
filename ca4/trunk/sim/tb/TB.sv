`timescale 1ns/1ns

`define HALF_CLK 5
`define CLK (2 * `HALF_CLK)
module TB;
    parameter BUFFER_WIDTH = 16;
    parameter BUFFER_DEPTH = 8;
    parameter PAR_WRITE = 4;
    parameter PAR_READ = 1;
    parameter ADDR_WIDTH = 4;

    reg clk;
    reg rstn;
    reg wen, ren, buffer_ready, ready_out;
    reg [PAR_WRITE * BUFFER_WIDTH - 1 : 0] din;
    wire [PAR_READ * BUFFER_WIDTH - 1 : 0] dout;


    FIFOBuf2 #(ADDR_WIDTH, BUFFER_WIDTH, BUFFER_DEPTH, PAR_READ, PAR_WRITE) UUT(clk, ~rstn, ren, wen, din, buffer_ready, ready_out, dout);


    always @(clk)begin
        # `HALF_CLK
        clk <= ~clk;
    end
    
    //for writing
    initial begin
        clk = 0;
        rstn = 0;
        wen = 0;

        #`CLK;
        rstn = 1;
        #`CLK;
        wen = 1;
        din = {16'd4, 16'd3, 16'd2, 16'd1};
        #`CLK;
	ren = 1;
        wen = 1;
        din = {16'd5, 16'd6, 16'd7, 16'd8};
        #`CLK;
        din = {16'd19, 16'd16, 16'd14, 16'd10};
        #`CLK;
        #`CLK;
        #`CLK;
        #`CLK;
        #`CLK;
        din = {16'd8, 16'd7, 16'd6, 16'd5};
        #`CLK;
        #`CLK;
	ren = 0;
        #`CLK;
	wen = 0;
        #`CLK;
	ren = 1;
        #100 $stop;
    end

endmodule
