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
    output reg initial_cnt_sh,
    output reg initial_cnt_sh1,
    output reg initial_cnt_sh2,
    output reg en_sh_16bit,
    output reg en_cnt_load,
    output reg en_cnt_sh1,
    output reg en_cnt_sh2,
    output reg en_cnt_sh,
    output reg load_result,
    output reg shift_result,
    output reg wr_ram,
    output reg done
);

    // State encoding
    parameter IDLE      = 3'b000; 
    parameter START    = 3'b001;
    parameter LOAD1     = 3'b010; 
    parameter LOAD2     = 3'b011; 
    parameter FIND_BITS = 3'b100; 
    parameter SHIFT_RES = 3'b101; 
    parameter WR        = 3'b110; 
    parameter DONE        = 3'b111;

    reg [2:0] current_state, next_state;

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
                next_state = lsb_cnt ? LOAD2 : LOAD1;  
            end

            LOAD2: begin
                next_state = FIND_BITS;
            end

            FIND_BITS: begin
                next_state = (end_shift1 || end_shift2) ? FIND_BITS : SHIFT_RES;
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
        {initial_cnt_load,inital_cnt_sh,inital_cnt_sh1,
        inital_cnt_sh2,en_sh_16bit,en_cnt_load,en_cnt_sh1,
        en_cnt_sh2,en_cnt_sh,load_result,shift_result,wr_ram,done} = 13'b0;
        case (current_state)
            IDLE: begin
                {initial_cnt_load,
                initial_cnt_sh,
                initial_cnt_sh1,
                initial_cnt_sh2} = 4'b1111;
            end

            START: begin
            end

            LOAD1: begin
                {en_sh_16bit, en_cnt_load} = 2'b11;
            end

            LOAD2: begin
                {en_sh_16bit, en_cnt_load} = 2'b11;
            end

            FIND_BITS: begin
                {en_cnt_sh1, en_cnt_sh2,
                 en_cnt_sh, load_result} = 4'b1111;
            end

            SHIFT_RES: begin
                {en_cnt_sh, shift_result} = 2'b11;
            end

            WR: begin
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