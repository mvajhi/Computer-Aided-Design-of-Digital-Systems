module main_controller (
    input clk,
    input rst,
    input start,
    input av_data,
    input av_filter,
    input co_filter,
    input end_of_row,
    input end_of_filter,
    output reg ld_stride,
    output reg ld_fileSize,
    output reg put_data,
    output reg put_filter,
    output reg clear_sum,
    output reg store_buffer,
    output reg next_filter,
    output reg next_row
)
    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter INIT_SIZE = 2'b10;
    parameter AVAILABLE = 2'b11;

    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = IDLE;
        case (current_state)
            IDLE: next_state = start ? START : IDLE;
            START: next_state = start ? START : INIT_SIZE;
            INIT_SIZE: next_state = AVAILABLE;
            AVAILABLE: next_state = AVAILABLE;
        endcase
    end

    always @(*) begin
        {ld_stride ,ld_fileSize ,put_data ,
        put_filter ,clear_sum ,store_buffer ,
        next_filter ,next_row} = 8'b0;
        case (current_state)
            IDLE: begin
                // do nothing
            end

            START: begin
                // do nothing
            end

            INIT_SIZE: begin
                ld_fileSize = 1'b1;
                ld_stride = 1'b1;
            end

            AVAILABLE: begin
               put_data = av_data && av_filter;
               put_filter = av_data && av_filter;
               clear_sum = co_filter;
               store_buffer = co_filter;
               next_filter = end_of_row;
               next_row = end_of_filter && end_of_row;
            end
        endcase
    end


endmodule