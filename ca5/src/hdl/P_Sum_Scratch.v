module P_Sum_Registers #(
    parameter ADDR_LEN = 8,
    parameter SCRATCH_DEPTH = 8,
    parameter SCRATCH_WIDTH = 8
) (
    input wire clk,
    input wire rst,
    input wire wen,
    input wire [ADDR_LEN - 1:0] waddr,
    input wire [ADDR_LEN - 1:0] raddr,
    input wire [SCRATCH_WIDTH - 1:0] din,
    output wire [SCRATCH_WIDTH - 1:0] dout
);

    reg [SCRATCH_WIDTH - 1:0] main_mem [SCRATCH_DEPTH - 1:0];
    
    assign dout = main_mem[raddr];
    
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < SCRATCH_DEPTH; i = i + 1) begin
                main_mem[i] <= 0;
            end
        end
        else if (wen)
            main_mem[waddr] <= din;
    end

endmodule