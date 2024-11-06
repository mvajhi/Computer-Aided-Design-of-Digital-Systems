module fifo_buffer #(parameter DATA_WIDTH = 8, parameter SIZE = 16, parameter PAR_WRITE = 1, parameter PAR_READ = 1) (
    input wire clk,
    input wire rst,
    input wire [DATA_WIDTH-1:0] data_in [PAR_WRITE-1:0],
    input wire write_enable,
    input wire read_enable,
    output reg [DATA_WIDTH-1:0] data_out [PAR_READ-1:0],
    output wire full,
    output wire empty,
    output wire valid,
    output wire ready
);

    datapath #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIZE(SIZE),
        .PAR_WRITE(PAR_WRITE),
        .PAR_READ(PAR_READ)
    ) dp (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .write_enable(done_writer),
        .read_enable(done_reader),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    handshake_controller handshake_writer (
        .clk(clk),
        .rst(rst),
        .request(write_enable),
        .accept(ready),
        .done(done_writer)
    );

    handshake_controller handshake_reader (
        .clk(clk),
        .rst(rst),
        .request(read_enable),
        .accept(valid),
        .done(done_reader)
    );

endmodule