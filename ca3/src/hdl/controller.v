module controller (
    input wire clk,        
    input wire rst, 

    input wire start,     

    input wire cntr_dual_co,
    input wire end_shift1,       
    input wire end_shift2,       

    // counters
    output wire cntr_3bit_en,
    output wire cntr_dual_en,
    output wire cntr_dual_end,
    output wire load_shift1,
    output wire load_shift2,
    output wire en_shift1,
    output wire en_shift2,
    output wire sel_sh1,
    output wire sel_insh2,
    output wire sel_sh2,
    output wire done
);

    // State encoding
    parameter IDLE         = 7'b0000001; 
    parameter START        = 7'b0000010;
    parameter LOAD         = 7'b0000100; 
    parameter SHIFT        = 7'b0001000; 
    parameter LOAD_RESULT  = 7'b0010000; 
    parameter SHIFT_RESULT = 7'b0100000; 
    parameter DONE         = 7'b1000000;

    wire [6:0] ps;
    wire state_shift;

    wire other;
    wire end_sh1_nor_2;
    C1 c1_inst (
        // LOAD and OTHERS
        .A0(other),
        .A1(1'b1),
        .SA(ps[2]),

        // IDLE and START
        .B0(ps[1]),
        .B1(ps[0]),
        .SB(start),  

        .S0(ps[0]),
        .S1(ps[1]),
        .F(state_shift)
    );

    C1 c1_inst_other (
        .A0(1'b1),
        .A1(end_sh1_nor_2),
        .SA(ps[3]),

        .B0(1'b1),
        .B1(cntr_dual_co),
        .SB(ps[5]),  // SHIFT_RESULT

        .S0(ps[5]), // SHIFT_RESULT
        .S1(ps[6]), // DONE
        .F(other)
    );

    nor_mod nor_inst_end_sh1 (
        .A(end_shift1),
        .B(end_shift2),
        .out(end_sh1_nor_2)
    );

        
    /* Signal assignment */
    // LOAD
    wire loads_states;
    or_mod or_loads (
        .a(ps[2]),
        .b(ps[4]),
        .y(loads_states)
    );
    assign load_shift1 = loads_states;
    assign load_shift2 = loads_states;

    // SHIFT
    assign cntr_3bit_en = ps[3];
    assign cntr_dual_en = ps[3];

    // LOAD_RESULT
    assign sel_sh1 = ps[4];
    assign sel_sh2 = ps[4];

    // SHIFT_RESULT
    assign cntr_dual_end = ps[5];
    assign en_shift1 = ps[5];
    assign en_shift2 = ps[5];
    assign sel_insh2 = ps[5];

    // DONE
    assign done = ps[6];

    wire is_first, other_first;
    C1 c1_inst_is_first (
        .A0(other_first),
        .A1(1'b0),
        .SA(loads_states),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),  
        .S0(ps[0]),
        .S1(ps[1]),
        .F(is_first)
    );

    C1 c1_inst_other_first (
        .A0(1'b1),
        .A1(1'b0),
        .SA(ps[4]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),  
        .S0(ps[3]),
        .S1(ps[5]),
        .F(other_first)
    );

    ShiftRegister #(
        .WIDTH(7)
    ) sh1 (
        .clk(clk),
        .rst(rst),
        .load(is_first),
        .shift_en(state_shift),
        .in(IDLE),
        .in_sh(ps[6]),
        .out(ps)
    );

endmodule