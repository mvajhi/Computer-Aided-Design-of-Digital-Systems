module FIFOBuf2(clk, rst, read_enable, write_enable, din, ready, valid, dout);
	parameter ADDR_WIDTH = 4, DATA_WIDTH = 1, DEPTH = 4, PAR_READ = 1, PAR_WRITE = 1;	

	input clk, rst, read_enable, write_enable;
	input [PAR_WRITE * DATA_WIDTH - 1 : 0] din;
	output ready, valid;
    	output [PAR_READ * DATA_WIDTH - 1 : 0] dout; 
	
	wire full, empty;
	wire [ADDR_WIDTH-1: 0] raddr, waddr, raddr_next, waddr_next,raddr_new,waddr_new;
	wire [ADDR_WIDTH-1: 0] raddr_dep, waddr_dep;
	wire rsel, wsel, unused, bigger, equal;	

	SimpleBuf #(ADDR_WIDTH, DATA_WIDTH, DEPTH, PAR_READ, PAR_WRITE) SB(clk, write_enable & ~full, waddr, raddr, din, dout);
	Register #(ADDR_WIDTH) Read_addrreg(clk, rst, read_enable & ~empty  , raddr_next, raddr);
	Register #(ADDR_WIDTH) Write_addrreg(clk, rst, write_enable & ~full, waddr_next, waddr);
	Incrementer #(ADDR_WIDTH, PAR_READ) READ_INC(raddr, raddr_new);
	Incrementer #(ADDR_WIDTH, PAR_WRITE) WRITE_INC(waddr, waddr_new);

	Threshold_unit #(ADDR_WIDTH, DEPTH ) RATU(raddr_new, rsel);
	Threshold_unit #(ADDR_WIDTH, DEPTH) WATU(waddr_new, wsel);

	Decrementer #(ADDR_WIDTH, DEPTH) RDEC(raddr_new, raddr_dep);
	Decrementer #(ADDR_WIDTH, DEPTH) WDEC(waddr_new, waddr_dep);
	
	Mux2to1 #(ADDR_WIDTH) RMUX (raddr_new, raddr_dep, rsel, raddr_next);
	Mux2to1 #(ADDR_WIDTH) WMUX (waddr_new, waddr_dep, wsel, waddr_next);
	
	wire neg1, neg2;
	wire [ADDR_WIDTH-1:0] dif1, dif2, dif1pos, dif2pos;
	ALUMinus #(ADDR_WIDTH) RMW(raddr, waddr, neg1, dif1);
	ALUMinus2 #(ADDR_WIDTH) WMR(waddr, raddr, neg2, dif2);

	Incrementer #(ADDR_WIDTH, DEPTH + 1) POSD1(dif1, dif1pos);
	Incrementer #(ADDR_WIDTH, DEPTH) POSD2(dif2, dif2pos);
	
	wire [ADDR_WIDTH-1:0] rmwdif, wmrdif;
	wire nfull;
	Mux2to1 #(ADDR_WIDTH) FMUX (dif1, dif1pos, neg1, rmwdif);
	Threshold_unit #(ADDR_WIDTH, PAR_WRITE) NFTU(rmwdif, ready);
	assign full= ~ready;

	Mux2to1 #(ADDR_WIDTH) EMUX (dif2, dif2pos, neg2, wmrdif);
	MIN_Threshold_unit #(ADDR_WIDTH, PAR_READ) EMTU(wmrdif, empty);
	assign valid = ~empty;
endmodule