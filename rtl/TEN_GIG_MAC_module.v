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


module TEN_GIG_MAC_module#(
    parameter       P_SRC_MAC = 48'h00_00_00_00_00_00,
    parameter       P_DST_MAC = 48'h00_00_00_00_00_00
)(
    input           i_xgmii_clk         ,
    input           i_xgmii_rst         ,
    input  [63:0]   i_xgmii_rxd         ,
    input  [7 :0]   i_xgmii_rxc         ,
    output [63:0]   o_xgmii_txd         ,
    output [7 :0]   o_xgmii_txc         ,

    input  [47:0]   i_dynamic_src_mac   ,
    input           i_dynamic_src_valid ,
    input  [47:0]   i_dynamic_dst_mac   ,
    input           i_dynamic_dst_valid ,
    
    output [63:0]   m_axis_rdata        ,
    output [79:0]   m_axis_ruser        ,//用户自定义{16'dlen,对端mac[47:0],16'dr_type}
    output [7 :0]   m_axis_rkeep        ,
    output          m_axis_rlast        ,
    output          m_axis_rvalid       ,
    output          o_crc_error         ,
    output          o_crc_valid         ,

    input  [63:0]   s_axis_tdata        ,
    input  [79:0]   s_axis_tuser        ,//用户自定义{16'dlen,对端mac[47:0],16'dr_type}
    input  [7 :0]   s_axis_tkeep        ,
    input           s_axis_tlast        ,
    input           s_axis_tvalid       ,
    output          s_axis_tready       
);
/*对端mac[47:0]:针对接收而言，对端mac指接收MAC数据当中的源mac地址字段；
* 针对发送端而言，对端mac指发送MAC数据当中的目的mac地址字段。
*/

wire            w_crc_error         ;
wire            w_crc_valid         ;

wire [63:0]     m2crc_axis_rdata    ;
wire [79:0]     m2crc_axis_ruser    ;
wire [7 :0]     m2crc_axis_rkeep    ;
wire            m2crc_axis_rlast    ;
wire            m2crc_axis_rvalid   ;

wire [63:0]     w_xgmii_rxd         ;
wire [7 :0]     w_xgmii_rxc         ;
wire [63:0]     w_xgmii_rxd_7h55    ;
wire [7 :0]     w_xgmii_rxc_7h55    ;
wire [63:0]     w_xgmii_txd         ;
wire [7 :0]     w_xgmii_txc         ;
wire [63:0]     w_xgmii_txd_7h55    ;
wire [7 :0]     w_xgmii_txc_7h55    ;

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


MAC_TX_header MAC_TX_header_u0(
    .i_clk                          (i_xgmii_clk            ),
    .i_rst                          (i_xgmii_rst            ),

    .i_xgmii_txd                    (w_xgmii_txd_7h55       ),
    .i_xgmii_txc                    (w_xgmii_txc_7h55       ),

    .o_xgmii_txd                    (w_xgmii_txd            ),
    .o_xgmii_txc                    (w_xgmii_txc            )
);


TEN_GIG_MAC_TX#(
    .P_SRC_MAC              (P_SRC_MAC),
    .P_DST_MAC              (P_DST_MAC)
)TEN_GIG_MAC_TX_u0(
    .i_clk                  (i_xgmii_clk        ),
    .i_rst                  (i_xgmii_rst        ),
    .i_dynamic_src_mac      (i_dynamic_src_mac  ),
    .i_dynamic_src_valid    (i_dynamic_src_valid),
    .i_dynamic_dst_mac      (i_dynamic_dst_mac  ),
    .i_dynamic_dst_valid    (i_dynamic_dst_valid),
    .s_axis_tdata           (s_axis_tdata       ),
    .s_axis_tuser           (s_axis_tuser       ),
    .s_axis_tkeep           (s_axis_tkeep       ),
    .s_axis_tlast           (s_axis_tlast       ),
    .s_axis_tvalid          (s_axis_tvalid      ),
    .s_axis_tready          (s_axis_tready      ),
    .o_xgmii_txd            (w_xgmii_txd_7h55   ),
    .o_xgmii_txc            (w_xgmii_txc_7h55   ) 
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

MAC_RX_header MAC_RX_header_u0(
    .i_clk                  (i_xgmii_clk            ),
    .i_rst                  (i_xgmii_rst            ),

    .i_xgmii_rxd            (w_xgmii_rxd            ),
    .i_xgmii_rxc            (w_xgmii_rxc            ),

    .o_xgmii_rxd            (w_xgmii_rxd_7h55       ),
    .o_xgmii_rxc            (w_xgmii_rxc_7h55       )
);

TEN_GIG_MAC_RX#(
    .P_SRC_MAC              (P_SRC_MAC),
    .P_DST_MAC              (P_DST_MAC)
) TEN_GIG_MAC_RX_u0(
    .i_clk                  (i_xgmii_clk        ),
    .i_rst                  (i_xgmii_rst        ),
    .i_dynamic_src_mac      (i_dynamic_src_mac  ),
    .i_dynamic_src_valid    (i_dynamic_src_valid),
    .i_dynamic_dst_mac      (i_dynamic_dst_mac  ),
    .i_dynamic_dst_valid    (i_dynamic_dst_valid),    
    .i_xgmii_rxd            (w_xgmii_rxd_7h55   ),
    .i_xgmii_rxc            (w_xgmii_rxc_7h55   ),
    //仿真的时候不需要添加55
    // .i_xgmii_rxd            (w_xgmii_rxd   ),
    // .i_xgmii_rxc            (w_xgmii_rxc   ),

    .m_axis_rdata           (m2crc_axis_rdata   ),
    .m_axis_ruser           (m2crc_axis_ruser   ),
    .m_axis_rkeep           (m2crc_axis_rkeep   ),
    .m_axis_rlast           (m2crc_axis_rlast   ),
    .m_axis_rvalid          (m2crc_axis_rvalid  ),
    .o_crc_error            (w_crc_error        ),
    .o_crc_valid            (w_crc_valid        )
);


endmodule
