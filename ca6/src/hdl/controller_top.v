module controller_top #(PE_COUNT = 3) 
(
    input clk,
    input rst,
    input start,
    input co_onehot,
    input co_ifG,
    input done_all,
    output rst_dp,
    output sel_addr,
    output en_onehot,
    output cnt_filtG,
    output start_pe,
    output cnt_ifG,
    output ifwen,
    output mod
)
    parameter SIZE_STATE = 3;
    parameter [SIZE_STATE:0] IDEL = 0;
    parameter [SIZE_STATE:0] ld_filt = 1;
    parameter [SIZE_STATE:0] start_pe = 2;
    parameter [SIZE_STATE:0] ld_if = 3;
    parameter [SIZE_STATE:0] calc = 4;
    parameter [SIZE_STATE:0] sum = 5;

    reg [SIZE_STATE:0] ns, ps;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            ps <= IDEL;
        end
        else begin
            ps <= ns;
        end
    end

    always @(*) begin
        ns = IDEL;
        case (ps)
            IDEL: begin
                ns = start ? ld_filt : IDEL;
            end
            ld_filt: begin
                ns = co_onehot ? start_pe : ld_filt;
            end
            start_pe: begin
                ns = ld_if;
            end
            ld_if: begin
                ns = co_ifG ? calc : ld_if;
            end
            calc: begin
                ns = done_all ? sum : calc;
            end
            sum: begin
                ns = done_all ? IDEL : sum;
            end
        endcase
    end

    always @(*) begin
        {   rst_dp,
            sel_addr,
            en_onehot,
            cnt_filtG,
            start_pe,
            cnt_ifG,
            ifwen,
            mod} = 8'b0;

        case (ps)
            IDEL: begin
                rst_dp = 1'b1;
                sel_addr = 1'b0;
            end
            ld_filt: begin
                en_onehot = 1'b1;
                cnt_filtG = 1'b1;
                sel_addr = 1'b0;
            end
            start_pe: begin
                start_pe = 1'b1;
                sel_addr = 1'b1;
                cnt_ifG = 1'b1;
            end
            ld_if: begin
                sel_addr = 1'b1;
                cnt_ifG = 1'b1;
                ifwen = 1'b1;
            end
            calc: begin
            end
            sum: begin
                mod = 1'b1;
            end
        endcase
    end
endmodule