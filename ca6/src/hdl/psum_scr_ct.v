`default_nettype none

module psum_sc_ct #(
    parameter PSUM_SC_ADDR_LEN = 8
) (
    input wire clk,
    input wire rst,
    input wire finish_step,
    input wire read_from_scratch_dp,
    output wire stall_pipeline,
    output wire psum_sc_wen,
    output wire psum_sc_reg_en,
    output wire psum_sc_done,
    output wire regs_en,
    output wire clear_regs,
    output wire [PSUM_SC_ADDR_LEN - 1:0] psum_sc_cnt_lead
);

    wire psum_sc_cnt_lead_en;

    // Controller Instance
    psum_sc_controller controller_inst (
        .clk(clk),
        .rst(rst),
        .finish_step(finish_step),
        .read_from_scratch_dp(read_from_scratch_dp),
        .psum_sc_done(psum_sc_done),
        .psum_sc_wen(psum_sc_wen),
        .stall_pipeline(stall_pipeline),
        .psum_sc_reg_en(psum_sc_reg_en),
        .regs_en(regs_en),
        .clear_regs(clear_regs),
        .psum_sc_cnt_lead_en(psum_sc_cnt_lead_en)
    );

    // Datapath Instance
    psum_sc_datapath #(
        .PSUM_SC_ADDR_LEN(PSUM_SC_ADDR_LEN)
    ) datapath_inst (
        .clk(clk),
        .rst(rst),
        .psum_sc_cnt_lead_en(psum_sc_cnt_lead_en),
        .psum_sc_cnt_lead(psum_sc_cnt_lead)
    );

endmodule


module psum_sc_controller (
    input wire clk,
    input wire rst,
    input wire finish_step,
    input wire read_from_scratch_dp,
    output reg psum_sc_done,
    output reg psum_sc_wen,
    output reg stall_pipeline,
    output reg psum_sc_reg_en,
    output reg regs_en,
    output reg clear_regs,
    output reg psum_sc_cnt_lead_en
);

    reg [2:0] ps = 3'd0, ns;

    // State Register
    always @(posedge clk or posedge rst) begin
        if (rst)
            ps <= 3'd0;
        else
            ps <= ns;
    end

    // Next-State Logic
    always @(*) begin
        case (ps)
            3'd0: ns = (read_from_scratch_dp) ? 3'd1 : 3'd0;
            3'd1: ns = (read_from_scratch_dp) ? 3'd2 : 3'd1;
            3'd2: ns = (finish_step) ? 3'd4 : 3'd3;
            3'd3: ns = (read_from_scratch_dp) ? 3'd2 : 3'd3;
            3'd4: ns = 3'd5;
            3'd5: ns = 3'd6;
            3'd6: ns = 3'd7;
            3'd7: ns = 3'd0;
            default: ns = 3'd0;
        endcase
    end

    // Output Logic
    always @(*) begin
        // Default values to avoid latches
        {psum_sc_done, psum_sc_wen, stall_pipeline, psum_sc_reg_en,
         regs_en, psum_sc_cnt_lead_en, clear_regs} = 0;

        case (ps)
            3'd2: begin
                psum_sc_wen = 1'b1;
                stall_pipeline = 1'b1;
            end
            3'd3: begin
                psum_sc_reg_en = 1'b1;
            end
            3'd4: begin
                regs_en = 1'b1;
                psum_sc_reg_en = 1'b1;
                stall_pipeline = 1'b1;
            end
            3'd5: begin
                stall_pipeline = 1'b1;
                psum_sc_wen = 1'b1;
                psum_sc_cnt_lead_en = 1'b1;
            end
            3'd6: begin
                clear_regs = 1'b1;
                stall_pipeline = 1'b1;
            end
            3'd7: psum_sc_done = 1'b1;
        endcase
    end

endmodule

module psum_sc_datapath #(
    parameter PSUM_SC_ADDR_LEN = 8
) (
    input wire clk,
    input wire rst,
    input wire psum_sc_cnt_lead_en,
    output wire [PSUM_SC_ADDR_LEN - 1:0] psum_sc_cnt_lead
);

    wire dum_co_num;

    // Counter Instance for psum_sc_cnt_lead
    Counter #(
        .NUM_BIT(PSUM_SC_ADDR_LEN)
    ) filt_wcnt (
        .clk(clk),
        .rst(rst),
        .ld_cnt(1'b0),
        .cnt_en(psum_sc_cnt_lead_en),
        .co(dum_co_num),
        .load_value({PSUM_SC_ADDR_LEN{1'b0}}),
        .cnt_out_wire(psum_sc_cnt_lead)
    );

endmodule
