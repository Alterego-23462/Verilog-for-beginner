//2025-11-6
//串口数据接收
`timescale 1ns/10ps
module UART_TXer(
	clk,
	res,
	data_in,
	en_data_in,
	TX,
	rdy,
);
input clk;
input res;
input[7:0] data_in;//准备发送的数据
input en_data_in;//发送使能
output TX;
output rdy;//空闲标志，0表示空闲

reg[3:0] state;//主状态机寄存器
reg[9:0] send_buf;//发送寄存器

reg[12:0] con;//控制寄存器右移节奏:用于计算波特周期
reg[9:0] send_flag;//用于判断右移结束

reg rdy;

assign TX=send_buf[0];//连接TX。send_buf右移连接输出TX，相当于串口发送（见原理图）

always@(posedge clk or negedge res)
if(~res)begin
	state<=0;con<=0;
	send_buf<=1;//因为接的是TX，TX空闲时为1，所以初值不能为0
	send_flag<=10'b10_0000_0000;//按照binary写时中间可以加下划线_
	rdy<=0;
end
else begin
	case(state)
	
	0://等待使能信号；
	begin
		if(en_data_in)begin
		send_buf={1'b1,data_in,1'b0};//{结束位，输入，起始位}
		send_flag<=10'b10_0000_0000;
		rdy<=1;
		state<=1;
		end
	end
	
	1://串口发送，寄存器右移
	begin
		if(con==5000-1)begin//24Mhz/4800波特率
			con<=0;
		end
		else begin
			con<=con+1;
		end
		
		if(con==5000-1)begin//con来控制右移的频率，按照4800的波特率,否则的话就是按系统时钟频率了
		//一开始con设置的是0，但这样的话一开始就会移1位，所以要改成4999
			send_buf[8:0]<=send_buf[9:1];//右移
			send_flag[8:0]<=send_flag[9:1];
		end
		
		if(send_flag[0])begin
			rdy<=0;//发送完了恢复0状态，表示空闲。发送中是1，表示正在忙
			state<=0;
		end
	end
	
	endcase
end
endmodule

//testbench
module UART_TXer_tb;

reg clk,res;
reg[7:0] data_in;
reg en_data_in;
wire TX;
wire rdy;

UART_TXer UART_TXer(
	clk,
	res,
	data_in,
	en_data_in,
	TX,
	rdy,
);

initial begin
	clk<=0;res<=0;data_in<=8'h0a;en_data_in<=0;
	#17 res<=1;
	#30 en_data_in<=1;
	#10 en_data_in<=0;//能坚持1个时钟周期即可,这里timescale设置的是10ns
	
	#2000000 $stop;
end

always#5 clk<=~clk;
endmodule
