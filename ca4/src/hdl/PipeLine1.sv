module Pipeline1 #(
    parameter DATA_WIDTH = 8
) (
    input  wire clk,
    input  wire rst,
    input  wire stall_in,
    input  wire done_in,
    input  wire co_filter,
    input  wire [DATA_WIDTH-1:0] in,
    input  wire clear,

    output wire  clear_out,
    output wire  [DATA_WIDTH-1:0] out,
    output wire  stall_out,
    output wire  done_out,
    output wire  co_filter_out
);

Register #(DATA_WIDTH) Reg_data(clk, rst, 1'b1, in, out);
Register #(1) Reg_stall(clk, rst, 1'b1, stall_in, stall_out);
Register #(1) Reg_done(clk, rst, 1'b1, done_in, done_out);
Register #(1) Reg_co_filter(clk, rst, 1'b1, co_filter, co_filter_out);
Register #(1) Reg_clear(clk, rst, 1'b1, clear, clear_out);

endmodule