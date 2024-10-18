module datapath(
    input wire clk,
    input wire rst,
    // counters
    input wire cntr_ld_init,
    input wire cntr_ld_en,
    input wire cntr_sh_en,
    input wire cntr_sh_ld,
    input wire cntr_sh1_en,
    input wire cntr_sh2_en,

    // shift
    input wire en_sh_16bit,
    input wire sh_result_ld,
    input wire sh_result_shift,

    // ram
    input wire wr_out_ram,

    output wire lsb_cnt,

    output wire co_cnt_sh,
    output wire co_cntr_ld, 
    output wire cntr_sh1_init,
    output wire cntr_sh2_init,
    
    output wire end_shift1,
    output wire end_shift2
);

    wire [3:0] addr_in_ram;
    wire [15:0] data_in_ram;
    In_RAM in_ram
    (
        .clk(clk),
        .rst(rst),
        .addr(addr_in_ram),
        .data_out(data_in_ram)
    );

    wire [3:0] out_cntr_ld;
    
    wire [2:0] addr_out_ram = out_cntr_ld[2:0] - 3'b001;

    // counter load
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

    ///////////////////////////////////////
    wire load_shift1 = out_cntr_ld[0] && en_sh_16bit;
    wire load_shift2 = ~out_cntr_ld[0] && en_sh_16bit;
    wire [15:0] out_shift1;
    // shift 1
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
    // shift 2
    ShiftRegister #(16) shift2
    (
        .clk(clk),
        .rst(rst),
        .load(load_shift2),
        .shift_en(end_shift2),
        .in(data_in_ram),
        .out(out_shift2)
    );


    wire [15:0] shift_result_in = out_shift1[15:8] * out_shift2[15:8];
    wire [31:0] shift_result_out;
    // shift result
    ShiftRegister #(32) shift_result
    (
        .clk(clk),
        .rst(rst),
        .load(sh_result_ld),
        .shift_en(sh_result_shift),
        .in({16'b0, shift_result_in}),
        .out(shift_result_out)
    );
    ///////////////////////////////////

    // out ram
    Out_RAM out_ram
    (
        .clk(clk),
        .wr(wr_out_ram),
        .addr(addr_out_ram),
        .data_in(shift_result_out)
    );

    // counters

    wire [2:0] out_cntr_sh1;
    // counter shift 1
    Counter #(.WIDTH(3)) cntr_sh1
    (
        .clk(clk),
        .rst(rst),
        .init(cntr_sh1_init),
        .en(cntr_sh1_en),
        .out(out_cntr_sh1),
        .co(co_cntr_sh1)
    );
    assign end_shift1 = ~(co_cntr_sh1 || out_shift1[15]);

    // counter shift 2
    wire [2:0] out_cntr_sh2;
    Counter #(.WIDTH(3)) cntr_sh2
    (
        .clk(clk),
        .rst(rst),
        .init(cntr_sh2_init),
        .en(cntr_sh2_en),
        .out(out_cntr_sh2),
        .co(co_cntr_sh2)
    );
    assign end_shift2 = ~(co_cntr_sh2 || out_shift2[15]);


    wire [3:0] cntr_sh_in = out_cntr_sh1 + out_cntr_sh2;
    // counter shift
    Counter_in #(.WIDTH(4)) cntr_sh
    (
        .clk(clk),
        .rst(rst),
        .en(cntr_sh_en),
        .load(cntr_sh_ld),
        .in(cntr_sh_in),
        .co(co_cnt_sh)
    );


endmodule


