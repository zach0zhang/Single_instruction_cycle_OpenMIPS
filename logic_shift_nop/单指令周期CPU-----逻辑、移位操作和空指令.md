之前实现了单指令周期的ori，已经实现了Verilog HDL语言设计的CPU系统框架和数据流，接下来的逻辑、移位操作和空指令，只是在实现的流程上增添指令

## 指令介绍
### 1. 逻辑操作
#### 1.1 and、or、xor、nor
**and、or、xor、nor的指令格式：**
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/logic_shift_nop/md_images/and_or_xor_nor.png)
这4条指令，指令码都是6'b000000，第6~10bit都为0，需要功能码(0\~5bit)的值进一步判断是哪一种指令

1. and指令，功能码是6'b100100，逻辑“与”运算。
    
    指令用法：and rd, rs,rt (rd <- rs AND rt)
2. or指令，功能码是6'b100101，逻辑“或”运算。

    指令用法：or rd, rs,rt (rd <- rs OR rt)
3. xor指令，功能码是6'b100110，异或运算。

    指令用法：xor rd, rs,rt (rd <- rs XOR rt)
4. nor指令，功能码是6'b100111，或非运算。

    指令用法：nor rd, rs,rt (rd <- rs NOR rt)
#### 1.2 andi xori
**andi、xori的指令格式：**
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/logic_shift_nop/md_images/andi_xori.png)
这两条指令，通过指令码(26~31bit)判断是哪一种指令
1. andi指令，指令码是6'b001100,逻辑“与”运算。
    
    指令用法：andi rt, rs,imm ( rt <- rs AND zero_extended(imm) )
2. xori指令，指令码是6'b01110,逻辑“异或”运算

    指令用法：xori rt, rs,imm ( rt <- rs XORI zero_extended(imm) )
#### 1.3 lui
**lui的指令格式：**
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/logic_shift_nop/md_images/lui.png)
通过指令码(26~31bit)是6b001111判断

指令用法：lui rt,imm ( rt <- imm || 0^16 , 即将指令中的16bit立即数保存到地址为rt的通用寄存器的高16位，低16位用0填充) 

### 2. 移位操作
**sll、sllv、sra、srav、srl、srlv的指令格式：**
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/logic_shift_nop/md_images/sll_srl_sra_sllv_srlv_srav.png)
这6条指令指令码(26~31bit)都是6'b000000，需要根据指令的功能码(0\~5bit)进一步判断是哪一条指令
1.  sll指令，功能码是6'b000000,逻辑左移

    指令用法：sll rd,rt,sa ( rd <- rt << sa(logic) rt的值向左移位sa位，空出来的位置用0填充，结果保存到地址为rd的通用寄存器中)
2. srl指令，功能码是6'b000010,逻辑右移

    指令用法：srl rd,rt,sa ( rd <- rt >> sa(logic) rt的值向右移位sa位，空出来的位置用0填充，结果保存到地址为rd的通用寄存器中)
3. sra指令，功能码是6'b000011,算术右移

    指令用法：sra rd,rt,sa ( rd <- rt >> sa(arithmetic) rt的值向右移位sa位，空出来的位置用rt[31]的值填充，结果保存到地址为rd的通用寄存器中)
4. sllv指令，功能码是6'b000100，逻辑左移

    指令用法：sllv rd,rt,rs ( rd <- rt << rs\[4:0](logic) rt的值向左移位rs[4:0]位，空出来的位置用0填充，结果保存到地址为rd的通用寄存器中)
5. srlv指令，功能码是6'b000110，逻辑右移

    指令用法：srlv rd,rt,rs ( rd <- rt >> rs\[4:0](logic) rt的值向右移位rs[4:0]位，空出来的位置用0填充，结果保存到地址为rd的通用寄存器中)
6. srav指令，功能码是6'b000111,算术右移

    指令用法：srav rd,rt,rs ( rd <- rt >> rs\[4:0](arithmetic) rt的值向右移位rs[4:0]位，空出来的位置用rt[31]填充，结果保存到地址为rd的通用寄存器中)
### 3. 空指令
**nop、ssnop、sync和pref的指令格式：**
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/logic_shift_nop/md_images/nop_ssnop_sync_pref.png)

## 实现逻辑、移位操作和空指令
### 1. 修改译码阶段的ID模块
根据8条逻辑操作指令、6条位操作、4条空指令的指令格式，判断相应的指令码和功能码来确定是什么指令，并执行每一个指令的译码操作

**确定指令种类的过程：**
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/logic_shift_nop/md_images/select.png)
**id.v:**

```
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

```
### 2. 修改执行阶段EX模块
在之前的基础上扩展了逻辑运算的过程，增加了移位运算的过程

```
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

    //运算完毕后的结果
    output reg[`RegAddrBus]         wd_o,
    output reg                      wreg_o,
    output reg[`RegBus]             wdata_o
);

//保存逻辑运算的结果 
reg[`RegBus] logicout;
reg[`RegBus] shiftres;

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

//根据alusel_i指示的运算类型，选择一个运算结果作为最终结果
always @ (*) begin
    wd_o <= wd_i;       //要写的目的寄存器地址
    wreg_o <= wreg_i;
    case(alusel_i)
        `EXE_RES_LOGIC:begin
            wdata_o <= logicout;
        end
        `EXE_RES_SHIFT:begin
            wdata_o <= shiftres;
        end
        default:begin
            wdata_o<=`ZeroWord;
        end
    endcase
end

endmodule


```

## 仿真验证
执行程序：

```
.org 0x0
	.global _start
   .set noat
_start:
   lui  $1,0x0101			# $1 = 0x01010000
   ori  $1,$1,0x0101		# $1 = $1 | 0x0101 = 0x01010101
   ori  $2,$1,0x1100        # $2 = $1 | 0x1100 = 0x01011101
   or   $1,$1,$2            # $1 = $1 | $2 = 0x01011101
   andi $3,$1,0x00fe        # $3 = $1 & 0x00fe = 0x00000000
   and  $1,$3,$1            # $1 = $3 & $1 = 0x00000000
   xori $4,$1,0xff00        # $4 = $1 ^ 0xff00 = 0x0000ff00
   xor  $1,$4,$1            # $1 = $4 ^ $1 = 0x0000ff00
   nor  $1,$4,$1            # $1 = $4 ~^ $1 = 0xffff00ff   nor is "not or"
   lui   $2,0x0404			# $2 = 0x04040000
   ori   $2,$2,0x0404		# $2 = $2 | 0x0404 = 0x04040404
   ori   $7,$0,0x7			# $7 = $0 | 0x7 = 0x00000007
   ori   $5,$0,0x5			# $5 = $0 | 0x5 = 0x00000005
   ori   $8,$0,0x8			# $8 = $0 | 0x8 = 0x00000008
   sync
   sll   $2,$2,8    # $2 = 0x40404040 sll 8  = 0x04040400
   sllv  $2,$2,$7   # $2 = 0x04040400 sll 7  = 0x02020000
   srl   $2,$2,8    # $2 = 0x02020000 srl 8  = 0x00020200
   srlv  $2,$2,$5   # $2 = 0x00020200 srl 5  = 0x00001010
   nop
   sll   $2,$2,19   # $2 = 0x00001010 sll 19 = 0x80800000
   ssnop
   sra   $2,$2,16   # $2 = 0x80800000 sra 16 = 0xffff8080
   srav  $2,$2,$8   # $2 = 0xffff8080 sra 8  = 0xffffff80 
```
使用GNU工具链针对MIPS平台的工具最终编译、连接成为bin文件，之后用ModelSim仿真得到：

![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/logic_shift_nop/md_images/sumulate.png)
