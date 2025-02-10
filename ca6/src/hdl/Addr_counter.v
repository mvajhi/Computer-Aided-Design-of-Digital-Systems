module AddressCounter #(parameter ADDR_WIDTH = 8, parameter OFFSET = 0, parameter FOR_CO = 3) (
    input   clk,
    input   reset,
    input   enable,
    output co,
    output reg [ADDR_WIDTH-1:0] addr
);

    logic [ADDR_WIDTH-1:0] counter;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 0;
        else if (enable)
            counter <= counter + 1;
    end
    
    assign addr = counter + OFFSET;
    assign co = (counter != 0) && (counter % FOR_CO == 0)
    
endmodule
