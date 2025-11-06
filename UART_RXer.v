`timescale 1ns/10ps
module UART_RXer(
clk,
res,
RX,
data_out,
en_data_out
);

input clk;
input res;
input RX;//串口输入
output[7:0] data_out;//按字节输出
output en_data_out;//输出使能

reg[7:0] data_out;

reg[7:0] state;//状态机状态一开始可以多设置些存量
reg[12:0] con;//用于计算比特宽度24M/4800(波特率)=5,000,换成二进制
//ly:24M指的是1秒被分为24M个系统时，即24M个频率，波特率4800指的是1秒传输4800bit数据
//所以24M/4800指的是传输1个bit数据所占用的系统时
//而传输1.5bit则占用4800*1.5=8000个系统时，二进制也是13位
//设采样在一个bit中间采样，则起始位（1bit）到第一个bit数据之间间隔了1.5bit
//当然，实际采样中根据deepseek所说常采用过采样，如16倍过采样，一个bit采样16次，而不是只在中间采样一下
reg[3:0] con_bits;

reg RX_delay;//RX的延时，1状态时用到

reg en_data_out;
always@(posedge clk or negedge res)
if(~res)begin
	state<=0;con<=0;con_bits<=0;
	RX_delay<=0;data_out<=0;en_data_out<=0;//每定义了一个寄存器，都要赋初值
end
else begin
	RX_delay<=RX;//非阻塞赋值特性，在clk上升沿来临时记录RX的值，
	//在该时钟周期结束时赋给RX_delay，所以看起来是慢了一拍
	
	case(state)
	0://等空闲
	begin
		if(con==5000-1)begin
			con<=0;//ly：估计是4999到0的跳转还有1个系统时，所以一个周期总共是5000个系统时
		end
		else begin
			con<=con+1;
		end
		
		if(con==0)begin
			if(RX)begin
				con_bits<=con_bits+1;//每次加1表示接收了1个bite
			end
			else begin
				con_bits<=0;
			end
		end
		
		if(con_bits===12)begin//全等===会精确比较x和z状态，而==中这x状态的不确定会使得比较时认为不等
			state<=1;//接收了12个bit后停止,从状态0离开
		end
	end
	
	1://等起始位
	begin
		en_data_out<=0;
		if(~RX&RX_delay)begin
			state<=2;
		end
	end
	
	2://收最低为b0
	begin
		if(con==7500-1)begin//5000*1.5
		//后面仿真时data_out一直为0，没接收到8'haa，是因为con==7500-1我全写成con<=7500-1了
			con<=0;
			data_out[0]<=RX;
			state<=3;
		end
		else begin
			con<=con+1;
		end
	end
	
	3://收b1
	begin
	if(con==5000-1)begin//从b1开始就不用1.5bit了，而是1个bit即可
			con<=0;
			data_out[1]<=RX;
			state<=4;
		end
		else begin
			con<=con+1;
		end
	end
	
	4://收b2
	begin
	if(con==5000-1)begin//从b1开始就不用1.5bit了，而是1个bit即可
			con<=0;
			data_out[2]<=RX;
			state<=5;
		end
		else begin
			con<=con+1;
		end
	end
	
	5://收b3
	begin
	if(con==5000-1)begin//从b1开始就不用1.5bit了，而是1个bit即可
			con<=0;
			data_out[3]<=RX;
			state<=6;
		end
		else begin
			con<=con+1;
		end
	end
	
	6://收b4
	begin
	if(con==5000-1)begin//从b1开始就不用1.5bit了，而是1个bit即可
			con<=0;
			data_out[4]<=RX;
			state<=7;
		end
		else begin
			con<=con+1;
		end
	end
	
	7://收b5
	begin
	if(con==5000-1)begin//从b1开始就不用1.5bit了，而是1个bit即可
			con<=0;
			data_out[5]<=RX;
			state<=8;
		end
		else begin
			con<=con+1;
		end
	end
	
	8://收b6
	begin
	if(con==5000-1)begin//从b1开始就不用1.5bit了，而是1个bit即可
			con<=0;
			data_out[6]<=RX;
			state<=9;
		end
		else begin
			con<=con+1;
		end
	end
	
	9://收b7
	begin
	if(con==5000-1)begin//从b1开始就不用1.5bit了，而是1个bit即可
			con<=0;
			data_out[7]<=RX;
			state<=10;
		end
		else begin
			con<=con+1;
		end
	end
	
	10://产生使能信号
	begin
		en_data_out<=1;
		state<=1;
	end
	
	default://
	begin
		state<=0;
		con<=0;
		con_bits<=0;
		en_data_out<=0;
	end
	endcase
end

endmodule

//testbench
module UART_RXer_tb;
reg clk,res;
wire RX;
wire[7:0] data_out;
wire en_data_out;

reg[25:0] RX_send;//里面装有串口字节发送数据,1起始位+8数据位+1结束位+连续16位1表示处于空闲状态
assign RX=RX_send[0];//连接RX

reg[13:0] con;

UART_RXer UART_RXer(//同名例化,不用写点和括号等，要求上面的名字和这里的必须完全一样，比如都是clk
clk,
res,
RX,
data_out,
en_data_out
);

initial begin
	clk<=0;res<=0;
	RX_send<={1'b1,8'haa,1'b0,16'hffff};//{结束位，发送的数据，起始位，连续16个1}
	//这样写是为了让RX_send右移送出数据
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
		RX_send[24:0]<=RX_send[25:1];
		RX_send[25]<=RX_send[0];//循环右移
	end
end

endmodule


