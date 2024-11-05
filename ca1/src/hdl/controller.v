module controller (
    input wire clk,        
    input wire rst, 

    input wire start,     

    input wire lsb_cnt,       
    input wire end_shift1,       
    input wire end_shift2,       
    input wire co_cnt_sh,
    input wire co_cntr_ld,

    output reg initial_cnt_load,
    output reg initial_cnt_sh1,
    output reg initial_cnt_sh2,
    output reg load_shift1,
    output reg load_shift2,
    output reg en_cnt_load,
    output reg en_cnt_sh1,
    output reg en_cnt_sh2,
    output reg en_cnt_sh,
    output reg en_shift1,
    output reg en_shift2,
    output reg ld_cnt_sh,
    output reg load_result,
    output reg shift_result,
    output reg wr_ram,
    output reg done
);

    // State encoding
    parameter IDLE      = 4'b0000; 
    parameter START     = 4'b0001;
    parameter LOAD1     = 4'b0010; 
    parameter LOAD2     = 4'b0011; 
    parameter LOAD3     = 4'b1000; 
    parameter FIND_BITS = 4'b0100; 
    parameter SHIFT_RES = 4'b0101; 
    parameter WR        = 4'b0110; 
    parameter DONE      = 4'b0111;

    reg [3:0] current_state, next_state;

    // Sequential block for state transitions
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Combinational block for next state logic
    always @(*) begin
        next_state = IDLE;
        case (current_state)
            IDLE: begin
                next_state = start ? START : IDLE;
            end

            START: begin
                next_state = start ? START : LOAD1;
            end

            LOAD1: begin
                next_state = LOAD2;  
            end

            LOAD2: begin
                next_state = LOAD3;
            end

            LOAD3: begin
                next_state = FIND_BITS;
            end

            FIND_BITS: begin
                next_state = (end_shift1 || end_shift2) == 1 ? FIND_BITS : SHIFT_RES;
            end

            SHIFT_RES: begin
                next_state = co_cnt_sh ? WR : SHIFT_RES;
            end

            WR: begin
                next_state = co_cntr_ld ? DONE : LOAD1; 
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Combinational block for output logic
    always @(*) begin
        {initial_cnt_load,initial_cnt_sh1,en_shift1,en_shift2,
        initial_cnt_sh2,en_cnt_load,en_cnt_sh1,load_shift1,load_shift2,
        en_cnt_sh2,en_cnt_sh,load_result,shift_result,wr_ram,done, ld_cnt_sh} = 25'b0;
        case (current_state)
            IDLE: begin
                {initial_cnt_load,
                initial_cnt_sh1,
                initial_cnt_sh2} = 4'b1111;
            end

            START: begin
            end

            LOAD1: begin
                // load_shift1 = lsb_cnt;
                // load_shift2 = ~lsb_cnt;
                {en_cnt_load} = 2'b11;
            end

            LOAD2: begin
                load_shift1 = lsb_cnt;
                load_shift2 = ~lsb_cnt;
                {en_cnt_load} = 2'b11;
            end

            LOAD3: begin
                load_shift1 = lsb_cnt;
                load_shift2 = ~lsb_cnt;
                // {en_cnt_load} = 2'b11;
            end

            // LOAD4: begin
            //     load_shift1 = lsb_cnt;
            //     load_shift2 = ~lsb_cnt;
            //     {en_cnt_load} = 2'b11;
            // end



            FIND_BITS: begin
                {en_cnt_sh1, en_cnt_sh2} = {end_shift1, end_shift2};
                {en_shift1, en_shift2} = {end_shift1, end_shift2};
                 {en_cnt_sh, load_result, ld_cnt_sh} = 5'b11111;
            end

            SHIFT_RES: begin
                {en_cnt_sh, shift_result} = 2'b11;
            end

            WR: begin
                {initial_cnt_sh1,
                initial_cnt_sh2} = 4'b1111;
                wr_ram = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end

            default: begin
            end
        endcase
    end

endmodule