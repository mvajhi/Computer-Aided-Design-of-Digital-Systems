module adder #(
    parameter WIDTH = 16
) (
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    input wire cin,
    output wire [WIDTH-1:0] out,
    output wire co
);
    wire [WIDTH:0] carry;
    assign carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_adder
            adder_1bit u_adder (
                .A(in1[i]),
                .B(in2[i]),
                .Cin(carry[i]),
                .Sum(out[i]),
                .Cout(carry[i+1])
            );
        end
    endgenerate

    assign co = carry[WIDTH];
endmodule
