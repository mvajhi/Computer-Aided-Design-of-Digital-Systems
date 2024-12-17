`define SIMULATION // Comment this out for synthesis

module Buffer #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 4,
    parameter PAR_WRITE = 1,
    parameter PAR_READ = 1,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input clk,
    input wen,
    input [ADDR_WIDTH - 1 : 0] waddr, //write address
    input [ADDR_WIDTH - 1 : 0] raddr, //read address
    input [PAR_WRITE * DATA_WIDTH - 1 : 0] din, //write data in
    output [PAR_READ * DATA_WIDTH - 1 : 0] dout //read data out
);
    localparam DEPTH_POW2 = (DEPTH & (DEPTH - 1)) == 0;

    reg [DATA_WIDTH - 1 : 0] memory [0 : DEPTH - 1];
    
    reg [$clog2(PAR_WRITE) : 0] par_cnt;

    reg [ADDR_WIDTH - 1 : 0] waddr_mod, waddr_plus_par_cnt;

    always @(posedge clk) begin
    if (wen) begin
        for(par_cnt = 0; par_cnt < PAR_WRITE; par_cnt = par_cnt + 1) begin
            waddr_plus_par_cnt = waddr + par_cnt;

            if (DEPTH_POW2) begin
                waddr_mod = waddr_plus_par_cnt[ADDR_WIDTH - 1 : 0];
            end else begin
                waddr_mod = waddr_plus_par_cnt;
                if (waddr_plus_par_cnt >= DEPTH)
                    waddr_mod = waddr_plus_par_cnt - DEPTH;
            end

            memory[waddr_mod] <= din[par_cnt * DATA_WIDTH +: DATA_WIDTH];
        end
    end
end

    genvar i;
    generate
        for (i = 0; i < PAR_READ; i = i + 1) begin : read_loop
            wire [ADDR_WIDTH : 0] raddr_plus_i = raddr + i;
            wire [ADDR_WIDTH - 1 : 0] ind;

            if (DEPTH_POW2) begin
                assign ind = raddr_plus_i[ADDR_WIDTH - 1 : 0];
            end else begin
                assign ind = (raddr_plus_i >= DEPTH) ? raddr_plus_i - DEPTH : raddr_plus_i;
            end

            assign dout[i * DATA_WIDTH +: DATA_WIDTH] = memory[ind];
        end
    endgenerate

    `ifdef SIMULATION
    integer c;
    initial begin
        for (c = 0; c < DEPTH; c = c + 1)
            memory[c] = 0;
    end
    `endif
        
endmodule