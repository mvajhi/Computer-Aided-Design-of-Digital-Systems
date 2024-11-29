module multiplexer #(
    parameter WIDTH = 8
) (
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire sel,
    output wire [WIDTH-1:0] out
);

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : mux_block
        C1 mux_inst (
            .A0(in0[i]),
            .A1(in1[i]),
            .SA(sel),
            .B0(1'b1),
            .B1(1'b1),
            .SB(1'b1),
            .S0(1'b0),
            .S1(1'b0),
            .F(out[i])
        );
    end
endgenerate

endmodule