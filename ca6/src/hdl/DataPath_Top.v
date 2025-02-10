module DataPath_Top # (
    parameter FILT_ADDR_LEN,
    parameter IF_ADDR_LEN,
    parameter IF_SCRATCH_DEPTH,
    parameter IF_SCRATCH_WIDTH,
    parameter FILT_SCRATCH_DEPTH,
    parameter FILT_SCRATCH_WIDTH,
    parameter IF_par_write,
    parameter filter_par_write,
    parameter outbuf_par_read,
    parameter IF_BUFFER_DEPTH,
    parameter FILT_BUFFER_DEPTH,
    parameter OUT_BUFFER_DEPTH,
    parameter PSUM_SC_ADDR_LEN,
    parameter PSUM_SC_DEPTH,
    parameter INPUT_PSUM_WIDTH,
    parameter INPUT_PSUM_DEPTH
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] inData,
    output wire [31:0] outData
);
    
    
    
    // PE 1
    PE PE1 #(
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
    ) (
        .clk(clk),
        .rst(rst),
        .inData(inData),
        .outData(outData)
    );

endmodule