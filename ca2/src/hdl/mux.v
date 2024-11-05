module multiplexer #(
    parameter SIZE = 4,           
    parameter DATA_WIDTH = 8      
) (
    input  wire [DATA_WIDTH-1:0] in [0:SIZE-1],
    input  wire [$clog2(SIZE)-1:0] select,       
    output wire [DATA_WIDTH-1:0] out             
);

    assign out = in[select];

endmodule
