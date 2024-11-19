module ram #(
    parameter RAM_VALUE_0 = 32'b0,
    parameter RAM_VALUE_1 = 32'b0
) (
    input         addr,
    output [31:0] data_out
);

    reg [31:0] ram [1:0];

    initial begin
        ram[0] = RAM_VALUE_0;
        ram[1] = RAM_VALUE_1;
    end

    assign data_out = ram[addr];

endmodule
