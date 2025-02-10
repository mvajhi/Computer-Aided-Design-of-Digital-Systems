`default_nettype none

module read_addr_gen_module 
        #(parameter FILT_ADDR_LEN,
        parameter IF_ADDR_LEN,
        parameter IF_SCRATCH_DEPTH,
        parameter IF_SCRATCH_WIDTH)
        (
          input wire clk,rst,psum_sc_done,
          input wire start, IF_end_valid, filt_ready, stall_pipeline,
          input wire [IF_ADDR_LEN - 1:0] stride_len, IF_end_pos, IF_start_pos, IF_waddr,
          input wire [FILT_ADDR_LEN - 1:0] filter_len, filt_waddr,
          input wire [1:0] mode,
          output wire [IF_ADDR_LEN - 1:0] IF_raddr,
          output wire [FILT_ADDR_LEN - 1:0] filt_raddr,
          output wire read_from_scratch, done, full_done, stride_count_flag,half_done        );

        // Internal Signals for Wiring
        wire filter_pos_flag, read_safe;
        wire filter_count_cnt_en, filter_pos_cnt_en, filter_pos_ld;
        wire stride_cnt_en, stride_pos_ld;
        wire reset_all;

        // Instantiate Controller
        read_addr_gen_controller #(
            .FILT_ADDR_LEN(FILT_ADDR_LEN),
            .IF_ADDR_LEN(IF_ADDR_LEN)
        ) controller (
            .clk(clk),.rst(rst),.psum_sc_done(psum_sc_done),
            .start(start),
            .stride_count_flag(stride_count_flag),
            .filter_pos_flag(filter_pos_flag),
            .read_safe(read_safe),
            .stall_pipeline(stall_pipeline),
            .read_from_scratch(read_from_scratch),
            .filter_pos_cnt_en(filter_pos_cnt_en),
            .stride_cnt_en(stride_cnt_en),
            .done(done),
            .filter_pos_ld(filter_pos_ld),
            .filter_count_cnt_en(filter_count_cnt_en),
            .stride_pos_ld(stride_pos_ld),
            .full_done(full_done),
            .reset_all(reset_all),
            .mode(mode),
            .half_done(half_done));

        // Instantiate Datapath
        read_addr_gen_datapath #(
            .FILT_ADDR_LEN(FILT_ADDR_LEN),
            .IF_ADDR_LEN(IF_ADDR_LEN),
            .IF_SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
            .IF_SCRATCH_WIDTH(IF_SCRATCH_WIDTH)
        ) datapath (
            .clk(clk),.rst(rst | reset_all),
            .stride_len(stride_len),
            .IF_end_pos(IF_end_pos),
            .IF_start_pos(IF_start_pos),
            .IF_waddr(IF_waddr),
            .filter_len(filter_len),
            .filt_waddr(filt_waddr),
            .IF_raddr(IF_raddr),
            .filt_raddr(filt_raddr),
            .IF_end_valid(IF_end_valid),
            .filt_ready(filt_ready),
            .filter_count_cnt_en(filter_count_cnt_en),
            .filter_pos_ld(filter_pos_ld),
            .filter_pos_cnt_en(filter_pos_cnt_en),
            .stride_cnt_en(stride_cnt_en),
            .stride_pos_ld(stride_pos_ld),
            .stride_count_flag(stride_count_flag),
            .read_safe(read_safe),
            .filter_pos_flag(filter_pos_flag),
            .mode(mode),
            .half_done(half_done),
            .psum_sc_done(psum_sc_done)
        );

endmodule


module read_addr_gen_controller
        #(parameter FILT_ADDR_LEN,
        parameter IF_ADDR_LEN)
        (
            input wire clk,rst,psum_sc_done,half_done,
            input wire start,stride_count_flag,filter_pos_flag,read_safe,stall_pipeline,
            input wire[1:0]mode,
            output reg read_from_scratch,filter_pos_cnt_en,stride_cnt_en,done,filter_pos_ld,
                        filter_count_cnt_en,stride_pos_ld,full_done,reset_all
        );

    reg [2:0] ps = 3'd0, ns;
        always @(posedge clk,posedge rst) begin
        if (rst) 
            ps <= 3'd0;
        else if (~stall_pipeline)
            ps <= ns;
    end

    // Next state logic
    always @(*) begin
        case (ps)
            3'd0: ns = (start) ? 3'd1 : 3'd0;
            3'd1: ns = (stride_count_flag) ? 3'd0 : (mode == 2) ? 3'd2 : 3'd3;
            3'd2: ns = (half_done & psum_sc_done) ? 3'd3 : 3'd2;
            3'd3: ns = (filter_pos_flag & psum_sc_done) ? 3'd1 : 3'd3;
            default: ns = 3'd0;
        endcase
    end

    // Output logic
    always @(*) begin

        reset_all = 1'b0;
        {filter_count_cnt_en, filter_pos_cnt_en, read_from_scratch, stride_pos_ld, 
        filter_pos_ld, stride_cnt_en, full_done, done} = 0;

            case (ps)
                3'd0: reset_all = 1'b1;
                3'd1: begin 
                    full_done = stride_count_flag;
                    filter_pos_ld = ~stride_count_flag & ~stall_pipeline;
                end

                3'd2: begin
                    filter_pos_cnt_en = (~half_done & read_safe & ~stall_pipeline);
                    read_from_scratch = (~half_done & read_safe & ~stall_pipeline);
                end

                    3'd3: begin
                    filter_pos_cnt_en = (~filter_pos_flag & read_safe & ~stall_pipeline);
                    read_from_scratch = (~filter_pos_flag & read_safe & ~stall_pipeline);
                    stride_cnt_en = (filter_pos_flag & psum_sc_done & ~stall_pipeline);
                    //changed
                    done = filter_pos_flag;
                end
            endcase
        end
endmodule

module  read_addr_gen_datapath
        #(parameter FILT_ADDR_LEN,
        parameter IF_ADDR_LEN,
        parameter IF_SCRATCH_DEPTH,
        parameter IF_SCRATCH_WIDTH)
        (
            input wire clk,rst,
            input wire[IF_ADDR_LEN - 1:0] stride_len,IF_end_pos,IF_start_pos,IF_waddr,
            input wire [FILT_ADDR_LEN - 1:0] filter_len,filt_waddr,
            output wire[IF_ADDR_LEN - 1:0] IF_raddr,
            output wire [FILT_ADDR_LEN - 1:0] filt_raddr,
            input wire IF_end_valid,filt_ready,filter_count_cnt_en,filter_pos_ld,filter_pos_cnt_en,
            stride_cnt_en,stride_pos_ld,psum_sc_done,
            input wire [1:0] mode,
            output wire stride_count_flag,read_safe,filter_pos_flag,half_done
        );


        wire [IF_ADDR_LEN - 1:0] stride_distance,end_distance,IF_waddr_distance,IF_raddr_distance;
        wire [IF_ADDR_LEN - 1:0] stride_end;

        IF_distance_calculator #(.ADDR_LEN(IF_ADDR_LEN),
          .SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
          .SCRATCH_WIDTH(IF_SCRATCH_WIDTH)) IF_waddr_distance_calc 
          (.start_val(IF_start_pos),.end_val(IF_waddr),.distance(IF_waddr_distance));
          
        IF_distance_calculator #(.ADDR_LEN(IF_ADDR_LEN),
          .SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
          .SCRATCH_WIDTH(IF_SCRATCH_WIDTH)) IF_raddr_distance_calc 
          (.start_val(IF_start_pos),.end_val(IF_raddr),.distance(IF_raddr_distance));

        assign read_safe = (IF_waddr_distance > IF_raddr_distance | 
                        ((IF_waddr_distance == IF_raddr_distance) & (IF_waddr_distance == IF_SCRATCH_DEPTH - 1)))
                         & ((filt_waddr > filt_raddr) | filt_ready);

        IF_distance_calculator #(.ADDR_LEN(IF_ADDR_LEN),
          .SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
          .SCRATCH_WIDTH(IF_SCRATCH_WIDTH)) stride_distance_calc 
          (.start_val(IF_start_pos),.end_val(stride_end),.distance(stride_distance));
          
        IF_distance_calculator #(.ADDR_LEN(IF_ADDR_LEN),
          .SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
          .SCRATCH_WIDTH(IF_SCRATCH_WIDTH)) end_distance_calc 
          (.start_val(IF_start_pos),.end_val(IF_end_pos),.distance(end_distance));

        reg next_stride_count_flag;

        always @(posedge clk,posedge rst) begin
            if (rst) next_stride_count_flag <= 0;
            else if (filter_pos_flag & psum_sc_done) next_stride_count_flag <= (stride_distance == IF_SCRATCH_DEPTH - 1) & (stride_distance == end_distance) & IF_end_valid;
        end

        assign stride_count_flag = (stride_distance > end_distance) & IF_end_valid | next_stride_count_flag;

        wire [FILT_ADDR_LEN - 1:0] filter_pos_out;
        wire [IF_ADDR_LEN - 1: 0] stride_pos_out;

        wire dum1,dum2,dum3;

        Counter #(.NUM_BIT(FILT_ADDR_LEN)) filt_pos_cnt (.clk(clk),.rst(rst),.ld_cnt(filter_pos_ld),
        .cnt_en(filter_pos_cnt_en),.co(dum2),.load_value({FILT_ADDR_LEN{1'd0}}),.cnt_out_wire(filter_pos_out));

        wire next_part_flag;
        assign next_part_flag = (filter_len - 1) < filter_pos_out;
        assign filt_raddr =(mode == 2'd2)? 2 * (filter_pos_out - (next_part_flag ? filter_len : 0)) + next_part_flag : filter_pos_out;

        assign filter_pos_flag = (mode == 2'd1) ? (filter_len == filter_pos_out) : (2 * filter_len == filter_pos_out);

        assign half_done = (mode == 2'd2) & (filter_pos_out == filter_len);

        Counter #(.NUM_BIT(IF_ADDR_LEN)) stride_pos_cnt (.clk(clk),.rst(rst),.ld_cnt(stride_pos_ld),
        .cnt_en(stride_cnt_en),.co(dum3),.load_value({IF_ADDR_LEN{1'd0}}),.cnt_out_wire(stride_pos_out));

        wire[IF_ADDR_LEN:0] stride_mult;
        wire[2 * IF_ADDR_LEN - 1:0] temp_stride_mult_full;
        assign temp_stride_mult_full = stride_pos_out * stride_len;
        assign stride_mult = temp_stride_mult_full[IF_ADDR_LEN:0];

        wire[IF_ADDR_LEN:0] temp_stride_end_mult;
        wire [FILT_ADDR_LEN - 1:0] filt_len_plc = (mode !== 3) ? filter_len : 2 * filter_len;
        assign temp_stride_end_mult = (IF_start_pos + filt_len_plc + stride_mult - 1) % IF_SCRATCH_DEPTH;
        assign stride_end = temp_stride_end_mult[IF_ADDR_LEN - 1:0];

        wire[IF_ADDR_LEN:0] stride_val_cond;
        assign stride_val_cond = (mode == 2) ? stride_mult + filter_pos_out - next_part_flag * filter_len : stride_mult + filter_pos_out;

        assign IF_raddr = (stride_val_cond + IF_start_pos) % IF_SCRATCH_DEPTH;

endmodule