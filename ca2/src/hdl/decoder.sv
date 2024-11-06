module decoder #(
    parameter SIZE = 8,
    parameter WRITE_SIZE = 2
) (
    input wire [$clog2(SIZE)-1:0] in,
    input wire en,
    output reg  [SIZE-1:0] out
);

    integer i;
    always @(*) begin

        out = {SIZE{1'b0}};
        if (en)
        begin
            for (i = 0; i < WRITE_SIZE; i = i + 1) begin
                out[(in + i) % SIZE] = 1'b1;
            end
        end
    end
endmodule
