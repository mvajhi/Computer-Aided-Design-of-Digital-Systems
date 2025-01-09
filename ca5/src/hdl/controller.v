module design_controller
        #(parameter FILT_ADDR_LEN,
        parameter IF_ADDR_LEN,
        parameter SCRATCH_DEPTH,
        parameter SCRATCH_WIDTH)
        (
            input wire clk,rst,
            input wire start,full_done,psum_done,stride_count_flag, just_add_flag, stride_pos_ld, 
            input wire P_sum_buff_empty, psum_empty, // TODO : psum_full
            input wire [1:0] mod,
            output reg psum_clear, psum_ren, psum_same_addr,
            output reg reset_all,IF_read_start,filter_read_start,
            clear_regs,start_rd_gen,usage_stride_pos_ld, reset_Filter, accumulate
        );

    parameter [3:0] MOD_0 = 4'd3;
    parameter [3:0] MOD_1 = 4'd4;
    parameter [3:0] MOD_1_p = 4'd10;
    parameter [3:0] MOD_1_ROW_2 = 4'd8;
    parameter [3:0] MOD_2 = 4'd5;
    parameter [3:0] MOD_2_p = 4'd9;
    parameter [3:0] MOD_3 = 4'd6;
    parameter [3:0] JUST_ADD = 4'd7;

    reg [3:0] ps = 4'd0, ns;
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
            3'd2: ns =  just_add_flag ? JUST_ADD :
                        mod == 2'd0 ? MOD_0 : 
                        mod == 2'd1 ? MOD_1_p : 
                        mod == 2'd2 ? MOD_2_p : 
                        mod == 2'd3 ? MOD_2_p : 3'd2;
            MOD_0: ns = (full_done) ? 3'd2 : MOD_0;
            MOD_1_p: ns = (stride_pos_ld) ? MOD_1 : MOD_1_p;
            MOD_1: ns = (stride_pos_ld) ? MOD_1_ROW_2 : MOD_1;
            MOD_1_ROW_2: ns = (stride_pos_ld) ? 3'd0 : MOD_1_ROW_2;
            MOD_2_p: ns = (stride_pos_ld) ? MOD_2 : MOD_2_p;
            MOD_2: ns = (stride_pos_ld) ? 3'd0 : MOD_2;
            MOD_3: ns = (full_done) ? 3'd2 : MOD_3;
            JUST_ADD: ns = (psum_empty) ? 3'd0 : JUST_ADD;
            default: ns = 3'd0;
        endcase
    end

    // Output logic
    always @(*) begin

        psum_clear = 1'b0; psum_ren = 1'b0; psum_same_addr = 1'b1;
        reset_all = 1'b0; IF_read_start = 1'b0; filter_read_start = 1'b0; 
        clear_regs = 1'b0; start_rd_gen = 1'b0;
        usage_stride_pos_ld = 1'b1; reset_Filter = 1'b0;
        accumulate = 1'b0;

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
                    clear_regs = psum_done | stride_count_flag; // ?
                    reset_Filter = stride_pos_ld;
                    usage_stride_pos_ld = 1'b0;
                end

                MOD_1_ROW_2: begin
                    clear_regs = psum_done | stride_count_flag; // ?
                    // TODO
                end

                MOD_2: begin
                    clear_regs = psum_done | stride_count_flag; // ?
                    reset_all = start;
                end

                JUST_ADD: begin
                    accumulate = ~P_sum_buff_empty && psum_empty;
                    psum_ren = 1'b1;
                    psum_same_addr = 1'b0;
                end
            endcase
        end
endmodule