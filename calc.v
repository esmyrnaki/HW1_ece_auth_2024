`include "calc_enc.v"
`include "alu.v"
module calc (
    input clk, btnc, btnl, btnu, btnr, btnd,
    input [15:0] sw,
    output reg [15:0] led
);
reg [15:0] accumulator;
wire [31:0]alu_op1, alu_op2, alu_result;
wire [3:0] alu_op;
calc_enc my_enc(
    .btnr(btnr),
    .btnl(btnl),
    .btnc(btnc),
    .alu_op(alu_op)
);
assign alu_op1 = {{16{accumulator[15]}}, accumulator};
assign alu_op2 = {{16{sw[15]}}, sw};

alu my_alu(
    .op1(alu_op1),
    .op2(alu_op2),
    .alu_op(alu_op),
    .result(alu_result),
    .zero()
);
always @(posedge clk) begin
    if (btnu) begin
        accumulator <= 16'b0;
    end else if (btnd) begin
        accumulator <= alu_result[15:0];
    end
    led = accumulator;
end
endmodule