`include "regfile.v"
`include "alu.v"
module datapath #(parameter [31:0] INITIAL_PC = 32'h00400000)(
input clk, rst, PCSrc, ALUSrc, RegWrite, MemToReg, loadPC,
input [31:0] instr, dReadData,
input [3:0] ALUCtrl,
output reg [31:0] PC,
output Zero,
output reg [31:0] dAddress, dWriteData, WriteBackData
);

reg [31:0] ALU_op2,WriteData, branch_offset, immIext, immBext, immSext;
wire [31:0] readData1, readData2, ALU_result;
reg [4:0] readReg1, readReg2, writeReg;

regfile my_reg(
.clk(clk),
.readReg1(readReg1),
.readReg2(readReg2),
.writeReg(writeReg),
.writeData(WriteData),
.write(RegWrite),
.readData1(readData1),
.readData2(readData2)
);
alu my_alu(
.op1(readData1),
.op2(ALU_op2),
.alu_op(ALUCtrl),
.zero(Zero),
.result(ALU_result)
);

always @(posedge clk or negedge rst) 
begin : Program_Counter
if(!rst)
PC <= INITIAL_PC;
else if (loadPC)
PC <= PCSrc ? PC + branch_offset : PC + 4;
end

always @(instr)
begin : Register_File
readReg1 = instr[19:15];
readReg2 = instr[24:20];
writeReg  = instr[11:7];
end

always @(instr)
begin : Immediate_Generation
    immIext = {{20{instr[31]}}, instr[31:20]};
    immSext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    immBext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
end

always @*
begin
ALU_op2 = ALUSrc ? immIext : readData2;
branch_offset = PC + immBext;
end

always @*
begin : Write_Back
WriteData = MemToReg ? dReadData : ALU_result;
WriteBackData = dWriteData;
end
 
always @* begin
dAddress = ALU_result;
dWriteData = readData2;
end
endmodule