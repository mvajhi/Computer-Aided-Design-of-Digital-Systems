`default_nettype none

module design_datapath #(
    parameter FILT_ADDR_LEN,
    parameter IF_ADDR_LEN,
    parameter IF_SCRATCH_DEPTH,
    parameter IF_SCRATCH_WIDTH,
    parameter FILT_SCRATCH_DEPTH,
    parameter FILT_SCRATCH_WIDTH,
    parameter PSUM_SC_ADDR_LEN,
    parameter PSUM_SC_DEPTH,
    parameter INPUT_PSUM_WIDTH)
    (
    input wire clk,rst,
    input wire IF_read_start,
    input wire filter_read_start,
    input wire regs_clr,
    input wire IF_buf_empty_flag,
    input wire filt_buf_empty,
    input wire start_rd_gen,
    input wire outbuf_full,
    input wire [1:0] mode,
    input wire outbuf_write_flag,
    input wire [INPUT_PSUM_WIDTH - 1:0] input_psum_val,
    input wire [FILT_ADDR_LEN - 1:0] filt_len,
    input wire [IF_ADDR_LEN - 1:0] stride_len,
    input wire [IF_SCRATCH_WIDTH + 1:0] IF_buf_inp,
    input wire [FILT_SCRATCH_WIDTH - 1:0] filt_buf_inp,
    output wire [IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH:0] module_outval,
    output wire IF_buf_read,
    output wire filt_buf_read,
    output wire full_done,
    output wire psum_sc_done,
    output wire stride_count_flag,
    output wire outbuf_write,
    output wire read_inp_sum_buf,
    output wire ready_to_get,
    input wire inpsum_buf_empty,
    output wire [FILT_SCRATCH_WIDTH + IF_SCRATCH_WIDTH:0] psum_sc_out,
    input wire [PSUM_SC_ADDR_LEN - 1:0] see_inside_psum_sc_counter,
    input wire inside_psum_sc_flag
);

    // Wire declarations
    wire IF_scratch_wen, IF_end_valid;
    wire [IF_ADDR_LEN - 1:0] start_IF, end_IF, IF_waddr, IF_raddr;
    wire [FILT_ADDR_LEN - 1:0] filt_waddr, filt_raddr;
    wire filt_scratch_wen, filt_ready;
    wire read_from_scratch, done, stall_pipeline;
    wire [IF_SCRATCH_WIDTH - 1:0] IF_scratch_out, IF_scratch_reg_out;
    wire [FILT_SCRATCH_WIDTH - 1:0] filt_scratch_out;
    wire [IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH - 1:0] mult_inp, mult_reg_out;
    wire [IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH:0] add_out;
    wire psum_done,half_done;

    // IF Read Module
    IF_read_module #(
        .ADDR_LEN(IF_ADDR_LEN),
        .SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
        .SCRATCH_WIDTH(IF_SCRATCH_WIDTH)
    ) if_reader (
        .clk(clk),
        .rst(rst),
        .start(IF_read_start),
        .IF_buf_end_flag(IF_buf_inp[IF_SCRATCH_WIDTH]),
        .IF_buf_empty_flag(IF_buf_empty_flag),
        .full_done(full_done),
        .start_IF(start_IF),
        .end_IF(end_IF),
        .IF_buf_read(IF_buf_read),
        .IF_scratch_wen(IF_scratch_wen),
        .IF_waddr(IF_waddr),
        .IF_end_valid(IF_end_valid)
    );

    // Filter Read Module
    filt_read_module #(
        .ADDR_LEN(FILT_ADDR_LEN),
        .SCRATCH_DEPTH(FILT_SCRATCH_DEPTH),
        .SCRATCH_WIDTH(FILT_SCRATCH_WIDTH)
    ) filt_reader (
        .clk(clk),
        .rst(rst),
        .start(filter_read_start),
        .filt_len(filt_len),
        .filt_buf_empty(filt_buf_empty),
        .filt_buf_read(filt_buf_read),
        .filt_scratch_wen(filt_scratch_wen),
        .filt_waddr(filt_waddr),
        .filt_ready(filt_ready),
        .mode(mode)
    );

    wire [PSUM_SC_ADDR_LEN - 1 : 0] psum_sc_cnt_follow, psum_sc_cnt_lead;
    wire psum_sc_reg_en_outbuf,psum_sc_reg_en_psct;

    // Output Buffer Module
    outbuf_module #(
        .PSUM_SC_ADDR_LEN(PSUM_SC_ADDR_LEN)
    ) out_buf_writer (
        .clk(clk),
        .rst(rst),
        .psum_outbuf_start(outbuf_write_flag),       
        .outbuf_full(outbuf_full),
        .stall_psum_buf(~outbuf_write_flag),          
        .psum_sc_cnt_lead(psum_sc_cnt_lead),        
        .psum_done(psum_done),
        .outbuf_write(outbuf_write),
        .psum_sc_reg_en(psum_sc_reg_en_outbuf),          
        .read_inp_sum_buf(read_inp_sum_buf),        
        .psum_sc_cnt_follow(psum_sc_cnt_follow),
        .inpsum_buf_empty(inpsum_buf_empty)       
    );


    // Read Address Generator
    read_addr_gen_module #(
        .FILT_ADDR_LEN(FILT_ADDR_LEN),
        .IF_ADDR_LEN(IF_ADDR_LEN),
        .IF_SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
        .IF_SCRATCH_WIDTH(IF_SCRATCH_WIDTH)
    ) read_addr_gener (
        .clk(clk),
        .rst(rst),
        .psum_sc_done(psum_sc_done),
        .start(start_rd_gen),
        .IF_end_valid(IF_end_valid),
        .filt_ready(filt_ready),
        .stall_pipeline(stall_pipeline),
        .stride_len(stride_len),
        .IF_end_pos(end_IF),
        .IF_start_pos(start_IF),
        .IF_waddr(IF_waddr),
        .filter_len(filt_len),
        .filt_waddr(filt_waddr),
        .mode(mode),                     
        .IF_raddr(IF_raddr),
        .filt_raddr(filt_raddr),
        .read_from_scratch(read_from_scratch),
        .done(done),
        .full_done(full_done),
        .stride_count_flag(stride_count_flag),
        .half_done(half_done)    );

    wire psum_sc_wen, psum_stall_pipeline, regs_en_psum,
         clear_regs_psum, ultimate_regs_clear;

    psum_sc_ct #(.PSUM_SC_ADDR_LEN(PSUM_SC_ADDR_LEN)) psct (
        .clk(clk),
        .rst(rst),
        .finish_step(half_done | full_done | done),
        .read_from_scratch_dp(read_from_scratch),
        .stall_pipeline(psum_stall_pipeline),
        .psum_sc_wen(psum_sc_wen),
        .psum_sc_reg_en(psum_sc_reg_en_psct),
        .psum_sc_done(psum_sc_done),
        .regs_en(regs_en_psum),
        .clear_regs(clear_regs_psum),
        .psum_sc_cnt_lead(psum_sc_cnt_lead)
    );

    assign ultimate_regs_clear = rst | regs_clr | clear_regs_psum;

    assign stall_pipeline = psum_stall_pipeline | outbuf_write_flag;

    // IF Scratchpad
    IF_scratch #(
        .ADDR_LEN(IF_ADDR_LEN),
        .SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
        .SCRATCH_WIDTH(IF_SCRATCH_WIDTH)
    ) scr_IF (
        .clk(clk),
        .rst(rst),
        .wen(IF_scratch_wen),
        .waddr(IF_waddr),
        .raddr(IF_raddr),
        .din(IF_buf_inp[IF_SCRATCH_WIDTH - 1:0]),
        .dout(IF_scratch_out)
    );

    // Filter Scratchpad
    filter_scratch #(
        .ADDR_LEN(FILT_ADDR_LEN),
        .SCRATCH_DEPTH(FILT_SCRATCH_DEPTH),
        .SCRATCH_WIDTH(FILT_SCRATCH_WIDTH)
    ) scr_filt (
        .clk(clk),
        .rst(rst),
        .clr_out(ultimate_regs_clear),
        .wen(filt_scratch_wen),
        .ren(read_from_scratch),
        .waddr(filt_waddr),
        .raddr(filt_raddr),
        .din(filt_buf_inp),
        .dout(filt_scratch_out)
    );

    wire [PSUM_SC_ADDR_LEN - 1:0] psum_sc_raddr;
    assign psum_sc_raddr = (outbuf_write_flag) ? psum_sc_cnt_follow :
                            (inside_psum_sc_flag) ? see_inside_psum_sc_counter : psum_sc_cnt_lead;

    psum_scratch #(.ADDR_LEN(PSUM_SC_ADDR_LEN),
            .SCRATCH_DEPTH(PSUM_SC_DEPTH),
            .SCRATCH_WIDTH(INPUT_PSUM_WIDTH)) pssc
        (
            .clk(clk),
            .rst(rst),
            .wen(psum_sc_wen),
            .waddr(psum_sc_cnt_lead),
            .raddr(psum_sc_raddr),
            .din(add_out),
            .dout(psum_sc_out)
        );

    // IF Register
    wire dum1,dum2,dum3;
    Register #(
        .SIZE(IF_SCRATCH_WIDTH)
    ) IF_reg (
        .clk(clk),
        .rst(ultimate_regs_clear),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(IF_scratch_reg_out),
        .inval(IF_scratch_out),
        .ld_en(read_from_scratch | regs_en_psum),
        .msb(dum1)
    );

    // Multiplier Register
    // assign mult_inp = filt_scratch_out * IF_scratch_reg_out;
    signed_multiplier #(
        .INPUT_A_WIDTH(FILT_SCRATCH_WIDTH),
        .INPUT_B_WIDTH(IF_SCRATCH_WIDTH)
    ) smp (
        .operand_a(filt_scratch_out),
        .operand_b(IF_scratch_reg_out),
        .result(mult_inp)
    );

    Register #(
        .SIZE(IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH)
    ) mult_reg (
        .clk(clk),
        .rst(ultimate_regs_clear),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(mult_reg_out),
        .inval(mult_inp),
        .ld_en(read_from_scratch | regs_en_psum),
        .msb(dum2)
    );

    wire [IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH:0] add_inp_1, psum_sc_reg_out;
    assign add_inp_1 = ~outbuf_write_flag ? {mult_reg_out[IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH -1],mult_reg_out} : input_psum_val; 

    assign add_out = psum_sc_reg_out + add_inp_1;

    Register #(
        .SIZE(IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH + 1)
    ) psum_reg (
        .clk(clk),
        .rst(ultimate_regs_clear),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(psum_sc_reg_out),
        .inval(psum_sc_out),
        .ld_en(psum_sc_reg_en_psct | psum_sc_reg_en_outbuf | regs_en_psum),
        .msb(dum3)
    );

    // Output Assignment
    assign module_outval = add_out;

    parameter ULTIMATE_DONE = 2;

    reg [1:0] process_state = 0;

    always @(posedge clk, posedge rst) begin
        if (rst)
            process_state <= 0;
        else if (full_done)
            process_state <= (mode == 1) ? process_state + 1 : ULTIMATE_DONE;
    end

    assign ready_to_get = process_state == ULTIMATE_DONE;


endmodule
