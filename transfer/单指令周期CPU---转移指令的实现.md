## 指令介绍
- 跳转指令：jr、jalr、j、jar
- 分支指令b、bal、beq、bgez、bgezal、bgtz、blez、bltz、bltzal、bne
### 跳转指令
指令格式：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/transfer/md_images/jump.png)
- **jr(功能码为6'b001000)**:用法：jr rs，作用：pc <- rs 将地址为rs的通用寄存器的值赋给寄存器PC，作为新的指令地址
- **jalr(功能码为6'b001001)**：用法：jalr rs 或者 jalr rd,rs 作用：rd <- return_address,pc <- rs,将地址为rs的通用寄存器的值赋给寄存器PC，作为新的指令地址，同时将跳转指令后面第2条指令的地址作为返回地址保存到地址为rd的通用寄存器，**如果没有在指令中指明rd，那么默认将返回地址保存到寄存器$31**
- **j(指令码为6'b000010)**：用法：j target，作用：pc <- (pc+4)[31,28]||target||'00',转移到新的指令地址，其中新地址的低28位是target左移两位后的值，新指令地址高4位是后一指令的高四位
    
    **因为处理器按照字节寻址，二指令存储器每个地址是一个32bit字，所以要给指令中的立即数乘4，即左移两位**

- **jal(指令码为6'b000011)**：用法：jal target，作用：pc <- (pc+4)[31,28]||target||'00',转移到新的指令地址，其中新地址的低28位是target左移两位后的值，新指令地址高4位是后一指令的高四位,**jal指令要将跳转指令后面的一条指令地址(pc+4)写入$31寄存器**
### 分支指令
指令格式：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/transfer/md_images/b.png)
- 由指令格式可以看出：
    
    beq、b、bgtz、blez、bne这5条指令可以直接依据指令中的指令码进行判断是哪一条指令，bltz、bltzal、bgez、bgezal、bal这5条指令指令码相同，依据指令中16\~20bit的值进一步判断是哪一条指令

    所有分支指令的第0\~15bit存储的都是offset，如果发生转移，那么将offset左移2位，并符号扩展至32位
    
    转移目标地址 = (signed_extend)(offset||'00')+(pc+4)
- **beq(指令码为6'b000100)**：用法：beq rs,rt,offset，作用：if rs = rt then branch,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行比较，如果相等，则发生转移
- **b(指令码为6'b000100，且16\~25bit为0)**：用法：b offset，作用：无条件转移，**即beq指令的rs,rt都为0时的情况，实现时不需要特意实现b指令，只需要实现beq即可**
- **bgtz(指令码为6'b000111)**：用法：bgtz rs,offset，作用：if rs > 0 then branch
- **blez(指令码6'b000110)**：用法：blez rs,offset，作用：if rs <= 0 then branch
- **bne(指令码6'b000101)**：用法：bne rs,rt,offset，作用:if rs != rt then branch
- **bltz(指令码为REGIMM,且第16\~20bit为5'b00000)**:用法：bltz rs,offset，作用：if rs < 0 then branch
- ** bltzal(指令码为REGIMM,且第16\~20bit为5'b10000)**:用法：bltzal rs,offset，作用：if rs < 0 then branch,**并且将指令后面的指令地址作为返回地址，保存到通用寄存器$31**
- **bgez(指令码为REGIMM,且第16\~20bit为5'b00001)**：用法：bgez rs,offset，作用：if rs >= 0 then branch
- **bgezal(指令码为REGIMM,且第16\~20bit为5'b10001)**:用法：bgezal rs,offset，作用：if rs >= 0 then branch,**并且将指令后面的指令地址作为返回地址，保存到通用寄存器$31**
- **bal(指令码为REGIMM,且第21\~25bit为0，第16\~20bit为5'b10001)**:用法：bal offset，作用：无条件转移，并且将指令后面的指令地址作为返回地址，保存到通用寄存器$31，**bal是bgezal指令的特殊情况，即bgezal指令的rs为0，不用特意实现这个指令**
## 修改系统结构
增加了PC和ID模块的两个接口，用来表示是否跳转和跳转的指令地址，也增加了ID模块和EX模块的一个借口，用来表示将要保存的指令地址
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/transfer/md_images/transfer_struct.png)

## 代码修改
### 1. 增加宏定义

```
`define Branch 1'b1				//发生转移
`define NotBranch 1'b0			//不发生转移

`define EXE_J  6'b000010		//指令J的功能码
`define EXE_JAL  6'b000011		//指令JAL的功能码
`define EXE_JALR  6'b001001		//指令JALR的功能码
`define EXE_JR  6'b001000		//指令JR的功能码
`define EXE_BEQ  6'b000100		//指令BEQ的指令码
`define EXE_BGEZ  5'b00001		//指令BGEZ第16~20bit
`define EXE_BGEZAL  5'b10001	//指令BGEZAL第16~20bit
`define EXE_BGTZ  6'b000111		//指令BGTZ的指令码
`define EXE_BLEZ  6'b000110		//指令BLEZ的指令码
`define EXE_BLTZ  5'b00000		//指令BLTZ第16~20bit
`define EXE_BLTZAL  5'b10000	//指令BLTZAL第16~20bit
`define EXE_BNE  6'b000101		//指令BNE的指令码

`define EXE_REGIMM_INST 6'b000001	//REGIMM类的指令码

`define EXE_J_OP  8'b01001111
`define EXE_JAL_OP  8'b01010000
`define EXE_JALR_OP  8'b00001001
`define EXE_JR_OP  8'b00001000
`define EXE_BEQ_OP  8'b01010001
`define EXE_BGEZ_OP  8'b01000001
`define EXE_BGEZAL_OP  8'b01001011
`define EXE_BGTZ_OP  8'b01010100
`define EXE_BLEZ_OP  8'b01010011
`define EXE_BLTZ_OP  8'b01000000
`define EXE_BLTZAL_OP  8'b01001010
`define EXE_BNE_OP  8'b01010010
```

### 2. 修改取指阶段PC阶段
- 增加了两个输入接口：用来接收从译码阶段ID模块传来的信息
    
    branch_flag_i：用来标识是否发生转移

    branch_target_address_i：转移到的目标地址

```
always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= 32'h00000000;
		end else if(stall[0] == `NoStop) begin
		  	if(branch_flag_i == `Branch) begin
					pc <= branch_target_address_i;
				end else begin
		  		pc <= pc + 4'h4;
		  	end
		end
	end
```


### 3. 修改译码阶段ID模块
根据指令的指令码和功能码，以及指令有关bit位的特点来判断是哪一条指令
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/transfer/md_images/select.png)

```
wire[`RegBus] pc_plus_4;
wire[`RegBus] imm_sll2_signedext; 

assign pc_plus_4 = pc_i +4;
assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };  

...
    `EXE_JR: begin
		wreg_o <= `WriteDisable;		
		aluop_o <= `EXE_JR_OP;
		alusel_o <= `EXE_RES_JUMP_BRANCH;   
		reg1_read_o <= 1'b1;	
		reg2_read_o <= 1'b0;
		link_addr_o <= `ZeroWord;
		branch_target_address_o <= reg1_o;
	    branch_flag_o <= `Branch;
		instvalid <= `InstValid;	
	end
	`EXE_JALR: begin
		wreg_o <= `WriteEnable;		
		aluop_o <= `EXE_JALR_OP;
		alusel_o <= `EXE_RES_JUMP_BRANCH;   
		reg1_read_o <= 1'b1;	
		reg2_read_o <= 1'b0;
		if(inst_i[15:11] == 5'b00000)begin //如果没有指定保存寄存器，则默认保存到$31
		    wd_o <= 5'b11111;
		end
		else begin
		    wd_o <= inst_i[15:11];
		end
		link_addr_o <= pc_plus_4;
		branch_target_address_o <= reg1_o;
		branch_flag_o <= `Branch;
		instvalid <= `InstValid;	
	end		
	...
`EXE_J:			begin
	wreg_o <= `WriteDisable;		
	aluop_o <= `EXE_J_OP;
	alusel_o <= `EXE_RES_JUMP_BRANCH; 
    reg1_read_o <= 1'b0;	
	reg2_read_o <= 1'b0;
	link_addr_o <= `ZeroWord;
	branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
	branch_flag_o <= `Branch;	  	
	instvalid <= `InstValid;	
end
`EXE_JAL:			begin
	wreg_o <= `WriteEnable;		
	aluop_o <= `EXE_JAL_OP;
	alusel_o <= `EXE_RES_JUMP_BRANCH; 
	reg1_read_o <= 1'b0;	
	reg2_read_o <= 1'b0;
	wd_o <= 5'b11111;	
	link_addr_o <= pc_plus_4 ;
	branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
	branch_flag_o <= `Branch;		  	
	instvalid <= `InstValid;	
end
`EXE_BEQ:			begin
	wreg_o <= `WriteDisable;		
	aluop_o <= `EXE_BEQ_OP;
	alusel_o <= `EXE_RES_JUMP_BRANCH; 
	reg1_read_o <= 1'b1;	
	reg2_read_o <= 1'b1;
	instvalid <= `InstValid;	
	if(reg1_o == reg2_o) begin
	    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
	    branch_flag_o <= `Branch;	  	
    end
end
`EXE_BGTZ:			begin
	wreg_o <= `WriteDisable;		
    aluop_o <= `EXE_BGTZ_OP;
    alusel_o <= `EXE_RES_JUMP_BRANCH; 
	reg1_read_o <= 1'b1;	
	reg2_read_o <= 1'b0;
	instvalid <= `InstValid;	
	if((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord)) begin
	    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
		branch_flag_o <= `Branch;	  	
	end
end
`EXE_BLEZ:			begin
	wreg_o <= `WriteDisable;		
	aluop_o <= `EXE_BLEZ_OP;
	alusel_o <= `EXE_RES_JUMP_BRANCH; 
	reg1_read_o <= 1'b1;	
	reg2_read_o <= 1'b0;
	instvalid <= `InstValid;	
	if((reg1_o[31] == 1'b1) || (reg1_o == `ZeroWord)) begin
		branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
		branch_flag_o <= `Branch;	  	
	end
end
`EXE_BNE:			begin
	wreg_o <= `WriteDisable;		
	aluop_o <= `EXE_BLEZ_OP;
	alusel_o <= `EXE_RES_JUMP_BRANCH; 
	reg1_read_o <= 1'b1;	
    reg2_read_o <= 1'b1;
	instvalid <= `InstValid;	
	if(reg1_o != reg2_o) begin
	    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
	    branch_flag_o <= `Branch;		  	
	end
end
`EXE_REGIMM_INST:		begin
	case (op4)
		`EXE_BGEZ:	begin
			wreg_o <= `WriteDisable;		
			aluop_o <= `EXE_BGEZ_OP;
		  	alusel_o <= `EXE_RES_JUMP_BRANCH; 
			reg1_read_o <= 1'b1;	
			reg2_read_o <= 1'b0;
		  	instvalid <= `InstValid;	
		  	if(reg1_o[31] == 1'b0) begin
			    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    branch_flag_o <= `Branch;	  	
			end
		end
		`EXE_BGEZAL:		begin
			wreg_o <= `WriteEnable;		
			aluop_o <= `EXE_BGEZAL_OP;
		    alusel_o <= `EXE_RES_JUMP_BRANCH; 
			reg1_read_o <= 1'b1;	
			reg2_read_o <= 1'b0;
			link_addr_o <= pc_plus_4; 
		  	wd_o <= 5'b11111;  	
			instvalid <= `InstValid;
			if(reg1_o[31] == 1'b0) begin
			    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    branch_flag_o <= `Branch;
			end
		end
		`EXE_BLTZ:		begin
			wreg_o <= `WriteDisable;		
			aluop_o <= `EXE_BGEZAL_OP;
		  	alusel_o <= `EXE_RES_JUMP_BRANCH; 
			reg1_read_o <= 1'b1;	
			reg2_read_o <= 1'b0;
		  	instvalid <= `InstValid;	
		  	if(reg1_o[31] == 1'b1) begin
		  	    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;branch_flag_o <= `Branch;		
		  	end
		end
		`EXE_BLTZAL:		begin
			wreg_o <= `WriteEnable;		
			aluop_o <= `EXE_BGEZAL_OP;
		  	alusel_o <= `EXE_RES_JUMP_BRANCH; 
			reg1_read_o <= 1'b1;	
			reg2_read_o <= 1'b0;
		  	link_addr_o <= pc_plus_4;	
		  	wd_o <= 5'b11111; 
		    instvalid <= `InstValid;
		  	if(reg1_o[31] == 1'b1) begin
			    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    branch_flag_o <= `Branch;
			end
		end
		...
```
### 4. 修改执行阶段EX模块
转移指令在执行阶段里，只需要把要保存的指令地址作为最终结果传递到下一执行阶段保存到目标寄存器即可
```
...
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
		`EXE_RES_JUMP_BRANCH:	begin //转移指令
	 		wdata_o <= link_address_i;
	 	end	
	 	...
```

## 测试
编写指令测试程序进行测试：

```
   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
   ori  $1,$0,0x0010   # (1) $1 = 0x10                
   jr   $1	       # (2) jump to 0x10
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x10
   ori  $1,$0,0x0020   # (3) $1 = 0x20               
   jalr $2,$1	       # (4) jump to 0x20,$2 = 0x18
   ori  $1,$0,0x0002   # $1 = 0x2
   
   .org 0x20
   ori  $1,$0,0x0003   # (5) $1 = 0x3
   jal  0x30	       # (6) jmup to 0x30,$31 =0x28
   ori  $1,$0,0x0002   # $1 = 0x2
   
   .org 0x30 
   ori  $1,$0,0x0004   # (7) $1 = 0x4
   j  0x40	       # (8) jmup to 0x40
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x40          
   ori  $1,$0,0x0005   # (9) $1 = 0x5   
   b   s1	       # (10) jump to s1
   ori  $1,$0,0x0002   # $1 = 0x2
  
   .org 0x50
s1:
   ori  $1,$0,0x0006   # (11) $1 = 0x6
   bal  s2 	       # (12) jump to s2,$31 = 0x58
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x60
s2:
   ori  $1,$0,0x0007   # (13) $1 = 0x7
   ori  $2,$0,0x0007   # (14) $2 = 0x7
   ori  $3,$0,0x8000   # (15) $3 = 0x8000
   beq  $1,$2,s3       # (16) $1 == $2 ==> jump to s3
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x80
s3:
   ori  $1,$0,0x0008   # (17) $1 = 0x8
   bgtz $1,s4          # (18) $1(0x8) > 0 ==> jump to s4
   ori  $1,$0,0x0002   # $1 = 0x2  

   .org 0x90
s4:
   ori  $1,$0,0x0009   # (19) $1 = 0x9
   bgez $1,s5          # (20) $1(0x9) > 0 ==> jump to s5
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x100
s5:
   ori  $1,$0,0x000a   # (21) $1 = 0xa
   sll  $3,16          # (22) $3 = 0x8000<<16 ==> $3 = 0x80000000
   bgezal $3,s6        # (23) $3(0x80000000) <0 ==> not jump
   ori  $1,$0,0x000b   # (24) $1 = 0xb
   bltz $3,s6          # (25) $3(0x80000000) <0 ==> jump to s6
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x120
s6:
   ori  $1,$0,0x000c   # (26) $1 = 0xc
   blez $2,s7          # (27) $2(0x7) > 0 ==> not jump
   ori  $1,$0,0x000d   # (28) $1 = 0xd
   bne  $1,$0,s7       # (29) $1 != $0 ==> jump to s7
   ori  $1,$0,0x0002   # $1 = 0x2
   nop      

   .org 0x140
s7:
   ori  $1,$0,0x000e   # (30) $1 = 0xe
   bltzal $3,s8        # (31) $3(0x80000000) <0 ==> jump to s8, $31 = 0x148
   ori  $1,$0,0x0002   # $1 = 0x2 

   .org 0x150
s8:
   ori  $1,$0,0x000f   # (32) $1 = 0xf
   nop   
    
_loop:
   j _loop
   nop

```
测试结果：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/transfer/md_images/test.png)
