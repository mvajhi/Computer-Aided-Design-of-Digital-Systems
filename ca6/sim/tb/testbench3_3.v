// `timescale 1ps / 1ps
// `default_nettype none

// module testbench3_3();

//     // Parameters
//     parameter FILT_ADDR_LEN = 4;
//     parameter IF_ADDR_LEN = 4;
//     parameter IF_SCRATCH_DEPTH = 12;
//     parameter IF_SCRATCH_WIDTH = 16;
//     parameter FILT_SCRATCH_DEPTH = 16;
//     parameter FILT_SCRATCH_WIDTH = 16;
//     parameter IF_par_write = 1;
//     parameter filter_par_write = 1;
//     parameter outbuf_par_read = 1;
//     parameter IF_BUFFER_DEPTH = 64;
//     parameter FILT_BUFFER_DEPTH = 64;
//     parameter OUT_BUFFER_DEPTH = 64;
//     parameter PSUM_SC_ADDR_LEN = 6;
//     parameter PSUM_SC_DEPTH = 64;
//     parameter INPUT_PSUM_WIDTH = FILT_SCRATCH_DEPTH + IF_SCRATCH_WIDTH + 1;
//     parameter INPUT_PSUM_DEPTH = 64;

//     // Signals
//     reg clk;
//     reg rst;
//     reg start;
//     reg IF_wen;
//     reg [IF_par_write * (IF_SCRATCH_WIDTH + 2) - 1 : 0] IF_din;
//     reg filter_wen;
//     reg [filter_par_write * FILT_SCRATCH_WIDTH - 1 : 0] filter_din;
//     reg outbuf_ren;
//     wire [outbuf_par_read * (IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH + 1) - 1 : 0] outbuf_dout;
//     reg [outbuf_par_read * (IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH + 1) - 1 : 0] dout_val;
//     wire IF_full;
//     wire IF_empty;
//     wire filter_full;
//     wire filter_empty;
//     wire outbuf_full;
//     wire outbuf_empty;
//     reg [FILT_ADDR_LEN - 1:0] filt_len;
//     reg [IF_ADDR_LEN - 1:0] stride_len;
//     wire inpusm_buf_full;
//     wire ready_to_get;
//     wire [FILT_SCRATCH_WIDTH + IF_SCRATCH_WIDTH:0] psum_sc_out;
//     reg[1:0] mode = 3;
//     reg outbuf_write_flag = 0;
//     reg [PSUM_SC_ADDR_LEN - 1:0] see_inside_psum_sc_counter;
//     reg inside_psum_sc_flag = 0;

//     design_top #(
//     .FILT_ADDR_LEN(FILT_ADDR_LEN),
//     .IF_ADDR_LEN(IF_ADDR_LEN),
//     .IF_SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
//     .IF_SCRATCH_WIDTH(IF_SCRATCH_WIDTH),
//     .FILT_SCRATCH_DEPTH(FILT_SCRATCH_DEPTH),
//     .FILT_SCRATCH_WIDTH(FILT_SCRATCH_WIDTH),
//     .IF_par_write(IF_par_write),
//     .filter_par_write(filter_par_write),
//     .outbuf_par_read(outbuf_par_read),
//     .IF_BUFFER_DEPTH(IF_BUFFER_DEPTH),
//     .FILT_BUFFER_DEPTH(FILT_BUFFER_DEPTH),
//     .OUT_BUFFER_DEPTH(OUT_BUFFER_DEPTH),
//     .PSUM_SC_ADDR_LEN(PSUM_SC_ADDR_LEN),
//     .PSUM_SC_DEPTH(PSUM_SC_DEPTH),      
//     .INPUT_PSUM_WIDTH(INPUT_PSUM_WIDTH),
//     .INPUT_PSUM_DEPTH(INPUT_PSUM_DEPTH) 
// ) uut (
//     .clk(clk),
//     .rst(rst),
//     .start(start),
//     .IF_wen(IF_wen),
//     .IF_din(IF_din),
//     .filter_wen(filter_wen),
//     .filter_din(filter_din),
//     .outbuf_ren(outbuf_ren),
//     .outbuf_dout(outbuf_dout),
//     .IF_full(IF_full),
//     .IF_empty(IF_empty),
//     .filter_full(filter_full),
//     .filter_empty(filter_empty),
//     .outbuf_full(outbuf_full),
//     .outbuf_empty(outbuf_empty),
//     .filt_len(filt_len),
//     .stride_len(stride_len),
//     .mode(mode),                         // Placeholder for new input
//     .outbuf_write_flag(outbuf_write_flag),            // Placeholder for new input
//     .inpsum_buf_wen(1'b0),               // Placeholder for new input
//     .inpsum_buf_inval({(INPUT_PSUM_WIDTH){1'b0}}), // Placeholder for new input
//     .inpsum_buf_full(inpusm_buf_full),                  // Placeholder for new output
//     .ready_to_get(ready_to_get),                      // Placeholder for new output
//     .psum_sc_out(psum_sc_out),
//     .see_inside_psum_sc_counter(see_inside_psum_sc_counter),
//     .inside_psum_sc_flag(inside_psum_sc_flag)
// );

//     always @(posedge clk) begin
//         if (outbuf_ren) dout_val <= outbuf_dout;
//     end

//     // Clock generation
//     always #5 clk = ~clk;

//     // Testbench logic
//     integer i;
//     reg [15:0] psum_values [0:63];
//     reg [FILT_SCRATCH_WIDTH - 1:0] filter_inputs [0:63];
//     reg [IF_SCRATCH_WIDTH + 1:0] IFmap_inputs [0:63];
//     reg inside_count_flag = 0;

//     initial begin
//         // Initialize signals
//         clk = 0;
//         rst = 1;
//         start = 0;
//         IF_wen = 0;
//         filter_wen = 0;
//         outbuf_ren = 0;
//         IF_din = 0;
//         filter_din = 0;
//         filt_len = 3;
//         stride_len = 1;

//         // Assign 16-bit x to indices 3 through 11
//         for (i = 0; i <= 11; i = i + 1) begin
//             filter_inputs[i] = 16'bx;
//         end

//         // Initialize filter inputs
//         filter_inputs[0] = -16'd130;
//         filter_inputs[1] = -16'd53;
//         filter_inputs[2] = 16'd177;
//         filter_inputs[3] = -16'd120;
//         filter_inputs[4] = -16'd121;
//         filter_inputs[5] = 16'd25;

//         // Initialize IFmap inputs (applying the first two-bit rule)
//         IFmap_inputs[0] = {2'b10, 16'd0};      // Starts with 10
//         IFmap_inputs[1] = {2'b00, 16'd0};      // Starts with 00
//         IFmap_inputs[2] = {2'b00, -16'd1};     // Starts with 00
//         IFmap_inputs[3] = {2'b00, 16'd2};      // Starts with 00
//         IFmap_inputs[4] = {2'b00, -16'd1};     // Starts with 00
//         IFmap_inputs[5] = {2'b00, -16'd2};     // Starts with 00
//         IFmap_inputs[6] = {2'b00, 16'd2};      // Starts with 00
//         IFmap_inputs[7] = {2'b00, 16'd0};      // Starts with 00
//         IFmap_inputs[8] = {2'b00, 16'd1};      // Starts with 00
//         IFmap_inputs[9] = {2'b01, 16'd1};      // Ends with 01

//         // Initialize psum values
//         psum_values[0] = -346;
//         psum_values[1] = 819;
//         psum_values[2] = -155;
//         psum_values[3] = -776;
//         psum_values[4] = 494;

//         // Apply reset
//         #10 rst = 0;

//         // Start operation
//         start = 1;
//         #10 start = 0;

//         // Input data
//         for (i = 0; i < 10; i = i + 1) begin
//             if (filter_inputs[i] !== 16'bX) begin
//                 filter_din = filter_inputs[i];
//                 filter_wen = 1;
//             end

//             if (IFmap_inputs[i] !== 18'bX) begin
//                 IF_din = IFmap_inputs[i];
//                 IF_wen = 1;
//             end

//             #10;
//             filter_wen = 0;
//             IF_wen = 0;
//         end

//         // Read outputs
//         while (~ready_to_get) begin
//             #1; // Wait for 1 time unit and recheck
//         end

//         inside_psum_sc_flag = 1;

//         #10;

//         for (i = 0; i < 5; i = i + 1) begin
//             // Wait until buffer is not empty
//             inside_count_flag = 1;
//             $display("Time: %0t - psum_scratch: %b, Psum: %b, True: %b", $time, 
//                     psum_sc_out[15:0], psum_values[i], psum_sc_out[15:0] == psum_values[i]);
//             #10;
//         end


//         // End simulation
//         #100 $stop;
//     end

//     always @(posedge clk, posedge rst) begin
//         if (rst)
//             see_inside_psum_sc_counter <= 0;
//         else if (inside_psum_sc_flag & inside_count_flag)
//             see_inside_psum_sc_counter <= see_inside_psum_sc_counter + 1;
//     end


// endmodule

`timescale 1ps / 1ps
`default_nettype none

module testbench3_3();

    // Parameters
    parameter FILT_ADDR_LEN = 4;
    parameter IF_ADDR_LEN = 4;
    parameter IF_SCRATCH_DEPTH = 12;
    parameter IF_SCRATCH_WIDTH = 16;
    parameter FILT_SCRATCH_DEPTH = 16;
    parameter FILT_SCRATCH_WIDTH = 16;
    parameter IF_par_write = 1;
    parameter filter_par_write = 1;
    parameter outbuf_par_read = 1;
    parameter IF_BUFFER_DEPTH = 64;
    parameter FILT_BUFFER_DEPTH = 64;
    parameter OUT_BUFFER_DEPTH = 64;
    parameter PSUM_SC_ADDR_LEN = 6;
    parameter PSUM_SC_DEPTH = 64;
    parameter INPUT_PSUM_WIDTH = FILT_SCRATCH_DEPTH + IF_SCRATCH_WIDTH + 1;
    parameter INPUT_PSUM_DEPTH = 64;

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
    wire inpusm_buf_full;
    wire ready_to_get;
    wire [FILT_SCRATCH_WIDTH + IF_SCRATCH_WIDTH:0] psum_sc_out;
    reg[1:0] mode = 1;
    reg outbuf_write_flag = 0;
    reg [PSUM_SC_ADDR_LEN - 1:0] see_inside_psum_sc_counter;
    reg inside_psum_sc_flag = 0;
    reg inbuf_psum_wen;

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
    .OUT_BUFFER_DEPTH(OUT_BUFFER_DEPTH),
    .PSUM_SC_ADDR_LEN(PSUM_SC_ADDR_LEN),
    .PSUM_SC_DEPTH(PSUM_SC_DEPTH),      
    .INPUT_PSUM_WIDTH(INPUT_PSUM_WIDTH),
    .INPUT_PSUM_DEPTH(INPUT_PSUM_DEPTH) 
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
    .stride_len(stride_len),
    .mode(mode),                         // Placeholder for new input
    .outbuf_write_flag(outbuf_write_flag),            // Placeholder for new input
    .inpsum_buf_wen(inbuf_psum_wen),               // Placeholder for new input
    .inpsum_buf_inval({(INPUT_PSUM_WIDTH){1'b0}}), // Placeholder for new input
    .inpsum_buf_full(inpusm_buf_full),                  // Placeholder for new output
    .ready_to_get(ready_to_get),                      // Placeholder for new output
    .psum_sc_out(psum_sc_out),
    .see_inside_psum_sc_counter(see_inside_psum_sc_counter),
    .inside_psum_sc_flag(inside_psum_sc_flag)
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
    reg inside_count_flag = 0;

    initial begin
        // Initialize signals
        mode = 3;
        clk = 0;
        rst = 1;
        start = 0;
        IF_wen = 0;
        filter_wen = 0;
        outbuf_ren = 0;
        IF_din = 0;
        filter_din = 0;
        filt_len = 3;
        stride_len = 1;

        // Assign 16-bit x to indices 3 through 11
        for (i = 0; i <= 11; i = i + 1) begin
            filter_inputs[i] = 16'bx;
        end

        // Initialize filter inputs
        filter_inputs[0] = -16'd130;
        filter_inputs[1] = -16'd53;
        filter_inputs[2] = 16'd177;
        filter_inputs[3] = -16'd120;
        filter_inputs[4] = -16'd121;
        filter_inputs[5] = 16'd25;

        // Initialize IFmap inputs (applying the first two-bit rule)
        IFmap_inputs[0] = {2'b10, 16'd0};      // Starts with 10
        IFmap_inputs[1] = {2'b00, 16'd0};      // Starts with 00
        IFmap_inputs[2] = {2'b00, -16'd1};     // Starts with 00
        IFmap_inputs[3] = {2'b00, 16'd2};      // Starts with 00
        IFmap_inputs[4] = {2'b00, -16'd1};     // Starts with 00
        IFmap_inputs[5] = {2'b00, -16'd2};     // Starts with 00
        IFmap_inputs[6] = {2'b00, 16'd2};      // Starts with 00
        IFmap_inputs[7] = {2'b00, 16'd0};      // Starts with 00
        IFmap_inputs[8] = {2'b00, 16'd1};      // Starts with 00
        IFmap_inputs[9] = {2'b01, 16'd1};      // Ends with 01

        // Initialize psum values
        psum_values[0] = -346;
        psum_values[1] = 819;
        psum_values[2] = -155;
        psum_values[3] = -776;
        psum_values[4] = 494;

        // Apply reset
        #10 rst = 0;

        // Start operation
        start = 1;
        #10 start = 0;

        // Input data
        for (i = 0; i < 10; i = i + 1) begin
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
        while (~ready_to_get) begin
            #1; // Wait for 1 time unit and recheck
        end

        outbuf_write_flag = 1;
        inbuf_psum_wen = 1;

        #10;

        inbuf_psum_wen = 0;

        // Read outputs
        for (i = 0; i < 5; i = i + 1) begin
            // Wait until buffer is not empty
            while (outbuf_empty) begin
                #1; // Wait for 1 time unit and recheck
            end

            outbuf_ren = 1; // Enable read
            inbuf_psum_wen = 1;
            #10;
            $display("Time: %0t - Outbuf: %b, Psum: %b, True: %b", $time, dout_val[15:0], psum_values[i], dout_val[15:0] == psum_values[i]);
            outbuf_ren = 0; // Disable read
            inbuf_psum_wen = 0;
        end

        // End simulation
        #100 $stop;
    end

endmodule
