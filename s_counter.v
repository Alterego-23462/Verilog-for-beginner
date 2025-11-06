//2025.11.1
`timescale 1ns/10ps //有testbench就要写这个，ly：估计是因为tb里面有时序仿真
module s_counter(clk,res,s_sum);
input clk;
input res;
output[3:0] s_sum;

reg[24:0] con_t;//秒脉冲分频计数器24M
parameter frequency_clk=24;//指的是24M赫兹

reg s_pulse;//秒脉冲尖
reg s_counter;
reg[3:0] s_sum;//想要在always里赋值，得定义成reg

always@(posedge clk or negedge res)
//begin//always里面有多个if，所以记得加begin end
//错了，这多个if是在最外面的if嵌套里面的，不是并列的！
if(~res) begin
	con_t<=0;
	s_pulse<=0;
	s_sum<=0;//一旦在always里面赋值就成了一个实际的触发器，所以得赋初值。
end
else 
begin
	//if(con_t==frequency_clk*1000000-1)begin//设置好频率
	if(con_t==frequency_clk*1000-1)
	begin
		con_t<=0;
	end
	else begin
		con_t<=con_t+1;
	end
	
	
	if(con_t==0)
	begin
		s_pulse<=1;//每一个周期,在秒脉冲分频计数器为0时冒出一个脉冲尖
	end
	else begin
		s_pulse<=0;
	end
		
		
	if(s_pulse)
	begin
		if(s_sum==9)
		begin
			s_sum<=0;//0到9的循环计数
		end
		else begin
			s_sum<=s_sum+1;
		end
	end
end
endmodule


//testbench
module s_counter_tb;
reg clk,res;
wire[3:0] s_sum;
s_counter s_counter(
.clk(clk),
.res(res),
.s_sum(s_sum)//这种例化方式称为异名例化
);

initial begin
	clk<=0;res<=0;
	#17 res<=1;
	#1000 $stop;
end

always #5 clk<=~clk;

endmodule
