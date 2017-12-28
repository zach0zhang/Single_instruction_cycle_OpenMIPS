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
`define EXE_ORI  6'b001101      //指令ori的指令码

//AluOp
`define EXE_OR_OP 8'b00100101
`define EXE_ORI_OP 8'b01011010
`define EXE_NOP_OP 8'b00000000
//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_NOP 3'b000

`define InstAddrBus 31:0        //ROM的地址总线宽度
`define InstBus 31:0            //ROM的数据总线宽度
`define InstMemNumLog2 17       //ROM地址线宽度 2^17=131072
`define InstMemNum 131071       //ROM的实际大小128KB

`define RegAddrBus 4:0          //Regfile模块的地址线宽度
`define RegBus 31:0             //Regfile模块的数据线宽度
`define NOPRegAddr 5'b00000     //空操作使用的寄存器地址
`define RegNum 32               //通用寄存器的数量
`define RegNumLog2 5            //寻址通用寄存器使用的地址位数