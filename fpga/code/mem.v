`include "defines.v"

module mem(

	input wire					rst,
	
	//来自执行阶段的信息	
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
	input wire[`RegBus]			  wdata_i,
	input wire[`RegBus]           hi_i,
	input wire[`RegBus]           lo_i,
	input wire                    whilo_i,	
	
	input wire[`AluOpBus]        aluop_i,
	input wire[`RegBus]          mem_addr_i,
	input wire[`RegBus]          reg2_i,
	
	//送到回写阶段的信息
	output reg[`RegAddrBus]      wd_o,
	output reg                   wreg_o,
	output reg[`RegBus]			 wdata_o,
	output reg[`RegBus]          hi_o,
	output reg[`RegBus]          lo_o,
	output reg                   whilo_o,
	
	//来自memory / io的信息
	input wire[`RegBus]          mem_data_i,
	input wire[`RegBus]          io_data_i,
	
	//送到memory / io的信息
	output reg[`RegBus]          mem_addr_o,
	output wire					 mem_we_o,
	output reg[3:0]              mem_sel_o,
	output reg[`RegBus]          mem_data_o,
	output reg                   mem_ce_o,
	
	output reg[`RegBus]          io_addr_o,
    output wire                  io_we_o,
    output reg[`RegBus]          io_data_o,
	output reg                   io_ce_o	
	
	//output reg[15:0] led
);

wire[`RegBus] zero32;
reg          mem_we;
reg          io_we;
assign mem_we_o = mem_we ;
assign io_we_o = io_we;

assign zero32 = `ZeroWord;
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			wdata_o <= `ZeroWord;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
			whilo_o <= `WriteDisable;		
			mem_addr_o <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_o <= 4'b0000;
			mem_data_o <= `ZeroWord;
			mem_ce_o <= `ChipDisable;
			io_addr_o <= `ZeroWord;
            io_we <= `WriteDisable;
            io_data_o <= `ZeroWord;		
			io_ce_o <= `ChipDisable;	  
		end else begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			hi_o <= hi_i;
			lo_o <= lo_i;
			whilo_o <= whilo_i;		
			mem_we <= `WriteDisable;
			mem_addr_o <= `ZeroWord;
			mem_sel_o <= 4'b1111;
			mem_ce_o <= `ChipDisable;
			io_addr_o <= `ZeroWord;
            io_we <= `WriteDisable;
            io_data_o <= `ZeroWord;
			io_ce_o <= `ChipDisable;
			case (aluop_i)
				`EXE_LB_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
                        case (mem_addr_i[1:0])
                            2'b00:	begin
                                wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                                mem_sel_o <= 4'b1000;
                            end
                            2'b01:	begin
                                wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                                mem_sel_o <= 4'b0100;
                            end
                            2'b10:	begin
                                wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                                mem_sel_o <= 4'b0010;
                            end
                            2'b11:	begin
                                wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                                mem_sel_o <= 4'b0001;
                            end
                            default:	begin
                                wdata_o <= `ZeroWord;
                            end
                        endcase
                    end
				`EXE_LBU_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						2'b01:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b10:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b11:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LH_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase					
				end
				`EXE_LHU_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LW_OP:		begin
					if(mem_addr_i<=32'hffff0000) begin
					   mem_addr_o <= mem_addr_i;
                       mem_we <= `WriteDisable;
                       wdata_o <= mem_data_i;
                       mem_sel_o <= 4'b1111;
					   mem_ce_o <= `ChipEnable;
                    end
                    else begin
                        io_addr_o <= mem_addr_i;
                        io_we <= `WriteDisable;
                        wdata_o <= io_data_i;
                        io_ce_o<= `ChipEnable;		
				    end
				end
				`EXE_SB_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							mem_sel_o <= 4'b1000;
						end
						2'b01:	begin
							mem_sel_o <= 4'b0100;
						end
						2'b10:	begin
							mem_sel_o <= 4'b0010;
						end
						2'b11:	begin
							mem_sel_o <= 4'b0001;	
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase				
				end
				`EXE_SH_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {reg2_i[15:0],reg2_i[15:0]};
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							mem_sel_o <= 4'b1100;
						end
						2'b10:	begin
							mem_sel_o <= 4'b0011;
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase						
				end
				`EXE_SW_OP:		begin	
					if(mem_addr_i<=32'hffff0000)begin
					    mem_ce_o <= `ChipEnable;
                        mem_addr_o <= mem_addr_i;
                        mem_we <= `WriteEnable;
                        mem_data_o <= reg2_i;
                        mem_sel_o <= 4'b1111;
                    end
                    else begin
                        io_ce_o<= `ChipEnable;
                        io_addr_o <=  mem_addr_i;
                        io_we <= `WriteEnable;
                        io_data_o <= reg2_i;
                       // led<=16'hffff;
                    end//led<=16'h8800;//		
				end
				default:	begin
				end
			endcase	
		end    //if
	end      //always
			

endmodule