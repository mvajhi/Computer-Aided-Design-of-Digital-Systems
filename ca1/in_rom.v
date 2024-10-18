module RAM #(
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);
    
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
    
    initial begin
        $readmemh("input.txt", mem);
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst)
            data_out <= 0;
        else
            data_out <= mem[addr];
    end
    
endmodule

