## 指令介绍
MIPS32指令集架构定义的所有算术操作指令，共有21条
共有三类，分别是：
- 简单算术指令
- 乘累加、乘累减指令
- 除法指令
### 简单算术操作指令介绍
一共有15条指令分别是：add、addi、addiu、addu、sub、subu、clo、clz、slt、slti、sltiu、sltu、mul、mult、multu
#### 1. add、addu、sub、subu、slt、sltu指令
add、addu、sub、subu、slt、sltu指令格式为：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/simple_arithmetic_1/md_images/add_sub_slt.png)
由指令格式可以看出这六条指令指令码都是6'b000000即SPECIAL类，而且指令的第6\~10bit都是0，根据指令的功能码(0\~5bit)来判断是那一条指令
- **ADD(功能码是6'b100000)**:加法运算，用法：add rd,rs,rt；作用：rd <- rs+rt，将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行加法运算，结果保存到地址为rd的通用寄存器中。**如果加法运算溢出，那么会产生溢出异常，同时不保存结果。**
- **ADDU(功能码是6'b100001)**:加法运算，用法：addu rd,rs,rt; 作用：rd <-rs+rd,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行加法运算，结果保存到rd的通用寄存器中。**不进行溢出检查，总是将结果保存到目的寄存器。**
- **SUB(功能码是6'b100010)**:减法运算，用法：sub rd,rs,rt; 作用：rd <- rs-rt,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行减法运算，结果保存到地址为rd的通用寄存器中。**如果减法运算溢出，那么产生溢出异常，同时不保存结果。**
- **SUBU(功能码是6'b100011)**:减法运算，用法：subu rd,rs,rt; 作用：rd <- rs-rt将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行减法运算，结果保存到地址为rd的通用寄存器中。**不进行溢出检查，总是将结果保存到目的寄存器。**
- **SLT(功能码是6'b101010)**:比较运算，用法：slt rd,rs,rt; 作用：rd <- (rs<rt)将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值按照**有符号数**进行比较，**若前者小于后者，那么将1保存到地址为rd的通用寄存器，若前者大于后者，则将0保存到地址为rd的通用寄存器中**
- **SLTU(功能码是6'b101011)**:比较运算，用法：sltu rd,rs,rt; 作用：rd <- (rs<rt)将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值按照**无符号数**进行比较，**若前者小于后者，那么将1保存到地址为rd的通用寄存器，若前者大于后者，则将0保存到地址为rd的通用寄存器中**

#### 2. addi、addiu、slti、sltiu指令
addi、addiu、slti、sltiu指令格式为：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/simple_arithmetic_1/md_images/addi_slti.png)
由指令格式可以看出，依据指令码(26\~31bit)判断是哪一种指令
- **ADDI(指令码是6'b001000)**:加法运算，用法：addi rt,rs,immediate; 作用：rt <- rs+(sign_extended)immediate,将指令中16位立即数进行符号扩展，与地址为rs的通用寄存器进行加法运算，结果保存到地址为rt的通用寄存器。**如果加法运算溢出，则产生溢出异常，同时不保存结果。**
- **ADDIU(指令码是6'b001001)**:加法运算，用法：addiu rt,rs,immediate; 作用：rt <- rs+(sign_extended)immediate,将指令中16位立即数进行符号扩展，与地址为rs的通用寄存器进行加法运算，结果保存到地址为rt的通用寄存器。**不进行溢出检查，总是将结果保存到目的寄存器。**
- **SLTI(功能码是6'b001010)**:比较运算，用法：slti rt,rs,immediate; 作用：rt <- (rs<(sign_extended)immediate)将指令中的16位立即数进行符号扩展，与地址为rs的通用寄存器的值按照**有符号数**进行比较，**若前者小于后者，那么将1保存到地址为rt的通用寄存器，若前者大于后者，则将0保存到地址为rt的通用寄存器中**
- **SLTIU(功能码是6'b001011)**:比较运算，用法：sltiu rt,rs,immediate; 作用：rt <- (rs<(sign_extended)immediate)将指令中的16位立即数进行符号扩展，与地址为rs的通用寄存器的值按照**无符号数**进行比较，**若前者小于后者，那么将1保存到地址为rt的通用寄存器，若前者大于后者，则将0保存到地址为rt的通用寄存器中**

#### 3. clo、clz指令
clo、clz的指令格式：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/simple_arithmetic_1/md_images/clo_clz.png)
由指令格式可以看出，这两条指令的指令码(26\~31bit)都是6'b011100,即是SPECIAL2类；而且第6\~10bit都为0，根据指令中的功能码(0\~5bit)判断是哪一条指令
- **CLZ(功能码是6'b100000)**:计数运算，用法：clz rd,rs; 作用：rd <- coun_leading_zeros rs,对地址为rs的通用寄存器的值，从最高位开始向最低位方向检查，**直到遇到值为“1”的位，将该为之前“0”的个数保存到地址为rd的通用寄存器中**，如果地址为rs的通用寄存器的所有位都为0(即0x00000000),那么将32保存到地址为rd的通用寄存器中
- **CLO(功能码是6'b100001)**:计数运算，用法：clo,rd,rs; 作用：rd <- coun_leading_zeros rs对地址为rs的通用寄存器的值，从最高位开始向最低位方向检查，**直到遇到值为“0”的位，将该为之前“1”的个数保存到地址为rd的通用寄存器中**，如果地址为rs的通用寄存器的所有位都为1(即0xFFFFFFFF),那么将32保存到地址为rd的通用寄存器中

#### 4. multu、mult、mul指令
multu、mult、mul的指令格式：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/simple_arithmetic_1/md_images/mul.png)
由指令格式可以看出，mul指令的指令码(26\~31bit)都是6'b011100,即是SPECIAL2类，mult和multu这两条指令的指令码(26\~31bit)都是6'b000000,即是SPECIAL类；有着不同的功能码(0\~5bit)
- **mul(指令码是SPECIAL2,功能码是6'b000010)**:乘法运算，用法：mul,rd,rs,st; 作用：rd <- rs * rt,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值作为有符号数相乘，乘法结果低32bit保存到地址为rd的通用寄存器中
- **mult(指令码是SPECIAL,功能码是6'b011000)**:乘法运算，用法：mult,rs,st; 作用：{hi,lo} <- rs * rt,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值作为**有符号数**相乘，**乘法结果低32bit保存到LO寄存器中，高32bit保存到HI寄存器中**
- multu(指令码是SPECIAL,功能码是6'b011001):乘法运算，用法：mult,rs,st; 作用：{hi,lo} <- rs * rt,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值作为**无符号数**相乘，**乘法结果低32bit保存到LO寄存器中，高32bit保存到HI寄存器中**
## 添加相关宏定义

```
`define EXE_SLT  6'b101010		//指令SLT的功能码
`define EXE_SLTU  6'b101011		//指令SLTU的功能码
`define EXE_SLTI  6'b001010		//指令SLTI的指令码
`define EXE_SLTIU  6'b001011   	//指令SLTIU的指令码
`define EXE_ADD  6'b100000		//指令ADD的功能码
`define EXE_ADDU  6'b100001		//指令ADDU的功能码
`define EXE_SUB  6'b100010		//指令SUB的功能码
`define EXE_SUBU  6'b100011		//指令SUBU的功能码
`define EXE_ADDI  6'b001000		//指令ADDI的指令码
`define EXE_ADDIU  6'b001001	//指令ADDIU的指令码
`define EXE_CLZ  6'b100000		//指令CLZ的功能码
`define EXE_CLO  6'b100001		//指令CLO的功能码
`define EXE_MULT  6'b011000		//指令MULT的功能码
`define EXE_MULTU  6'b011001	//指令MULTU的功能码
`define EXE_MUL  6'b000010		//指令MUL的功能码

`define EXE_SPECIAL2_INST 6'b011100 //special2类的指令码
//AluOp
`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_SLTI_OP  8'b01010111
`define EXE_SLTIU_OP  8'b01011000   
`define EXE_ADD_OP  8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP  8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP  8'b01010110
`define EXE_CLZ_OP  8'b10110000
`define EXE_CLO_OP  8'b10110001

`define EXE_MULT_OP  8'b00011000
`define EXE_MULTU_OP  8'b00011001
`define EXE_MUL_OP  8'b10101001
//AluSel
`define EXE_RES_ARITHMETIC 3'b100
`define EXE_RES_MUL 3'b101
```

## 修改译码阶段ID模块
根据指令的指令码，和功能码确定是哪一条指令，再由具体的指令给出译码结果
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/simple_arithmetic_1/md_images/select.png)

```
case(op)
    `EXE_SPECIAL_INST:  begin //SPECIAL
        case(op2)
            5'b00000: begin
                case(op3)
                ...
                `EXE_SLT: begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_SLT_OP;
                    alusel_o <=`EXE_RES_ARITHMETIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;
                end
                `EXE_SLTU: begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_SLTU_OP;
                    alusel_o <=`EXE_RES_ARITHMETIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;
                end
                `EXE_ADD: begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_ADD_OP;
                    alusel_o <=`EXE_RES_ARITHMETIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;
                end
                `EXE_ADDU: begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_ADDU_OP;
                    alusel_o <=`EXE_RES_ARITHMETIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;
                end
                `EXE_SUB: begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_SUB_OP;
                    alusel_o <=`EXE_RES_ARITHMETIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;
                end
                `EXE_SUBU: begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_SUBU_OP;
                    alusel_o <=`EXE_RES_ARITHMETIC;
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
    `EXE_SLTI:			begin
		wreg_o <= `WriteEnable;		
		aluop_o <= `EXE_SLT_OP;
		alusel_o <= `EXE_RES_ARITHMETIC; 
		reg1_read_o <= 1'b1;	
		reg2_read_o <= 1'b0;	  	
		imm <= {{16{inst_i[15]}}, inst_i[15:0]};	wd_o <= inst_i[20:16];		  	
		instvalid <= `InstValid;	
		end
	`EXE_SLTIU:			begin
		wreg_o <= `WriteEnable;		
		aluop_o <= `EXE_SLTU_OP;
		alusel_o <= `EXE_RES_ARITHMETIC; 
		reg1_read_o <= 1'b1;	
		reg2_read_o <= 1'b0;	  	
		imm <= {{16{inst_i[15]}}, inst_i[15:0]};	wd_o <= inst_i[20:16];		  	
		instvalid <= `InstValid;	
	end
	`EXE_ADDI:			begin
		wreg_o <= `WriteEnable;		
		aluop_o <= `EXE_ADDI_OP;
		alusel_o <= `EXE_RES_ARITHMETIC; 
		reg1_read_o <= 1'b1;	
		reg2_read_o <= 1'b0;	  	
		imm <= {{16{inst_i[15]}}, inst_i[15:0]};	wd_o <= inst_i[20:16];		  	
		instvalid <= `InstValid;	
		end
	`EXE_ADDIU:			begin
		wreg_o <= `WriteEnable;		
		aluop_o <= `EXE_ADDIU_OP;
		alusel_o <= `EXE_RES_ARITHMETIC; 
		reg1_read_o <= 1'b1;	
		reg2_read_o <= 1'b0;	  	
		imm <= {{16{inst_i[15]}}, inst_i[15:0]};	wd_o <= inst_i[20:16];		  	
		instvalid <= `InstValid;
		end
		`EXE_SPECIAL2_INST:		begin
			case ( op3 )
				`EXE_CLZ:		begin
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_CLZ_OP;
		  			alusel_o <=`EXE_RES_ARITHMETIC;
		  			reg1_read_o <= 1'b1;	
					reg2_read_o <= 1'b0;	  	
					instvalid <= `InstValid;	
					end
				`EXE_CLO:		begin
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_CLO_OP;
		  			alusel_o <=`EXE_RES_ARITHMETIC;
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
		  		...
```
这些简单算术操作指令的指令操作类型都是EXE_RES_ARITHMETIC
- add、addu、sub、subu、slt、sltu：需要两个寄存器的值分别作为两个操作数，所以设置reg1_read_o和reg2_read_o都为1，运算完后结果需要写入目的寄存器，所以设置wreg_o为WriteEnable，写入目的寄存器地址wd_o是指令中16\~20bit的值
- addi、addiu、subi、subiu：只需要读取一个寄存器的值作为第一个操作数，即设置reg1_read_o为1，reg2_read_o为0，第二个操作数为立即数进行符号扩展后的值，运算完后结果需要写入目的寄存器，所以设置wreg_o为WriteEnable,写入目的寄存器地址wd_o是指令中16\~20bit的值
- mult、multu:需要两个寄存器的值分别作为两个操作数，所以设置reg1_read_o和reg2_read_o都为1,运算完后结果需要不需要写入通用寄存器，而是写入HI、LO寄存器所以设置wreg_o为WriteDisable
- mul：需要两个寄存器的值分别作为两个操作数，所以设置reg1_read_o和reg2_read_o都为1，aluop_o为EXE_MUL_OP运算完后结果需要写入目的寄存器，所以设置wreg_o为WriteEnable，写入目的寄存器地址wd_o是指令中11\~15bit的值
- clo、clz：只需要读取一个寄存器的值作为第一个操作数，即设置reg1_read_o为1，reg2_read_o为0，运算完后结果需要写入目的寄存器，所以设置wreg_o为WriteEnable，写入目的寄存器地址wd_o是指令中11\~15bit的值
## 修改执行阶段EX模块
根据译码阶段的结果，来进行相关的执行操作
### 1. 添加一些新的变量

```
reg[`RegBus] arithmeticres; //保存算术运算结果
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
```
### 2. 计算五个变量的值
#### 2.1 reg2_i_mux
如果是减法或者有符号比较运算，那么reg2_i_mux等于第二个操作数reg2_i的补码，否则reg2_i_mux等于第二个操作数reg2_i

```
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||
                    (aluop_i == `EXE_SLT_OP)) ? (~reg2_i)+1 : reg2_i;

```

#### 2.2 result_sum
- 如果是加法运算，此时reg2_i_mux就是第二个操作数reg2_i,所以result_sum就是加法运算的结果
- 如果是减法运算，此时reg2_i_mux是第二个操作数reg2_i的补码，所以result_sum就是减法运算的结果
- 如果是有符号比较运算，此时reg2_i_mux也是第二个操作数reg2_i的补码，所以result_sum也是减法运算的结果，可以通过判断减法结果是否小于零，进而判断第一个操作数reg1_i是否小于第二个操作数reg2_i

```
assign result_sum = reg1_i + reg2_i_mux;
```
#### 2.3 ov_sum
计算是否溢出，加法指令(add和addi)、减法指令(sub)执行的时候，需要判断是否溢出，满足一下两种情况时，有溢出：
- reg1_i为正数，reg2_i_mux为正数，但是两者之和为负数
- reg1_i为负数，reg2_i_mux为负数，但是两者之和为正数

```
assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
                ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
```
#### 2.4 reg1_lt_reg2
计算操作数1是否小于操作数2，分两种情况
- aluop_i为EXE_SLT_OP表示有符号比较运算：
    
    reg1_i为负数、reg2_i为正数，显然reg1_i小于reg2_i

    reg1_i为正数、reg2_i为正数，并且reg1_i减去reg2_i的值小于0(即result_sum为负)，此时也有reg1_i小于reg2_i
    
    reg1_i为负数、reg2_i为负数，并且并且reg1_i减去reg2_i的值小于0(即result_sum为负)，此时也有reg1_i小于reg2_i
- 无符号数比较的时候u，直接使用比较运算符比较reg1_i与reg2_i

```
assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ? ((reg1_i[31] && !reg2_i[31]) 
                    || (!reg1_i[31] && !reg2_i[31] && result_sum[31]) 
                    || (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);
```
#### 2.5 reg1_i_not
对操作数1逐位取反，赋给reg1_i_not

```
assign reg1_i_not = ~reg1_i;
```
### 3. 依据不同的算术运算类型，给arithmeticres变量赋值

```
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
```
### 4. 进行乘法运算
#### 4.1计算opdata1_mult
取得乘法运算的被除数，如果是有符号乘法且被乘数是负数，则取补码

```
assign opdata1_mult=(((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))
                    && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;

```
#### 4.2 取得乘法运算的除数，如果是有符号乘法且被乘数是负数，则取补码

```
assign opdata2_mult=(((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) 
                    && (reg2_i[31] ==1'b1)) ? (~reg2_i+1) : reg2_i;

```
#### 4.3 得到临时乘法结果，保存变量hilo_temp中

```
assign hilo_temp = opdata1_mult*opdata2_mult;
```
#### 4.4 对临时乘法结果进行修正，最终结果保存在变量mulres中
- 如果是有符号乘法指令mul、mult：
    
    如果被乘数与乘数一正一负，那么需要对hilo_temp求补码，作为最终乘法结果

    如果被乘数与乘数同号，那么hilo_temp的值为最终结果
- 如果是无符号乘法指令，则hilo_temp的值作为最终结果
- 
```
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
```
#### 4.5 确定要写入目的寄存器的数据

```
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
```
#### 4.6 确定对HI、LO寄存器的操作信息

```
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
```
## 测试
### 1. 测试add、addi、addiu、addu、sub、subu指令

```
   ori  $1,$0,0x8000           # $1 = 0x8000
   sll  $1,$1,16               # $1 = 0x80000000
   ori  $1,$1,0x0010           # $1 = 0x80000010 给$1赋值

   ori  $2,$0,0x8000           # $2 = 0x8000
   sll  $2,$2,16               # $2 = 0x80000000
   ori  $2,$2,0x0001           # $2 = 0x80000001 给$2赋值

   ori  $3,$0,0x0000           # $3 = 0x00000000
   addu $3,$2,$1               # $3 = 0x00000011 $1加$2，无符号加法
   ori  $3,$0,0x0000           # $3 = 0x00000000
   add  $3,$2,$1               # $2 加 $1，有符号加法，结果溢出，$3保持不变

   sub   $3,$1,$3              # $3 = 0x80000010     $1减去$3，有符号减法
   subu  $3,$3,$2              # $3 = 0xF 	$3减去$2,无符号减法

   addi $3,$3,2                # $3 = 0x11		$3 加2，有符号加法
   ori  $3,$0,0x0000           # $3 = 0x00000000
   addiu $3,$3,0x8000          # $3 = 0xffff8000 $3加0xffff8000 无符号加法
```
测试结果：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/simple_arithmetic_1/md_images/test1.png)

### 2. 测试slt、sltu、slti、sltiu

```
    or   $1,$0,0xffff           # $1 = 0xffff
   sll  $1,$1,16               # $1 = 0xffff0000        给$1赋值
   slt  $2,$1,$0               # $2 = 1			 比较$1与0x0，有符号比较
   sltu $2,$1,$0               # $2 = 0			 比较$1与0x0，无符号比较
   slti $2,$1,0x8000           # $2 = 1			 比较$1与0xffff8000，有符号比较
   sltiu $2,$1,0x8000          # $2 = 1			 比较$1与0xffff8000，无符号比较
```
测试结果：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/simple_arithmetic_1/md_images/test2.png)
### 3. 测试clo和clz指令

```
    lui $1,0x0000          # $1 = 0x00000000 给$1赋值
   clo $2,$1              # $2 = 0x00000000 统计$1中“1”之前“0”的个数
   clz $2,$1              # $2 = 0x00000020 统计$1中“0”之前“1”的个数

   lui $1,0xffff          # $1 = 0xffff0000
   ori $1,$1,0xffff       # $1 = 0xffffffff 给$1赋值
   clz $2,$1              # $2 = 0x00000000 统计$1中“1”之前“0”的个数
   clo $2,$1              # $2 = 0x00000020 统计$1中“0”之前“1”的个数

   lui $1,0xa100          # $1 = 0xa1000000 给$1赋值
   clz $2,$1              # $2 = 0x00000000 统计$1中“1”之前“0”的个数
   clo $2,$1              # $2 = 0x00000001 统计$1中“0”之前“1”的个数

   lui $1,0x1100          # $1 = 0x11000000 给$1赋值
   clz $2,$1              # $2 = 0x00000003 统计$1中“1”之前“0”的个数
   clo $2,$1              # $2 = 0x00000000 统计$1中“0”之前“1”的个数
```
测试结果：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/simple_arithmetic_1/md_images/test3.png)
### 4. 测试mul、mult、multu指令

```
   ori  $1,$0,0xffff                  
   sll  $1,$1,16
   ori  $1,$1,0xfffb           # $1 = -5   给$1赋值
   ori  $2,$0,6                # $2 = 6	   给$2赋值
   mul  $3,$1,$2               # $3 = -30 = 0xffffffe2 $1 乘以$2，有符号乘法，结果低32位保存到$3
   mult $1,$2                  # hi = 0xffffffff 
                               # lo = 0xffffffe2
							   # $1 乘以$2，有符号乘法，结果低32位保存到HI LO
   multu $1,$2                 # hi = 0x5
                               # lo = 0xffffffe2
							   # $1 乘以$2，无符号乘法，结果低32位保存到HI LO
   nop
   nop
```
测试结果：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/simple_arithmetic_1/md_images/test4.png)
