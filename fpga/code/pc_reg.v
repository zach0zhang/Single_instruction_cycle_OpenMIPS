`include "defines.v"
module pc_reg(
	input wire					clk,
	input wire					rst,
	
	//来自译码阶段ID模块的信息
	input wire					branch_flag_i, //是否发生转移
	input wire[`RegBus] 		branch_target_address_i,//转移到的目标地址
	
	output reg[`InstAddrBus]    pc,
	output reg					ce
);


always @(posedge clk)begin
	if(rst==`RstEnable) begin
		ce<=`ChipDisable;		//复位时指令存储器禁用
	end
	else begin
		ce<=`ChipEnable;		//复位结束使能指令存储器
	end
end

always @(posedge clk)begin
	if(ce==`ChipDisable)begin
		pc<=32'h00000000;		//指令存储器禁用时，pc为0
	end
	else if(branch_flag_i == `Branch)begin
		pc <= branch_target_address_i;
	end
	else begin
		pc<=pc+4'h4;			//指令存储器使能时，pc=pc+4
	end
end

endmodule