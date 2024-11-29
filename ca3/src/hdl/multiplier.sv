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
                    .pi(pv[i][j+1]),
                    .ci(cv[i][j]),
                    .xo(xv[i][j+1]),
                    .yo(yv[i+1][j]),
                    .po(pv[i+1][j]),
                    .co(cv[i][j+1])
                );
            end
        end
    endgenerate

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : xv_gen
            assign xv[i][0] = in1[i];
            assign cv[i][0] = 1'b0;
            assign pv[0][i + 1] = 1'b0;
            assign pv[i + 1][WIDTH] = cv[i][WIDTH];
            assign yv[0][i] = in2[i];
            assign out[i] = pv[i + 1][0];
            assign out[i + WIDTH] = pv[WIDTH][i + 1];
        end
    endgenerate

endmodule

module bit_multiplier
(
    input xi, yi, ci, pi,
    output xo, yo, co, po
);
    wire xy;
    assign xo = xi;
    assign yo = yi;

    
    // assign xy = xi & yi;
    // assign co = (pi & xy) | (pi & ci) | (xy & ci);
    // assign po = pi ^ xy ^ ci;

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
        .A(co),
        .out(inv_co)
    );

    wire or_pi_ci;
    or_mod or_inst (
        .a(pi),
        .b(ci),
        .y(or_pi_ci)
    );

    C2 po_gen (
        .A0(pi),
        .B0(ci),
        .A1(xy),
        .B1(xy),
        .D({1'b1, inv_co, inv_co, or_pi_ci}),
        .out(po)
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