## 指令介绍
### 1. 加载指令
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/Load_Store/md_images/load.png)
- **lb(指令码6'b100000)**：**字节**加载指令，用法：lb,rt,offset(base)，作用：从内存中指定的加载地址处，读取**一个字节**，然后**符号扩展**至32位，保存到地址为rt的通用寄存器中
- **lbu(指令码6'b100100)**：**无符号字节**加载指令，用法：lbu,rt,offset(base)，作用：从内存中指定的加载地址处，读取**一个字节**，然后**无符号扩展**至32位，保存到地址为rt的通用寄存器中
- **lh(指令码6'b100001)**：**半字**加载指令，用法：lh,rt,offset(base)，作用：从内存中指定的加载地址处，读取**一个半字**，然后**符号扩展**至32位，保存到地址为rt的通用寄存器中**该指令有地址对齐要求，要求计算出来的存储地址的最低两位为0**
- **lhu(指令码6'b100101)**：**无符号半字**加载指令，用法：lhu,rt,offset(base)，作用：从内存中指定的加载地址处，读取**一个半字**，然后**无符号扩展**至32位，保存到地址为rt的通用寄存器中**该指令有地址对齐要求，要求计算出来的存储地址的最低两位为0**
- **lw(指令码6'b100011)**：字加载指令，用法：lw,rt,offset(base)，作用：从内存中指定的加载地址处，读取**一个字**，保存到地址为rt的通用寄存器中。**该指令有地址对齐要求，要求加载地址的最低两位为00**
### 2. 存储指令
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/Load_Store/md_images/Store.png)
- **sb(指令码为6'b101000)**：**字节**存储指令，用法：sb rt,offset(base)，作用：将地址为rt的通用寄存器的值存储到内存中的指定地址。
- **sh(指令码为6'b101001)**：**半字**存储指令，用法：sh rt,offset(base)，作用：将地址为rt的通用寄存器的值存储到内存中的指定地址。**该指令有地址对齐要求，要求计算出来的存储地址的最低两位为0**
- **sw(指令码为6'b101011)**：**字**存储指令，用法：sw rt,offset(base)，作用：将地址为rt的通用寄存器的值存储到内存中的指定地址。**该指令有地址对齐要求，要求计算出来的存储地址的最低两位为00**

## 修改系统结构
增加了访存阶段MEM模块和RAM，和相关的接口
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/Load_Store/md_images/LS_struct.png)
### 1. 增加访存阶段MEM模块
之前因为不需要访问内存，所以在改变MIPS五级流水线线时省略了只用来传递数据的访存阶段，现在需要加上访存阶段，访存阶段需要通过执行阶段EX传递过来的信息，根据具体的加载、存储指令来对数据存储器RAM进行读/写操作

- 加载操作：可以加载字节、半字、字，根据字节选择信号（mem_sel_o）来选择有效字节占32位数据总线的多少
- 存储操作：可以存储字节、半字、字，根据字节选择信号（mem_sel_o）来选择有效字节占32位数据总线的多少

**mem_sel_o宽度是4位，每一位代表一个字节是否有效，比如：**
    
    加载时mem_sel_o=4'b1000，说明加载加载地址处32位数据总线的最高字节
    
    存储时mem_sel_o=4'b0011，说明存储要存储数据的最低两个字节

```
`include "defines.v"

module mem(

	input wire					rst,
	
	//来自执行阶段的信息	
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
	input wire[`RegBus]			  wdata_i,
	input wire[`RegBus]           hi_i,
	input wire[`RegBus]           lo_i,
	input wire                    whilo_i,	
	
	input wire[`AluOpBus]        aluop_i,
	input wire[`RegBus]          mem_addr_i,
	input wire[`RegBus]          reg2_i,
	
	//送到回写阶段的信息
	output reg[`RegAddrBus]      wd_o,
	output reg                   wreg_o,
	output reg[`RegBus]			 wdata_o,
	output reg[`RegBus]          hi_o,
	output reg[`RegBus]          lo_o,
	output reg                   whilo_o,
	
	//来自memory的信息
	input wire[`RegBus]          mem_data_i,
	
	//送到memory的信息
	output reg[`RegBus]          mem_addr_o,
	output wire					 mem_we_o,
	output reg[3:0]              mem_sel_o,
	output reg[`RegBus]          mem_data_o,
	output reg                   mem_ce_o	
	
);

wire[`RegBus] zero32;
reg          mem_we;

assign mem_we_o = mem_we ;

assign zero32 = `ZeroWord;
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			wdata_o <= `ZeroWord;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
			whilo_o <= `WriteDisable;		
			mem_addr_o <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_o <= 4'b0000;
			mem_data_o <= `ZeroWord;
			mem_ce_o <= `ChipDisable;			  
		end else begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			hi_o <= hi_i;
			lo_o <= lo_i;
			whilo_o <= whilo_i;		
			mem_we <= `WriteDisable;
			mem_addr_o <= `ZeroWord;
			mem_sel_o <= 4'b1111;
			mem_ce_o <= `ChipDisable;	
			case (aluop_i)
				`EXE_SW_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= reg2_i;
					mem_sel_o <= 4'b1111;	
					mem_ce_o <= `ChipEnable;		
				end
				`EXE_LW_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					wdata_o <= mem_data_i;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `ChipEnable;		
				end
				default:	begin
				end
			endcase	
		end    //if
	end      //always
			

endmodule
```

### 2. 增加数据存储器RAM
数据存储器的建立与指令存储器非常相似，7个接口分别为

接口名 | 作用
---|---
ce | 数据存储器使能信号
clk | 时钟信号
data_i | 要写入的数据
addr | 要访问的地址
we | 1：写操作；0：读操作
sel | 字选择信号
data_o | 读出的数据

**为了反汇编对数据存储器按字节寻址，使用4个8位存储器代替一个32位的存储器**

```
`include "defines.v"

module data_ram(

	input	wire						clk,
	input wire							ce,
	input wire							we,
	input wire[`DataAddrBus]			addr,
	input wire[3:0]						sel,
	input wire[`DataBus]				data_i,
	output reg[`DataBus]				data_o
	
);

reg[`ByteWidth]  data_mem0[0:`DataMemNum-1];
reg[`ByteWidth]  data_mem1[0:`DataMemNum-1];
reg[`ByteWidth]  data_mem2[0:`DataMemNum-1];
reg[`ByteWidth]  data_mem3[0:`DataMemNum-1];

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			//data_o <= ZeroWord;
		end else if(we == `WriteEnable) begin
			  if (sel[3] == 1'b1) begin
		      data_mem3[addr[`DataMemNumLog2+1:2]] <= data_i[31:24];
		    end
			  if (sel[2] == 1'b1) begin
		      data_mem2[addr[`DataMemNumLog2+1:2]] <= data_i[23:16];
		    end
		    if (sel[1] == 1'b1) begin
		      data_mem1[addr[`DataMemNumLog2+1:2]] <= data_i[15:8];
		    end
			  if (sel[0] == 1'b1) begin
		      data_mem0[addr[`DataMemNumLog2+1:2]] <= data_i[7:0];
		    end			   	    
		end
	end
	
	always @ (*) begin
		if (ce == `ChipDisable) begin
			data_o <= `ZeroWord;
	  end else if(we == `WriteDisable) begin
		    data_o <= {data_mem3[addr[`DataMemNumLog2+1:2]],
		               data_mem2[addr[`DataMemNumLog2+1:2]],
		               data_mem1[addr[`DataMemNumLog2+1:2]],
		               data_mem0[addr[`DataMemNumLog2+1:2]]};
		end else begin
				data_o <= `ZeroWord;
		end
	end		

endmodule
```

## 修改相关模块
### 1. 增加相关宏定义
defines.v:

```
`define EXE_LB  6'b100000		//指令LB的指令码
`define EXE_LBU  6'b100100		//指令LBU的指令码
`define EXE_LH  6'b100001		//指令LH的指令码
`define EXE_LHU  6'b100101		//指令LHU的指令码
`define EXE_LW  6'b100011		//指令LW的指令码
`define EXE_SB  6'b101000		//指令SB的指令码
`define EXE_SH  6'b101001		//指令SH的指令码
`define EXE_SW  6'b101011		//指令SW的指令码

`define EXE_LB_OP  8'b11100000
`define EXE_LBU_OP  8'b11100100
`define EXE_LH_OP  8'b11100001
`define EXE_LHU_OP  8'b11100101
`define EXE_LW_OP  8'b11100011
`define EXE_SB_OP  8'b11101000
`define EXE_SH_OP  8'b11101001
`define EXE_SW_OP  8'b11101011

`define EXE_RES_LOAD_STORE 3'b111

//数据存储器data_ram
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0
```
### 2. 修改译码阶段ID模块
需要将指令传递到下一阶段，因为需要在执行阶段使用到指令

如果读则需要写入目的寄存器，即Load类的指令wreg_o都是WriteEnable；而且只需要知道base的值即reg1_read_o为1即可

写则不需要写入目的寄存器，即Store类指令wreg_o都是WriteDisable；而且存储要知道存储的寄存器的值，还需要知道base的值，所以reg1_read_o和reg2_read_o都为1


此类指令的操作类型为`EXE_RES_LOAD_STORE
```
...
assign inst_o = inst_i;
...
            `EXE_LB:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_LB_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; 
				instvalid <= `InstValid;	
			end
			`EXE_LBU:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_LBU_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; 
				instvalid <= `InstValid;	
			end
			`EXE_LH:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_LH_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; 
				instvalid <= `InstValid;	
			end
			`EXE_LHU:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_LHU_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; 
				instvalid <= `InstValid;	
			end
			`EXE_LW:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_LW_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; 
				instvalid <= `InstValid;	
			end
			`EXE_SB:			begin
		  		wreg_o <= `WriteDisable;		
				aluop_o <= `EXE_SB_OP;
		  		reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b1; 
				instvalid <= `InstValid;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SH:			begin
		  		wreg_o <= `WriteDisable;		
				aluop_o <= `EXE_SH_OP;
		  		reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b1; 
				instvalid <= `InstValid;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SW:			begin
		  		wreg_o <= `WriteDisable;		
				aluop_o <= `EXE_SW_OP;
		  		reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b1; 
				instvalid <= `InstValid;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			...
```
### 2.修改执行阶段EX模块

```
//将指令类别传递到访存阶段，利用其确定加载、存储类型
assign aluop_o = aluop_i;

//mem_addr_o即传递到访存阶段，是加载、存储指令的地址
//reg1_i是加载存储指令中地址为base的通用寄存器的值
//inst_i[15:0]就是指令中的offset
assign mem_addr_o = reg1_i + {{16{inst_i[15]}},inst_i[15:0]};

//reg2_i是存储指令要存储的数据，或者lwl、lwr指令要加载到的目的寄存器的原始值
assign reg2_o = reg2_i;
```

### 3. 修改openmips
增加了访存模块和RAM，和一些接口，需要修改相关代码，将模块与模块之间连接起来

## 测试
编写测试代码：

```
   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
   ori  $3,$0,0xeeff
   sb   $3,0x3($0)       # [0x3] = 0xff
   srl  $3,$3,8
   sb   $3,0x2($0)       # [0x2] = 0xee
   ori  $3,$0,0xccdd
   sb   $3,0x1($0)       # [0x1] = 0xdd
   srl  $3,$3,8
   sb   $3,0x0($0)       # [0x0] = 0xcc
   lb   $1,0x3($0)       # $1 = 0xffffffff
   lbu  $1,0x2($0)       # $1 = 0x000000ee
   nop

   ori  $3,$0,0xaabb
   sh   $3,0x4($0)       # [0x4] = 0xaa, [0x5] = 0xbb
   lhu  $1,0x4($0)       # $1 = 0x0000aabb
   lh   $1,0x4($0)       # $1 = 0xffffaabb
 
   ori  $3,$0,0x8899
   sh   $3,0x6($0)       # [0x6] = 0x88, [0x7] = 0x99
   lh   $1,0x6($0)       # $1 = 0xffff8899
   lhu  $1,0x6($0)       # $1 = 0x00008899

   ori  $3,$0,0x4455
   sll  $3,$3,0x10
   ori  $3,$3,0x6677     
   sw   $3,0x8($0)       # [0x8] = 0x44, [0x9]= 0x55, [0xa]= 0x66, [0xb] = 0x77
   lw   $1,0x8($0)       # $1 = 0x44556677
    
_loop:
   j _loop
   nop

```
测试结果：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/Load_Store/md_images/test.png)

