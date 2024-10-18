module Out_RAM #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst,
    input wr,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);
    
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
    
    always @(posedge clk or posedge rst) begin
        if(rst)
            data_out <= 0;
        else if(wr)
            data_out <= mem[addr];
    end
    
    always @(posedge clk) begin
        if(wr)
            mem[addr] <= data_in;
    end
    
endmodule

