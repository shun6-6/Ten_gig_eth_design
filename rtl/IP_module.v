`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/22 14:58:35
// Design Name: 
// Module Name: IP_module
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


module IP_module#(
    parameter       P_SRC_IP_ADDR   = {8'd192,8'd168,8'd100,8'd99},
    parameter       P_DST_IP_ADDR   = {8'd192,8'd168,8'd100,8'd100}
)(
    input           i_clk               ,
    input           i_rst               ,

    input  [31:0]   i_dynamic_src_ip    ,
    input           i_dynamic_src_valid ,
    input  [31:0]   i_dynamic_dst_ip    ,
    input           i_dynamic_dst_valid ,
    output [31:0]   o_seek_ip           ,
    output          o_seek_ip_valid     ,
    input  [47:0]   i_seek_mac          ,
    input           i_seek_mac_valid    ,
    output          o_arp_active        ,
    output [31:0]   o_arp_active_dst_ip ,
    /*****MAC AXIS interface*****/
    output [63:0]   m_axis_mac_data     ,
    output [79:0]   m_axis_mac_user     ,//用户自定义{16'dlen,r_src_mac[47:0],16'dr_type}
    output [7 :0]   m_axis_mac_keep     ,
    output          m_axis_mac_last     ,
    output          m_axis_mac_valid    ,
    input           m_axis_mac_ready    ,

    input  [63:0]   s_axis_mac_data     ,
    input  [79:0]   s_axis_mac_user     ,
    input  [7 :0]   s_axis_mac_keep     ,
    input           s_axis_mac_last     ,
    input           s_axis_mac_valid    ,
    /*****upper layer AXIS interface*****/
    output [63:0]   m_axis_upper_data   ,
    output [55:0]   m_axis_upper_user   ,//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    output [7 :0]   m_axis_upper_keep   ,
    output          m_axis_upper_last   ,
    output          m_axis_upper_valid  ,

    input  [63:0]   s_axis_upper_data   ,
    input  [55:0]   s_axis_upper_user   ,
    input  [7 :0]   s_axis_upper_keep   ,
    input           s_axis_upper_last   ,
    input           s_axis_upper_valid  ,
    output          s_axis_upper_ready  
);


IP_TX#(
    .P_SRC_IP_ADDR          (P_SRC_IP_ADDR      ),
    .P_DST_IP_ADDR          (P_DST_IP_ADDR      )
)IP_TX_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),
    .i_dynamic_src_ip       (i_dynamic_src_ip   ),
    .i_dynamic_src_valid    (i_dynamic_src_valid),
    .i_dynamic_dst_ip       (i_dynamic_dst_ip   ),
    .i_dynamic_dst_valid    (i_dynamic_dst_valid),
    .o_seek_ip              (o_seek_ip          ),
    .o_seek_ip_valid        (o_seek_ip_valid    ),
    .i_seek_mac             (i_seek_mac         ),
    .i_seek_mac_valid       (i_seek_mac_valid   ),
    .o_arp_active           (o_arp_active       ),
    .o_arp_active_dst_ip    (o_arp_active_dst_ip),
    .m_axis_mac_data        (m_axis_mac_data    ),
    .m_axis_mac_user        (m_axis_mac_user    ),
    .m_axis_mac_keep        (m_axis_mac_keep    ),
    .m_axis_mac_last        (m_axis_mac_last    ),
    .m_axis_mac_valid       (m_axis_mac_valid   ),
    .m_axis_mac_ready       (m_axis_mac_ready   ),
    .s_axis_upper_data      (s_axis_upper_data  ),
    .s_axis_upper_user      (s_axis_upper_user  ),
    .s_axis_upper_keep      (s_axis_upper_keep  ),
    .s_axis_upper_last      (s_axis_upper_last  ),
    .s_axis_upper_valid     (s_axis_upper_valid ),
    .s_axis_upper_ready     (s_axis_upper_ready ) 
);

IP_RX#(
    .P_SRC_IP_ADDR          (P_SRC_IP_ADDR      ),
    .P_DST_IP_ADDR          (P_DST_IP_ADDR      )
)IP_RX_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),
    .i_dynamic_src_ip       (i_dynamic_src_ip   ),
    .i_dynamic_src_valid    (i_dynamic_src_valid),
    .i_dynamic_dst_ip       (i_dynamic_dst_ip   ),
    .i_dynamic_dst_valid    (i_dynamic_dst_valid),
    .s_axis_mac_data        (s_axis_mac_data    ),
    .s_axis_mac_user        (s_axis_mac_user    ),
    .s_axis_mac_keep        (s_axis_mac_keep    ),
    .s_axis_mac_last        (s_axis_mac_last    ),
    .s_axis_mac_valid       (s_axis_mac_valid   ),
    .m_axis_upper_data      (m_axis_upper_data  ),
    .m_axis_upper_user      (m_axis_upper_user  ),
    .m_axis_upper_keep      (m_axis_upper_keep  ),
    .m_axis_upper_last      (m_axis_upper_last  ),
    .m_axis_upper_valid     (m_axis_upper_valid ) 
);


endmodule
