module controller (
    input        clk,
    input        rst,
    input        start,
    input        in_valid,
    output       ready,
    output       out_valid,
    output       error,
    output       sel_x,
    output       sel_num,
    output       sel_sum
);
    parameter IDLE = 1'b0;
    parameter COMPUTE = 1'b1;

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
        {ready, out_valid, error, sel_x, sel_num, sel_sum} = 6'b000000;
        case (state)
            IDLE: begin
                ready = 1'b1;
                out_valid = start;
            end
            COMPUTE: begin
                ready = in_valid || N <= 3'd4;
                out_valid = ready;
                sel_x = !ready;
                sel_num = !ready;
                sel_sum = !ready;
                sel_i = !ready;
            end
        endcase
    end

endmodule
