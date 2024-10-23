module calc_enc(
    input wire btnr, btnl, btnc,
    output wire [3:0] alu_op
);

wire w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12;
//sx2
not(w0, btnr);
and(w1, w0, btnl);
xor(w2, btnl, btnc);
and(w3, w2, btnr);
or(alu_op[0], w3, w1);
//sx3
and(w4, btnr, btnl);
not(w5, btnl);
not(w6, btnc);
and(w7, w5, w6);
or(alu_op[1], w4, w7);
//sx4
xor(w8, btnr, btnl);
or(w9, w4, w8);
and(alu_op[2], w9, w6);
//sx5
and(w10, w0, btnc);
xnor(w11, btnr, btnc);
or(w12, w10, w11);
and(alu_op[3], btnl, w12);

endmodule