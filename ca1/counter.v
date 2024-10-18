module Counter #(
    parameter WIDTH = 4
) (
    input clk,
    input rst,
    input en,
    input [WIDTH-1:0] init,
    output reg [WIDTH-1:0] counter
);
    
    always @(posedge clk or posedge rst) begin
        if(rst)
            counter <= {WIDTH{1'b0}};
        else if(en)
            if(counter == init)
                counter <= {WIDTH{1'b0}};
            else
                counter <= counter + 1'b1;
    end
    
endmodule


