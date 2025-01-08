module filt_read_module #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH) 
    (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [ADDR_LEN - 1:0] filt_len,
    input wire filt_buf_empty,

    output wire filt_buf_read,
    output wire filt_scratch_wen,
    output wire [ADDR_LEN - 1:0] filt_waddr,
    output wire filt_ready
);

    // Internal signals
    wire filt_wcnt_en,reset_all;
    wire filt_end_flag;

    // Instantiate the datapath
    filt_read_datapath #(
        .ADDR_LEN(ADDR_LEN),
        .SCRATCH_DEPTH(SCRATCH_DEPTH),
        .SCRATCH_WIDTH(SCRATCH_WIDTH)
    ) datapath (
        .clk(clk),
        .rst(rst | reset_all),
        .filt_wcnt_en(filt_wcnt_en),
        .filt_len(filt_len),
        .filt_waddr(filt_waddr),
        .filt_end_flag(filt_end_flag)
    );

    // Instantiate the controller
    filt_read_controller #(
        .ADDR_LEN(ADDR_LEN),
        .SCRATCH_DEPTH(SCRATCH_DEPTH),
        .SCRATCH_WIDTH(SCRATCH_WIDTH)
    ) controller (
        .clk(clk),
        .rst(rst),
        .start(start),
        .filt_buf_empty(filt_buf_empty),
        .filt_end_flag(filt_end_flag),
        .filt_buf_read(filt_buf_read),
        .filt_scratch_wen(filt_scratch_wen),
        .filt_wcnt_en(filt_wcnt_en),
        .filt_ready(filt_ready),
        .reset_all(reset_all)
    );

endmodule


module filt_read_controller #(parameter ADDR_LEN,
          parameter SCRATCH_DEPTH,
          parameter SCRATCH_WIDTH)
 (
    clk, rst, start, filt_buf_empty, filt_end_flag,reset_all,
    filt_buf_read, filt_scratch_wen, filt_wcnt_en, filt_ready
);

    input wire clk;
    input wire rst;
    input wire start;
    input wire filt_end_flag;
    input wire filt_buf_empty;

    output reg reset_all;
    output reg filt_wcnt_en;
    output reg filt_buf_read;
    output reg filt_scratch_wen;
    output reg filt_ready;

    reg [2:0] ps = 3'd0, ns;

    always @(posedge clk,posedge rst) begin
        if (rst) 
            ps <= 3'd0;
        else if (start) 
            ps <= 3'd1;
        else 
            ps <= ns;
    end

    always @(*) begin
        case (ps)
            3'd0: ns = (start) ? 3'd1 : 3'd0;
            3'd1: ns = (start) ? 3'd1 : 3'd2;
            3'd2: ns = (filt_end_flag) ? 3'd0 : 3'd2;
            default: ns = 3'd0;
        endcase
    end

    always @(*) begin
        reset_all = 1'b0;
        {filt_buf_read, filt_scratch_wen, filt_wcnt_en, filt_ready} = 4'd0;

        case (ps)
            3'd0: filt_ready = 1'b1;
            3'd1: reset_all = 1'b1;

            3'd2: begin
                {filt_buf_read, filt_scratch_wen, filt_wcnt_en} = 
                    (~filt_buf_empty ) ? {2'b11,~filt_end_flag} : 3'b000;
            end
        endcase
    end

endmodule


module filt_read_datapath #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH)  
    (
    input wire clk,
    input wire rst,
    input wire filt_wcnt_en,
    input wire [ADDR_LEN - 1:0] filt_len,
    output wire [ADDR_LEN - 1:0] filt_waddr,
    output wire filt_end_flag
);

    // Counter instantiation
    wire dum_co_num;
    Counter #(
        .NUM_BIT(ADDR_LEN)
    ) filt_wcnt (
        .clk(clk),
        .rst(rst),
        .ld_cnt(1'b0),
        .cnt_en(filt_wcnt_en),
        .co(dum_co_num),
        .load_value({ADDR_LEN{1'b0}}),
        .cnt_out_wire(filt_waddr)
    );

    // Flag register connections
    wire [ADDR_LEN:0] filt_flag_out, filt_flag_in;
    wire filt_flag_reg_ld;

    assign filt_flag_reg_ld = (filt_flag_out == filt_waddr);
    assign filt_flag_in = (filt_flag_out == 0) ? {1'b0, filt_len} + filt_flag_out - 1: {1'b0, filt_len} + filt_flag_out;

    wire dum_reg_flag;

    Register #(
        .SIZE(ADDR_LEN + 1)
    ) filt_flag_reg (
        .clk(clk),
        .rst(rst),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(filt_flag_out),
        .inval(filt_flag_in),
        .ld_en(filt_flag_reg_ld),
        .msb(dum_reg_flag)
    );

    // End flag logic
    assign filt_end_flag = (filt_flag_in >= SCRATCH_DEPTH) & filt_flag_reg_ld;

endmodule