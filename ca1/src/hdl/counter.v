module Counter #(
    parameter WIDTH = 4
) (
    input clk,
    input rst,
    input en,
    input init,
    output reg [WIDTH-1:0] out,
    output co
);
    
    always @(posedge clk or posedge rst) begin
        if(rst || init)
            out <= {WIDTH{1'b0}};
        else if(en)
            out <= out + 1;
    end

    assign co = &out && en;
endmodule


