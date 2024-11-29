module C1(
    input A0, A1, SA,
    input B0, B1, SB,
    input S0, S1,
    output F
);
    wire F1, F2, S2;

    assign F1 = SA ? A1 : A0;
    assign F2 = SB ? B1 : B0;
    assign S2 = S1 | S0;
    assign F = S2 ? F2 : F1;
endmodule

module C2(
    input A0, B0, A1, B1,
    input [3:0] D,
    output out
);
    wire S0, S1;

    assign S0 = A0 & B0;
    assign S1 = A1 | B1;

    assign out = D[{S1, S0}];
endmodule

module S1(
    input A0, B0, A1, B1,
    input [3:0] D,
    input CLK, CLR,
    output reg out
);
    wire S0, S1;
    wire [1:0] select;
    wire mux_out;

    assign S0 = A0 & B0; 
    assign S1 = A1 | B1; 
    assign select = {S1, S0}; 

    assign mux_out = D[select];

    always @(posedge CLK or posedge CLR) begin
        if (CLR)
            out <= 0;
        else
            out <= mux_out;
    end
endmodule

module S2(
    input A0, B0, A1, B1,
    input [3:0] D,
    input CLK, CLR,
    output reg out
);
    wire S0, S1;
    wire [1:0] select;
    wire mux_out;

    assign S0 = A0 & B0; 
    assign S1 = A1 | B1;
    assign select = {S1, S0}; 

    assign mux_out = D[select];

    always @(posedge CLK or posedge CLR) begin
        if (CLR)
            out <= 0;
        else
            out <= mux_out;
    end
endmodule
