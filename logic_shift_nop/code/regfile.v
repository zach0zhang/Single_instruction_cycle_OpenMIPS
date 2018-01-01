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