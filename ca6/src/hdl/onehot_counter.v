module OneHotCounter #(parameter WIDTH = 8) (
    input  clk,
    input  rst,
    input  enable,
    input  count,
    output reg [WIDTH-1:0] one_hot
);

    always @(posedge clk or posedge rst) begin
        if (reset)
            one_hot <= 1;
        else if (!enable)
            one_hot <= 0;
        else if (count)
            one_hot <= {one_hot[WIDTH-2:0], one_hot[WIDTH-1]};
    end
    
endmodule
