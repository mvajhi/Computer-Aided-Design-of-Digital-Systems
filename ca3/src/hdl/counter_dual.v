module Counter_dual #(
    parameter WIDTH = 4
) (
    input clk,
    input rst,
    input en1,
    input en2,
    input en_d,
    input [WIDTH-1:0] init,
    output co
);
    wire [WIDTH-1:0] adder_out;
    wire [WIDTH-1:0] out;
    wire co_add;
    
    wire temp;
    
    C1 c1_inst_en1 (
        .A0(1'b0),
        .A1(1'b0),
        .SA(1'b0),
        .B0(1'b1),
        .B1(1'b1),
        .SB(1'b1),  
        .S0(en_d),
        .S1(en1),
        .F(temp)
    );

    adder #(
        .WIDTH(WIDTH)
    ) adder_inst_1( .in1(out), .in2({3'b0, temp}), .cin(en2), .out(adder_out), .co(co_add) );

    ShiftRegister #(
        .WIDTH(WIDTH)
    ) sr_inst (
        .clk(clk),
        .rst(rst),
        .load(1'b1),
        .shift_en(1'b0),
        .in(adder_out),
        .in_sh(1'b0),
        .out(out)
    );

    // assign co = &out;
    C2 co_calc(
        .A0(out[0]),
        .B0(out[1]),
        .A1(out[2]),
        .B1(out[2]),
        .D({out[3], 3'b0}),
        .out(co)
    );
endmodule


