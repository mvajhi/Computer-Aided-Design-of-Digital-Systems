module design_controller
        #(parameter FILT_ADDR_LEN,
        parameter IF_ADDR_LEN,
        parameter SCRATCH_DEPTH,
        parameter SCRATCH_WIDTH)
        (
            input wire clk,rst,
            input wire start,full_done,psum_done,stride_count_flag, mod, just_add_flag, stride_pos_ld,
            output reg reset_all,IF_read_start,filter_read_start,clear_regs,start_rd_gen,usage_stride_pos_ld, reset_Filter
        );

    parameter [2:0] MOD_0 = 3'd3;
    parameter [2:0] MOD_1 = 3'd4;
    parameter [2:0] MOD_2 = 3'd5;
    parameter [2:0] MOD_3 = 3'd6;
    parameter [2:0] JUST_ADD = 3'd7;

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
            3'd2: ns = 3'd3;
            MOD_0: ns = (full_done) ? 3'd2 : 3'd3;
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
                    start_rd_gen = 1'b1;
                    reset_all = start;
                end

                MOD_0: begin
                    clear_regs = psum_done | stride_count_flag;
                    reset_all = start;
                end

                MOD_1: begin

                end

                MOD_2: begin

                end

                MOD_3: begin

                end

                JUST_ADD: begin

                end
            endcase
        end
endmodule