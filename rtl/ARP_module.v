`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 15:56:26
// Design Name: 
// Module Name: ARP_module
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


module ARP_module#(
    parameter       P_DST_IP_ADDR   = {8'd192,8'd168,8'd100,8'd100},
    parameter       P_SRC_IP_ADDR   = {8'd192,8'd168,8'd100,8'd99 },
    parameter       P_SRC_MAC_ADDR  = 48'h01_02_03_04_05_06
)(
    input           i_clk               ,
    input           i_rst               ,

    input  [31:0]   i_dymanic_src_ip    ,
    input           i_src_ip_valid      ,
    input  [47:0]   i_dymanic_src_mac   ,
    input           i_src_mac_valid     ,
    input           i_arp_active        ,
    input  [31:0]   i_arp_active_dst_ip ,
    input           i_ip2arp_active     ,   
    input  [31:0]   i_ip2arp_active_dst_ip,
    /*** seek mac ***/
    input  [31:0]   i_seek_ip           ,
    input           i_seek_valid        ,
    output [47:0]   o_seek_mac          ,
    output          o_seek_mac_valid    ,

    input  [63:0]   s_axis_mac_data     ,
    input  [79:0]   s_axis_mac_user     ,
    input  [7 :0]   s_axis_mac_keep     ,
    input           s_axis_mac_last     ,
    input           s_axis_mac_valid    ,

    output [63:0]   m_axis_arp_data     ,
    output [79:0]   m_axis_arp_user     ,
    output [7 :0]   m_axis_arp_keep     ,
    output          m_axis_arp_last     ,
    output          m_axis_arp_valid    ,
    input           m_axis_arp_ready    
);

wire [47:0]     w_recv_target_mac   ;
wire [31:0]     w_recv_target_ip    ;
wire            w_recv_target_valid ;
wire            w_arp_reply         ;

ARP_table ARP_table_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),
    .i_recv_target_mac      (w_recv_target_mac  ),
    .i_recv_target_ip       (w_recv_target_ip   ),
    .i_recv_target_valid    (w_recv_target_valid),
    .i_seek_ip              (i_seek_ip          ),
    .i_seek_valid           (i_seek_valid       ),
    .o_seek_mac             (o_seek_mac         ),
    .o_seek_mac_valid       (o_seek_mac_valid   ) 
);

ARP_TX#(
    .P_DST_IP_ADDR          (P_DST_IP_ADDR      ),
    .P_SRC_IP_ADDR          (P_SRC_IP_ADDR      ),
    .P_SRC_MAC_ADDR         (P_SRC_MAC_ADDR     )
)ARP_TX_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),
    .i_dymanic_src_ip       (i_dymanic_src_ip   ),
    .i_src_ip_valid         (i_src_ip_valid     ),
    .i_dymanic_src_mac      (i_dymanic_src_mac  ),
    .i_src_mac_valid        (i_src_mac_valid    ),
    .i_recv_target_mac      (w_recv_target_mac  ),
    .i_recv_target_ip       (w_recv_target_ip   ),
    .i_recv_target_valid    (w_recv_target_valid),
    .i_arp_reply            (w_arp_reply        ),
    .i_arp_active           (i_arp_active       ),
    .i_arp_active_dst_ip    (i_arp_active_dst_ip),
    .i_ip2arp_active        (i_ip2arp_active            ),
    .i_ip2arp_active_dst_ip (i_ip2arp_active_dst_ip     ),
    .m_axis_arp_data        (m_axis_arp_data    ),
    .m_axis_arp_user        (m_axis_arp_user    ),
    .m_axis_arp_keep        (m_axis_arp_keep    ),
    .m_axis_arp_last        (m_axis_arp_last    ),
    .m_axis_arp_valid       (m_axis_arp_valid   ),
    .m_axis_arp_ready       (m_axis_arp_ready   )
);

ARP_RX#(
    .P_SRC_IP_ADDR          (P_SRC_IP_ADDR      ),
    .P_SRC_MAC_ADDR         (P_SRC_MAC_ADDR     )
)ARP_RX_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),
    .o_recv_target_mac      (w_recv_target_mac  ),
    .o_recv_target_ip       (w_recv_target_ip   ),
    .o_recv_target_valid    (w_recv_target_valid),
    .o_arp_reply            (w_arp_reply        ),
    .i_dymanic_src_ip       (i_dymanic_src_ip   ),
    .i_src_ip_valid         (i_src_ip_valid     ),
    .s_axis_mac_data        (s_axis_mac_data    ),
    .s_axis_mac_user        (s_axis_mac_user    ),
    .s_axis_mac_keep        (s_axis_mac_keep    ),
    .s_axis_mac_last        (s_axis_mac_last    ),
    .s_axis_mac_valid       (s_axis_mac_valid   ) 
);


endmodule
