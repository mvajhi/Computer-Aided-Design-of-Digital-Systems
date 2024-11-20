module C2(
    input A0, B0, A1, B1,
    input [3:0] D,
    output out
);
    wire S0, S1;

    assign S0 = A0 & B0;
    assign S1 = A1 | B1;

    assign out = D[{S1, S0}];
endmodule
