module adder_synth #(
    parameter WIDTH = 8
) (
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    input wire cin,
    output wire [WIDTH-1:0] out,
    output wire co
);
    wire [WIDTH:0] carry; // Carry chain
    assign carry[0] = cin; // Initial carry input

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : adder_bit
            wire sum, c_out;
            // Using C1 for Sum calculation
            C1 sum_logic (
                .A0(in1[i]), .A1(in2[i]),
                .B0(carry[i]), .B1(1'b0), // Carry in as a second input
                .S0(1'b1), .S1(1'b1),
                .F(sum)
            );

            // Using C2 for Carry-Out calculation
            C2 carry_logic (
                .D00(in1[i] & in2[i]), .D01(carry[i] & in1[i]),
                .D10(carry[i] & in2[i]), .D11(1'b0), // Logic for Carry-Out
                .S0(carry[i]), .S1(in1[i] ^ in2[i]),
                .out(c_out)
            );

            assign out[i] = sum; // Final sum output
            assign carry[i+1] = c_out; // Propagate carry
        end
    endgenerate

    assign co = carry[WIDTH]; // Final carry-out
endmodule
