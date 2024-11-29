module adder_1bit (
    input wire A,
    input wire B,
    input wire Cin,
    output wire Sum,
    output wire Cout
);

    wire A_inv;
    not_mod not_inst (
        .A(A),
        .out(A_inv)
    );

    C1 sum (
        .A0(A), .A1(A_inv),
        .SA(B),
        .B0(A_inv), .B1(A),
        .SB(B),
        .S0(Cin), .S1(Cin),
        .F(Sum)
    );

    C1 carry (
        .A0(1'b0), .A1(A),
        .SA(B),
        .B0(A), .B1(1'b1),
        .SB(B),
        .S0(Cin), .S1(Cin),
        .F(Cout)
    );
endmodule
