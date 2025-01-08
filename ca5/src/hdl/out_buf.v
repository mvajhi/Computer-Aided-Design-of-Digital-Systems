module outbuf_module (clk,rst,done,outbuf_full,stall_pipeline,psum_done,outbuf_write,read_from_scratch);

    input wire clk,rst,done,outbuf_full,read_from_scratch;
    output reg stall_pipeline,psum_done,outbuf_write;

    reg [2:0] ps = 3'd0, ns;

    always @(posedge clk, posedge rst) begin
        if (rst) 
            ps <= 3'd0;
        else 
            ps <= ns;
    end

    always @(*) begin
        case (ps)
            3'd0: ns = (done) ? 3'd1 : 3'd0;
            3'd1: ns = (read_from_scratch) ? 3'd2 : 3'd1;
            3'd2: ns = (read_from_scratch) ? 3'd3 : 3'd2;
            3'd3: ns = (outbuf_full) ? 3'd3 : 3'd4;
            3'd4: ns = 3'd0;
            default: ns = 3'd0;
        endcase
    end

    always @(*) begin
        {outbuf_write,stall_pipeline,psum_done} = 3'd0;
        case (ps)
            3'd3:begin stall_pipeline = outbuf_full;
            outbuf_write = ~outbuf_full; end
            3'd4: psum_done = 1'b1;
        endcase
    end

endmodule