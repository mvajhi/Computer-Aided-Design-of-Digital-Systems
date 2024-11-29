module controller (
    input wire clk,        
    input wire rst, 

    input wire start,     

    input wire Zero,
    input wire end_shift1,       
    input wire end_shift2,       

    // counters
    output reg cntr_3bit_en,
    output reg cntr_dual_en,
    output reg cntr_dual_end,

    // shift
    output reg load_shift1,
    output reg load_shift2,
    output reg en_shift1,
    output reg en_shift2,
    output reg sel_sh1,
    output reg sel_insh2,
    output reg sel_sh2,

    output reg done
);

    // State encoding
    parameter IDLE = 3'd0; 
    parameter START = 3'd1;
    parameter LOAD = 3'd2; 
    parameter SHIFT = 3'd3; 
    parameter LOAD_RESULT = 3'd4; 
    parameter SHIFT_RESULT = 3'd5; 
    parameter DONE = 3'd6;

    reg [3:0] ps, ns;

    always @(*) begin
        ns = ps;
        case (ps)
            IDLE: begin
                ns = start ? START : IDLE;
            end

            START: begin
                ns = start ? START : LOAD;
            end

            LOAD: begin
                ns = SHIFT;
            end

            SHIFT: begin
                ns = (end_shift1 || end_shift2) ? SHIFT : LOAD_RESULT;
            end

            LOAD_RESULT: begin
                ns = SHIFT_RESULT;
            end

            SHIFT_RESULT: begin
                ns = Zero ? DONE : SHIFT_RESULT;
            end

            DONE: begin
                ns = IDLE;
            end

        endcase
    end
        
    always @(*) begin
        cntr_3bit_en = 0;
        cntr_dual_en = 0;
        cntr_dual_end = 0;
        load_shift1 = 0;
        load_shift2 = 0;
        en_shift1 = 0;
        en_shift2 = 0;
        sel_sh1 = 0;
        sel_insh2 = 0;
        sel_sh2 = 0;
        done = 0;

        case (ps)
            LOAD: begin
                load_shift1 = 1;
                load_shift2 = 1;
            end

            SHIFT: begin
                cntr_3bit_en = 1;
                cntr_dual_en = 1;
            end

            LOAD_RESULT: begin
                sel_sh1 = 1;
                sel_sh2 = 1;
                load_shift1 = 1;
                load_shift2 = 1;
            end

            SHIFT_RESULT: begin
                cntr_dual_end = 1;
                en_shift1 = 1;
                en_shift2 = 1;
                sel_insh2 = 1;
            end

            DONE: begin
                done = 1;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ps <= IDLE;
        end else begin
            ps <= ns;
        end
    end

endmodule