# Single_instruction_cycle_OpenMIPS
通过学习《自己动手写CPU》，将书中实现的兼容MIPS32指令集架构的处理器——OpenMIPS（五级流水线结构），简化成单指令周期实现的处理器

### 根据以下顺序查看效果更佳：

1. [ori](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/tree/master/ori)：通过学习《自己动手写CPU》第四章，学习了MIPS五级流水线下的ori指令，b并简化五级流水线实现单指令周期下的ori指令。
2. [logic_shift_nop](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/tree/master/logic_shift_nop)：在完成了单指令周期的ori指令后，已经大致上实现了Verilog HDL语言设计的CPU系统框架和数据流，接下来的逻辑、移位操作和空指令，只是在实现的流程上增添指令
3. [move](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/tree/master/move):在之前实现的基础上继续增加了移动操作指令（增加了特殊寄存器HI和LO，以及对他们的操作）
4. [simple_arithmetic_1](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/tree/master/simple_arithmetic_1):在之前实现的基础上继续增加了15条简单算术操作指令（add、addi、addiu、addu、sub、subu、clo、clz、slt、slti、sltiu、sltu、mul、mult、multu）
5. [transfer](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/tree/master/transfer)：在之前实现的基础上继续增加了14条（实际上是12条）简单算术操作指令（jr、jalr、j、jar、b、bal、beq、bgez、bgezal、bgtz、blez、bltz、bltzal、bne） 
6. [Load_Store](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/tree/master/Load_Store)：在之前实现的基础上继续增加了加载、存储指令，系统结构上增加了访存模块和RAM 
7. [fpga](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/tree/master/fpag)：对EGO1开发板的外设（发光二极管、数码管、开关、按键）进行操作，对内存和外设实行统一编址 

### 系统结构图：
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/Load_Store/md_images/LS_struct.png)
### 增加了对外设IO模块后的系统结构图:
![image](https://github.com/zach0zhang/Single_instruction_cycle_OpenMIPS/blob/master/fpga/md_images/LS_struct.png)
每个子文件夹下均有相关详细解释
