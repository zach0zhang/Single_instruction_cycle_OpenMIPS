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
//连接RAM
wire mem_we_i;
wire[`RegBus] mem_addr_i;
wire[`RegBus] mem_data_i;
wire[`RegBus] mem_data_o;
wire[3:0] mem_sel_i;  
wire mem_ce_i;  

//OpenMIPS real
openmips openmips0(
    .clk(clk),      .rst(rst),
    .rom_addr_o(inst_addr), .rom_data_i(inst),
    .rom_ce_o(rom_ce),
	
	.ram_we_o(mem_we_i),
	.ram_addr_o(mem_addr_i),
	.ram_sel_o(mem_sel_i),
	.ram_data_o(mem_data_i),
	.ram_data_i(mem_data_o),
	.ram_ce_o(mem_ce_i)	
);

//instraction rom real
inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(inst_addr),   .inst(inst)
);

// data ram real
data_ram data_ram0(
	.clk(clk),
	.we(mem_we_i),
	.addr(mem_addr_i),
	.sel(mem_sel_i),
	.data_i(mem_data_i),
	.data_o(mem_data_o),
	.ce(mem_ce_i)		
);
	
endmodule