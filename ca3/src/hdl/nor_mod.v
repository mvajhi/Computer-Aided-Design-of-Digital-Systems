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