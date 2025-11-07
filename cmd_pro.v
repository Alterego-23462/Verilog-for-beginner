//2025.11.7
//串口指令处理器
module cmd_pro(
clk,
res,
din_pro,
en_din_pro,
dout_pro,
en_dout_pro,
rdy
);

input clk,res;
input[7:0] din_pro;//指令和数据
input en_din_pro;//输入使能
output[7:0] dout_pro;//指令执行结果
output en_dout_pro;//指令输出使能
input rdy;//串口发送空闲标志，0表示空闲

reg[3:0] state;//主状态机寄存器
reg[7:0] cmd_reg,A_reg,B_reg;//存放 指令、A、B

parameter add_ab=8'h0a;//将状态3中的数字用参数代替，这样以后修改时在这里修改即可.
parameter sub_ab=8'h0b;
parameter and_ab=8'h0c;
parameter or_ab=8'h0d;

reg[7:0] dout_pro;
reg en_dout_pro;

always@(posedge clk or  negedge res)
if(~res)begin
	state<=0;cmd_reg<=0;A_reg<=0;B_reg<=0;
	dout_pro<=0;en_dout_pro<=0;
end
else begin
	case(state)
	0://等指令
	begin
		en_dout_pro<=0;
		if(en_din_pro)begin
			cmd_reg<=din_pro;
			state<=1;
		end
	end
	
	1://收A
	begin
		if(en_din_pro)begin
			A_reg<=din_pro;
			state<=2;
		end
	end
	
	2://收B
	begin
		if(en_din_pro)begin
			B_reg<=din_pro;
			state<=3;
		end
	end
	
	3://指令译码和执行
	begin
	state<=4;//此处状态译码一个时钟周期即可完成，所以跳到4不需要别的条件
		case(cmd_reg)
		add_ab:begin dout_pro=A_reg+B_reg;end
		sub_ab:begin dout_pro=A_reg-B_reg;end		
		and_ab:begin dout_pro=A_reg&B_reg;end
		or_ab:begin  dout_pro=A_reg|B_reg;end
		endcase
	end
	
	4://发送指令执行结果
	begin
	 if(~rdy)begin
		en_dout_pro<=1;//为空闲时让输出使能为1（有效）
		state<=0;
	 end
	end
	
	default:
	begin
		en_dout_pro<=0;
		state<=0;
	end
	
	endcase
end
endmodule