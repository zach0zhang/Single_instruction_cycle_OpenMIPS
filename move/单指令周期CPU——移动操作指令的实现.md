## 指令简介
MIPS指令集架构中定义6条移动操作指令：**movn、movz、mfhi、mthi、mflo、mtlo**

后4条指令涉及对特殊寄存器HI、LO的读写操作

HI、LO寄存器用于保存乘法、除法结果

6条移动操作指令格式:
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/move/md_images/res_move.png)
由指令格式可以看出指令码都是6'b000000(bit26\~31)，由功能码(0\~5bit)判断是哪个指令,并且指令6~10bit都是0
- **movn**(功能码是6'b001011):用法：movn rd, rs, rt；作用：if rt != 0 then rd <- rs(如果rt通用寄存器里的值不为0，则将地址为rs的通用寄存器的值赋值给地址为rd的通用寄存器)
- **movz**(功能码是6'b001010):用法：movn rd, rs, rt；作用：if rt == 0 then rd <- rs(如果rt通用寄存器里的值为0，则将地址为rs的通用寄存器的值赋值给地址为rd的通用寄存器)
- **mfhi**(功能码是6'b010010):用法：mflo rd 作用：rd <- lo将特殊寄存器HI的值赋给地址为rd的通用寄存器
- **mflo**(功能码是6'b010000)：用法 mflo rd 作用：rd <- lo将特殊寄存器LO的值赋给地址为rd的通用寄存器
- **mthi**(功能码是6‘b010001):用法：mthi rs 作用：hi <- rs将地址为rs的通用寄存器的值赋给特殊寄存器HI
- **mtlo**(功能码是6'b010011):用法：mtlo rs 作用：lo <- rs,将地址为rs的通用寄存器的值赋给特殊寄存器LO
## 修改系统结构
对之前的结构进行改变
1. 增加HILO模块，实现HI、LO寄存器
2. 增加执行模块EX的输入接口，接收从HILO模块传来的HI、LO寄存器的值；输出到WB模块是否要写HILO、写入HI寄存器的值、写入LO寄存器的值
3. 增加回写模块WB的输入输出接口
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/move/md_images/move_struct.png)
## 添加HILO模块，实现HI、LO寄存器

```
module hilo_reg(
    input wire clk,
    input wire rst,

    //写端口
    input wire we,
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,

    //读端口
    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o
);
always @(posedge clk)begin
  if(rst==`RstEnable) begin
    hi_o <= `ZeroWord;
    lo_o <= `ZeroWord;
  end else if(we == `WriteEnable) begin
    hi_o<=
  end
end
```

## 修改译码阶段的ID模块
首先把移动操作这令的这六条指令的功能码和操作码以及操作类型的宏定义添加到defines.v文件中去：

```
`define EXE_MOVZ  6'b001010     //指令MOVZ的功能码
`define EXE_MOVN  6'b001011     //指令MOVN的功能码
`define EXE_MFHI  6'b010000     //指令MFHI的功能码
`define EXE_MTHI  6'b010001     //指令MTHI的功能码
`define EXE_MFLO  6'b010010     //指令MFLO的功能码
`define EXE_MTLO  6'b010011     //指令MTLO的功能码
`define EXE_MOVZ_OP  8'b00001010
`define EXE_MOVN_OP  8'b00001011
`define EXE_MFHI_OP  8'b00010000
`define EXE_MTHI_OP  8'b00010001
`define EXE_MFLO_OP  8'b00010010
`define EXE_MTLO_OP  8'b00010011
`define EXE_RES_MOVE 3'b011	
```
其次在译码模块ID中根据六条指令的功能码判断是那一条指令：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/move/md_images/select.png)

- MFLO和MFHI:将特殊寄存器LO和HI赋给通用寄存器，则可以知道肯定是要修改寄存器的即wreg_o为`WriteEnable，而且不需要读取寄存器的值即reg1_read_o和reg2_read_o都为0，另外运算类型为`EXE_RES_MOVE
- MTHI和MTLO:将通用寄存器的值赋值给特殊寄存器LO和HI,则可知不需要修改通用寄存器的值即wreg_o为`WriteDisable，需要读取端口1的寄存器的值,也就是指令中rs的值即reg1_read_o 为1，另外运算类型为`EXE_RES_NOP
- MOVN和MOVZ:需要读取rs，rt寄存器的值即reg1_read_o和reg2_read_o都为1，从端口1中读取rs寄存器(指令的21\~25bit)的值,从端口2中读取rt寄存器(指令第16\~20bit),判断读出的rt寄存器的值，根据rt寄存器的值是否为0，决定wreg_o为`WriteEnable还是`WriteDisable

```
        case(op)
            `EXE_SPECIAL_INST:  begin //SPECIAL
                case(op2)
                    5'b00000: begin
                        case(op3)
                        ...
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
							....
```

## 修改执行阶段EX模块
- 首先得到最新的HI、LO的值

```
always @ (*) begin
	if(rst == `RstEnable) begin
		{HI,LO} <= {`ZeroWord,`ZeroWord};
	end else begin
		{HI,LO} <= {hi_i,lo_i};			
	end
end	
```
- 针对不同的移动操作指令确定moveres的值，变量moveres存储的是移动操作指令的结果

```
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
```
- 再在选择运算结果里添加依据EXE_RES_MOVE的运算类型，将moveres作为运算结果

```
always @ (*) begin
    wd_o <= wd_i;       //要写的目的寄存器地址
    wreg_o <= wreg_i;
    case(alusel_i)
        ...
        `EXE_RES_MOVE:		begin
	 		wdata_o <= moveres;
	 	end	
        ...
    endcase
end
```
- 最后确定是否要写HI、LO寄存器，如果指令为MTHI何MTLO，则需要些HI、LO寄存器，则输出信号whilo_o为WriteEnable，根据是哪一条指令，制定reg1_i的值输出到HI和LO哪一寄存器

```
always @ (*) begin
	if(rst == `RstEnable) begin
		whilo_o <= `WriteDisable;
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;		
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
## 修改回写模块wb
增加由执行模块传来的HI、LO特殊寄存器的数值和是否写入信息，根据传入信息传到HILO特殊寄存器

```
	always @ (*) begin
		if(rst == `RstEnable) begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
		  	wb_wdata <= `ZeroWord;	
			wb_hi <= `ZeroWord;
		  	wb_lo <= `ZeroWord;
		  	wb_whilo <= `WriteDisable;
		end else begin
			wb_wd <= ex_wd;
			wb_wreg <= ex_wreg;
			wb_wdata <= ex_wdata;
			wb_hi <= ex_hi;
			wb_lo <= ex_lo;
			wb_whilo <= ex_whilo;	
		end    //if
	end      //always
```
## 修改顶层模块openmips
添加了HILO模块并且对多个模块的新增接口进行连接

```
module openmips(
    input wire          clk,
    input wire          rst,

    input wire[`RegBus]         rom_data_i,
    output wire[`RegBus]        rom_addr_o,
    output wire                 rom_ce_o
);
//连接ID模块和EX模块
wire[`AluOpBus] id_aluop;
wire[`AluSelBus] id_alusel;
wire[`RegBus] id_reg1;
wire[`RegBus] id_reg2;
wire          id_wreg;
wire[`RegAddrBus] id_wd;
//连接ID模块和Regfile模块
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
//连接执行阶段与hilo模块的输出，即读取HI、LO寄存器
wire[`RegBus] 	hi;
wire[`RegBus]   lo;
//连接EX模块和WB模块
wire ex_wreg;
wire[`RegAddrBus] ex_wd;
wire[`RegBus] ex_wdata;
wire[`RegBus] ex_hi_o;
wire[`RegBus] ex_lo_o;
wire ex_whilo_o;
//连接WB模块和Regfile模块
wire[`RegAddrBus] wb_wd;
wire wb_wreg;
wire[`RegBus] wb_wdata;
//连接WB模块和hilo_reg模块
wire[`RegBus] wb_hi;
wire[`RegBus] wb_lo;
wire wb_whilo;
//pc_reg real
pc_reg pc_reg0(
    .clk(clk),  .rst(rst),  .pc(rom_addr_o),    .ce(rom_ce_o)
);
//ID real
id id0(
    .rst(rst),  
    .pc_i(rom_addr_o), 
    .inst_i(rom_data_i),
    //来自Regfile模块的输入
    .reg1_data_i(reg1_data),    .reg2_data_i(reg2_data),
    //送到Regfile模块的信息
    .reg1_read_o(reg1_read),    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),    .reg2_addr_o(reg2_addr),
    //送到EX模块的信息
    .aluop_o(id_aluop),   .alusel_o(id_alusel),
    .reg1_o(id_reg1),     .reg2_o(id_reg2),
    .wd_o(id_wd),         .wreg_o(id_wreg)
);
//Regfile real
regfile regfile1(
    .clk(clk),
    .rst(rst),
    //从WB模块传来信息
    .we(wb_wreg), .waddr(wb_wd),
    .wdata(wb_wdata),
    //ID模块传来的信息
    .re1(reg1_read),    .raddr1(reg1_addr), 
    .rdata1(reg1_data),
    .re2(reg2_read),    .raddr2(reg2_addr),
    .rdata2(reg2_data)
);
//EX real
ex ex0(
    .rst(rst),
    //从ID模块传来的信息
    .aluop_i(id_aluop),   .alusel_i(id_alusel),
    .reg1_i(id_reg1),     .reg2_i(id_reg2),
    .wd_i(id_wd),         .wreg_i(id_wreg),
    //从hilo_reg模块传来的信息
    .hi_i(hi),
	.lo_i(lo),
    //送到WB模块的信息
    .wd_o(ex_wd),         .wreg_o(ex_wreg),
    .wdata_o(ex_wdata)
    .hi_o(ex_hi_o),
	.lo_o(ex_lo_o),
	.whilo_o(ex_whilo_o)

);
//WB real
wb wb0(
    .rst(rst),
    .ex_wd(ex_wd),         .ex_wreg(ex_wreg),
    .ex_wdata(ex_wdata),
    .ex_hi(ex_hi_o),
	.ex_lo(ex_lo_o),
	.exwhilo(ex_whilo_o),
    .wb_wd(wb_wd),  .wb_wreg(wb_wreg),
    .wb_wdata(wb_wdata)
    .wb_hi(wb_hi),
	.wb_lo(wb_lo),
	.wb_whilo(wb_whilo)
);
hilo_reg hilo_reg0(
	.clk(clk),
	.rst(rst),
	
	//写端口
	.we(wb_whilo),
	.hi_i(wb_hi),
	.lo_i(wb_lo),
	
	//读端口1
	.hi_o(hi),
	.lo_o(lo)	
	);
        
endmodule

```
## 测试

```
   .org 0x0
   .set noat
   .global _start
_start:
   lui $1,0x0000          # $1 = 0x00000000
   lui $2,0xffff          # $2 = 0xffff0000
   lui $3,0x0505          # $3 = 0x05050000
   lui $4,0x0000          # $4 = 0x00000000 

   movz $4,$2,$1          # $4 = 0xffff0000
   movn $4,$3,$1          # $4 = 0xffff0000
   movn $4,$3,$2          # $4 = 0x05050000
   movz $4,$2,$3          # $4 = 0x05050000

   mthi $0                # hi = 0x00000000
   mthi $2                # hi = 0xffff0000
   mthi $3                # hi = 0x05050000
   mfhi $4                # $4 = 0x05050000

   mtlo $3                # li = 0x05050000
   mtlo $2                # li = 0xffff0000
   mtlo $1                # li = 0x00000000
   mflo $4                # $4 = 0x00000000 
```
经编译后得到用于指令寄存器的文件：

```
3c010000
3c02ffff
3c030505
3c040000
0041200a
0061200b
0062200b
0043200a
00000011
00400011
00600011
00002010
00600013
00400013
00200013
00002012
```
仿真结果
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/move/md_images/test.png)

