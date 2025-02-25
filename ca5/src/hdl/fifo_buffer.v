module Fifo_buffer #(
    parameter DATA_WIDTH = 16, //data bitwidth
    parameter PAR_WRITE = 1,
    parameter PAR_READ = 1,
    parameter DEPTH = 4 //total size
) (
    input clk,
    input rstn, //active low reset
    input clear, //clear buffer counters
    input ren, //read enable 
    input wen, //write enable
    input [PAR_WRITE * DATA_WIDTH - 1 : 0] din, //input data to write into the buffer
    output [PAR_READ * DATA_WIDTH - 1 : 0] dout, //output data to read from the buffer
    output full, //output to signal if buffer is full
    output empty //output to signal if buffer is empty
);

//for cicular buffer, consider one more register as one is always unused
localparam BUFFER_DEPTH = DEPTH + 1;
localparam BUFFER_ADDR_WIDTH = $clog2(BUFFER_DEPTH);
localparam PAR_DATA_WRITE = PAR_WRITE == 1 ? PAR_WRITE - 1 : PAR_WRITE;
localparam PAR_DATA_READ = PAR_READ == 1 ? PAR_READ - 1 : PAR_READ;

reg [BUFFER_ADDR_WIDTH - 1 : 0] raddr_cnt, waddr_cnt;
wire buffer_wen, buffer_ren;
wire at_max_write, at_max_read;


assign buffer_wen = wen & !full;
assign buffer_ren = ren & !empty;

assign at_max_write = waddr_cnt >= BUFFER_DEPTH;
assign at_max_read = raddr_cnt >= DEPTH;

wire [PAR_DATA_WRITE : 0] full_conditions;
wire [PAR_DATA_READ : 0] empty_conditions;

genvar k;
generate
    for (k = 0; k <= PAR_DATA_WRITE; k = k + 1) begin : FULL_COND_GEN
        wire [BUFFER_ADDR_WIDTH-1:0] waddr_cnt_next = waddr_cnt + (k+1);
        assign full_conditions[k] = (waddr_cnt_next >= BUFFER_DEPTH) ? (waddr_cnt_next - BUFFER_DEPTH) == raddr_cnt : waddr_cnt_next == raddr_cnt;
    end
endgenerate

genvar r;
generate
    for (r = 0; r <= PAR_DATA_READ; r = r + 1) begin : EMPTY_COND_GEN
        wire [BUFFER_ADDR_WIDTH - 1 : 0] raddr_cnt_next = raddr_cnt + r;
        assign empty_conditions[r] = (raddr_cnt_next >= DEPTH) ? (raddr_cnt_next - DEPTH) == waddr_cnt : raddr_cnt_next == waddr_cnt;
    end
endgenerate

assign full = |full_conditions;
assign empty = |empty_conditions;

Buffer #(
    .DATA_WIDTH(DATA_WIDTH),
    .PAR_WRITE(PAR_WRITE),
    .PAR_READ(PAR_READ),
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH)
) buffer (
    .clk(clk),
    .wen(buffer_wen),
    .waddr(waddr_cnt),
    .raddr(raddr_cnt),
    .din(din),
    .dout(dout)
);

always @(posedge clk) begin
    if (!rstn) begin
        raddr_cnt <= 0;
        waddr_cnt <= 0;
    end
    else if (clear) begin
        raddr_cnt = 0;
        waddr_cnt = 0;
    end
    else begin
        if (buffer_wen) begin
            waddr_cnt = waddr_cnt + PAR_WRITE;   
            if (waddr_cnt >= BUFFER_DEPTH)
                waddr_cnt = waddr_cnt - BUFFER_DEPTH;

        end
        

        if (buffer_ren) begin
            raddr_cnt = raddr_cnt + PAR_READ;
            if (raddr_cnt >= BUFFER_DEPTH)
                raddr_cnt = raddr_cnt - BUFFER_DEPTH;
        end
        
    end
end

endmodule


module Psum_scratch_pad #(
    parameter DATA_WIDTH = 16, //data bitwidth
    parameter PAR_WRITE = 1,
    parameter PAR_READ = 1,
    parameter DEPTH = 4 //total size
) (
    input clk,
    input rstn, //active low reset
    input clear, //clear buffer counters
    input ren, //read enable 
    input wen, //write enable
    input freeze, //write enable
    input same_addr, //write enable
    input [PAR_WRITE * DATA_WIDTH - 1 : 0] din, //input data to write into the buffer
    output [PAR_READ * DATA_WIDTH - 1 : 0] dout, //output data to read from the buffer
    output full, //output to signal if buffer is full
    output empty //output to signal if buffer is empty
);
    wire [DATA_WIDTH - 1 : 0] din_buf;
    wire [DATA_WIDTH - 1 : 0] dout_buf;
    wire [DATA_WIDTH - 1 : 0] din_reg;
    wire [DATA_WIDTH - 1 : 0] dout_reg;
    wire tmp;
    reg wen_buf;
    wire ren_buf;
    wire full_buf;
    reg rst_reg;
    reg rstn_buf;

    always @(posedge clk) begin
        if (rstn_buf === 1'bX) begin
            rstn_buf <= 1'b0;
        end
        else begin
            rstn_buf <= 1'b1;
        end
    end

    Fifo_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .PAR_WRITE(PAR_WRITE),
        .PAR_READ(PAR_READ),
        .DEPTH(DEPTH)
    ) psum_buffer (
        .clk(clk),
        .rstn(rstn_buf),
        .clear(clear),
        .ren(ren_buf),
        .wen(wen_buf),
        .din(din_buf),
        .dout(dout_buf),
        .full(full),
        .empty(empty)
    );

    Register #(
        .SIZE(DATA_WIDTH)
    ) reg_tmp (
        .clk(clk),
        .rst(~rstn | rst_reg),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(dout_reg),
        .inval(din_reg),
        .ld_en(wen_reg),
        .msb(tmp)
    );

    Mux2to1 #(
        .WIDTH(DATA_WIDTH)
    ) mux_out (
        .a(dout_buf),
        .b(dout_reg),
        .sel(same_addr),
        .c(dout)
    );

    assign din_buf = dout_reg;
    assign din_reg = din;
    assign ren_buf = ren;
    assign wen_reg = wen;

reg is_freeze;

always @(posedge clk) begin
    wen_buf <= 1'b0;
    if (freeze == 1'b0 && is_freeze == 1'b1 && same_addr) begin
        is_freeze <= 1'b0;
        wen_buf <= 1'b1;
    end
    if (freeze && same_addr) begin
        is_freeze <= 1'b1;
    end
    rst_reg <= wen_buf;
end

endmodule
