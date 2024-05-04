`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/22 14:58:35
// Design Name: 
// Module Name: UDP_10G_Stack
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


module UDP_10G_Stack#(
    parameter       P_SRC_MAC       = 48'h00_00_00_00_00_00         ,
    parameter       P_DST_MAC       = 48'h00_00_00_00_00_00         ,
    parameter       P_SRC_IP_ADDR   = {8'd192,8'd168,8'd100,8'd99}  ,
    parameter       P_DST_IP_ADDR   = {8'd192,8'd168,8'd100,8'd100} ,
    parameter       P_SRC_UDP_PORT  = 16'h0808                      ,
    parameter       P_DST_UDP_PORT  = 16'h0808                      

)(
    input           i_xgmii_clk             ,
    input           i_xgmii_rst             ,
    input  [63:0]   i_xgmii_rxd             ,
    input  [7 :0]   i_xgmii_rxc             ,
    output [63:0]   o_xgmii_txd             ,
    output [7 :0]   o_xgmii_txc             ,

    input  [47:0]   i_dynamic_src_mac       ,
    input           i_dynamic_src_mac_valid ,
    input  [47:0]   i_dynamic_dst_mac       ,
    input           i_dynamic_dst_mac_valid ,
    input  [15:0]   i_dymanic_src_port      ,
    input           i_dymanic_src_port_valid,
    input  [15:0]   i_dymanic_dst_port      ,
    input           i_dymanic_dst_port_valid,
    input  [31:0]   i_dynamic_src_ip        ,
    input           i_dynamic_src_ip_valid  ,
    input  [31:0]   i_dynamic_dst_ip        ,
    input           i_dynamic_dst_ip_valid  ,
    input           i_arp_active            ,
    input  [31:0]   i_arp_active_dst_ip     ,

    /****user data****/
    output [63:0]   m_axis_user_data        ,
    output [31:0]   m_axis_user_user        ,
    output [7 :0]   m_axis_user_keep        ,
    output          m_axis_user_last        ,
    output          m_axis_user_valid       ,

    input  [63:0]   s_axis_user_data        ,
    input  [31:0]   s_axis_user_user        ,
    input  [7 :0]   s_axis_user_keep        ,
    input           s_axis_user_last        ,
    input           s_axis_user_valid       ,
    output          s_axis_user_ready       
);

wire [63:0]     wm_axis_mac_rdata       ;
wire [79:0]     wm_axis_mac_ruser       ;
wire [7 :0]     wm_axis_mac_rkeep       ;
wire            wm_axis_mac_rlast       ;
wire            wm_axis_mac_rvalid      ;
wire            wo_crc_error            ;
wire            wo_crc_valid            ;
wire [63:0]     ws_axis_mac_tdata       ;
wire [79:0]     ws_axis_mac_tuser       ;
wire [7 :0]     ws_axis_mac_tkeep       ;
wire            ws_axis_mac_tlast       ;
wire            ws_axis_mac_tvalid      ;
wire            ws_axis_mac_tready      ;

//udp
wire [63:0]     wm_axis_udp2ip_data     ;
wire [55:0]     wm_axis_udp2ip_user     ;
wire [7 :0]     wm_axis_udp2ip_keep     ;
wire            wm_axis_udp2ip_last     ;
wire            wm_axis_udp2ip_valid    ;
wire            wm_axis_udp2ip_ready    ;

//icmp
wire [63:0]     wm_axis_icmp2ip_data    ;
wire [55:0]     wm_axis_icmp2ip_user    ;
wire [7 :0]     wm_axis_icmp2ip_keep    ;
wire            wm_axis_icmp2ip_last    ;
wire            wm_axis_icmp2ip_valid   ;
wire            wm_axis_icmp2ip_ready   ;

//arbiter ip
wire [63:0]     wm_axis_arbiter_ip_data ;
wire [79:0]     wm_axis_arbiter_ip_user ;
wire [7 :0]     wm_axis_arbiter_ip_keep ;
wire            wm_axis_arbiter_ip_last ;
wire            wm_axis_arbiter_ip_valid;
wire            wm_axis_arbiter_ip_ready;

wire [63:0]     wm_axis_ip2upper_data   ;
wire [55:0]     wm_axis_ip2upper_user   ;
wire [7 :0]     wm_axis_ip2upper_keep   ;
wire            wm_axis_ip2upper_last   ;
wire            wm_axis_ip2upper_valid  ;

//ip
wire [63:0]     wm_axis_ip2mac_data     ;
wire [79:0]     wm_axis_ip2mac_user     ;
wire [7 :0]     wm_axis_ip2mac_keep     ;
wire            wm_axis_ip2mac_last     ;
wire            wm_axis_ip2mac_valid    ;
wire            wm_axis_ip2mac_ready    ;
wire            w_ip2arp_active         ;
wire [31:0]     w_ip2arp_active_dst_ip  ;

//arp
wire [31:0]     w_seek_ip               ;
wire            w_seek_ip_valid         ;
wire [47:0]     w_seek_mac              ;
wire            w_seek_mac_valid        ;
wire [63:0]     wm_axis_arp2mac_data    ;
wire [79:0]     wm_axis_arp2mac_user    ;
wire [7 :0]     wm_axis_arp2mac_keep    ;
wire            wm_axis_arp2mac_last    ;
wire            wm_axis_arp2mac_valid   ;
wire            wm_axis_arp2mac_ready   ;

//arbiter mac
wire [63:0]     wm_axis_arbiter_mac_data ;
wire [79:0]     wm_axis_arbiter_mac_user ;
wire [7 :0]     wm_axis_arbiter_mac_keep ;
wire            wm_axis_arbiter_mac_last ;
wire            wm_axis_arbiter_mac_valid;
wire            wm_axis_arbiter_mac_ready;

//mac
wire [63:0]     wm_axis_mac2upper_data  ;
wire [79:0]     wm_axis_mac2upper_user  ;
wire [7 :0]     wm_axis_mac2upper_keep  ;
wire            wm_axis_mac2upper_last  ;
wire            wm_axis_mac2upper_valid ;
wire            w_crc_error             ;
wire            w_crc_valid             ;

UDP_module#(
    .P_SRC_UDP_PORT         (P_SRC_UDP_PORT             ),
    .P_DST_UDP_PORT         (P_DST_UDP_PORT             )
)UDP_module_u0(
    .i_clk                  (i_xgmii_clk                ),
    .i_rst                  (i_xgmii_rst                ),
    .i_dymanic_src_port     (i_dymanic_src_port         ),
    .i_dymanic_src_valid    (i_dymanic_src_port_valid   ),
    .i_dymanic_dst_port     (i_dymanic_dst_port         )   ,
    .i_dymanic_dst_valid    (i_dymanic_dst_port_valid   ),

    .m_axis_ip_data         (wm_axis_udp2ip_data        ),
    .m_axis_ip_user         (wm_axis_udp2ip_user        ),//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    .m_axis_ip_keep         (wm_axis_udp2ip_keep        ),
    .m_axis_ip_last         (wm_axis_udp2ip_last        ),
    .m_axis_ip_valid        (wm_axis_udp2ip_valid       ),
    .m_axis_ip_ready        (wm_axis_udp2ip_ready       ),
    .s_axis_ip_data         (wm_axis_ip2upper_data      ),
    .s_axis_ip_user         (wm_axis_ip2upper_user      ),
    .s_axis_ip_keep         (wm_axis_ip2upper_keep      ),
    .s_axis_ip_last         (wm_axis_ip2upper_last      ),
    .s_axis_ip_valid        (wm_axis_ip2upper_valid     ),

    .m_axis_user_data       (m_axis_user_data           ),
    .m_axis_user_user       (m_axis_user_user           ),
    .m_axis_user_keep       (m_axis_user_keep           ),
    .m_axis_user_last       (m_axis_user_last           ),
    .m_axis_user_valid      (m_axis_user_valid          ),
    .s_axis_user_data       (s_axis_user_data           ),
    .s_axis_user_user       (s_axis_user_user           ),
    .s_axis_user_keep       (s_axis_user_keep           ),
    .s_axis_user_last       (s_axis_user_last           ),
    .s_axis_user_valid      (s_axis_user_valid          ),
    .s_axis_user_ready      (s_axis_user_ready          )
);

ICMP_Module ICMP_Module_u0(
    .i_clk                  (i_xgmii_clk                ),
    .i_rst                  (i_xgmii_rst                ),

    .s_axis_ip_data         (wm_axis_ip2upper_data      ),
    .s_axis_ip_user         (wm_axis_ip2upper_user      ),//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    .s_axis_ip_keep         (wm_axis_ip2upper_keep      ),
    .s_axis_ip_last         (wm_axis_ip2upper_last      ),
    .s_axis_ip_valid        (wm_axis_ip2upper_valid     ),
    .m_axis_ip_data         (wm_axis_icmp2ip_data       ),
    .m_axis_ip_user         (wm_axis_icmp2ip_user       ),//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    .m_axis_ip_keep         (wm_axis_icmp2ip_keep       ),
    .m_axis_ip_last         (wm_axis_icmp2ip_last       ),
    .m_axis_ip_valid        (wm_axis_icmp2ip_valid      ),
    .m_axis_ip_ready        (wm_axis_icmp2ip_ready      )
);

Arbiter_module#(
    .P_ARBITER_LAYER        ("IP")
)Arbiter_module_ip(
    .i_clk                  (i_xgmii_clk                ),
    .i_rst                  (i_xgmii_rst                ),

    .s_axis_c0_data         (wm_axis_icmp2ip_data       ),
    .s_axis_c0_user         ({24'd0,wm_axis_icmp2ip_user}),
    .s_axis_c0_keep         (wm_axis_icmp2ip_keep       ),
    .s_axis_c0_last         (wm_axis_icmp2ip_last       ),
    .s_axis_c0_valid        (wm_axis_icmp2ip_valid      ),
    .s_axis_c0_ready        (wm_axis_icmp2ip_ready      ),
    .s_axis_c1_data         (wm_axis_udp2ip_data        ),
    .s_axis_c1_user         ({24'd0,wm_axis_udp2ip_user}),
    .s_axis_c1_keep         (wm_axis_udp2ip_keep        ),
    .s_axis_c1_last         (wm_axis_udp2ip_last        ),
    .s_axis_c1_valid        (wm_axis_udp2ip_valid       ),
    .s_axis_c1_ready        (wm_axis_udp2ip_ready       ),
    .m_axis_out_data        (wm_axis_arbiter_ip_data    ),
    .m_axis_out_user        (wm_axis_arbiter_ip_user    ),
    .m_axis_out_keep        (wm_axis_arbiter_ip_keep    ),
    .m_axis_out_last        (wm_axis_arbiter_ip_last    ),
    .m_axis_out_valid       (wm_axis_arbiter_ip_valid   ),
    .m_axis_out_ready       (wm_axis_arbiter_ip_ready   ) 
);

IP_module#(
    .P_SRC_IP_ADDR          (P_SRC_IP_ADDR              ),
    .P_DST_IP_ADDR          (P_DST_IP_ADDR              )
)IP_module_u0(
    .i_clk                  (i_xgmii_clk                ),
    .i_rst                  (i_xgmii_rst                ),
    .i_dynamic_src_ip       (i_dynamic_src_ip           ),
    .i_dynamic_src_valid    (i_dynamic_src_ip_valid     ),
    .i_dynamic_dst_ip       (i_dynamic_dst_ip           ),
    .i_dynamic_dst_valid    (i_dynamic_dst_ip_valid     ),
    .o_seek_ip              (w_seek_ip                  ),
    .o_seek_ip_valid        (w_seek_ip_valid            ),
    .i_seek_mac             (w_seek_mac                 ),
    .i_seek_mac_valid       (w_seek_mac_valid           ),
    .o_arp_active           (w_ip2arp_active            ),
    .o_arp_active_dst_ip    (w_ip2arp_active_dst_ip     ),
    .m_axis_mac_data        (wm_axis_ip2mac_data        ),
    .m_axis_mac_user        (wm_axis_ip2mac_user        ),
    .m_axis_mac_keep        (wm_axis_ip2mac_keep        ),
    .m_axis_mac_last        (wm_axis_ip2mac_last        ),
    .m_axis_mac_valid       (wm_axis_ip2mac_valid       ),
    .m_axis_mac_ready       (wm_axis_ip2mac_ready       ),
    .s_axis_mac_data        (wm_axis_mac2upper_data     ),
    .s_axis_mac_user        (wm_axis_mac2upper_user     ),
    .s_axis_mac_keep        (wm_axis_mac2upper_keep     ),
    .s_axis_mac_last        (wm_axis_mac2upper_last     ),
    .s_axis_mac_valid       (wm_axis_mac2upper_valid    ),
    .m_axis_upper_data      (wm_axis_ip2upper_data      ),
    .m_axis_upper_user      (wm_axis_ip2upper_user      ),
    .m_axis_upper_keep      (wm_axis_ip2upper_keep      ),
    .m_axis_upper_last      (wm_axis_ip2upper_last      ),
    .m_axis_upper_valid     (wm_axis_ip2upper_valid     ),
    .s_axis_upper_data      (wm_axis_arbiter_ip_data    ),
    .s_axis_upper_user      (wm_axis_arbiter_ip_user    ),
    .s_axis_upper_keep      (wm_axis_arbiter_ip_keep    ),
    .s_axis_upper_last      (wm_axis_arbiter_ip_last    ),
    .s_axis_upper_valid     (wm_axis_arbiter_ip_valid   ),
    .s_axis_upper_ready     (wm_axis_arbiter_ip_ready   ) 
);

ARP_module#(
    .P_DST_IP_ADDR          (P_DST_IP_ADDR      ),
    .P_SRC_IP_ADDR          (P_SRC_IP_ADDR  ),
    .P_SRC_MAC_ADDR         (P_SRC_MAC      )
)ARP_module_u0(
    .i_clk                  (i_xgmii_clk                ),
    .i_rst                  (i_xgmii_rst                ),
    .i_dymanic_src_ip       (i_dynamic_src_ip           ),
    .i_src_ip_valid         (i_dynamic_src_ip_valid     ),
    .i_dymanic_src_mac      (i_dynamic_src_mac          ),
    .i_src_mac_valid        (i_dynamic_src_mac_valid    ),
    .i_arp_active           (i_arp_active               ),
    .i_arp_active_dst_ip    (i_arp_active_dst_ip        ),
    .i_ip2arp_active        (w_ip2arp_active            ),
    .i_ip2arp_active_dst_ip (w_ip2arp_active_dst_ip     ),
    .i_seek_ip              (w_seek_ip                  ),
    .i_seek_valid           (w_seek_ip_valid            ),
    .o_seek_mac             (w_seek_mac                 ),
    .o_seek_mac_valid       (w_seek_mac_valid           ),
    .s_axis_mac_data        (wm_axis_mac2upper_data     ),
    .s_axis_mac_user        (wm_axis_mac2upper_user     ),
    .s_axis_mac_keep        (wm_axis_mac2upper_keep     ),
    .s_axis_mac_last        (wm_axis_mac2upper_last     ),
    .s_axis_mac_valid       (wm_axis_mac2upper_valid    ),
    .m_axis_arp_data        (wm_axis_arp2mac_data       ),
    .m_axis_arp_user        (wm_axis_arp2mac_user       ),
    .m_axis_arp_keep        (wm_axis_arp2mac_keep       ),
    .m_axis_arp_last        (wm_axis_arp2mac_last       ),
    .m_axis_arp_valid       (wm_axis_arp2mac_valid      ),
    .m_axis_arp_ready       (wm_axis_arp2mac_ready      ) 
);

Arbiter_module#(
    .P_ARBITER_LAYER        ("MAC")
)Arbiter_module_mac(
    .i_clk                  (i_xgmii_clk                ),
    .i_rst                  (i_xgmii_rst                ),

    .s_axis_c0_data         (wm_axis_arp2mac_data       ),
    .s_axis_c0_user         (wm_axis_arp2mac_user       ),
    .s_axis_c0_keep         (wm_axis_arp2mac_keep       ),
    .s_axis_c0_last         (wm_axis_arp2mac_last       ),
    .s_axis_c0_valid        (wm_axis_arp2mac_valid      ),
    .s_axis_c0_ready        (wm_axis_arp2mac_ready      ),
    .s_axis_c1_data         (wm_axis_ip2mac_data        ),
    .s_axis_c1_user         (wm_axis_ip2mac_user        ),
    .s_axis_c1_keep         (wm_axis_ip2mac_keep        ),
    .s_axis_c1_last         (wm_axis_ip2mac_last        ),
    .s_axis_c1_valid        (wm_axis_ip2mac_valid       ),
    .s_axis_c1_ready        (wm_axis_ip2mac_ready       ),
    .m_axis_out_data        (wm_axis_arbiter_mac_data   ),
    .m_axis_out_user        (wm_axis_arbiter_mac_user   ),
    .m_axis_out_keep        (wm_axis_arbiter_mac_keep   ),
    .m_axis_out_last        (wm_axis_arbiter_mac_last   ),
    .m_axis_out_valid       (wm_axis_arbiter_mac_valid  ),
    .m_axis_out_ready       (wm_axis_arbiter_mac_ready  ) 
);

TEN_GIG_MAC_module#(
    .P_SRC_MAC              (P_SRC_MAC              ),
    .P_DST_MAC              (P_DST_MAC              )
)TEN_GIG_MAC_module_u0(
    .i_xgmii_clk            (i_xgmii_clk                ),
    .i_xgmii_rst            (i_xgmii_rst                ),
    .i_xgmii_rxd            (i_xgmii_rxd                ),
    .i_xgmii_rxc            (i_xgmii_rxc                ),
    .o_xgmii_txd            (o_xgmii_txd                ),
    .o_xgmii_txc            (o_xgmii_txc                ),

    .i_dynamic_src_mac      (i_dynamic_src_mac          ),
    .i_dynamic_src_valid    (i_dynamic_src_mac_valid    ),
    .i_dynamic_dst_mac      (i_dynamic_dst_mac          ),
    .i_dynamic_dst_valid    (i_dynamic_dst_mac_valid    ),

    .m_axis_rdata           (wm_axis_mac2upper_data     ),
    .m_axis_ruser           (wm_axis_mac2upper_user     ),//用户自定义{16'dlen,对端mac[47:0],16'dr_type}
    .m_axis_rkeep           (wm_axis_mac2upper_keep     ),
    .m_axis_rlast           (wm_axis_mac2upper_last     ),
    .m_axis_rvalid          (wm_axis_mac2upper_valid    ),
    .o_crc_error            (w_crc_error                ),
    .o_crc_valid            (w_crc_valid                ),
    .s_axis_tdata           (wm_axis_arbiter_mac_data   ),
    .s_axis_tuser           (wm_axis_arbiter_mac_user   ),//用户自定义{16'dlen,对端mac[47:0],16'dr_type}
    .s_axis_tkeep           (wm_axis_arbiter_mac_keep   ),
    .s_axis_tlast           (wm_axis_arbiter_mac_last   ),
    .s_axis_tvalid          (wm_axis_arbiter_mac_valid  ),
    .s_axis_tready          (wm_axis_arbiter_mac_ready  )
);





endmodule
