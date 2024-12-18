module MIN_Threshold_unit(data, valid);
	parameter WIDTH = 4, Threshold = 4;
	input [WIDTH-1:0] data;
	output valid;
	assign valid = (data < Threshold) ? 1 : 0;
endmodule
