module SimpleBuf(clk, wen, waddr, raddr, din, dout);
	parameter ADDR_WIDTH = 4, DATA_WIDTH = 1, DEPTH = 4, PAR_READ = 1, PAR_WRITE = 1;	
	input clk;
    	input wen;
    	input [ADDR_WIDTH - 1 : 0] waddr;
    	input [ADDR_WIDTH - 1 : 0] raddr;
    	input [PAR_WRITE * DATA_WIDTH - 1 : 0] din;
    	output [PAR_READ * DATA_WIDTH - 1 : 0] dout;
	
	reg [DATA_WIDTH - 1:0] mem [0:DEPTH];
	integer i = 0;

	always@(posedge clk)begin 
		if(wen)begin
			for (i=0;i<PAR_WRITE;i=i+1)begin
				if(waddr+i > DEPTH)
				mem[waddr+i-DEPTH-1] <= din[i*DATA_WIDTH +: DATA_WIDTH];
				else
				mem[waddr+i] <= din[i*DATA_WIDTH +: DATA_WIDTH];
			end
		end
	end

	genvar j;
	
	generate
		for(j=0;j<PAR_READ;j=j+1)begin
			assign dout[(j+1)*DATA_WIDTH-1:j*DATA_WIDTH]= (j+raddr > DEPTH) ? mem[j+raddr-DEPTH - 1]:mem[j+raddr];
		end
	endgenerate

 

endmodule
