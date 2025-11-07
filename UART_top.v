//2025.11.7
//串口通信顶层
`timescale 1ns/10ps
module UART_top(
clk,
res,
RX,
TX,
);
input clk;
input res;
input RX;
output TX;

//top里面纯是连接，没有一句逻辑
wire[7:0] din_pro;
wire en_din_pro;
wire[7:0] dout_pro;
wire en_dout_pro;
wire rdy;

UART_RXer UART_RXer(//这里要用异名例化了
.clk(clk),
.res(res),
.RX(RX),
.data_out(din_pro),
.en_data_out(en_din_pro)
);


UART_TXer UART_TXer(
   .clk(clk),
   .res(res),
	.data_in(dout_pro),
	.en_data_in(en_dout_pro),
	.TX(TX),
	.rdy(rdy)
);

cmd_pro cmd_pro(
.clk(clk),
.res(res),
.din_pro(din_pro),
.en_din_pro(en_din_pro),
.dout_pro(dout_pro),
.en_dout_pro(en_dout_pro),
.rdy(rdy)
);
endmodule


//testbench
module UART_top_tb;
reg clk,res;
wire RX;
wire TX;

reg[45:0] RX_send;//因为要发3个字节，所以比RX里面的拓宽些
assign RX=RX_send[0];

reg[13:0] con;

UART_top UART_top(
clk,
res,
RX,
TX,
);

initial begin
	clk<=0;res<=0;
	RX_send<={1'b1,8'h09,1'b0,
	1'b1,8'h06,1'b0,
	1'b1,8'h0a,1'b0,
	16'hffff};//{结束位，发送的数据，起始位，连续16个1}
	con<=0;
	#17   res<=1;
	#4000000 $stop;
end

always #5 clk<=~clk;

always@(posedge clk)begin
	if(con==5000-1)begin
		con<=0;
	end
	else begin
		con<=con+1;
	end
	
	if(con==0)begin
		RX_send[44:0]<=RX_send[45:1];
		RX_send[45]<=RX_send[0];//循环右移
	end
end
endmodule