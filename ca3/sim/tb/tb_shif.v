module tb ();
    reg clk = 0, rst, load, en, in_sh;
    reg [15:0] in;
    wire [15:0] out;

    ShiftRegister #(
        .WIDTH(16)
    ) sh1 (
        .clk(clk),
        .rst(rst),
        .load(load),
        .shift_en(en),
        .in(in),
        .in_sh(in_sh),
        .out(out)
    );

    always #5 clk = ~clk;

    initial begin
        rst = 0;
        load = 0;
        en = 0;
        in_sh = 0;
        in = 16'b1010011010101001;
        #10 rst = 1;
        #10 rst = 0;
        #10 load = 1;
        #10 load = 0;
        #10 en = 1;
        #10 en = 0;
        #10 in_sh = 1;
        #10 en = 1;
        #10 en = 0;
        #10 in_sh = 0;
        #1000 $finish;
    end
endmodule