module OneHotCounter #(parameter WIDTH = 8) (
    input  clk,
    input  rst,
    input  enable,
    input  count,
    output reg [WIDTH-1:0] one_hot,
    output reg co
);

    always @(posedge clk or posedge rst) begin
        co = 1'b0;
        if (reset)
            one_hot <= 1;
        else if (!enable)
            one_hot <= 0;
        else if (count) begin
            one_hot <= {one_hot[WIDTH-2:0], one_hot[WIDTH-1]};
            co = 1'b1;
        end
    end
    
endmodule
