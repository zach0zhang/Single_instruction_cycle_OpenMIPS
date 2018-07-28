在实现访存指令的基础上，增加了使用Load/Store指令对fpga开发板上的外设(发光二极管、数码管、按键、开关)读写的功能

使用fpga开发板为EGO1

## 将外设跟内存统一编址
将32位内存地址的后3位划给外设

即地址为0000_0000~ffff_efff依旧作为普通内存地址，使用Load/Store进行内存的读写

而地址为ffff_f000~ffff_ffff作为外设地址，使用Load/Store指令进行对外设的读写


内存示意图如下：
![image](F:\笔记\Verilog\fpga/1.png)
从图中可以看出来对应的地址分别是

外设 | 地址
---|---
LED（发光二极管） | fffff000
SW（按键） | fffff010
SEG（数码管）|fffff020
BUTTON(按键）|fffff030

define.v:

```
`define LED 32'hFFFF_F000
`define SW  32'hFFFF_F010
`define SEG 32'hFFFF_F020
`define BTN 32'hFFFF_F030
```
## 更改系统结构
增加IO控制模块与访存模块相连，增加了MEM访存模块与IO模块的数据和地址线

通过在WB访存模块中对要访问的地址进行判断，决定要对IO或者data_ram模块两者之一进行操作

增加IO模块后的系统结构图：
![image](F:\笔记\Verilog\fpga/LS_Struct.png)

### 1. 增加IO模块
IO模块代码：

```
`include "defines.v"
module io(
    input	wire						clk,
	input wire							ce,
	input wire							we,
	input wire[`DataAddrBus]			addr,
	input wire[`DataBus]				data_i,
	output reg[`DataBus]				data_o,
	input wire[15:0]                   sw,
	input wire[3:0]                    btn,
	output reg[15:0]                   led,
	output reg[31:0]                   seg
    );
    
    always@(posedge clk)begin
        if(ce==`ChipDisable)begin
            //data_o <= ZeroWord;
           // led<=16'h000F;
        end
        else if(we == `WriteEnable) begin
            if(addr== `LED)begin //led
                led<=data_i[15:0];//data_i[15:0];
            end 
            else if(addr == `SEG)begin
                seg <= data_i;
            end
            else
                led<=16'h0011;
        end
    end
    
    always @ (*) begin
            if (ce == `ChipDisable) begin
                data_o <= `ZeroWord;
          end else if(we == `WriteDisable) begin
                if(addr== `SW)//sw
                    data_o <= {16'b0,sw[15:0]};
                else if(addr == `BTN)
                    data_o <= {28'b0,btn[3:0]};
            end else begin
                    data_o <= `ZeroWord;
            end
        end
endmodule
```
### 2. 修改MEM访存模块
增加MEM访存模块对内存地址的判断，如果是00000000~ffffefff则使能data_ram模块，否侧使能IO模块，并进行相应地址和数据的传输工作：

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
	
	//来自memory / io的信息
	input wire[`RegBus]          mem_data_i,
	input wire[`RegBus]          io_data_i,
	
	//送到memory / io的信息
	output reg[`RegBus]          mem_addr_o,
	output wire					 mem_we_o,
	output reg[3:0]              mem_sel_o,
	output reg[`RegBus]          mem_data_o,
	output reg                   mem_ce_o,
	
	output reg[`RegBus]          io_addr_o,
    output wire                  io_we_o,
    output reg[`RegBus]          io_data_o,
	output reg                   io_ce_o	
	
);

wire[`RegBus] zero32;
reg          mem_we;
reg          io_we;
assign mem_we_o = mem_we ;
assign io_we_o = io_we;

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
			io_addr_o <= `ZeroWord;
            io_we <= `WriteDisable;
            io_data_o <= `ZeroWord;		
			io_ce_o <= `ChipDisable;	  
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
			io_addr_o <= `ZeroWord;
            io_we <= `WriteDisable;
            io_data_o <= `ZeroWord;
			io_ce_o <= `ChipDisable;
			case (aluop_i)
				`EXE_LB_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
                        case (mem_addr_i[1:0])
                            2'b00:	begin
                                wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                                mem_sel_o <= 4'b1000;
                            end
                            2'b01:	begin
                                wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                                mem_sel_o <= 4'b0100;
                            end
                            2'b10:	begin
                                wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                                mem_sel_o <= 4'b0010;
                            end
                            2'b11:	begin
                                wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                                mem_sel_o <= 4'b0001;
                            end
                            default:	begin
                                wdata_o <= `ZeroWord;
                            end
                        endcase
                    end
				`EXE_LBU_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						2'b01:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b10:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b11:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LH_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase					
				end
				`EXE_LHU_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LW_OP:		begin
					if(mem_addr_i<=32'hffff0000) begin
					   mem_addr_o <= mem_addr_i;
                       mem_we <= `WriteDisable;
                       wdata_o <= mem_data_i;
                       mem_sel_o <= 4'b1111;
					   mem_ce_o <= `ChipEnable;
                    end
                    else begin
                        io_addr_o <= mem_addr_i;
                        io_we <= `WriteDisable;
                        wdata_o <= io_data_i;
                        io_ce_o<= `ChipEnable;		
				    end
				end
				`EXE_SB_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							mem_sel_o <= 4'b1000;
						end
						2'b01:	begin
							mem_sel_o <= 4'b0100;
						end
						2'b10:	begin
							mem_sel_o <= 4'b0010;
						end
						2'b11:	begin
							mem_sel_o <= 4'b0001;	
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase				
				end
				`EXE_SH_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {reg2_i[15:0],reg2_i[15:0]};
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase						
				end
				`EXE_SW_OP:		begin	
					if(mem_addr_i<=32'hffff0000)begin
					    mem_ce_o <= `ChipEnable;
                        mem_addr_o <= mem_addr_i;
                        mem_we <= `WriteEnable;
                        mem_data_o <= reg2_i;
                        mem_sel_o <= 4'b1111;
                    end
                    else begin
                        io_ce_o<= `ChipEnable;
                        io_addr_o <=  mem_addr_i;
                        io_we <= `WriteEnable;
                        io_data_o <= reg2_i;
                    end		
				end
				default:	begin
				end
			endcase	
		end    //if
	end      //always
			

endmodule
```
## 3. 修改顶层文件的连接关系并和外设相连
这里仅放出数码管驱动相关代码，其他细节上的修改请直接参考源文件
数码管驱动(show_seg0):

```
module show_seg(
    input clk,
    input rst,
    input [31:0]add_num,
    output reg[7:0]seg_code,
    output reg[3:0]an
    );
    parameter T100MS = 27'd10_000_000;// 0.1s
    parameter T1MS=14'd10_000;
    
    reg[26:0] cnt;
    reg[7:0] add_ge,add_shi,add_bai;
   
    always @( posedge clk or posedge rst )
        if( rst )
            cnt <= 27'd0;
        else if( cnt == T100MS )begin
            cnt <= 27'd0;
            add_ge<=add_num%10;
            add_shi<=(add_num-add_ge)/10%10;
            add_bai<=(add_num-10*add_shi-add_ge)/100;
        end    
        else 
            cnt <= cnt + 1'b1;
     
     reg[14:0]count;       
     always @(posedge clk or posedge rst)
        if( rst )begin
             count <= 14'b0;
             an <= 4'd8;
        end
        else if( count == T1MS)begin
            count <= 14'd0;
            if(an==4'd1)
                an<= 4'd8;
            else
                an<=an>>1;
        end
        else
            count <= count + 1'b1;   
            
       parameter _0 = 8'hc0,_1 = 8'hf9,_2 = 8'ha4,_3 = 8'hb0,
                 _4 = 8'h99,_5 = 8'h92,_6 = 8'h82,_7 = 8'hf8,
                 _8 = 8'h80,_9 = 8'h90;
       reg [7:0]seg_data;
       always @( posedge clk or posedge rst )
           if( rst )
               seg_code <= 8'hff;
           else begin
               case( an )
                   4'd1:seg_data<=8'd0;
                   4'd2:seg_data<=add_bai;
                   4'd4:seg_data<=add_shi;
                   4'd8:seg_data<=add_ge;
                   default:seg_data<=8'hff;
                endcase
               case( seg_data )
                   8'd0:seg_code <= ~_0;
                   8'd1:seg_code <= ~_1;
                   8'd2:seg_code <= ~_2;
                   8'd3:seg_code <= ~_3;
                   8'd4:seg_code <= ~_4;
                   8'd5:seg_code <= ~_5;
                   8'd6:seg_code <= ~_6;
                   8'd7:seg_code <= ~_7;
                   8'd8:seg_code <= ~_8;
                   8'd9:seg_code <= ~_9;
                   default:
                       seg_code <= 8'hff;
               endcase   
            end
            
                    
endmodule

```

## 测试代码
inst_rom.S:

```
   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
   lui  $3,0xffff
   ori  $3,$3,0xf000
   ori  $2,$0,0x0001
   
_loop:   
   lw   $4,0x10($3)
   andi $5,$4,0x00ff
   srl  $4,$4,8
   lw	$6,0x30($3)
   ori  $2,$0,0x0001
   beq  $6,$2,s1
   ori  $2,$0,0x0002
   beq  $6,$2,s2
   ori  $2,$0,0x0004
   beq  $6,$2,s3
   j s4
s1:
   addu $1,$5,$4
   j s4
s2:
   subu $1,$5,$4
   j s4
s3:
   mul  $1,$5,$4
s4:
   sw 	$1,0x0($3)
   sw	$1,0x20($3)
   j _loop
   nop
```

通过对两个八位的开关进行二进制值的捕获，用按键来选择加、减或者乘，在数码管和led灯上以二进制形式展示结果

![image](F:\笔记\Verilog\fpga/3.png)