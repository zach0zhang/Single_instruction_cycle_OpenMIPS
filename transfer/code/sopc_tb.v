`timescale 1ns/100ps
`include "sopc.v"
module sopc_tb();

reg CLOCK_50;
reg rst;

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, sopc_tb);
    CLOCK_50 = 1'b0;
    rst = `RstEnable;
    #195 rst= `RstDisable;
    #2000 $finish;
end

always #10 CLOCK_50=~CLOCK_50;

sopc sopc0(
    .clk(CLOCK_50),
    .rst(rst)
);
endmodule