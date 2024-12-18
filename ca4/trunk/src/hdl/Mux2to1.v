module Mux2to1(a, b, sel, c);
	parameter WIDTH = 4;	
	input [WIDTH-1:0] a, b;
	input sel;
	output [WIDTH-1:0] c;
	assign c = (sel==1) ? b : a;
endmodule
