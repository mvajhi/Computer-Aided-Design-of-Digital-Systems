module Counter #(
    parameter WIDTH = 3
) (
    input clk,
    input rst,
    input en,
    input load,
    input [WIDTH-1:0] in,
    output wire co
);
    wire [WIDTH-1:0] adder_out;
    wire [WIDTH-1:0] counter;
    wire co_add;

    adder #(.WIDTH(WIDTH)) adder_inst(.in1(counter), .in2(3'b000), .cin(en), .out(adder_out), .co(co));


    // always @(posedge clk or posedge rst) begin
    //     if(rst)
    //         counter <= 0;
    //     else if(load)
    //         counter <= in;
    //     else if(en)
    //         counter <= adder_out;
    // end

    genvar i;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : register_block
            // data[i] sel if load and shift_en is 0
            // data[i-1] sel if load is 0 and shift_en is 1
            // in[i] sel if load is 1
            S2 reg_inst (
                .A0(en),
                .B0(en),
                .A1(load),
                .B1(load),
                .D({in[i], in[i], adder_out[i], counter[i]}),
                .CLK(clk),
                .CLR(rst),
                .out(counter[i])
            );
        end
    endgenerate

    // assign co = &counter && en;
    // and_mod and_co (co_add, en, co);

endmodule

