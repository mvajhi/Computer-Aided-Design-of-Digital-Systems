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
    output wire  stall_out,
    output wire  done_out,
    output wire  co_filter_out
);

wire [DATA_WIDTH-1:0] data;
wire done;
wire stall;

Mux2to1 #(DATA_WIDTH) Mux_ld(in, out, stall_out, data);
Mux2to1 #(1) Mux_ld2(stall_in, stall_out, stall_out, stall);
Mux2to1 #(1) Mux_ld3(done_in, done_out, stall_out, done);
Mux2to1 #(1) Mux_ld4(co_filter, co_filter_out, stall_out, co_filter);

Register #(DATA_WIDTH) Reg_data(clk, rst, 1'b1, data, out);
Register #(1) Reg_stall(clk, rst, 1'b1, stall, stall_out);
Register #(1) Reg_done(clk, rst, 1'b1, done, done_out);
Register #(1) Reg_co_filter(clk, rst, 1'b1, co_filter, co_filter_out);


endmodule