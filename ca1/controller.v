module controller (
    input wire clk,        
    input wire rst, 

    input wire start,      
    input wire lsb_cnt,       
    input wire en_shift1,       
    input wire en_shift2,       
    input wire co_cnt_sh,

    output reg initial_cnt_load,
    output reg initial_cnt_sh,
    output reg initial_cnt_sh1,
    output reg initial_cnt_sh2,
    output reg load_shift_16,
    output reg en_cnt_load,
    output reg en_cnt_sh1,
    output reg en_cnt_sh2,
    output reg en_cnt_sh,
    output reg load_result,
    output reg shift_result,
    output reg wr_ram,
    output reg done,
);

    // State encoding
    typedef enum reg [2:0] {
        IDLE      = 3'b000, 
        START    = 3'b001, 
        LOAD1     = 3'b010, 
        LOAD2     = 3'b011, 
        FIND_BITS = 3'b100, 
        SHIFT_RES = 3'b101, 
        WR        = 3'b110, 
        DONE        = 3'b111 
    } state_t;

    state_t current_state, next_state;

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
                next_state = (en_shift1 || en_shift2) ? FIND_BITS : SHIFT_RES;
            end

            SHIFT_RES: begin
                next_state = co_cnt_sh ? WR : SHIFT_RES;
            end

            WR: begin
                next_state = co_cnt_load ? DONE : LOAD1; 
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
                {load_shift_16, en_cnt_load} = 2'b11;
            end

            LOAD2: begin
                {load_shift_16, en_cnt_load} = 2'b11;
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