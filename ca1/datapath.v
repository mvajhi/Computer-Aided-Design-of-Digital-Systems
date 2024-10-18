module datapath(
    input wire clk,
    input wire rst,

    // shift regs
    input wire load_shift1,
    input wire shift1,
    input wire load_shift2,
    input wire shift2,
    input wire load_shift_result,
    input wire shift_result,

    // counters
    input wire [3:0] cntr_ld_init,
    input wire cntr_ld_en,
    input wire [2:0] cntr1_init,
    input wire cntr1_en,
    input wire [2:0] cntr2_init,
    input wire cntr2_en,
    input wire cntr_sh_load,
    input wire cntr_sh_en,

    output wire [27:0] result
);

    // Internal signals
    wire [15:0] shift1_out;
    wire [15:0] shift2_out;

    In_RAM #(.ADDR_WIDTH(16),.DATA_WIDTH(16),) in_ram
    (
        .clk(clk),
        .rst(rst),
    )

    // Instantiate the first 14-bit shift register
    shiftreg shift1(
        .clk(clk),
        .rst(rst),
        .load(load_shift1),
        .shift_en(shift1),
        .in(data_in1),
        .out(shift1_out)
    );

    // Instantiate the second 14-bit shift register
    shiftreg shift2(
        .clk(clk),
        .rst(rst),
        .load(load_shift2),
        .shift_en(shift2),
        .in(data_in2),
        .out(shift2_out)
    );

    // Instantiate the multiplier
    multiplier mul(
        .in1(shift1_out),
        .in2(shift2_out),
        .product(product)
    );

    // Instantiate the counter
    Counter counter(
        .clk(clk),
        .rst(rst),
        .en(shift1 | shift2), // Enable counter when any shift signal is active
        .init(counter_load_value),
        .counter(),
        .zero(counter_zero)
    );

    // Result register to hold the product
    reg [27:0] result_reg;

    always @(posedge clk or posedge rst) begin
        if (rst)
            result_reg <= 28'b0; // rst result register
        else if (load_shift1 || load_shift2) // Store the product when loading new data
            result_reg <= product;
    end

    // Output the result
    assign result = result_reg;

endmodule


