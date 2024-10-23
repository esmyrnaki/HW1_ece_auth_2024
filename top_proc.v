`include "datapath.v"
module top_proc(
    input clk, rst,
    input [31:0] instr, dReadData,
    output [31:0] PC, dAddress, dWriteData, WriteBackData,
    output reg MemRead, MemWrite
);
parameter [31:0] INITIAL_PC = 32'h00400000;
parameter IF = 3'b000, ID = 3'b001, EX = 3'b010, MEM = 3'b011, WB = 3'b100;
reg [2:0] current_state, next_state;
reg [3:0] ALUCtrl;
reg ALUSrc, loadPC, PCSrc, MemToReg, RegWrite;
wire Zero;
datapath #(.INITIAL_PC(INITIAL_PC)) my_datapath(
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .PCSrc(PCSrc),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .MemToReg(MemToReg),
    .ALUCtrl(ALUCtrl),
    .loadPC(loadPC),
    .PC(PC),
    .Zero(Zero),
    .dAddress(dAddress),
    .dWriteData(dWriteData),
    .dReadData(dReadData),
    .WriteBackData(WriteBackData)
);

always @(posedge clk or negedge rst)
begin: State_memory
if(!rst)
current_state <= IF;
else
current_state <= next_state;
end

always @(*)
begin: Next_state_logic
case (current_state)
IF : next_state = ID;
ID :begin
    case (instr[6:0]) 
    7'b0000011: next_state = MEM;
    7'b0100011: next_state = MEM;
    7'b0110011: next_state = EX;
    7'b0010011: next_state = EX;
    7'b1100011: next_state = EX;
endcase
end
EX:begin
    case (instr[6:0])
    7'b0110011, 7'b0010011: next_state = WB;
    7'b1100011 : next_state = IF;
    default: next_state = IF;
endcase
end
MEM:begin
    case (instr[6:0])
    7'b0000011: next_state = WB;
    7'b0100011: next_state = IF;
    default: next_state = IF;
endcase
end
WB: next_state = IF;
endcase
end

always @(*)                            
begin : Output_logic
ALUCtrl = 4'b0000;
ALUSrc = 0;
MemRead = 0;
MemWrite = 0;
MemToReg = 0;
RegWrite = 0;
loadPC = 0;
PCSrc = 0;
case (current_state)
IF: begin
    loadPC = 0;
    PCSrc = 0;
end
ID: begin
    case (instr[6:0])
    7'b0000011,7'b0100011: begin
        ALUCtrl = 4'b0010;
        ALUSrc = 1;
    end
    7'b0110011:begin
        ALUSrc = 0;
        case ({instr[31:25], instr[14:12]})
        10'b0000000111: ALUCtrl = 4'b0000; // AND
        10'b0000000110: ALUCtrl = 4'b0001; // OR
        10'b0000000001: ALUCtrl = 4'b0011; // SLL
        10'b0000000101: ALUCtrl = 4'b0100; // SRL
        10'b0100000101: ALUCtrl = 4'b0101; // SRA
        10'b0000000010: ALUCtrl = 4'b0111; // SLT
        10'b0000000100: ALUCtrl = 4'b1000; // XOR
        default: ALUCtrl = 4'b0000;
        endcase
    end
    7'b0010011: begin
        ALUSrc = 1;
        case (instr[14:12])
        3'b000: ALUCtrl = 4'b0010; // ADDI
        3'b111: ALUCtrl = 4'b0000; // ANDI
        3'b110: ALUCtrl = 4'b0001; // ORI
        3'b001: ALUCtrl = 4'b0011; // SLLI
        3'b101: ALUCtrl = 4'b0100; // SRLI
        3'b010: ALUCtrl = 4'b0111; // SLTI
        3'b100: ALUCtrl = 4'b1000; // XORI
        default: ALUCtrl = 4'b0000;
        endcase
    end
    7'b1100011: begin
        ALUSrc = 0;
        ALUCtrl = 4'b0110;
    end 
    endcase
end
EX: begin
    case(instr[6:0])
    7'b0110011, 7'b0010011: begin
        MemToReg = 0;
        RegWrite = 1;
    end
    7'b1100011: begin
        loadPC = 1;
        PCSrc = Zero ? 0 : 1;
    end
    endcase
end
MEM: begin
    case (instr[6:0])
    7'b0000011: MemRead = 1;
    7'b0100011: begin
        MemWrite = 1;
        PCSrc = 0;
    end
    default: begin
        MemRead = 0;
        MemWrite = 0;
    end
    endcase
end
WB: begin
    RegWrite = 1;
    case (instr[6:0])
    7'b0110011, 7'b0010011: begin
        loadPC = 1;
        PCSrc = 0;
    end
    7'b0000011: begin
        MemToReg = 1;
        loadPC = 1;
        PCSrc = 0;
    end
    7'b1100011: begin
        loadPC = 1;
        if (Zero == 1)
        PCSrc = 1;
    end
    endcase
end
endcase
end
endmodule