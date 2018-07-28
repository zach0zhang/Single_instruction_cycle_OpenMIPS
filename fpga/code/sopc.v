`include "defines.v"
`include "openmips.v"
`include "inst_rom.v"
module sopc(
    input wire      clk,
    input wire      rst,
    input wire[15:0] sw,
    input  [3:0] btn,
    output [15:0] led,
    output [3:0] an,
    output [7:0] seg_code
);

//wire [15:0] led1;

reg [31:0] timer; 
reg clk_out; 
wire rst_out; 
assign rst_out=~rst;

//连接指令寄存器
wire[`InstAddrBus]  inst_addr;
wire[`InstBus]      inst;
wire                rom_ce;
//连接RAM / IO
wire mem_we_i;
wire[`RegBus] mem_addr_i;
wire[`RegBus] mem_data_i;
wire[`RegBus] mem_data_o;
wire[3:0] mem_sel_i;  
wire mem_ce_i;

wire io_we_i;
wire[`RegBus] io_addr_i;
wire[`RegBus] io_data_i;
wire[`RegBus] io_data_o;
wire io_ce_i;  

wire [31:0] seg;

//OpenMIPS real
openmips openmips0(
    .clk(clk_out),      .rst(rst_out),
    .rom_addr_o(inst_addr), .rom_data_i(inst),
    .rom_ce_o(rom_ce),
	
	.ram_we_o(mem_we_i),
	.ram_addr_o(mem_addr_i),
	.ram_sel_o(mem_sel_i),
	.ram_data_o(mem_data_i),
	.ram_data_i(mem_data_o),
	.ram_ce_o(mem_ce_i),
	
	 .io_addr_o(io_addr_i),
     .io_we_o(io_we_i),
     .io_data_o(io_data_i),	
     .io_data_i(io_data_o),
	 .io_ce_o(io_ce_i)
	
	//.led(led) ///
);

//instraction rom real
inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(inst_addr),   .inst(inst)
);

// data ram real
data_ram data_ram0(
	.clk(clk_out),
	.we(mem_we_i),
	.addr(mem_addr_i),
	.sel(mem_sel_i),
	.data_i(mem_data_i),
	.data_o(mem_data_o),
	.ce(mem_ce_i)		
);

io io0(
    .clk(clk_out),
    .we(io_we_i),
    .addr(io_addr_i),
    .data_i(io_data_i),
    .data_o(io_data_o),
    .ce(io_ce_i),
    .sw(sw),
    .btn(btn),
    .led(led),
    .seg(seg)
);

 show_seg show_seg0(
    .clk(clk),
    .rst(rst_out),
    .add_num(seg),
    .seg_code(seg_code),
    .an(an)
 );
always @(posedge clk or negedge rst)   //检测时钟的上升沿和复位的下降沿
    begin
      if (~rst)                          //复位信号低有效
          clk_out<=1'b0;                                          
      else if (timer == 32'd99)    //计数器计到1us，
          clk_out <= 1'b1;                                   
      else if (timer == 32'd199)   //计数器计到2us，
          clk_out <= !clk_out;                        
    end
    


//===========================================================================
// 计数器计数:循环计数0~4秒
//===========================================================================
  always @(posedge clk or negedge rst)    //检测时钟的上升沿和复位的下降沿
    begin
      if (~rst)                           //复位信号低有效
          timer <= 0;                       //计数器清零
      else if (timer == 32'd199)    
          timer <= 0;                       //计数器清零
      else
		    timer <= timer + 1'b1;            //计数器加1
    end	
endmodule