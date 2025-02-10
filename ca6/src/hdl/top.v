module top #(

) (
    input clk,
    input rst,
    input start
)
    parameter PE_COUNT = 3;
    
    reg co_onehot, co_ifG, done_all;
    reg rst_dp, sel_addr, en_onehot, cnt_filtG, start_pe, cnt_ifG, ifwen, mod;
    
    controller_top #(.PE_COUNT(PE_COUNT)) controller_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .co_onehot(co_onehot),
        .co_ifG(co_ifG),
        .done_all(done_all),
        .rst_dp(rst_dp),
        .sel_addr(sel_addr),
        .en_onehot(en_onehot),
        .cnt_filtG(cnt_filtG),
        .start_pe(start_pe),
        .cnt_ifG(cnt_ifG),
        .ifwen(ifwen),
        .mod(mod)
    );
endmodule