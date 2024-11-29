module multiplier #(
    parameter WIDTH = 8
) (
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    output wire [2*WIDTH-1:0] out
);
    
    wire [WIDTH:0][WIDTH:0] xv, yv, pv, cv;

    genvar i, j;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : row
            for (j = 0; j < WIDTH; j = j + 1) begin : column
                bit_multiplier inst(
                    .xi(xv[i][j]),
                    .yi(yv[i][j]),
                    .pi(pv[i][j]),
                    .ci(cv[i][j]),
                    .xo(xv[i][j+1]),
                    .yo(yv[i+1][j]),
                    .po(pv[i+1][j]),
                    .co(cv[i+1][j+1])
                );
            end
        end
    endgenerate

    assign xv[0][0] = in1[0];
    assign yv[0][0] = in2[0];

    assign out = {pv[WIDTH][WIDTH-1:0]};

endmodule

module bit_multiplier
(
    input xi, yi, ci, pi,
    output xo, yo, co, po
);
    wire xy;
    assign xo = xi;
    assign yo = yi;

    and_mod and_inst (
        .a(xi),
        .b(yi),
        .y(xy)
    );

    C1 co_gen (
        .A0(1'b0),
        .A1(ci),
        .SA(xy),
        .B0(ci),
        .B1(1'b1),
        .SB(xy),
        .S0(pi),
        .S1(pi),
        .F(co)
    );

    wire inv_co;
    not_mod not_co
    (
        .in(co),
        .out(inv_co)
    );

    C2 po_gen (
        .A0(pi),
        .B0(ci),
        .A1(xy),
        .B1(xy),
        .D({1'b1, inv_co, inv_co, 1'b0}),
        .out(po)
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