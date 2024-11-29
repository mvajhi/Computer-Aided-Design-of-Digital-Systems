module Counter_dual #(
    parameter WIDTH = 4
) (
    input clk,
    input rst,
    input en1,
    input en2,
    input en_d,
    input [WIDTH-1:0] init,
    output Zero
);
    
    reg [WIDTH-1:0] out,
    always @(posedge clk or posedge rst) begin
        if(rst)
            out <= {WIDTH{1'b0}};
        else if(en1)
            out <= out + 1;
        else if(en2)
            out <= out + 2;
        else if(en_d)
            out <= out - 1;
    end

    assign Zero = ~(&out);
endmodule


