module controller #(parameter N = 3'b111) (
    input        clk,
    input        rst,
    input        start,
    input        in_flag_next,
    output reg      ready,
    output reg      out_valid,
    output reg      error,
    output reg      sel_x,
    output reg      sel_num,
    output reg      sel_sum,
    output reg      sel_i,
    output reg      sel_overflow,
    output reg      out_flag_next
);
    parameter IDLE = 1'b0;
    parameter COMPUTE = 1'b1;

    wire big_N = N > 3'd3;

    reg state, next_state;

    always @(posedge clk , posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                next_state = start ? COMPUTE : IDLE;
            end
            COMPUTE: begin
                next_state = COMPUTE;
            end
        endcase
    end

    always @(*) begin
        {ready, error, out_valid} = 3'b000;
        case (state)
            IDLE: begin
                ready = start;
                out_valid = start && !big_N;
            end
            COMPUTE: begin
                ready = !in_flag_next || !big_N;
                out_valid = in_flag_next || !big_N;
            end
        endcase
    end

    assign out_flag_next = ready;
    assign sel_x = !ready;
    assign sel_num = !ready;
    assign sel_sum = !ready;
    assign sel_i = !ready;
    assign sel_overflow = !ready;

    assign error = 1'b0;

endmodule
