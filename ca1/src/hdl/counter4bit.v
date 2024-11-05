module Counter4bit (
    input clk,
    input rst,
    input en,
    input init,
    output reg [3:0] out,
    output reg co
);
    
    always @(posedge clk or posedge rst) begin
        if(rst || init)
        begin
            out <= 4'b0;
            co <= 1'b0;
        end
        else
        begin if(en) begin
            out <= out + 1;
            co <= (out == 4'b1111) ? 1'b1 : 1'b0;
        end
        end

    end

endmodule


