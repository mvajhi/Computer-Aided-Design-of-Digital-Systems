module Out_RAM #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
) (
    input clk,
    input wr,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data_in
);
    
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
    
    always @(posedge clk) begin
        if(wr)
            mem[addr] <= data_in;
    end
    
endmodule

