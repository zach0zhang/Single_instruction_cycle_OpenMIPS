`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/01 15:52:06
// Design Name: 
// Module Name: io
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module io(
    input	wire						clk,
	input wire							ce,
	input wire							we,
	input wire[`DataAddrBus]			addr,
	input wire[`DataBus]				data_i,
	output reg[`DataBus]				data_o,
	input wire[15:0]                   sw,
	input wire[3:0]                    btn,
	output reg[15:0]                   led,
	output reg[31:0]                   seg
    );
    
    always@(posedge clk)begin
        if(ce==`ChipDisable)begin
            //data_o <= ZeroWord;
           // led<=16'h000F;
        end
        else if(we == `WriteEnable) begin
            if(addr== `LED)begin //led
                led<=data_i[15:0];//data_i[15:0];
            end 
            else if(addr == `SEG)begin
                seg <= data_i;
            end
            else
                led<=16'h0011;
        end
    end
    
    always @ (*) begin
            if (ce == `ChipDisable) begin
                data_o <= `ZeroWord;
          end else if(we == `WriteDisable) begin
                if(addr== `SW)//sw
                    data_o <= {16'b0,sw[15:0]};
                else if(addr == `BTN)
                    data_o <= {28'b0,btn[3:0]};
            end else begin
                    data_o <= `ZeroWord;
            end
        end
endmodule
