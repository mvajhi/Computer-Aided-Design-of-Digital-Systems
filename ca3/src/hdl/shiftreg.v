module ShiftRegister #(
    parameter WIDTH = 8
) (
    input clk,
    input rst,
    input load,
    input shift_en,
    input [WIDTH-1:0] in,
    input in_sh,
    output reg [WIDTH-1:0] out
);
    
    always @(posedge clk or posedge rst) begin
        if(rst)
            out <= 0;
        else if(load)
            out <= in;
        else if(shift_en)
            out <= {out[WIDTH-2:0], in_sh};
    end
    
endmodule

