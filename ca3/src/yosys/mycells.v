`timescale 1ns/1ns
module NOT(A, Y);
input A;
output Y;
assign #3 Y = ~A;
endmodule

module NAND(A, B, Y);
input A, B;
output Y;
assign #5 Y = ~(A & B);
endmodule

module NOR(A, B, Y);
input A, B;
output Y;
assign #5 Y = ~(A | B);
endmodule

module DFF(C, D, Q);
input C, D;
output reg Q;
always @(posedge C)
	Q <= D;
endmodule

module DFF_PP0 (D, C, R, Q);
input D, C, R;
output reg Q;
always @(posedge C or posedge R) begin
	if (R == 1)
		Q <= 0;
	else
		Q <= D;
end
endmodule

module DFF_PP1 (D, C, R, Q);
input D, C, R;
output reg Q;
always @(posedge C or posedge R) begin
	if (R == 1)
		Q <= 1;
	else
		Q <= D;
end
endmodule
