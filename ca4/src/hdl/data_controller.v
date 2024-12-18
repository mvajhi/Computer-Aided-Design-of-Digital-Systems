module Read_Controller_Filter #(
    parameter SP_size = 8,
    parameter FILTER_SIZE = 8,
    parameter POINTER_SIZE = 8,
    parameter SIZE_IFMAP = 32
) (
    input [POINTER_SIZE-1:0] read_pointer,
    input [POINTER_SIZE-1:0] write_pointer,
    input next_row,
    input end_row,
    input co_filter,
    input len_counter,
    input av_input,
    
    output av_data
    output end_of_row,
    output ld_start_row,
    output write_counter_en,
    output stride,
    output inc_len,
    output dec_len,
    output write_en_src_pad
);
    assign av_data = (len_counter == 0);
    assign end_of_row = end_row;
    assign ld_start_row = next_row;
    assign write_counter_en = av_input && (len_counter < SIZE_IFMAP);
    assign stride = co_filter;
    assign inc_len = write_counter_en;
    assign dec_len = next_row;
    assign write_en_src_pad = write_counter_en;
endmodule