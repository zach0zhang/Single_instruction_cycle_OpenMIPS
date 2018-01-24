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
![image](E:\笔记\Verilog\simple_arithmetic\add_sub_slt.png)
由指令格式可以看出这六条指令指令码都是6'b000000即SPECIAL类，而且指令的第6\~10bit都是0，根据指令的功能码(0\~5bit)来判断是那一条指令
- **ADD(功能码是6'b100000)**:加法运算，用法：add rd,rs,rt；作用：rd <- rs+rt，将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行加法运算，结果保存到地址为rd的通用寄存器中。**如果加法运算溢出，那么会产生溢出异常，同时不保存结果。**
- **ADDU(功能码是6'b100001)**:加法运算，用法：addu rd,rs,rt; 作用：rd <-rs+rd,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行加法运算，结果保存到rd的通用寄存器中。**不进行溢出检查，总是将结果保存到目的寄存器。**
- **SUB(功能码是6'b100010)**:减法运算，用法：sub rd,rs,rt; 作用：rd <- rs-rt,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行减法运算，结果保存到地址为rd的通用寄存器中。**如果减法运算溢出，那么产生溢出异常，同时不保存结果。**
- **SUBU(功能码是6'b100011)**:减法运算，用法：subu rd,rs,rt; 作用：rd <- rs-rt将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行减法运算，结果保存到地址为rd的通用寄存器中。**不进行溢出检查，总是将结果保存到目的寄存器。**
- **SLT(功能码是6'b101010)**:比较运算，用法：slt rd,rs,rt; 作用：rd <- (rs<rt)将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值按照**有符号数**进行比较，**若前者小于后者，那么将1保存到地址为rd的通用寄存器，若前者大于后者，则将0保存到地址为rd的通用寄存器中**
- **SLTU(功能码是6'b101011)**:比较运算，用法：sltu rd,rs,rt; 作用：rd <- (rs<rt)将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值按照**无符号数**进行比较，**若前者小于后者，那么将1保存到地址为rd的通用寄存器，若前者大于后者，则将0保存到地址为rd的通用寄存器中**

#### 2. addi、addiu、slti、sltiu指令
addi、addiu、slti、sltiu指令格式为：
![image](E:\笔记\Verilog\simple_arithmetic\addi_slti.png)
由指令格式可以看出，依据指令码(26\~31bit)判断是哪一种指令
- **ADDI(指令码是6'b001000)**:加法运算，用法：addi rt,rs,immediate; 作用：rt <- rs+(sign_extended)immediate,将指令中16位立即数进行符号扩展，与地址为rs的通用寄存器进行加法运算，结果保存到地址为rt的通用寄存器。**如果加法运算溢出，则产生溢出异常，同时不保存结果。**
- **ADDIU(指令码是6'b001001)**:加法运算，用法：addiu rt,rs,immediate; 作用：rt <- rs+(sign_extended)immediate,将指令中16位立即数进行符号扩展，与地址为rs的通用寄存器进行加法运算，结果保存到地址为rt的通用寄存器。**不进行溢出检查，总是将结果保存到目的寄存器。**
- **SLTI(功能码是6'b001010)**:比较运算，用法：slti rt,rs,immediate; 作用：rt <- (rs<(sign_extended)immediate)将指令中的16位立即数进行符号扩展，与地址为rs的通用寄存器的值按照**有符号数**进行比较，**若前者小于后者，那么将1保存到地址为rt的通用寄存器，若前者大于后者，则将0保存到地址为rt的通用寄存器中**
- **SLTIU(功能码是6'b001011)**:比较运算，用法：sltiu rt,rs,immediate; 作用：rt <- (rs<(sign_extended)immediate)将指令中的16位立即数进行符号扩展，与地址为rs的通用寄存器的值按照**无符号数**进行比较，**若前者小于后者，那么将1保存到地址为rt的通用寄存器，若前者大于后者，则将0保存到地址为rt的通用寄存器中**

#### 3. clo、clz指令
clo、clz的指令格式：
![image](E:\笔记\Verilog\simple_arithmetic\clo_clz.png)
由指令格式可以看出，这两条指令的指令码(26\~31bit)都是6'b011100,即是SPECIAL2类；而且第6\~10bit都为0，根据指令中的功能码(0\~5bit)判断是哪一条指令
- **CLZ(功能码是6'b100000)**:计数运算，用法：clz rd,rs; 作用：rd <- coun_leading_zeros rs,对地址为rs的通用寄存器的值，从最高位开始向最低位方向检查，**直到遇到值为“1”的位，将该为之前“0”的个数保存到地址为rd的通用寄存器中**，如果地址为rs的通用寄存器的所有位都为0(即0x00000000),那么将32保存到地址为rd的通用寄存器中
- **CLO(功能码是6'b100001)**:计数运算，用法：clo,rd,rs; 作用：rd <- coun_leading_zeros rs对地址为rs的通用寄存器的值，从最高位开始向最低位方向检查，**直到遇到值为“0”的位，将该为之前“1”的个数保存到地址为rd的通用寄存器中**，如果地址为rs的通用寄存器的所有位都为1(即0xFFFFFFFF),那么将32保存到地址为rd的通用寄存器中

#### 4. multu、mult、mul指令
multu、mult、mul的指令格式：
![image](E:\笔记\Verilog\simple_arithmetic\mul.png)
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
```

## 修改译码阶段ID模块
根据指令的指令码，和功能码确定是哪一条指令，再由具体的指令给出译码结果
![image](http://note.youdao.com/favicon.ico)