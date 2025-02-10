module SRAM #(parameter ADDR_WIDTH = 8, parameter DATA_WIDTH = 16, parameter INIT_FILE = "") (
    input  logic [ADDR_WIDTH-1:0] read_addr,
    output logic [DATA_WIDTH-1:0] read_data,
    input  logic [ADDR_WIDTH-1:0] write_addr,
    input  logic write_enable,
    input  logic [DATA_WIDTH-1:0] write_data,
    input  logic clk
);

    logic [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];
    
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, memory);
        end
    end
    
    always_ff @(posedge clk) begin
        if (write_enable) begin
            memory[write_addr] <= write_data;
        end
        read_data <= memory[read_addr];
    end
    
endmodule
