`define RstEnable 1'b1          //复位使能
`define RstDisable 1'b0         //复位除能
`define WriteEnable 1'b1        //写使能
`define WriteDisable 1'b0       //写除能
`define ReadEnable 1'b1         //读使能
`define ReadDisable 1'b0        //读除能
`define InstValid 1'b0          //指令有效
`define InstInvalid 1'b1        //指令无效
`define ChipEnable 1'b1         //芯片使能
`define ChipDisable 1'b0        //芯片禁止
`define ZeroWord 32'h00000000   //32位数字0
`define AluOpBus 7:0            //译码阶段输出操作子类型数据宽度
`define AluSelBus 2:0           //译码阶段输出操作类型数据宽度


//指令
`define EXE_AND  6'b100100      //指令and的功能码
`define EXE_OR   6'b100101      //指令ori的功能码
`define EXE_XOR 6'b100110       //指令xor的功能码
`define EXE_NOR 6'b100111       //指令nor的功能码
`define EXE_ANDI 6'b001100      //指令andi的指令码
`define EXE_ORI  6'b001101      //指令ori的指令码
`define EXE_XORI 6'b001110      //指令xori的指令码
`define EXE_LUI 6'b001111       //指令lui的指令码


`define EXE_SLL  6'b000000      //指令sll的功能码
`define EXE_SLLV  6'b000100     //指令sllv的功能码
`define EXE_SRL  6'b000010      //指令srl的功能码
`define EXE_SRLV  6'b000110     //指令srlv的功能码
`define EXE_SRA  6'b000011      //指令sra的功能码
`define EXE_SRAV  6'b000111     //指令srav的功能码
`define EXE_SYNC  6'b001111     //指令sync的功能码
`define EXE_PREF  6'b110011     //指令pref的功能码

`define EXE_MOVZ  6'b001010     //指令MOVZ的功能码
`define EXE_MOVN  6'b001011     //指令MOVN的功能码
`define EXE_MFHI  6'b010000     //指令MFHI的功能码
`define EXE_MTHI  6'b010001     //指令MTHI的功能码
`define EXE_MFLO  6'b010010     //指令MFLO的功能码
`define EXE_MTLO  6'b010011     //指令MTLO的功能码

`define EXE_NOP 6'b000000  	     //指令nop的功能码
`define SSNOP 32'b00000000000000000000000001000000 //指令SSNOP



`define EXE_SPECIAL_INST 6'b000000  //指令special的指令码

//AluOp
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100   

`define EXE_SLL_OP  8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111

`define EXE_MOVZ_OP  8'b00001010
`define EXE_MOVN_OP  8'b00001011
`define EXE_MFHI_OP  8'b00010000
`define EXE_MTHI_OP  8'b00010001
`define EXE_MFLO_OP  8'b00010010
`define EXE_MTLO_OP  8'b00010011

`define EXE_NOP_OP 8'b00000000
//AluSel
`define EXE_RES_LOGIC 3'b001

`define EXE_RES_SHIFT 3'b010
`define EXE_RES_NOP 3'b000
`define EXE_RES_MOVE 3'b011	

`define InstAddrBus 31:0        //ROM的地址总线宽度
`define InstBus 31:0            //ROM的数据总线宽度
`define InstMemNumLog2 17       //ROM地址线宽度 2^17=131072
`define InstMemNum 131071       //ROM的实际大小128KB

`define RegAddrBus 4:0          //Regfile模块的地址线宽度
`define RegBus 31:0             //Regfile模块的数据线宽度
`define NOPRegAddr 5'b00000     //空操作使用的寄存器地址
`define RegNum 32               //通用寄存器的数量
`define RegNumLog2 5            //寻址通用寄存器使用的地址位数