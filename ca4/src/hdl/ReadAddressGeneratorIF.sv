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
    input [POINTER_SIZE-1:0] start_row,
    input [POINTER_SIZE-1:0] end_row,
    input end_of_row,

    output [POINTER_SIZE-1:0] read_pointer
);

reg [POINTER_SIZE-1:0] offset;
reg [FILTER_SIZE_REG_SIZE-1:0] counter;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        offset <= 0;
    end
    else if (next_row) begin
        offset <= offset + counter + 1;
    end
    else if (put_data && end_of_row && counter == filter_size - 1) begin
        offset <= start_row;
    end
    else if (put_data && counter == filter_size - 1) begin
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
        if (counter == filter_size - 1) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end
end

assign read_pointer = offset + counter;

endmodule