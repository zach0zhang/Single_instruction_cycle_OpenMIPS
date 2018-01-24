//EX模块
//根据译码模块传来的数据进行运算

`include "defines.v"
module ex(

    input wire          rst,

    //译码模块传来的信息
    input wire[`AluOpBus]           aluop_i,
    input wire[`AluSelBus]          alusel_i,
    input wire[`RegBus]             reg1_i,
    input wire[`RegBus]             reg2_i,
    input wire[`RegAddrBus]         wd_i,
    input wire                      wreg_i,

	//HI、LO寄存器的值
	input wire[`RegBus]           hi_i,
	input wire[`RegBus]           lo_i,

    //运算完毕后的结果
    output reg[`RegAddrBus]         wd_o,
    output reg                      wreg_o,
    output reg[`RegBus]             wdata_o,

    //运算完毕后
    output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	output reg                    whilo_o	
);


reg[`RegBus] logicout;		//保存逻辑运算的结果 
reg[`RegBus] shiftres;		//保存移位操作运算的结果 
reg[`RegBus] moveres;		//保存移动操作运算的结果 
reg[`RegBus] arithmeticres; //保存算术运算结果
reg[`RegBus] HI;
reg[`RegBus] LO;

wire ov_sum;				//保存溢出情况
wire reg1_eq_reg2;			//第一个操作数是否等于第二个操作数
wire reg1_lt_reg2;			//第一个操作数是否小于第二个操作数
wire[`RegBus] reg2_i_mux;	//保存输入的第二个操作reg2_i的补码
wire[`RegBus] reg1_i_not;	//保存输入的第一个操作数reg1_i取反后的值
wire[`RegBus] result_sum;	//保存加法结果
wire[`RegBus] opdata1_mult;	//乘法操作中的被乘数
wire[`RegBus] opdata2_mult;	//乘法操作中的乘数
wire[`DoubleRegBus] hilo_temp;	//临时保存乘法结果，宽度为64位
reg[`DoubleRegBus] mulres;		//保存乘法结果，宽度为64位
//根据aluop_i指示的运算子类型进行运算

//LOGIC
always @ (*) begin
    if(rst == `RstEnable) begin
        logicout <= `ZeroWord;
    end else begin
        case(aluop_i)
            `EXE_OR_OP:begin    //进行“或"运算
                logicout <= reg1_i | reg2_i;
            end
            
`EXE_AND_OP:begin //and
                logicout <= reg1_i & reg2_i;
            end
            `EXE_NOR_OP:begin //nor
                logicout <= ~(reg1_i | reg2_i);
            end
            `EXE_XOR_OP:begin //xor
                logicout <= reg1_i ^ reg2_i;
            end
            default:begin
                logicout<=`ZeroWord;
            end
        endcase
    end //if
end //always


//SHIFT
always @ (*) begin
    if(rst == `RstEnable)begin
        shiftres <= `ZeroWord;
    end else begin
        case(aluop_i)
            `EXE_SLL_OP:begin
                shiftres <= reg2_i << reg1_i[4:0];
            end
            `EXE_SRL_OP:begin
                shiftres <= reg2_i >> reg1_i[4:0];
            end
            `EXE_SRA_OP:begin
                shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0,reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
            end
            default: begin
                shiftres <= `ZeroWord;
            end
        endcase
    end //IF
end //always
//第二个操作数
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) || (aluop_i == `EXE_SLT_OP)) ? (~reg2_i)+1 : reg2_i;
//运算结果
assign result_sum = reg1_i + reg2_i_mux;
//是否溢出
assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) || ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
//操作数1是否小于操作数2
assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ? ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31]) || (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);
//对操作数1取反
assign reg1_i_not = ~reg1_i;

always @ (*) begin
	if(rst == `RstEnable)begin
		arithmeticres <= `ZeroWord;
	end else begin
		case(aluop_i)
			`EXE_SLT_OP,`EXE_SLTU_OP:begin //比较运算
				arithmeticres <= reg1_lt_reg2;
			end
			`EXE_ADD_OP,`EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP:begin //加法运算
				arithmeticres <= result_sum; 
			end
			`EXE_SUB_OP,`EXE_SUBU_OP:begin //减法运算
				arithmeticres <= result_sum;
			end
			`EXE_CLZ_OP:begin //计数运算clz
				arithmeticres <= reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
			end
			`EXE_CLO_OP:begin //计数运算clo
				arithmeticres <= (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
													 reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
													 reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
													 reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
													 reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
													 reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
													 reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
													 reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
													 reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
													 reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
													 reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32) ;
			end
			default:begin
					arithmeticres <= `ZeroWord;
			end
		endcase
	end
end

//被乘数
assign opdata1_mult=(((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
//乘数
assign opdata2_mult=(((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) && (reg2_i[31] ==1'b1)) ? (~reg2_i+1) : reg2_i;
//临时乘法结果
assign hilo_temp = opdata1_mult*opdata2_mult;
//对乘法结果修正(A*B）补=A补 * B补
always @ (*) begin
	if(rst == `RstEnable) begin
		mulres <= {`ZeroWord,`ZeroWord};
	end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP))begin
		if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin
			mulres <= ~hilo_temp + 1;
		end else begin
			mulres <= hilo_temp;
		end
	end else begin
		mulres <= hilo_temp;
	end
end

 //得到最新的HI、LO寄存器的值，此处要解决指令数据相关问题
always @ (*) begin
	if(rst == `RstEnable) begin
		{HI,LO} <= {`ZeroWord,`ZeroWord};
	end else begin
		{HI,LO} <= {hi_i,lo_i};			
	end
end	

//MFHI、MFLO、MOVN、MOVZ指令
always @ (*) begin
	if(rst == `RstEnable) begin
	  	moveres <= `ZeroWord;
	end else begin
	   moveres <= `ZeroWord;
	   case (aluop_i)
	   	`EXE_MFHI_OP:		begin
	   		moveres <= HI;
	   	end
	   	`EXE_MFLO_OP:		begin
	   		moveres <= LO;
	   	end
	   	`EXE_MOVZ_OP:		begin
	   		moveres <= reg1_i;
	   	end
	   	`EXE_MOVN_OP:		begin
	   		moveres <= reg1_i;
	   	end
	   	default : begin
	    end
	   endcase
	end
end	 
		

//根据alusel_i指示的运算类型，选择一个运算结果作为最终结果
always @ (*) begin
    wd_o <= wd_i;       //要写的目的寄存器地址
	//如果是add、addi、sub、subi、指令，且发生溢出，那么设置wreg_o为WriteDisable，即不写寄存器
	if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
		wreg_o <= `WriteDisable;
	end else begin
		wreg_o <= wreg_i;
	end
    case(alusel_i)
        `EXE_RES_LOGIC:begin	//逻辑运算
            wdata_o <= logicout;
        end
        `EXE_RES_SHIFT:begin	//移位运算
            wdata_o <= shiftres;
        end
        `EXE_RES_MOVE:		begin	//移动运算
	 		wdata_o <= moveres;
	 	end	
		`EXE_RES_ARITHMETIC:begin //除乘法外简单算术操作指令
			wdata_o <= arithmeticres;
		end
		`EXE_RES_MUL:begin		//乘法指令mul
			wdata_o <= mulres[31:0];
		end
        default:begin
            wdata_o<=`ZeroWord;
        end
    endcase
end
//MTHI和MTLO指令 乘法运算结果保存
always @ (*) begin
	if(rst == `RstEnable) begin
		whilo_o <= `WriteDisable;
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;		
	end else if((aluop_i == `EXE_MULT_OP) || (aluop_i ==`EXE_MULTU_OP))begin //mult、multu指令
		whilo_o <= `WriteEnable;
		hi_o <= mulres[63:32];
		lo_o <= mulres[31:0];
	end else if(aluop_i == `EXE_MTHI_OP) begin
		whilo_o <= `WriteEnable;
		hi_o <= reg1_i;
		lo_o <= LO;
	end else if(aluop_i == `EXE_MTLO_OP) begin
		whilo_o <= `WriteEnable;
		hi_o <= HI;
		lo_o <= reg1_i;
	end else begin
		whilo_o <= `WriteDisable;
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
	end				
end	
endmodule
