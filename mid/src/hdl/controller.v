module controller #(parameter N = 3'b111) (
    input        clk,
    input        rst,
    input        start,
    input        in_valid,
    input        flag,
    output       ready,
    output       out_valid,
    output       error,
    output       sel_x,
    output       sel_num,
    output       sel_sum,
    output       sel_i
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
                next_state = start ? GETX : IDLE;
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
                ready = 1'b1;
                out_valid = start;
            end
            COMPUTE: begin
                ready = in_valid || !big_N;
                out_valid = ready || flag;
            end
        endcase
    end

    assign flag = ready && big_N;
    assign sel_x = !ready;
    assign sel_num = !ready;
    assign sel_sum = !ready;
    assign sel_i = !ready;

endmodule
