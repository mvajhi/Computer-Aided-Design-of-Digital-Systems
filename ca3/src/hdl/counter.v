module Counter #(
    parameter WIDTH = 3
) (
    input clk,
    input rst,
    input en,
    input load,
    input [WIDTH-1:0] in,
    output wire co
);
    wire [WIDTH-1:0] adder_out;
    reg [WIDTH-1:0] counter;

    adder #(.WIDTH(WIDTH)) adder_inst(.in1(counter), .in2(3'b001), .cin(1'b0), .out(adder_out));


    always @(posedge clk or posedge rst) begin
        if(rst)
            counter <= 0;
        else if(load)
            counter <= in;
        else if(en)
            counter <= adder_out;
    end

    assign co = &counter && en;

endmodule

