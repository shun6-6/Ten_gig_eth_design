`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 15:52:25
// Design Name: 
// Module Name: 10G_MAC_module
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


module TEN_GIG_MAC_module(
    input           i_xgmii_clk         ,
    input           i_xgmii_rst         ,
    input  [63:0]   i_xgmii_rxd         ,
    input  [7 :0]   i_xgmii_rxc         ,
    output [63:0]   o_xgmii_txd         ,
    output [7 :0]   o_xgmii_txc         ,
    
    output [63:0]   m_axis_rdata        ,
    output [31:0]   m_axis_ruser        ,//用户自定义
    output [7 :0]   m_axis_rkeep        ,
    output          m_axis_rlast        ,
    output          m_axis_rvalid       ,

    input  [63:0]   s_axis_tdata        ,
    input  [31:0]   s_axis_tuser        ,//用户自定义
    input  [7 :0]   s_axis_tkeep        ,
    input           s_axis_tlast        ,
    input           s_axis_tvalid       ,
    output          s_axis_tready       
);

TEN_GIG_MAC_RX TEN_GIG_MAC_RX_u0(
    .i_clk              (i_xgmii_clk    ),
    .i_rst              (i_xgmii_rst    ),
    .i_xgmii_rxd        (i_xgmii_rxd    ),
    .i_xgmii_rxc        (i_xgmii_rxc    ),
    .m_axis_rdata       (m_axis_rdata   ),
    .m_axis_ruser       (m_axis_ruser   ),//用户自定义
    .m_axis_rkeep       (m_axis_rkeep   ),
    .m_axis_rlast       (m_axis_rlast   ),
    .m_axis_rvalid      (m_axis_rvalid  )
);

endmodule
