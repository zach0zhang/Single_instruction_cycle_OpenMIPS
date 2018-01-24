//ID模块
//对指令进译码
//得到并输出运算的类型、子类型、源操作数1、源操作数2、要写入目的寄存器的地址
`include "defines.v"
module id(
    input wire                  rst,
    input wire[`InstAddrBus]    pc_i,
    input wire[`InstBus]        inst_i,

    //读取得Regfile的值
    input wire[`RegBus]         reg1_data_i,
    input wire[`RegBus]         reg2_data_i,

    //输出到Regfile的信息
    output reg                     reg1_read_o,
    output reg                     reg2_read_o,
    output reg[`RegAddrBus]        reg1_addr_o,
    output reg[`RegAddrBus]        reg2_addr_o,

    //输出到执行阶段
    output reg[`AluOpBus]          aluop_o,
    output reg[`AluSelBus]         alusel_o,
    output reg[`RegBus]            reg1_o,
    output reg[`RegBus]            reg2_o,
    output reg[`RegAddrBus]        wd_o,
    output reg                     wreg_o
);
//取得的指令码功能码
wire[5:0] op = inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];

//保存指令执行需要的立即数
reg[`RegBus]   imm;

//指示指令是否有效
reg instvalid;

//对指令进行译码
always @ (*) begin
    if(rst == `RstEnable) begin
        aluop_o <=  `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o    <=  `NOPRegAddr;
        wreg_o  <=  `WriteDisable;
        instvalid   <=  `InstInvalid;
        reg1_read_o <=  1'b0;
        reg2_read_o <=  1'b0;
        reg1_addr_o <=  `NOPRegAddr;
        reg2_addr_o <=  `NOPRegAddr;
        imm         <=  32'h0;
    end else begin
        aluop_o <=  `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o    <=  inst_i[15:11];
        wreg_o  <=  `WriteDisable;
        instvalid   <=  `InstInvalid;
        reg1_read_o <=  1'b0;
        reg2_read_o <=  1'b0;
        reg1_addr_o <=  inst_i[25:21];  //默认第一个操作数寄存器为端口1读取的寄存器
        reg2_addr_o <=  inst_i[20:16];  //默认第二个操作寄存器为端口2读取的寄存器
        imm         <=  `ZeroWord;    

        case(op)
            `EXE_SPECIAL_INST:  begin //SPECIAL
              case(op2)
                5'b00000: begin
                  case(op3)
                    `EXE_OR:begin       //or
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_OR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_AND:begin      //and
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_AND_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_XOR:begin     //xor
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_XOR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_NOR:begin     //nor
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_NOR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_SLLV:begin     //sllv
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SLL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_SRLV:begin     //srlv
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_SRAV:begin     //srav
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRA_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_SYNC:begin     //sync
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_SRL_OP;
                                alusel_o <= `EXE_RES_NOP;
                                reg1_read_o <= 1'b0;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_MFHI: begin
								wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_MFHI_OP;
		  						alusel_o <= `EXE_RES_MOVE;
                                reg1_read_o <= 1'b0;
                                reg2_read_o <= 1'b0;
		  						instvalid <= `InstValid;	
								end
							`EXE_MFLO: begin
								wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_MFLO_OP;
		  						alusel_o <= `EXE_RES_MOVE;
                                reg1_read_o <= 1'b0;
                                reg2_read_o <= 1'b0;
		  						instvalid <= `InstValid;	
								end
							`EXE_MTHI: begin
								wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_MTHI_OP;
		  						reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b0; 
                                instvalid <= `InstValid;	
								end
							`EXE_MTLO: begin
							    wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_MTLO_OP;
		  					    reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b0; 
                                instvalid <= `InstValid;	
							end
							`EXE_MOVN: begin
								aluop_o <= `EXE_MOVN_OP;
		  						alusel_o <= `EXE_RES_MOVE;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
		  					    instvalid <= `InstValid;
								if(reg2_o != `ZeroWord) begin //reg2_o的值为rt通用寄存器的值
	 								wreg_o <= `WriteEnable;
	 							end else begin
	 								wreg_o <= `WriteDisable;
	 							end
							end
							`EXE_MOVZ: begin
								aluop_o <= `EXE_MOVZ_OP;
		  						alusel_o <= `EXE_RES_MOVE;   
                                reg1_read_o <= 1'b1;	
                                reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;
								if(reg2_o == `ZeroWord) begin
	 								wreg_o <= `WriteEnable;
	 							end else begin
	 								wreg_o <= `WriteDisable;
	 							end		  							
							end
							`EXE_SLT: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SLT_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
							`EXE_SLTU: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SLTU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
							`EXE_ADD: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
							`EXE_ADDU: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_ADDU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
							`EXE_SUB: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SUB_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
							`EXE_SUBU: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SUBU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
							`EXE_MULT: begin
								wreg_o <= `WriteDisable;		
								aluop_o <= `EXE_MULT_OP;
		  						reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1; 
								instvalid <= `InstValid;	
								end
							`EXE_MULTU: begin
								wreg_o <= `WriteDisable;		
								aluop_o <= `EXE_MULTU_OP;
		  						reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1; 
								instvalid <= `InstValid;	
								end
                            default: begin
                            end
                        endcase //op3
                    end
                    default: begin
                    end
                endcase //op2
            end //SPECIAL
            `EXE_ORI:   begin   //判断是ori的指令码
            //ori指令需要将结果写入目的寄存器，则输出写入信号使能
            wreg_o  <=  `WriteEnable;
            //运算的子类型是逻辑“或”运算
            aluop_o <=  `EXE_OR_OP;
            //运算类型是逻辑运算   
            alusel_o<=  `EXE_RES_LOGIC;
            //需要通过Regfile的读端口1读寄存器
            reg1_read_o <= 1'b1;
            //需要通过Regfile的读端口2读寄存器
            reg2_read_o <= 1'b0;
            //指令执行需要的立即数
            imm <=  {16'h0,inst_i[15:0]};
            //指令执行要写的目的寄存器
            wd_o <= inst_i[20:16];
            //ori指令有效
            instvalid   <=  `InstValid;
            end
            
            `EXE_ANDI:begin         //andi
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_AND_OP;
                alusel_o<=  `EXE_RES_LOGIC;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <=  {16'h0,inst_i[15:0]};
                wd_o <= inst_i[20:16];
                instvalid   <=  `InstValid;
            end
            `EXE_XORI:begin         //xori
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_XOR_OP;
                alusel_o<=  `EXE_RES_LOGIC;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <=  {16'h0,inst_i[15:0]};
                wd_o <= inst_i[20:16];
                instvalid   <=  `InstValid;
            end
            `EXE_LUI:begin          //lui
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_OR_OP;
                alusel_o<=  `EXE_RES_LOGIC;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <=  {inst_i[15:0],16'h0};
                wd_o <= inst_i[20:16];
                instvalid   <=  `InstValid;    
            end
            `EXE_PREF:begin        //pref
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_NOP_OP;
                alusel_o<=  `EXE_RES_NOP;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0;
                instvalid   <=  `InstValid;   
            end 
			`EXE_SLTI:			begin
				wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_SLT_OP;
				alusel_o <= `EXE_RES_ARITHMETIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end
			`EXE_SLTIU:			begin
				wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_SLTU_OP;
				alusel_o <= `EXE_RES_ARITHMETIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end
			`EXE_ADDI:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_ADDI_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end
			`EXE_ADDIU:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_ADDIU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;
			end
			`EXE_SPECIAL2_INST:		begin
				case ( op3 )
					`EXE_CLZ:		begin
						wreg_o <= `WriteEnable;		
						aluop_o <= `EXE_CLZ_OP;
		  				alusel_o <= `EXE_RES_ARITHMETIC; 
						reg1_read_o <= 1'b1;	
						reg2_read_o <= 1'b0;	  	
						instvalid <= `InstValid;	
					end
					`EXE_CLO:		begin
						wreg_o <= `WriteEnable;		
						aluop_o <= `EXE_CLO_OP;
		  				alusel_o <= `EXE_RES_ARITHMETIC; 
						reg1_read_o <= 1'b1;	
						reg2_read_o <= 1'b0;	  	
						instvalid <= `InstValid;	
					end
					`EXE_MUL:		begin
						wreg_o <= `WriteEnable;		
						aluop_o <= `EXE_MUL_OP;
		  				alusel_o <= `EXE_RES_MUL; 
						reg1_read_o <= 1'b1;	
						reg2_read_o <= 1'b1;	
		  				instvalid <= `InstValid;	  			
					end
					default:begin
					end
				endcase //SPECIAL2 OP3
			end//SPECIAL2
			default:begin
					end
        endcase //case op
        
if(inst_i[31:21] == 11'b00000000000) begin
            if(op3 == `EXE_SLL) begin       //sll
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_SLL_OP;
                alusel_o<=  `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <=  inst_i[10:6];
                wd_o <= inst_i[15:11];
                instvalid   <=  `InstValid; 
            end else if(op3 == `EXE_SRL)begin        //srl
                wreg_o <= `WriteEnable;
                aluop_o <=  `EXE_SRL_OP;
                alusel_o<=  `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <=  inst_i[10:6];
                wd_o <= inst_i[15:11];
                instvalid   <=  `InstValid;
            end else if (op3 == `EXE_SRA) begin //sra
                wreg_o <= `WriteEnable;
                aluop_o <=  `EXE_SRA_OP;
                alusel_o<=  `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <=  inst_i[10:6];
                wd_o <= inst_i[15:11];
                instvalid   <=  `InstValid;
            end
        end
    end //if
end //always

//确定运算源操作数1
always @ (*) begin
    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i;  //Regfile读端口1的输出值
    end else if(reg1_read_o == 1'b0) begin
        reg1_o <= imm;          //立即数
    end else begin
        reg1_o <= `ZeroWord;
    end
end

//确定运算源操作数2
always @ (*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i;  //Regfile读端口1的输出值
    end else if(reg2_read_o == 1'b0) begin
        reg2_o <= imm;          //立即数
    end else begin
        reg2_o <= `ZeroWord;
    end
end

endmodule