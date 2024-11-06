module handshake_controller (
    input wire clk,
    input wire rst,
    input wire request,
    output reg accept,
    output reg done
);

    parameter IDLE = 2'b00;
    parameter ACCEPTING = 2'b01;
    parameter PROCESSING = 2'b10;

    reg [1:0] current_state;
    reg [1:0] next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = current_state;
        accept = 0;
        done = 0;

        case (current_state)
            IDLE: begin
                next_state = request ? ACCEPTING : IDLE;
            end

            ACCEPTING: begin
                accept = 1;
                next_state = request ? ACCEPTING : PROCESSING;
            end

            PROCESSING: begin
                done = 1; 
                next_state = IDLE; 
            end
        endcase
    end

endmodule
