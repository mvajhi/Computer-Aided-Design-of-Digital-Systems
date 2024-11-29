module multiplier #(
    parameter WIDTH = 8
) (
    input signed [WIDTH-1:0] in1,
    input signed [WIDTH-1:0] in2,
    output wire [2*WIDTH-1:0] out
);
    assign out = in1 * in2;
endmodule