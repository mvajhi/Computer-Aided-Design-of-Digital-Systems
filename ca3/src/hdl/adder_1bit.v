module adder_1bit (
    input wire A,
    input wire B,
    input wire Cin,
    output wire Sum,
    output wire Cout
);
    C1 sum (
        .A0(1'b0), .A1(1'b1),
        .SA(Cin),
        .B0(1'b1), .B1(1'b0),
        .SB(C),
        .S0(A), .S1(B),
        .F(Sum)
    );

    C1 carry (
        .A0(1'b0), .A1(1'b1),
        .SA(C),
        .B0(1'b1), .B1(1'b0),
        .SB(C),
        .S0(A), .S1(B),
        .F(Cout)
    );
endmodule
