`default_nettype none

module outbuf_module #(
    parameter PSUM_SC_ADDR_LEN = 8
) (
    input wire clk,
    input wire rst,
    input wire psum_outbuf_start,
    input wire outbuf_full,
    input wire stall_psum_buf,
    input wire [PSUM_SC_ADDR_LEN-1:0] psum_sc_cnt_lead,
    output wire psum_done,
    output wire outbuf_write,
    output wire psum_sc_reg_en,
    output wire read_inp_sum_buf,
    output wire [PSUM_SC_ADDR_LEN-1:0] psum_sc_cnt_follow,
    input wire inpsum_buf_empty
);

    wire psum_sc_cnt_eq;
    wire psum_sc_cnt_follow_en;

    // Controller Instance
    outbuf_controller ctrl_inst (
        .clk(clk),
        .rst(rst),
        .psum_outbuf_start(psum_outbuf_start),
        .stall_psum_buf(stall_psum_buf),
        .psum_sc_cnt_eq(psum_sc_cnt_eq),
        .outbuf_full(outbuf_full),
        .psum_sc_reg_en(psum_sc_reg_en),
        .psum_sc_cnt_follow_en(psum_sc_cnt_follow_en),
        .outbuf_write(outbuf_write),
        .read_inp_sum_buf(read_inp_sum_buf),
        .psum_done(psum_done),
        .inpsum_buf_empty(inpsum_buf_empty)
    );

    // Datapath Instance
    outbuf_datapath #(
        .PSUM_SC_ADDR_LEN(PSUM_SC_ADDR_LEN)
    ) datapath_inst (
        .clk(clk),
        .rst(rst),
        .psum_sc_cnt_follow_en(psum_sc_cnt_follow_en),
        .psum_sc_cnt_eq(psum_sc_cnt_eq),
        .psum_sc_cnt_lead(psum_sc_cnt_lead),
        .psum_sc_cnt_follow(psum_sc_cnt_follow)
    );

endmodule


module outbuf_controller (
    input wire clk,
    input wire rst,
    input wire psum_outbuf_start,
    input wire stall_psum_buf,
    input wire psum_sc_cnt_eq,  // (psum_sc_cnt_lead == psum_sc_cnt_follow)
    input wire outbuf_full,
    output reg psum_sc_reg_en,
    output reg psum_sc_cnt_follow_en,
    output reg outbuf_write,
    output reg read_inp_sum_buf,
    output reg psum_done,
    input wire inpsum_buf_empty
);

    reg [2:0] ns,ps;

    // State Register
    always @(posedge clk or posedge rst) begin
        if (rst)
            ps <= 3'd0;
        else if (~stall_psum_buf)
            ps <= ns;
    end

    // Next-State Logic
    always @(*) begin
        case (ps)
            3'd0: ns = (psum_outbuf_start) ? 3'd1 : 3'd0;
            3'd1: ns = 3'd2;
            3'd2: ns = (~inpsum_buf_empty & psum_sc_cnt_eq) ? 3'd3 : 3'd2;
            3'd3: ns = 3'd0;
            default: ns = 3'd0;
        endcase
    end

    // Output Logic
    always @(*) begin
        {outbuf_write, psum_done, psum_sc_reg_en, psum_sc_cnt_follow_en, read_inp_sum_buf} = 0;

        if (~stall_psum_buf) begin
            case (ps)
                3'd1: begin
                    psum_sc_reg_en = 1'b1;
                    psum_sc_cnt_follow_en = 1'b1;
                end
                3'd2: begin
                    psum_sc_reg_en = ~inpsum_buf_empty & ~psum_sc_cnt_eq & ~outbuf_full;
                    psum_sc_cnt_follow_en = ~inpsum_buf_empty & ~psum_sc_cnt_eq & ~outbuf_full;
                    outbuf_write = ~inpsum_buf_empty & ~outbuf_full;
                    read_inp_sum_buf = ~inpsum_buf_empty & ~outbuf_full;
                end
                3'd3: begin
                    psum_done = 1'b1;
                end
            endcase
        end
    end

endmodule


module outbuf_datapath #(
    parameter PSUM_SC_ADDR_LEN = 8
) (
    input wire clk,
    input wire rst,
    input wire psum_sc_cnt_follow_en,
    output wire psum_sc_cnt_eq,
    input wire [PSUM_SC_ADDR_LEN-1:0] psum_sc_cnt_lead,
    output wire [PSUM_SC_ADDR_LEN-1:0] psum_sc_cnt_follow
);

    wire dum_co_num;

    // Counter Instance for `psum_sc_cnt_follow`
    Counter #(
        .NUM_BIT(PSUM_SC_ADDR_LEN)
    ) filt_wcnt (
        .clk(clk),
        .rst(rst),
        .ld_cnt(1'b0),
        .cnt_en(psum_sc_cnt_follow_en),
        .co(dum_co_num),
        .load_value({PSUM_SC_ADDR_LEN{1'b0}}),
        .cnt_out_wire(psum_sc_cnt_follow)
    );

    // Comparator
    assign psum_sc_cnt_eq = (psum_sc_cnt_lead == psum_sc_cnt_follow);

endmodule
