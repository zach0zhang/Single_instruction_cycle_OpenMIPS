module show_seg(
    input clk,
    input rst,
    input [31:0]add_num,
    output reg[7:0]seg_code,
    output reg[3:0]an
    );
    parameter T100MS = 27'd10_000_000;// 0.1s
    parameter T1MS=14'd10_000;
    
    reg[26:0] cnt;
    reg[7:0] add_ge,add_shi,add_bai;
   
    always @( posedge clk or posedge rst )
        if( rst )
            cnt <= 27'd0;
        else if( cnt == T100MS )begin
            cnt <= 27'd0;
            add_ge<=add_num%10;
            add_shi<=(add_num-add_ge)/10%10;
            add_bai<=(add_num-10*add_shi-add_ge)/100;
        end    
        else 
            cnt <= cnt + 1'b1;
     
     reg[14:0]count;       
     always @(posedge clk or posedge rst)
        if( rst )begin
             count <= 14'b0;
             an <= 4'd8;
        end
        else if( count == T1MS)begin
            count <= 14'd0;
            if(an==4'd1)
                an<= 4'd8;
            else
                an<=an>>1;
        end
        else
            count <= count + 1'b1;   
            
       parameter _0 = 8'hc0,_1 = 8'hf9,_2 = 8'ha4,_3 = 8'hb0,
                 _4 = 8'h99,_5 = 8'h92,_6 = 8'h82,_7 = 8'hf8,
                 _8 = 8'h80,_9 = 8'h90;
       reg [7:0]seg_data;
       always @( posedge clk or posedge rst )
           if( rst )
               seg_code <= 8'hff;
           else begin
               case( an )
                   4'd1:seg_data<=8'd0;
                   4'd2:seg_data<=add_bai;
                   4'd4:seg_data<=add_shi;
                   4'd8:seg_data<=add_ge;
                   default:seg_data<=8'hff;
                endcase
               case( seg_data )
                   8'd0:seg_code <= ~_0;
                   8'd1:seg_code <= ~_1;
                   8'd2:seg_code <= ~_2;
                   8'd3:seg_code <= ~_3;
                   8'd4:seg_code <= ~_4;
                   8'd5:seg_code <= ~_5;
                   8'd6:seg_code <= ~_6;
                   8'd7:seg_code <= ~_7;
                   8'd8:seg_code <= ~_8;
                   8'd9:seg_code <= ~_9;
                   default:
                       seg_code <= 8'hff;
               endcase   
            end
            
                    
endmodule
