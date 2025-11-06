//4级伪随机码发生器
`timescale 1ns/10ps
module m_gen(clk,res,y);//时序逻辑电路都有clk和res信号
	input clk;//也可以input clk,res;
	input res;
	output y;
	reg[3:0] d;//定义4位寄存器
	assign y=d[0];
	always@(posedge clk or negedge res)
		if(~res) 
			d<=4'b1111;//复位不能复位成全0,否则电路不会动了
		else
			begin
			d[2:0] <= d[3:1];//整体右移1位，不建议直接用移位符>>
			d[3] <= d[3]+d[0];//模2加，指的是这两个加起来，溢出的高位会自动舍去
			end//这里有两句了，必须等加begin end了
endmodule

module m_gen_tb;
	reg clk,res;
	wire y;
	m_gen m_gen(.clk(clk),.res(res),.y(y));
	initial
		begin
			clk<=0;res<=0;//res为0时有效，置位
			#17 res<=1;//延迟17单位时间后穷启动
			#600 $stop;
		end
		
	always #5 clk<=~clk;
endmodule

