module datapath #(parameter WIDTH = 8, parameter DEPTH = 16, parameter PAR_WRITE = 1, parameter PAR_READ = 1) (
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] data_in [PAR_WRITE-1:0],
    input wire write_enable,
    input wire read_enable,
    output reg [WIDTH-1:0] data_out [PAR_READ-1:0],
    output wire full,
    output wire empty
);
    input wire [$clog2(DEPTH)-1:0] w_address;
    input wire [$clog2(DEPTH)-1:0] r_address;
    input wire [$clog2(DEPTH)-1:0] len;

    up_down_counter #(.WIDTH(WIDTH), .UP_STEP(PAR_WRITE), .DOWN_STEP(PAR_READ)) len_counter (
        .clk(clk),
        .rst(rst),
        .up_enable(write_enable),
        .down_enable(read_enable),
        .count(len)
    );

    configurable_counter #(.WIDTH(WIDTH), .STEP(PAR_WRITE)) write_counter (
        .clk(clk),
        .rst(rst),
        .enable(write_enable),
        .count(w_address)
    );

    configurable_counter #(.WIDTH(WIDTH), .STEP(PAR_READ)) read_counter (
        .clk(clk),
        .rst(rst),
        .enable(read_enable),
        .count(r_address)
    );

    wire [$clog2(DEPTH)-1:0] len_add;
    wire len_add_co;

    assign {len_add_co, len_add} = len + PAR_WRITE;
    assign full = len_add_co;

    wire [$clog2(DEPTH):0] len_sub;
    assign len_sub = {0, len} - (PAR_READ + 1);
    assign empty = len_sub[$clog2(DEPTH)];

    instant_buffer #(
        .SIZE(DEPTH),
        .WRITE_SIZE(PAR_WRITE),
        .READ_SIZE(PAR_READ),
        .DATA_WIDTH(WIDTH)
    ) circular_buffer (
        .in(data_in),
        .write_addr(w_address),
        .read_addr(r_address),
        .clk(clk),
        .rst(rst),
        // TODO add write enable
        .out(data_out)
    );

endmodule
