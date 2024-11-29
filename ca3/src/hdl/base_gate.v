module xor_mod (
    input wire A,
    input wire B,
    output wire out
);

    C2 xor_inst (
        .A0(A),
        .B0(B),
        .A1(A),
        .B1(B),
        .D(4'b0100),
        .out(out)
    );

endmodule

module not_mod (
    input wire A,
    output wire out
);

    C1 not_inst (
        .A0(1'b1),
        .A1(1'b1),
        .SA(1'b1),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(A),
        .S1(A),
        .F(out)
    );

endmodule

module nor_mod (
    input wire A,
    input wire B,
    output wire out
);

    C1 nor_inst (
        .A0(1'b1),
        .A1(1'b1),
        .SA(1'b1),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(A),
        .S1(B),
        .F(out)
    );

endmodule

module or_mod
(
    input a, b,
    output y
);
    C1 or_inst (
        .A0(1'b0),
        .A1(1'b0),
        .SA(1'b0),
        .B0(1'b1),
        .B1(1'b1),
        .SB(1'b1),
        .S0(a),
        .S1(b),
        .F(y)
    );
endmodule

module and_mod
(
    input a, b,
    output y
);
    C1 and_inst (
        .A0(1'b0),
        .A1(b),
        .SA(a),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(1'b0),
        .S1(1'b0),
        .F(y)
    );
endmodule