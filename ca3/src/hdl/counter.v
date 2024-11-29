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

    reg [WIDTH-1:0] counter;

    always @(posedge clk or posedge rst) begin
        if(rst)
            counter <= 0;
        else if(load)
            counter <= in;
        else if(en)
            counter <= counter + 1;
    end

    assign co = &counter && en;

endmodule

