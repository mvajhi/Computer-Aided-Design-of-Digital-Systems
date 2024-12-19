module Pipeline2 #(
    parameter DATA_WIDTH = 8
) (
    input  wire clk,
    input  wire rst,
    input  wire stall_in,
    input  wire done_in,
    input  wire co_filter,
    input  wire [DATA_WIDTH-1:0] in,

    output wire  [DATA_WIDTH-1:0] out,
    output wire  done_out,
    output wire  co_filter_out
);

Register #(DATA_WIDTH) Reg_data(clk, rst, !stall_in, in, out);
Register #(1) Reg_done(clk, rst, !stall_in, done_in, done_out);
Register #(1) Reg_co_filter(clk, rst, !stall_in, co_filter, co_filter_out);


endmodule