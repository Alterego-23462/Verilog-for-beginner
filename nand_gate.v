//2025.10.17
//liuyu
`timescale 1ns/10ps

module nand_gate(A,B,Y);
input A;
input B;
output Y;
assign Y=~(A&B);
endmodule


//testbench

module nand_gate_tb;
reg aa,bb;
wire yy;
nand_gate nand_gate(.A(aa),.B(bb),.Y(yy));
initial 
	begin
	aa<=0;bb<=0;//reg型一般用非阻塞赋值，虽然书上说input一般用的是wire型而不是reg型
	//两个赋值之间要用;隔开
	#10 aa<=0;bb<=1;
	#10 aa<=1;bb<=0;
	#10 aa<=1;bb<=1;
	#10 $stop;
	end
endmodule
