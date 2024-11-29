module multiplier #(
    parameter WIDTH = 8
) (
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    output wire [2*WIDTH-1:0] out
);
    
    wire [WIDTH:0][WIDTH:0] xv, yv, pv, cv;

    genvar i, j;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : row
            for (j = 0; j < WIDTH; j = j + 1) begin : column
                bit_multiplier inst(
                    .xi(xv[i][j]),
                    .yi(yv[i][j]),
                    .pi(pv[i][j]),
                    .ci(cv[i][j]),
                    .xo(xv[i][j+1]),
                    .yo(yv[i+1][j]),
                    .po(pv[i+1][j]),
                    .co(cv[i+1][j+1])
                );
            end
        end
    endgenerate

    assign xv[0][0] = in1[0];
    assign yv[0][0] = in2[0];

    assign out = {pv[WIDTH][WIDTH-1:0]};

endmodule