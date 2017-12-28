通过学习《自己动手写CPU》第四章，学习了MIPS五级流水线下的ori指令，本文旨在实现单指令周期下的ori指令。

虽然原书中只实现了ori这一条指令，但是已经建立了五级流水线，在实现其它指令时，也就是在五级流水线上进行扩充

## ori指令
ori进行逻辑“或”运算，指令格式如图：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/ori/md_images/ori.png)
指令码为001101，处理器通过指令码识别出ori指令

ori指令作用：将16位立即数immediate进行无符号扩展至32位，与rs寄存器里的值进行“或”运算，结果放入rt寄存器中

## OpenMIPS 五级流水线
- **取指阶段**：从指令存储器读出指令，同时确定下一条指令地址
- **译码阶段**：对指令进行译码，从通用寄存器中读出要使用的寄存器的值，如果指令中含有立即数，那么还要将立即数进行符号扩展或无符号扩展。如果是转移指令，并且满足转移条件，那么给出转移目标，作为新的指令地址
- **执行阶段**：按照译码阶段给出的操作数、运算类型，进行运算，给出运算结果。如果是Load/Store指令，那么还会计算Load/Store的目标地址
- **访存阶段**：如果是Load/Store指令，那么在此阶段会访问数据存储器，反之，只是将执行阶段的结果向下传递到回写阶段。同时，在此阶段还要判断是否有异常需要处理，如果有，那么会清楚流水线，然后转移到异常处理例程入口地址处继续执行。
- **回写阶段**：将运算结果保存到目标寄存器

## 五级流水线中的ori指令
**OpenMIPS的原始数据流图**：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/ori/md_images/MIPS_ORI.png)
ori指令通过原始的数据流图所表示的数据流向即可完成操作。
- 取指：取出指令寄存器中的ori指令，PC值递增，准备取出下一条指令
- 译码：对ori指令译码，从寄存器中取出第一个操作数的值，对立即数进行扩展后作为第二个操作数的值
- 执行：依据译码阶段传来的源操作数和操作码进行运算，即进行ori指令所代表的“或”运算
- 访存：对于ori指令，在访存阶段没有任何操作，直接运算结果传递到回写阶段
- 回写：将运算结果保存到目的寄存器

**原始的OpenMIPS五级流水线系统结构图**：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/ori/md_images/system_struct_ori.png)
## 单指令周期ori指令的实现
五级流水线的好处是通过多个硬件处理单元并行执行来加快指令的执行速度，但是抱着学习计算机组成原理而言不需要实现高超的处理器性能，主旨实现指令功能和处理器工作原理，将五级流水线合成单指令周期执行。

单指令周期执行ori指令，不用考虑数据相关问题，每一条指令都在一个指令周期完成，即在一个指令周期完成取指、译码、执行、访存、回写等五个步骤

由于ori在访存阶段并没有任何操作，直接将运算结果传递回写阶段，则在此处省略掉这一阶段

**单指令周期在第一个时钟开始执行取指、译码、执行，在第二个时钟执行回写阶段**

**单指令周期系统结构图：**
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/ori/md_images/ori_new.png)

### 1. 取指
通过PC模块，PC值在复位时保持0，每个时钟上升沿到来时PC值加4（一条指令对应4个字节），将PC值传入指令存储器模块，通过指令存储器模块取得指令

**pc_reg:**
```
`include "defines.v"
module pc_reg(
	input wire					clk,
	input wire					rst,
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
	else begin
		pc<=pc+4'h4;			//指令存储器使能时，pc=pc+4
	end
end

endmodule
```
**inst_rom.v:**
```
`include "defines.v"
module inst_rom(
    input wire          ce,
    input wire[`InstAddrBus]    addr,
    output reg[`InstBus]        inst
);

reg[`InstBus] inst_mem[0:`InstMemNum-1];

initial $readmemh ("inst_rom.data",inst_mem);

always @ (*) begin
    if(ce == `ChipDisable) begin
        inst <= `ZeroWord;
    end else begin
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
    end
end

endmodule
```

### 2. 译码
将取指阶段取得的指令传入ID模块,通过ID模块对指令进行译码，获得运算子类型和运算类型，并通过将信息传给寄存器堆，读出相关寄存器值作为源操作数传向执行阶段

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
            default:begin
            end
        endcase //case op
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
**regfile.v:**

```
`include "defines.v"
module regfile(
  
    input wire clk,
    input wire rst,

    //写端口
    input wire                  we,
    input wire[`RegAddrBus]     waddr,
    input wire[`RegBus]         wdata,

    //读端口1
    input wire                  re1,
    input wire[`RegAddrBus]     raddr1,
    output reg[`RegBus]         rdata1,

    //读端口2
    input wire                  re2,
    input wire[`RegAddrBus]     raddr2,
    output reg[`RegBus]         rdata2
);

//定义32个32位寄存器
reg[`RegBus] regs[0:`RegNum-1];

//写操作
always @ (posedge clk) begin
    if(rst==`RstDisable)begin
        if((we==`WriteEnable) && (waddr !=`RegNumLog2'h0))begin
            regs[waddr]<=wdata;
        end
    end
end

//读端口1操作
always @ (*) begin
    if(rst==`RstEnable) begin
        rdata1<=`ZeroWord;
    end
    else if(raddr1==`RegNumLog2'h0) begin
        rdata1<=`ZeroWord;
    end
    else if(re1==`ReadEnable) begin
        rdata1<=regs[raddr1];
    end
    else begin
        rdata1<=`ZeroWord;
    end
end

//读端口2操作
always @ (*) begin
    if(rst==`RstEnable) begin
        rdata2<=`ZeroWord;
    end
    else if(raddr2==`RegNumLog2'h0) begin
        rdata2<=`ZeroWord;
    end
    else if(re2==`ReadEnable) begin
        rdata2<=regs[raddr2];
    end
    else begin
        rdata2<=`ZeroWord;
    end
end

endmodule
```
### 3. 执行
根据译码阶段传来的信息，通过EX模块进行相应的运算操作，并将结果传给回写阶段

**ex.v:**

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

//根据aluop_i指示的运算子类型进行运算
always @ (*) begin
    if(rst == `RstEnable) begin
        logicout <= `ZeroWord;
    end else begin
        case(aluop_i)
            `EXE_OR_OP:begin    //进行“或"运算
                logicout <= reg1_i | reg2_i;
            end
            default:begin
                logicout<=`ZeroWord;
            end
        endcase
    end //if
end //always

//根据alusel_i指示的运算类型，选择一个运算结果作为最终结果
always @ (*) begin
    wd_o <= wd_i;       //要写的目的寄存器地址
    wreg_o <= wreg_i;
    case(alusel_i)
        `EXE_RES_LOGIC:begin
            wdata_o <= logicout;
        end
        default:begin
            wdata_o<=`ZeroWord;
        end
    endcase
end

endmodule

```
### 4. 回写
根据执行阶段传来的信息，通过WB模块，在第二个时钟到来传递回寄存器堆，完成在一个指令周期的写回

**wb.v:**

```
`include "defines.v"
module wb(
	input wire										rst,
	

	//来自EX的信息	
	input wire[`RegAddrBus]       ex_wd,
	input wire                    ex_wreg,
	input wire[`RegBus]			  ex_wdata,

	//送到Regfile的信息
	output reg[`RegAddrBus]      wb_wd,
	output reg                   wb_wreg,
	output reg[`RegBus]					 wb_wdata	       
	
);

	always @ (*) begin
		if(rst == `RstEnable) begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
		  wb_wdata <= `ZeroWord;	
		end else begin
			wb_wd <= ex_wd;
			wb_wreg <= ex_wreg;
			wb_wdata <= ex_wdata;
		end    //if
	end      //always
			

endmodule
```
### 5.顶层模块调用
将上面所有模块实例化并连接起来

**openmips.v:**

```
`include "defines.v"
`include "pc_reg.v"
`include "id.v"
`include "regfile.v"
`include "ex.v"
`include "wb.v"
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
//连接EX模块和WB模块
wire ex_wreg;
wire[`RegAddrBus] ex_wd;
wire[`RegBus] ex_wdata;
//连接WB模块和Regfile模块
wire[`RegAddrBus] wb_wd;
wire wb_wreg;
wire[`RegBus] wb_wdata;
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
    //送到WB模块的信息
    .wd_o(ex_wd),         .wreg_o(ex_wreg),
    .wdata_o(ex_wdata)
);
//WB real
wb wb0(
    .rst(rst),
    .ex_wd(ex_wd),         .ex_wreg(ex_wreg),
    .ex_wdata(ex_wdata),
    .wb_wd(wb_wd),  .wb_wreg(wb_wreg),
    .wb_wdata(wb_wdata)
);
        
endmodule
```

### 仿真验证
为了仿真验证，建立一个SOPC，其中包括之前的顶层模块和指令存储器ROM，顶层模块从指令存储器中读取指令，指令进入顶层模块开始执行

**sopc.v:**

```
`include "defines.v"
`include "openmips.v"
`include "inst_rom.v"
module sopc(
    input wire      clk,
    input wire      rst
);

//连接指令寄存器
wire[`InstAddrBus]  inst_addr;
wire[`InstBus]      inst;
wire                rom_ce;

//OpenMIPS real
openmips openmips0(
    .clk(clk),      .rst(rst),
    .rom_addr_o(inst_addr), .rom_data_i(inst),
    .rom_ce_o(rom_ce)
);

//instraction rom real
inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(inst_addr),   .inst(inst)
);

endmodule

```
**sopc_tb.v:**

```
`timescale 1ns/100ps
`include "sopc.v"
module sopc_tb();

reg CLOCK_50;
reg rst;

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, sopc_tb);
    CLOCK_50 = 1'b0;
    rst = `RstEnable;
    #195 rst= `RstDisable;
    #1000 $finish;
end

always #10 CLOCK_50=~CLOCK_50;

sopc sopc0(
    .clk(CLOCK_50),
    .rst(rst)
);
endmodule

```
#### 指令寄存器内内容
对于指令与对应的二进制字

```
ori $1,$0,0x1100
```
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/ori/md_images/ori_01.png)
转化为16进制为0x34011100

在inst_rom.data,写入要执行的指令

```
34011100
34020020
3403ff00
3404ffff
34011100
34210020
34214400
34210044
```
即为执行：
```
ori $1,$0,0x1100    # $1 = $0 | 0x1100 = 0x1100
ori $2,$0,0x0020    # $2 = $0 | 0x0020 = 0x0020
ori $3,$0,0xff00    # $3 = $0 | 0xff00 = 0xff00
ori $4,$0,0xffff    # $f = $0 | 0xffff = 0xffff
ori $1,$0,0x1100    # $1 = $0 | 0x1100 = 0x1100
ori $1,$1,0x0020    # $1 = $1 | 0x0020 = 0x1120
ori $1,$1,0x4400    # $1 = $1 | 0x4400 = 0x5520
ori $1,$1,0x0044    # $1 = $1 | 0x0044 = 0x5564
```
执行寄存器的值：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/ori/md_images/reg.png)

