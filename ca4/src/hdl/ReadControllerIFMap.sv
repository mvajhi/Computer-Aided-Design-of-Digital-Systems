module Read_Controller_IFMap #(
    parameter POINTER_SIZE = 8,
    parameter STRIDE_SIZE = 3,
    parameter IFMAP_SIZE = 16
) (
    input [POINTER_SIZE-1:0] read_pointer,
    input [POINTER_SIZE-1:0] write_pointer,
    input next_row,
    input end_row,
    input co_filter,
    input [POINTER_SIZE-1:0] len_counter,
    input av_input,
    input [POINTER_SIZE-1:0] start_row_addr,
    input start_row_bit,

    output av_data,
    output end_of_row,
    output ld_start_row,
    output write_counter_en,
    output stride_en,
    output inc_len,
    output dec_len,
    output write_en_src_pad
);
    // assign av_data = (len_counter != 0);
    assign av_data = (len_counter - (read_pointer - start_row_addr)) > 0;
    assign end_of_row = end_row;
    assign ld_start_row = next_row;
    assign write_counter_en = av_input && (len_counter < IFMAP_SIZE);
    assign stride_en = co_filter;
    assign inc_len = write_counter_en;
    assign dec_len = start_row_bit;
    assign write_en_src_pad = write_counter_en;
endmodule