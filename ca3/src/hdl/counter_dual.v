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
    
    adder #(
        .WIDTH(WIDTH)
    ) adder_inst_1( .in1(out), .in2(en1 || en2), .cin(en2), .out(adder_out));

    wire [WIDTH-1:0] adder_out;
    reg [WIDTH-1:0] out;

    always @(posedge clk or posedge rst) begin
        if(rst)
            out <= {WIDTH{1'b0}};
        else if(en2)
            out <= adder_out;
        else if(en1)
            out <= adder_out;
        else if(en_d)
            out <= adder_out;
    end

    assign co = &out;
endmodule


