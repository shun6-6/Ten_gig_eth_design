`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 10:20:48
// Design Name: 
// Module Name: SIM_TOP_TB
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


module SIM_TOP_TB();

reg clk,gtclk;

always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end

always begin
    gtclk = 0;
    #3.2;
    gtclk = 1;
    #3.2;
end

reg i_sim_speedup_control;
wire o_gt_txp;
wire o_gt_txn;
wire o_tx_disable;



XC7Z100_Top#(    
    .P_SRC_MAC              (48'h01_02_03_04_05_06),
    .P_DST_MAC              (48'h01_02_03_04_05_06))
XC7Z100_Top_u0(
    .i_sys_clk_p     (clk),
    .i_sys_clk_n     (~clk),
    .i_gt_refclk_p   (gtclk),
    .i_gt_refclk_n   (~gtclk),
    .i_gt_rxp        (o_gt_txp),
    .i_gt_rxn        (o_gt_txn),
    .o_gt_txp        (o_gt_txp),
    .o_gt_txn        (o_gt_txn),
    .o_tx_disable    (o_tx_disable)
);

endmodule
