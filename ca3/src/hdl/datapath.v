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

    output wire cntr_dual_co,
    output wire end_shift1,
    output wire end_shift2,
    output wire [31:0] result
);
    wire [15:0] multi_result;

    // shift1
    wire [15:0] sh1_out;

    wire en_shift1_;
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
        .WIDTH(16)
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

    wire en_shift2_;
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
        .WIDTH(16)
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

    // wire cntr_dual_en1_ = (end_shift1 & end_shift2) & cntr_dual_en;
    // wire cntr_dual_en2_ = ~(end_shift1 ^ end_shift2) & cntr_dual_en;

    C2 c2_inst_en1 (
        .A1(cntr_dual_en), .B1(cntr_dual_en),
        .A0(end_shift1), .B0(end_shift2),
        .D(4'b1000),
        .out(cntr_dual_en1)
    );

    wire xor_inst_en2_out;
    xor_mod xor_inst_en2 (
        .A(end_shift1),
        .B(end_shift2),
        .out(xor_inst_en2_out)
    );

    C1 c1_inst_en2 (
        .A0(cntr_dual_en),
        .A1(1'b0),
        .SA(xor_inst_en2_out),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),  
        .S0(1'b0), .S1(1'b0),
        .F(cntr_dual_en2)
    );

    Counter_dual #(
        .WIDTH(4)
    ) cntr_dual (
        .clk(clk),
        .rst(rst),
        .en1(cntr_dual_en1),
        .en2(cntr_dual_en2),
        .en_d(cntr_dual_end),
        .init(4'b0000),
        .co(cntr_dual_co)
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
    nor_mod nor_inst1 (
        .A(cntr_3bit_co),
        .B(sh1_out[15]),
        .out(end_shift1)
    );
    nor_mod nor_inst2 (
        .A(cntr_3bit_co),
        .B(sh2_out[15]),
        .out(end_shift2)
    );

    // multiplier
    multiplier #(
        .WIDTH(8)
    ) mult (
        .in1(sh1_out[15:8]),
        .in2(sh2_out[15:8]),
        .out(multi_result)
    );

    // result
    assign result = {sh2_out, sh1_out};
endmodule