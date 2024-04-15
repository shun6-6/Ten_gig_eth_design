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
    output [79:0]   m_axis_ruser        ,//用户自定义
    output [7 :0]   m_axis_rkeep        ,
    output          m_axis_rlast        ,
    output          m_axis_rvalid       ,
    output          o_crc_error         ,
    output          o_crc_valid         ,

    input  [63:0]   s_axis_tdata        ,
    input  [79:0]   s_axis_tuser        ,//用户自定义
    input  [7 :0]   s_axis_tkeep        ,
    input           s_axis_tlast        ,
    input           s_axis_tvalid       ,
    output          s_axis_tready       
);


wire            w_crc_error         ;
wire            w_crc_valid         ;

wire [63:0]     m2crc_axis_rdata    ;
wire [79:0]     m2crc_axis_ruser    ;
wire [7 :0]     m2crc_axis_rkeep    ;
wire            m2crc_axis_rlast    ;
wire            m2crc_axis_rvalid   ;

wire [63:0]     w_xgmii_rxd         ;
wire [7 :0]     w_xgmii_rxc         ;
wire [63:0]     w_xgmii_txd         ;
wire [7 :0]     w_xgmii_txc         ;

assign o_crc_error = w_crc_error    ;
assign o_crc_valid = w_crc_valid    ;

assign w_xgmii_rxd   = {i_xgmii_rxd[7 :0],i_xgmii_rxd[15:8],i_xgmii_rxd[23:16],i_xgmii_rxd[31:24],
                        i_xgmii_rxd[39:32],i_xgmii_rxd[47:40],i_xgmii_rxd[55:48],i_xgmii_rxd[63:56]};
assign w_xgmii_rxc   = {i_xgmii_rxc[0],i_xgmii_rxc[1],i_xgmii_rxc[2],i_xgmii_rxc[3],
                        i_xgmii_rxc[4],i_xgmii_rxc[5],i_xgmii_rxc[6],i_xgmii_rxc[7]};
assign o_xgmii_txd = {w_xgmii_txd[7 :0],w_xgmii_txd[15:8],w_xgmii_txd[23:16],w_xgmii_txd[31:24],
                            w_xgmii_txd[39:32],w_xgmii_txd[47:40],w_xgmii_txd[55:48],w_xgmii_txd[63:56]};
assign o_xgmii_txc = {w_xgmii_txc[0],w_xgmii_txc[1],w_xgmii_txc[2],w_xgmii_txc[3],
                            w_xgmii_txc[4],w_xgmii_txc[5],w_xgmii_txc[6],w_xgmii_txc[7]};

TEN_GIG_MAC_TX#(
    .P_SRC_MAC              (48'h00_00_00_00_00_00),
    .P_DST_MAC              (48'h00_00_00_00_00_00)
)TEN_GIG_MAC_TX_u0(
    .i_clk                  (i_xgmii_clk        ),
    .i_rst                  (i_xgmii_rst        ),
    .i_dynamic_src_mac      (0),
    .i_dynamic_src_valid    (0),
    .i_dynamic_dst_mac      (0),
    .i_dynamic_dst_valid    (0),
    .s_axis_tdata           (s_axis_tdata       ),
    .s_axis_tuser           (s_axis_tuser       ),
    .s_axis_tkeep           (s_axis_tkeep       ),
    .s_axis_tlast           (s_axis_tlast       ),
    .s_axis_tvalid          (s_axis_tvalid      ),
    .s_axis_tready          (),
    .o_xgmii_txd            (),
    .o_xgmii_txc            () 
);


CRC_process CRC_process_u0(
    .i_clk                  (i_xgmii_clk        ),
    .i_rst                  (i_xgmii_rst        ),
    .s_axis_rdata           (m2crc_axis_rdata   ),
    .s_axis_ruser           (m2crc_axis_ruser   ),
    .s_axis_rkeep           (m2crc_axis_rkeep   ),
    .s_axis_rlast           (m2crc_axis_rlast   ),
    .s_axis_rvalid          (m2crc_axis_rvalid  ),
    .i_crc_error            (w_crc_error        ),
    .i_crc_valid            (w_crc_valid        ),
    .m_axis_rdata           (m_axis_rdata       ),
    .m_axis_ruser           (m_axis_ruser       ),
    .m_axis_rkeep           (m_axis_rkeep       ),
    .m_axis_rlast           (m_axis_rlast       ),
    .m_axis_rvalid          (m_axis_rvalid      ) 
);


TEN_GIG_MAC_RX TEN_GIG_MAC_RX_u0(
    .i_clk                  (i_xgmii_clk        ),
    .i_rst                  (i_xgmii_rst        ),
    .i_xgmii_rxd            (i_xgmii_rxd        ),
    .i_xgmii_rxc            (i_xgmii_rxc        ),
    .m_axis_rdata           (m2crc_axis_rdata   ),
    .m_axis_ruser           (m2crc_axis_ruser   ),
    .m_axis_rkeep           (m2crc_axis_rkeep   ),
    .m_axis_rlast           (m2crc_axis_rlast   ),
    .m_axis_rvalid          (m2crc_axis_rvalid  ),
    .o_crc_error            (w_crc_error        ),
    .o_crc_valid            (w_crc_valid        )
);


endmodule
