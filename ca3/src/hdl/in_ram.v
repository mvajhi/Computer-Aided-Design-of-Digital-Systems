module In_RAM (
    input clk,
    input rst,
    input [3:0] addr,
    output reg [15:0] data_out
);
    
    reg [15:0] mem [15:0];
    
    initial begin
        $readmemb("data_input.txt", mem);
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst)
            data_out <= 0;
        else
            data_out <= mem[addr];
    end
    
endmodule

