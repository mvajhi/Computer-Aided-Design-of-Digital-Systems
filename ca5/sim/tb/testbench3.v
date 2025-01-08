`timescale 1ps / 1ps

module testbench3();

    // Parameters
    parameter FILT_ADDR_LEN = 4;
    parameter IF_ADDR_LEN = 4;
    parameter IF_SCRATCH_DEPTH = 12;    // Adjusted based on CSV
    parameter IF_SCRATCH_WIDTH = 16;    // Adjusted based on CSV
    parameter FILT_SCRATCH_DEPTH = 15;  // Adjusted based on CSV
    parameter FILT_SCRATCH_WIDTH = 16;  // Adjusted based on CSV
    parameter IF_par_write = 1;
    parameter filter_par_write = 1;
    parameter outbuf_par_read = 1;
    parameter IF_BUFFER_DEPTH = 64;
    parameter FILT_BUFFER_DEPTH = 64;
    parameter OUT_BUFFER_DEPTH = 64;

    // Signals
    reg clk;
    reg rst;
    reg start;
    reg IF_wen;
    reg [IF_par_write * (IF_SCRATCH_WIDTH + 2) - 1 : 0] IF_din;
    reg filter_wen;
    reg [filter_par_write * FILT_SCRATCH_WIDTH - 1 : 0] filter_din;
    reg outbuf_ren;
    wire [outbuf_par_read * (IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH + 1) - 1 : 0] outbuf_dout;
    reg [outbuf_par_read * (IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH + 1) - 1 : 0] dout_val;
    wire IF_full;
    wire IF_empty;
    wire filter_full;
    wire filter_empty;
    wire outbuf_full;
    wire outbuf_empty;
    reg [FILT_ADDR_LEN - 1:0] filt_len;
    reg [IF_ADDR_LEN - 1:0] stride_len;

    // Instantiate the design_top module
    design_top #(
        .FILT_ADDR_LEN(FILT_ADDR_LEN),
        .IF_ADDR_LEN(IF_ADDR_LEN),
        .IF_SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
        .IF_SCRATCH_WIDTH(IF_SCRATCH_WIDTH),
        .FILT_SCRATCH_DEPTH(FILT_SCRATCH_DEPTH),
        .FILT_SCRATCH_WIDTH(FILT_SCRATCH_WIDTH),
        .IF_par_write(IF_par_write),
        .filter_par_write(filter_par_write),
        .outbuf_par_read(outbuf_par_read),
        .IF_BUFFER_DEPTH(IF_BUFFER_DEPTH),
        .FILT_BUFFER_DEPTH(FILT_BUFFER_DEPTH),
        .OUT_BUFFER_DEPTH(OUT_BUFFER_DEPTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .IF_wen(IF_wen),
        .IF_din(IF_din),
        .filter_wen(filter_wen),
        .filter_din(filter_din),
        .outbuf_ren(outbuf_ren),
        .outbuf_dout(outbuf_dout),
        .IF_full(IF_full),
        .IF_empty(IF_empty),
        .filter_full(filter_full),
        .filter_empty(filter_empty),
        .outbuf_full(outbuf_full),
        .outbuf_empty(outbuf_empty),
        .filt_len(filt_len),
        .stride_len(stride_len)
    );

    always @(posedge clk) begin
        if (outbuf_ren) dout_val <= outbuf_dout;
    end

    // Clock generation
    always #5 clk = ~clk;

    // Testbench logic
    integer i;
    reg [15:0] psum_values [0:63];
    reg [FILT_SCRATCH_WIDTH - 1:0] filter_inputs [0:63];
    reg [IF_SCRATCH_WIDTH + 1:0] IFmap_inputs [0:63];

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        IF_wen = 0;
        filter_wen = 0;
        outbuf_ren = 0;
        IF_din = 0;
        filter_din = 0;
        filt_len = 5;    // Adjusted based on CSV
        stride_len = 2;   // Adjusted based on CSV

        // Input data
        filter_inputs[0] = 16'b0000000000001010; IFmap_inputs[0] = 18'b101111111111011011; psum_values[0] = 16'b1110111100111001;
        filter_inputs[1] = 16'bX;                IFmap_inputs[1] = 18'bX;                psum_values[1] = 16'b0001000000111001;
        filter_inputs[2] = 16'b1111111111010101; IFmap_inputs[2] = 18'b001111111111010101; psum_values[2] = 16'b1110101110100000;
        filter_inputs[3] = 16'b1111111111000100; IFmap_inputs[3] = 18'b000000000000111111; psum_values[3] = 16'b0001000110000111;
        filter_inputs[4] = 16'b0000000000001110; IFmap_inputs[4] = 18'bX;                psum_values[4] = 16'b0001011101001100;
        filter_inputs[5] = 16'b0000000000101100; IFmap_inputs[5] = 18'b000000000000101011; psum_values[5] = 16'b0000011011100010;
        filter_inputs[6] = 16'b0000000000100001; IFmap_inputs[6] = 18'b001111111111000101; psum_values[6] = 16'b0000101100101000;
        filter_inputs[7] = 16'b0000000000011011; IFmap_inputs[7] = 18'b000000000000101110; psum_values[7] = 16'b0000000111010010;
        filter_inputs[8] = 16'bX;                IFmap_inputs[8] = 18'b010000000000011011; psum_values[8] = 16'b1111110011100001;
        filter_inputs[9] = 16'bX;                IFmap_inputs[9] = 18'b101111111111001110; psum_values[9] = 16'b1111111101110110;
        filter_inputs[10] = 16'b1111111111100001; IFmap_inputs[10] = 18'b001111111111110100; psum_values[10] = 16'b0000010110100010;
        filter_inputs[11] = 16'b1111111111110001; IFmap_inputs[11] = 18'b001111111111001001; psum_values[11] = 16'b1110011011000111;
        filter_inputs[12] = 16'b0000000000000100; IFmap_inputs[12] = 18'b000000000000011110; psum_values[12] = 16'b0000001110000110;
        filter_inputs[13] = 16'b0000000000110001; IFmap_inputs[13] = 18'b001111111111101100; psum_values[13] = 16'b0000001110010111;
        filter_inputs[14] = 16'b1111111111000011; IFmap_inputs[14] = 18'b001111111111110111; psum_values[14] = 16'b0000011000101111;
        filter_inputs[15] = 16'bX;                IFmap_inputs[15] = 18'b010000000000011100; psum_values[15] = 16'b1111100010101001;
        filter_inputs[16] = 16'b1111111111111000; IFmap_inputs[16] = 18'b100000000000011110; psum_values[16] = 16'b1110110110110000;
        filter_inputs[17] = 16'b0000000000110100; IFmap_inputs[17] = 18'b000000000000001000; psum_values[17] = 16'b1111101001001101;
        filter_inputs[18] = 16'b1111111111000110; IFmap_inputs[18] = 18'bX;                psum_values[18] = 16'b0000110000010111;
        filter_inputs[19] = 16'bX;                IFmap_inputs[19] = 18'b000000000000010000; psum_values[19] = 16'b1111011101111101;
        filter_inputs[20] = 16'bX;                IFmap_inputs[20] = 18'b001111111111010101; psum_values[20] = 16'b0000011110011000;
        filter_inputs[21] = 16'bX;                IFmap_inputs[21] = 18'b000000000000111001; psum_values[21] = 16'b1111100111000101;
        filter_inputs[22] = 16'bX;                IFmap_inputs[22] = 18'b001111111111101101; psum_values[22] = 16'b0000011110101101;
        filter_inputs[23] = 16'bX;                IFmap_inputs[23] = 18'b010000000000111011; psum_values[23] = 16'b0000010110011011;
        filter_inputs[24] = 16'bX;                IFmap_inputs[24] = 18'b100000000000110010; psum_values[24] = 16'bX;
        filter_inputs[25] = 16'bX;                IFmap_inputs[25] = 18'b001111111111101001; psum_values[25] = 16'bX;
        filter_inputs[26] = 16'bX;                IFmap_inputs[26] = 18'bX;                psum_values[26] = 16'bX;
        filter_inputs[27] = 16'bX;                IFmap_inputs[27] = 18'b001111111111101110; psum_values[27] = 16'bX;
        filter_inputs[28] = 16'bX;                IFmap_inputs[28] = 18'b001111111111101101; psum_values[28] = 16'bX;
        filter_inputs[29] = 16'bX;                IFmap_inputs[29] = 18'b000000000000010010; psum_values[29] = 16'bX;
        filter_inputs[30] = 16'bX;                IFmap_inputs[30] = 18'b001111111111110010; psum_values[30] = 16'bX;
        filter_inputs[31] = 16'bX;                IFmap_inputs[31] = 18'b011111111111011101; psum_values[31] = 16'bX;



        // Apply reset
        #10 rst = 0;

        // Start operation
        start = 1;
        #10 start = 0;

        // Input data
        for (i = 0; i < 32; i = i + 1) begin
            if (filter_inputs[i] !== 16'bX) begin
                filter_din = filter_inputs[i];
                filter_wen = 1;
            end

            if (IFmap_inputs[i] !== 18'bX) begin
                IF_din = IFmap_inputs[i];
                IF_wen = 1;
            end

            #10;
            filter_wen = 0;
            IF_wen = 0;
        end

        // Read outputs
        for (i = 0; i < 24; i = i + 1) begin
            // Wait until buffer is not empty
            while (outbuf_empty) begin
                #1; // Wait for 1 time unit and recheck
            end

            outbuf_ren = 1; // Enable read
            #10;
            $display("Time: %0t - i: %d - Outbuf: %b, Psum: %b, True: %b", $time, i, dout_val[15:0], psum_values[i], dout_val[15:0] == psum_values[i]);
            outbuf_ren = 0; // Disable read
        end

        // End simulation
        #100 $stop;
    end

endmodule
