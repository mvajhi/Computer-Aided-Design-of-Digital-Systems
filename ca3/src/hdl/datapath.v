module datapath(
    input wire clk,
    input wire rst,
    input wire [15:0] in1,
    input wire [15:0] in2,
    // counters
    input wire cntr_3bit_en,
    input wire cntr_dual_en,
    input wire cntr_dual_end,

    // shift
    input wire load_shift1,
    input wire load_shift2,
    input wire en_shift1,
    input wire en_shift2,
    input wire sel_sh1,
    input wire sel_insh2,
    input wire sel_sh2,

    output wire cntr_dual_zero,
    output wire end_shift1,
    output wire end_shift2,
    output wire [31:0] result,
);




    // shift1
    wire [15:0] sh1_out;

    wire en_shift1_,
    multiplexer #(
        .WIDTH(1)
    ) sh1_en_mux (
        .in0(end_shift1),
        .in1(en_shift1),
        .sel(en_shift1),
        .out(en_shift1_)
    );

    wire [15:0] sh1_in;
    multiplexer #(
        .WIDTH(16)
    ) sh1_in_mux (
        .in0(in1),
        .in1(multi_result),
        .sel(sel_sh1),
        .out(sh1_in)
    );

    ShiftRegister #(
        .DATA_WIDTH(16)
    ) sh1 (
        .clk(clk),
        .rst(rst),
        .load(load_shift1),
        .shift_en(en_shift1_),
        .in(sh1_in),
        .in_sh(1'b0),
        .out(sh1_out)
    );

    // shift2
    wire [15:0] sh2_out;

    wire en_shift2_,
    multiplexer #(
        .WIDTH(1)
    ) sh2_en_mux (
        .in0(end_shift2),
        .in1(en_shift2),
        .sel(en_shift2),
        .out(en_shift2_)
    );

    wire [15:0] sh2_in;
    multiplexer #(
        .WIDTH(16)   
    ) sh2_in_mux (
        .in0(in2),
        .in1(16'b0),
        .sel(sel_sh2),
        .out(sh2_in)
    );
    
    wire sh2_insh;
    multiplexer #(
        .WIDTH(1)
    ) sh2_insh_mux (
        .in0(1'b0),
        .in1(sh1_out[15]),
        .sel(sel_insh2),
        .out(sh2_insh)
    );

    ShiftRegister #(
        .DATA_WIDTH(16)
    ) sh2 (
        .clk(clk),
        .rst(rst),
        .load(load_shift2),
        .shift_en(en_shift2_),
        .in(sh2_in),
        .in_sh(sh2_insh),
        .out(sh2_out)
    );

    // counter dual
    wire cntr_dual_en1, cntr_dual_en2;
    assign cntr_dual_en1 = (end_shift1 & end_shift2) & cntr_dual_en;
    assign cntr_dual_en2 = ~(end_shift1 ^ end_shift2) & cntr_dual_en;

    Counter_dual #(
        .WIDTH(4)
    ) cntr_dual (
        .clk(clk),
        .rst(rst),
        .en1(cntr_dual_en1),
        .en2(cntr_dual_en2),
        .en_d(cntr_dual_end),
        .init(4'b0000),
        .Zero(cntr_dual_zero)
    );

    // counter3bit
    wire cntr_3bit_co;
    Counter #(
        .WIDTH(3)
    ) cntr_3bit (
        .clk(clk),
        .rst(rst),
        .en(cntr_3bit_en),
        .load(1'b0),
        .in(3'b000),
        .co(cntr_3bit_co)
    );


    // logic
    assign end_shift1 = ~cntr_3bit_co & ~sh1_out[15];
    assign end_shift2 = ~cntr_3bit_co & ~sh2_out[15];

    // multiplier
    wire [15:0] multi_result;
    assign multi_result = sh1_out[15:8] * sh2_out[15:8];

    // result
    assign result = {sh1_out, sh2_out};
endmodule