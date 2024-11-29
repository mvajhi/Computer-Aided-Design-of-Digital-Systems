module adder #(
    WIDTH = 8
) (
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    input wire cin,
    output wire [WIDTH-1:0] out,
    output wire co
);
    assign out = in1 + in2 + cin;
endmodule