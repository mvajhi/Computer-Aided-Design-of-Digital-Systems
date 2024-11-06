module instant_buffer #(
    parameter SIZE = 8,
    parameter WRITE_SIZE = 2,
    parameter READ_SIZE = 2,
    parameter DATA_WIDTH = 8
) (
    input wire [DATA_WIDTH-1:0] in [0:WRITE_SIZE-1],
    input wire [$clog2(SIZE)-1:0] write_addr,
    input wire [$clog2(SIZE)-1:0] read_addr,       
    input wire clk,
    input wire rst,
    input wire write_en,

    output wire [DATA_WIDTH-1:0] out [0:READ_SIZE-1]
);
    localparam SEL_WIDTH = $clog2(SIZE);
    localparam WRITE_SEL_WIDTH = $clog2(WRITE_SIZE);
    localparam READ_SEL_WIDTH = $clog2(READ_SIZE);

    // decoder
    wire [SIZE-1:0] write_addr_dec;
    decoder #(
        .SIZE(SIZE),
        .WRITE_SIZE(WRITE_SIZE)
    )
    dec (
       .in(write_addr),
       .en(write_en),
       .out(write_addr_dec) 
    );


    wire [DATA_WIDTH-1:0] reg_out [0:SIZE-1];
    generate
        genvar i;
        // instant_write
        for (i = 0; i < SIZE; i = i + 1) begin
            

            wire [WRITE_SEL_WIDTH-1:0] mux_select;
            wire [SEL_WIDTH:0] temp_result;
            assign temp_result = {1'b1, i} - write_addr;
            assign mux_select = temp_result[WRITE_SEL_WIDTH-1:0];

            wire [DATA_WIDTH-1:0] mux_out;
            multiplexer #(
                .SIZE(WRITE_SIZE),
                .DATA_WIDTH(DATA_WIDTH)
            )
            mux (
                .in(in),
                .select(mux_select),
                .out(mux_out)
            );

            register #(
                .DATA_WIDTH(DATA_WIDTH)
            )
            reg_ (
                .clk(clk),
                .rst(rst),
                .ld(write_addr_dec[i]),
                .in(mux_out),
                .out(reg_out[i])    
            );
        end

        for (i = 0; i < READ_SIZE; i = i + 1) begin
            multiplexer #(
                .SIZE(SIZE),
                .DATA_WIDTH(DATA_WIDTH)
            )
            mux (
                .in(reg_out),
                .select(read_addr + i[SEL_WIDTH-1:0]),
                .out(out[i])
            );
        end
    endgenerate
endmodule