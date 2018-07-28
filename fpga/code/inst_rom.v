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
    /*
        inst_mem[0]<=32'h3c03ffff;
        inst_mem[1]<=32'h3463f000;
        inst_mem[2]<=32'h8c640010;
        inst_mem[3]<=32'h308500ff;
        inst_mem[4]<=32'h00042202;
        inst_mem[5]<=32'h00a40821;
        inst_mem[6]<=32'hac610000;
        inst_mem[7]<=32'hac610020;
        inst_mem[8]<=32'h08000002;
        inst_mem[9]<=32'h00000000;
        inst <= `ZeroWord;
        */
    end else begin
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
    end
end

endmodule