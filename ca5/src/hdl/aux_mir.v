module Register #(parameter SIZE = 16) (clk,rst,right_shen,left_shen,ser_in,
                                            outval,inval,ld_en,msb);

    input wire clk,rst,right_shen,ser_in,left_shen,ld_en;
    input wire [SIZE - 1:0] inval;
    output wire msb;
    output wire [SIZE - 1 : 0] outval;
    
    reg [SIZE - 1 : 0] outval_reg;
    always @(posedge clk,posedge rst) begin
        if(rst) outval_reg <= 0;
        else if(ld_en) outval_reg <= inval;
        else begin
            if(right_shen) outval_reg = {ser_in,outval_reg[SIZE - 1:1]};
            else if(left_shen) outval_reg = {outval_reg[SIZE - 1 - 1 : 0],ser_in}; // msb out
        end
    end
    
    assign outval = outval_reg;
    assign msb = outval[SIZE - 1];
endmodule

module Counter #(parameter NUM_BIT = 4) (clk,rst,ld_cnt,cnt_en,co,load_value,cnt_out_wire);
    input wire clk,rst,ld_cnt,cnt_en;
    input wire[NUM_BIT - 1:0] load_value;
    output wire co;
    output wire [NUM_BIT - 1:0] cnt_out_wire;
    reg [NUM_BIT - 1:0] cnt_out = 0;
    always @(posedge clk,posedge rst) begin
        if (rst) cnt_out <= 0;
        else begin
            if (ld_cnt) cnt_out <= load_value;
            else if(cnt_en) cnt_out <= cnt_out + 1;
        end
    end

    assign co = &cnt_out;
    assign cnt_out_wire = cnt_out;

endmodule

module IF_distance_calculator #(parameter ADDR_LEN,
          parameter SCRATCH_DEPTH,
          parameter SCRATCH_WIDTH)
      (start_val,end_val,distance);

    input wire [ADDR_LEN - 1:0] start_val,end_val;
    output wire [ADDR_LEN - 1:0] distance;

    assign distance = start_val > end_val ? SCRATCH_DEPTH - (start_val - end_val):
                    end_val - start_val;

endmodule