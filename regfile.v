module regfile (
    input clk, write,
    input [4:0] readReg1, readReg2, writeReg,
    input [31:0] writeData,
    output reg [31:0] readData1, readData2
);

reg [31:0] registers [0:31];
integer i;

initial begin
    for (i = 0; i < 32; i = i + 1) begin
        registers[i] = 32'b0;
    end
end

always @(posedge clk) begin
    readData1 = registers[readReg1];
    readData2 = registers[readReg2];
 
    if (write) begin
        if (writeReg != readReg1 && writeReg != readReg2) begin
            registers[writeReg] = writeData;
        end
    end
end

endmodule