module Register(clk, rst, ld_data, ParIn, data);
    parameter WIDTH = 4;
    input clk, rst, ld_data;
    input [WIDTH - 1 :0] ParIn;
    output reg [WIDTH - 1:0] data;

  always @(posedge clk, posedge rst) begin
    if (rst) data <= 0;
    else if (ld_data) data <= ParIn;
  end
endmodule

