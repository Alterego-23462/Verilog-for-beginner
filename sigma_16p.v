`timescale 1ns/10ps
module sigma_16p(
clk,
res,
data_in,//input signal
syn_in,//sampling时钟
data_out,
syn_out
);

input clk;
input res;
input[7:0] data_in;//输入的采样信号
input syn_in;//采样时钟
output[11:0] data_out;//累加结果输出
output syn_out;//累加结果同步脉冲

reg syn_in_n1;//syn的反向延时
wire syn_pulse;//采样时钟 上升沿 识别脉冲,即采样脉冲尖
assign syn_pulse=syn_in_n1&syn_in;
reg[3:0] con_syn;//采样时钟循环计数器

wire[7:0] comp_8;
wire[11:0] d_12;//升位结果，一个循环16个，16个8位二进制相加，最多到12位二进制，因为16是2的4次方
assign comp_8=data_in[7]?{data_in[7],~data_in[6:0]+1}:data_in;
assign d_12={comp_8[7],comp_8[7],comp_8[7],comp_8[7],comp_8};//升位：扩展符号位
reg[11:0]  sigma;//累加运算
reg[11:0]  data_out;
reg        syn_out;

//定义了触发器，则需要复位
always@(posedge clk or negedge res)
if(~res) begin
	syn_in_n1<=0;
	con_syn<=0;
	sigma<=0;
	data_out<=0;
	syn_out<=0;
end
else begin
	syn_in_n1<=~syn_in;
	if(syn_pulse)begin
		con_syn<=con_syn+1;
	end
//	if(con_syn==15)begin
//		con_syn<=0;
//	end     
//因为con_syn是4位二进制，到1111时会自动进位以至于从0000重新开始计数，
//而我们循环设的为16，所以不用手动复位了
	if(syn_pulse)begin
		if(con_syn==15)begin
			sigma<=d_12;//下一轮循环中sigma的初值
			data_out<=sigma;//非阻塞赋值，这几句都是并行的，所以可以这样写
			syn_out<=1;
		end
		else begin
			sigma<=sigma+d_12;
		end
	end
	else begin
		syn_out<=0;//为1的值 只维持一个  脉冲尖为1时 的宽度
	end
end
endmodule

//testbench
module sigma_16p_tb;
reg clk;
reg res;
reg[7:0] data_in;
reg syn_in;
wire[11:0] data_out;
wire syn_out;

sigma_16p sigma_16p(
.clk(clk),
.res(res),
.data_in(data_in),//input signal
.syn_in(syn_in),//sampling时钟
.data_out(data_out),
.syn_out(syn_out)
);

initial begin
	clk<=0;res<=0;data_in<=1;syn_in<=0;
	#17 res<=17;
	#25000 $stop;
end

always #5 clk=~clk;//系统时钟

always #100 syn_in=~syn_in;//采样时钟

endmodule
