`include "calc.v"
`timescale 1ns/1ps
module calc_tb();
reg clk_tb, btnc_tb, btnl_tb, btnu_tb, btnr_tb, btnd_tb;
reg [15:0] sw_tb;
wire [15:0] led_tb;
calc my_calc(clk_tb, btnc_tb, btnl_tb, btnu_tb, btnr_tb, btnd_tb, sw_tb, led_tb);
initial begin
    clk_tb = 0;
    forever #5 clk_tb = ~clk_tb;
end
initial begin
    $dumpfile("calc_tb.vcd");
    $dumpvars(0,calc_tb);
    btnc_tb = 0; btnl_tb = 0; btnu_tb = 0; btnr_tb = 0; btnd_tb = 1; sw_tb = 16'h0000;
    // Test scenarios
    // Scenario 1: Reset
    #10 btnu_tb = 1;
    #10 btnu_tb = 0;
    // Scenario 2: OR operation
    #10 btnl_tb = 0; btnc_tb = 1; btnr_tb = 1; sw_tb = 16'h1234;
    // Scenario 3: AND operation
    #10 btnl_tb = 0; btnc_tb = 1; btnr_tb = 0; sw_tb = 16'h0ff0; $display("1 led = %h",led_tb);
    // Scenario 4: ADD operation
    #10 btnl_tb = 0; btnc_tb = 0; btnr_tb = 0; sw_tb = 16'h324f; $display("2 led = %h",led_tb);
    // Scenario 5: SUB operation
    #10 btnl_tb = 0; btnc_tb = 0; btnr_tb = 1; sw_tb = 16'h2d31; $display("3 led = %h",led_tb);
    // Scenario 6: XOR operation
    #10 btnl_tb = 1; btnc_tb = 0; btnr_tb = 0; sw_tb = 16'hffff; $display("4 led = %h",led_tb);
    // Scenario 7: Less Than operation
    #10 btnl_tb = 1; btnc_tb = 0; btnr_tb = 1; sw_tb = 16'h7346; $display("5 led = %h",led_tb);
    // Scenario 8: Shift Left Logical operation
    #10 btnl_tb = 1; btnc_tb = 1; btnr_tb = 0; sw_tb = 16'h0004; $display("6 led = %h",led_tb);
    // Scenario 9: Shift Right Arithmetic operation
    #10 btnl_tb = 1; btnc_tb = 1; btnr_tb = 1; sw_tb = 16'h0004; $display("7 led = %h",led_tb);
    // Scenario 10: Less Than operation with result 0xffff
    #10 btnl_tb = 1; btnc_tb = 0; btnr_tb = 1; sw_tb = 16'hffff; $display("8 led = %h",led_tb);
    #10 $display("9 led = %h",led_tb);
    #10 $display("10 led = %h",led_tb);
    $finish;
end
endmodule 