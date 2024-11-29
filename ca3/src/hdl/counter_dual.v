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
    reg [WIDTH-1:0] out;
    
    wire temp;
    assign temp = (en1 | en2) | en_d;

    adder #(
        .WIDTH(WIDTH)
    ) adder_inst_1( .in1(out), .in2({3'b0, temp}), .cin(en2), .out(adder_out));


    always @(posedge clk or posedge rst) begin
        if(rst)
            out <= {WIDTH{1'b0}};
        else if(en_d)
            out <= adder_out;
        else if(en2)
            out <= adder_out;
        else if(en1)
            out <= adder_out;
    end

    assign co = &out;
endmodule


