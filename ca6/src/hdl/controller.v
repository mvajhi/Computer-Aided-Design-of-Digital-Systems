`default_nettype none

module design_controller
        #(parameter FILT_ADDR_LEN,
        parameter IF_ADDR_LEN,
        parameter SCRATCH_DEPTH,
        parameter SCRATCH_WIDTH)
        (
            input wire clk,rst,
            input wire start,full_done,psum_done,stride_count_flag,ready_to_get,
            output reg reset_all,IF_read_start,filter_read_start,clear_regs,start_rd_gen
        );

    reg [2:0] ps = 3'd0, ns;
    // Sequential logic for present state
    always @(posedge clk,posedge rst) begin
        if (rst) 
            ps <= 3'd0;
        else if (start) 
            ps <= 3'd1;
        else 
            ps <= ns;
    end

    // Next state logic
    always @(*) begin
        case (ps)
            3'd0: ns = (start) ? 3'd1 : 3'd0;
            3'd1: ns = (start) ? 3'd1 : 3'd2;
            3'd2: ns = (ready_to_get) ? 3'd4 : 3'd3;
            3'd3: ns = (full_done) ? 3'd2 : 3'd3;
            3'd4: ns = 3'd4;
            default: ns = 3'd0;
        endcase
    end

    // Output logic
    always @(*) begin

        reset_all = 1'b0; IF_read_start = 1'b0; filter_read_start = 1'b0; 
        clear_regs = 1'b0; start_rd_gen = 1'b0;

            case (ps)
                3'd0: reset_all = 1'b1;
                3'd1: begin 
                    IF_read_start = 1'b1; 
                    filter_read_start = 1'b1;
                    reset_all = start;
                end

                3'd2: begin
                    start_rd_gen = ~ready_to_get;
                    reset_all = start;
                end

                3'd3: begin
                    clear_regs = psum_done | stride_count_flag;
                    reset_all = start;
                end
                3'd4: begin
                    reset_all = start;
                end
            endcase
        end
endmodule