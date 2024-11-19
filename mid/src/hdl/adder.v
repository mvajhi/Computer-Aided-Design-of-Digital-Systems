module adder (
    input  signed [31:0] a,
    input  signed [31:0] b,
    output signed [31:0] sum,
    output        overflow
);

    assign sum = a + b;

    assign overflow = ((a[31] == b[31]) && (sum[31] != a[31]));

endmodule
