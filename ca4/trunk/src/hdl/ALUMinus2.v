module ALUMinus2(a, b, neg, ans);
	parameter WIDTH = 4;
	input [WIDTH-1:0] a, b;
	output neg;
	output [WIDTH-1:0] ans;
	assign ans = a - b;
	assign neg = (a < b) ? 1 : 0;
endmodule
