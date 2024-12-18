module Incrementer(data, new_data);
	parameter WIDTH = 4,IncVal = 1;
	input [WIDTH-1:0] data;
	output [WIDTH-1:0] new_data;
	assign new_data = data + IncVal;
endmodule
