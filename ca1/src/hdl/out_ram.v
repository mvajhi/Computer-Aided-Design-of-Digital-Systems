module Out_RAM (
    input clk,
    input wr,
    input [2:0] addr,
    input [31:0] data_in
);
    
    reg [31:0] mem [7:0];
    
    always @(posedge clk) begin
        if(wr)
            mem[addr] <= data_in;
    end
    
endmodule

