`include "top_proc.v"
`include "ram.v"
`include "rom.v"
`timescale 1ns/1ps
module top_proc_tb ;
reg clk, rst;
wire [31:0] instr, dReadData;
wire [31:0] PC, dAddress, dWriteData, WriteBackData;
wire MemRead, MemWrite; 
top_proc my_top_proc (.clk(clk), .rst(rst), .instr(instr), .dReadData(dReadData), .PC(PC), .dAddress(dAddress), .dWriteData(dWriteData),
.WriteBackData(WriteBackData), .MemRead(MemRead), .MemWrite(MemWrite));
DATA_MEMORY dm (.clk(clk), .we(MemWrite), .addr(dAddress[8:0]), .din(dWriteData), .dout(dReadData));
INSTRUCTION_MEMORY im (.clk(clk), .addr(PC[8:0]), .dout(instr));
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    $dumpfile("top_proc_tb.vcd");
    $dumpvars(0,top_proc_tb);    
    rst = 0;
    #15 rst = 1;
    #1000 $finish;
end
endmodule 