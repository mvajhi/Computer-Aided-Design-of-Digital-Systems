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