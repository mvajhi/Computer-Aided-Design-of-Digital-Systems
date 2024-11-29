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
    // assign temp = (en1 | en2) | en_d;
    C1 c1_inst_en1 (
        .A0(1'b0),
        .A1(1'b1),
        .SA(en_d),
        .B0(1'b1),
        .B1(1'b1),
        .SB(1'b1),  
        .S0(en1),
        .S1(en2),
        .F(temp)
    );

    adder #(
        .WIDTH(WIDTH)
    ) adder_inst_1( .in1(out), .in2({3'b0, temp}), .cin(en2), .out(adder_out), .co(co_add) );


    // always @(posedge clk or posedge rst) begin
    //     if(rst)
    //         out <= {WIDTH{1'b0}};
    //     else if(en_d)
    //         out <= adder_out;
    //     else if(en2)
    //         out <= adder_out;
    //     else if(en1)
    //         out <= adder_out;
    // end

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


