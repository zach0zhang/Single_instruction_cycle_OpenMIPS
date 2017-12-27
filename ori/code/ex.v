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
