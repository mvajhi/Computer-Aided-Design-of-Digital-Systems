module datapath(
    input wire clk,
    input wire rst,
    // counters
    input wire cntr_ld_init,
    input wire cntr_ld_en,

    output wire lsb_cnt,
    input wire en_sh_16bit,

    output wire end_shift1,
    output wire end_shift2,
);

    // Internal signals
    wire [15:0] shift1_out;
    wire [15:0] shift2_out;

    wire [3:0] addr_in_ram;
    wire [15:0] data_in_ram;
    In_RAM #(.ADDR_WIDTH(4),.DATA_WIDTH(16),) in_ram
    (
        .clk(clk),
        .rst(rst),
        .addr(addr_in_ram),
        .data(data_in_ram)
    )

    wire [3:0] out_cntr_ld;
    Counter #(.WIDTH(4)) cntr_ld
    (
        .clk(clk),
        .rst(rst),
        .en(cntr_ld_en),
        .init(cntr_ld_init),
        .out(out_cntr_ld),
        .co(co_cntr_ld)
    );

    assign lsb_cnt = out_cntr_ld[0];
    assign addr_in_ram = out_cntr_ld;
    assign addr_out_ram = out_cntr_ld[2:0] - 3'b001;

    wire load_shift1 = out_cntr_ld[0] && en_sh_16bit;
    wire load_shift2 = ~out_cntr_ld[0] && en_sh_16bit;

    wire [15:0] out_shift1;
    ShiftRegister #(16) shift1
    (
        .clk(clk),
        .rst(rst),
        .load(load_shift1),
        .shift_en(end_shift1),
        .in(data_in_ram),
        .out(out_shift1)
    );

    wire [15:0] out_shift2;
    ShiftRegister #(16) shift2
    (
        .clk(clk),
        .rst(rst),
        .load(load_shift2),
        .shift_en(end_shift2),
        .in(out_shift1),
        .out(out_shift2)
    );

    Counter #(.WIDTH(3)) cntr_sh1
    (
        .clk(clk),
        .rst(rst),
        .init(4'b0000),
        .en(end_shift1),
        .out(out_cntr_sh1)
    );

endmodule


