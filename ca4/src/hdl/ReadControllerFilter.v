module Read_Controller_Filter #(
    parameter SP_SIZE = 8,
    parameter FILTER_SIZE_REG_SIZE = 8,
    parameter POINTER_SIZE = 8
) (
    input co_filter,
    input av_input,
    input [FILTER_SIZE_REG_SIZE-1:0] filter_size,
    input [POINTER_SIZE-1:0] write_pointer,
    input [POINTER_SIZE-1:0] read_pointer,
    
    output write_en_src_pad,
    output write_counter_en,
    output end_of_filter,
    output av_filter
);
    wire en;

    assign en = av_input && (write_pointer <= (SP_SIZE - filter_size));
    assign write_en_src_pad = en;
    assign write_counter_en = en;
    assign end_of_filter = (read_pointer == (SP_SIZE - (SP_SIZE % filter_size)));
    assign av_filter = (read_pointer < write_pointer);

endmodule