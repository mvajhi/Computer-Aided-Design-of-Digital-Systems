module TB ();
    reg rst=0;
    reg clk=0;
    reg [(16 + 2) * 14 - 1:0] data_in;
    reg [16 * 9 - 1:0] filter_in;
    reg start = 1'b1;
    reg [2:0] stride = 2'd2;
    reg w_data = 1'b0;
    reg w_filter = 1'b0;
    wire [15:0] data_out;
    wire done;
    wire r_sum;


    always #5 clk = ~clk;

    initial begin
        rst = 1;
        #20 rst = 0;

        data_in = {{{2'b01, 16'd14}, {2'b00, 16'd13}, {2'b00, 16'd12},
                    {2'b00, 16'd11}, {2'b00, 16'd10}, {2'b00, 16'd9}, {2'b10, 16'd8}},
                    {{2'b01, 16'd7}, {2'b00, 16'd6}, {2'b00, 16'd5},
                    {2'b00, 16'd4}, {2'b00, 16'd3}, {2'b00, 16'd2}, {2'b10, 16'd1}}};

        filter_in = {{16'd9, 16'd8, 16'd7}, {16'd6, 16'd5, 16'd4}, {16'd3, 16'd2, 16'd1}};

        w_data = 1'b1;
        w_filter = 1'b1;

        #20 w_data = 1'b0;
        w_filter = 1'b0;
        start = 1'b1;

        #10 start = 1'b0;



        #2000 $stop;
    end 

    topmodule #(
        .PSUM_DEPTH(16),
        .IFMAP_WIDTH(18),
        .IFMAP_BUFFER_DEPTH(16),
        .IFMAP_POINTER_SIZE(4),
        .IFMAP_SPAD_ROW(16),
        .FILTER_SPAD_ROW(9),
        .FILTER_BUFFER_DEPTH(16),
        .FILTER_WIDTH(16),
        .FILTER_SIZE_REG_SIZE(2),
        .FILTER_POINTER_SIZE(4),
        .STRIDE_SIZE(3),
        .PAR_WRITE_IFMAP(14),
        .PAR_WRITE_FILTER(9)
    ) UUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .stride(stride),
        .filter_size(2'd3),
        .IFMap_in(data_in),
        .Filter_in(filter_in),
        .wen_IFMap_buffer(w_data),
        .wen_Filter_buffer(w_filter),
        .ren_Psum_buffer(r_sum),
        .chip_en(1'b1),
        .Psum_out(data_out),
        .done(done)
    );
endmodule