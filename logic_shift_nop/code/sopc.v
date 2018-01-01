`include "defines.v"
`include "openmips.v"
`include "inst_rom.v"
module sopc(
    input wire      clk,
    input wire      rst
);

//Á¬½ÓÖ¸Áî¼Ä´æÆ÷
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