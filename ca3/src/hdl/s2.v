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
