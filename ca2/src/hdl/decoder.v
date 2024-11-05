module decoder #(
    parameter SIZE = 8,
    parameter WRITE_SIZE = 2
) (
    input  wire [SIZE-1:0] in,
    output reg  [SIZE-1:0] out
);

    integer i;
    always @(*) begin
        out = {SIZE{1'b0}};

        for (i = 0; i < WRITE_SIZE; i = i + 1) begin
            if (in + i < SIZE)
                out[in + i] = 1'b1;
        end
    end
endmodule
