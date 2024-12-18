module ReadAddressGeneratorIF #(
    parameter POINTER_SIZE = 8,
    parameter FILTER_SIZE_REG_SIZE = 8,
    parameter STRIDE_SIZE = 3
) (
    input clk,
    input rst,
    input [STRIDE_SIZE-1:0] stride,
    input [FILTER_SIZE_REG_SIZE-1:0] filter_size,
    input next_row,
    input put_data,

    output [POINTER_SIZE-1:0] read_pointer
);

reg [POINTER_SIZE-1:0] offset;
reg [FILTER_SIZE_REG_SIZE-1:0] counter;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        offset <= 0;
    end
    else if (next_row) begin
        offset <= 0;
    end
    else if (put_data && counter == filter_size) begin
        offset <= offset + stride;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
    end
    else if (next_row) begin
        counter <= 0;
    end
    else if (put_data) begin
        counter <= counter + 1;
    end
end

assign read_pointer = offset + counter;

endmodule