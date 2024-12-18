module ReadAddressGeneratorFilter #(
    parameter SP_SIZE = 8,
    parameter FILTER_SIZE_REG_SIZE = 8,
    parameter POINTER_SIZE = 8
) (
    input clk,
    input rst,
    input [FILTER_SIZE_REG_SIZE-1:0] filter_size,
    input put_filter,
    input next_filter,
    input end_of_filter,

    output co_filter,
    output reg [POINTER_SIZE-1:0] read_pointer
);
    reg [$clog2(SP_SIZE)-1:0] offset;
    reg [FILTER_SIZE_REG_SIZE-1:0] point_in_filter;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            offset <= 0;
        end
        else if (end_of_filter && next_filter) begin
            offset <= 0;
        end
        else if (next_filter) begin
            offset <= offset + filter_size;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            point_in_filter <= 0;
        end
        else if (put_filter) begin
            if (point_in_filter == filter_size - 1) begin
                point_in_filter <= 0;
            end
            else begin
                point_in_filter <= point_in_filter + 1'b1;
            end
        end
    end

    assign read_pointer = offset + point_in_filter;

    assign co_filter = point_in_filter == filter_size - 1;

endmodule