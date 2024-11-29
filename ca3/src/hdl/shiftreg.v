module ShiftRegister #(
    parameter WIDTH = 16
)  (
    input clk,
    input rst,
    input load,
    input shift_en,
    input [15:0] in,
    input in_sh,
    output [15:0] out
);

wire [15:0] data;
genvar i;

generate
    for (i = 0; i < WIDTH; i = i + 1) begin : register_block
        // data[i] sel if load and shift_en is 0
        // data[i-1] sel if load is 0 and shift_en is 1
        // in[i] sel if load is 1
        S2 reg_inst (
            .A0(shift_en),
            .B0(shift_en),
            .A1(load),
            .B1(load),
            .D({in[i], in[i], data[i-1], data[i]}),
            .CLK(clk),
            .CLR(rst),
            .out(data[i])
        );
    end
endgenerate

assign out = data;

endmodule
