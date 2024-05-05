`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 09:12:15
// Design Name: 
// Module Name: XC7Z100_Top
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


module XC7Z100_Top#(
    parameter       P_SRC_MAC = 48'h01_02_03_04_05_06,
    parameter       P_DST_MAC = 48'hff_ff_ff_ff_ff_ff
)(
    input           i_sys_clk_p     ,
    input           i_sys_clk_n     ,
    input           i_gt_refclk_p   ,
    input           i_gt_refclk_n   ,
    input           i_gt_rxp        ,
    input           i_gt_rxn        ,
    output          o_gt_txp        ,
    output          o_gt_txn        ,
    output          o_tx_disable
);
assign o_tx_disable = 0;

reg r_sim_ctrl = 0;
wire w_tx_disable;

wire            w_sys_clk       ;
wire            w_sys_rst       ;
wire            w_gt_refclk     ;
wire            w_qplllock      ;
wire            w_qplloutclk    ;
wire            w_qplloutrefclk ;
wire            w_qpllreset     ;

wire            w_xgmii_clk     ;
wire            w_xgmii_rst     ;
wire [63 : 0]   w_xgmii_txd     ;
wire [7  : 0]   w_xgmii_txc     ;
wire [63 : 0]   w_xgmii_rxd     ;
wire [7  : 0]   w_xgmii_rxc     ;

wire            w_block_sync    ;
wire            w_rst_done      ;
wire            w_pma_link      ;
wire            w_pcs_rx_link   ;

(* MARK_DEBUG = "TRUE" *)wire [63:0]     wm_axis_user_data   ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]     wm_axis_user_user   ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]     wm_axis_user_keep   ;
(* MARK_DEBUG = "TRUE" *)wire            wm_axis_user_last   ;
(* MARK_DEBUG = "TRUE" *)wire            wm_axis_user_valid  ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]     ws_axis_user_data   ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]     ws_axis_user_user   ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]     ws_axis_user_keep   ;
(* MARK_DEBUG = "TRUE" *)wire            ws_axis_user_last   ;
(* MARK_DEBUG = "TRUE" *)wire            ws_axis_user_valid  ;
(* MARK_DEBUG = "TRUE" *)wire            ws_axis_user_ready  ;


IBUFDS #(
    .DIFF_TERM      ("FALSE"            ), 
    .IBUF_LOW_PWR   ("TRUE"             ), 
    .IOSTANDARD     ("DEFAULT"          )  
)
IBUFDS_u0
(
    .O              (w_sys_clk          ),
    .I              (i_sys_clk_p        ),
    .IB             (i_sys_clk_n        ) 
);

IBUFDS_GTE2 IBUFDS_GTE2_gtrefclk
(
    .O     (w_gt_refclk ),
    .ODIV2 (),
    .CEB   (1'b0),
    .I     (i_gt_refclk_p),
    .IB    (i_gt_refclk_n)
);

rst_gen_module#(
    .P_RST_CYCLE            (20         )   
)
rst_gen_module_sys_rst
(
    .i_clk                  (w_sys_clk  ),
    .i_rst                  (0          ),
    .o_rst                  (w_sys_rst  )
);

rst_gen_module#(
    .P_RST_CYCLE            (20         )   
)
rst_gen_module_xgmii_rst 
(
    .i_clk                  (w_xgmii_clk),
    .i_rst                  (~w_rst_done),
    .o_rst                  (w_xgmii_rst)
);

ten_gig_eth_pcs_pma_0_gt_common # (
    .WRAPPER_SIM_GTRESET_SPEEDUP("TRUE") ) //Does not affect hardware
ten_gig_eth_pcs_pma_gt_common_block
(
    .refclk                 (w_gt_refclk        ),
    .qpllreset              (w_qpllreset        ),
    .qplllock               (w_qplllock         ),
    .qplloutclk             (w_qplloutclk       ),
    .qplloutrefclk          (w_qplloutrefclk    )
);

AXIS_test_module AXIS_test_module_u0(
    .i_clk                  (w_xgmii_clk        ),
    .i_rst                  (w_xgmii_rst || (!w_block_sync)),
    .m_axis_tdata           (ws_axis_user_data  ),
    .m_axis_tuser           (ws_axis_user_user  ),
    .m_axis_tkeep           (ws_axis_user_keep  ),
    .m_axis_tlast           (ws_axis_user_last  ),
    .m_axis_tvalid          (ws_axis_user_valid ),
    .s_axis_tready          (ws_axis_user_ready )
);

UDP_10G_Stack#(
    .P_SRC_MAC        (P_SRC_MAC                    ),
    .P_DST_MAC        (P_DST_MAC                    ),
    .P_SRC_IP_ADDR    ({8'd192,8'd168,8'd100,8'd100} ),
    .P_DST_IP_ADDR    ({8'd192,8'd168,8'd100,8'd90}),
    .P_SRC_UDP_PORT   (16'h8080                     ),
    .P_DST_UDP_PORT   (16'h8080                     )

)UDP_10G_Stack_u0(
    .i_xgmii_clk                (w_xgmii_clk        ),
    .i_xgmii_rst                (w_xgmii_rst || (!w_block_sync)),
    .i_xgmii_rxd                (w_xgmii_rxd        ),
    .i_xgmii_rxc                (w_xgmii_rxc        ),
    .o_xgmii_txd                (w_xgmii_txd        ),
    .o_xgmii_txc                (w_xgmii_txc        ),
    .i_dynamic_src_mac          (48'd0),
    .i_dynamic_src_mac_valid    (0),
    .i_dynamic_dst_mac          (48'd0),
    .i_dynamic_dst_mac_valid    (0),
    .i_dymanic_src_port         (0),
    .i_dymanic_src_port_valid   (0),
    .i_dymanic_dst_port         (0),
    .i_dymanic_dst_port_valid   (0),
    .i_dynamic_src_ip           (0),
    .i_dynamic_src_ip_valid     (0),
    .i_dynamic_dst_ip           (0),
    .i_dynamic_dst_ip_valid     (0),
    .i_arp_active               (0),
    .i_arp_active_dst_ip        (0),
    /****user data****/
    //回环模式
    .m_axis_user_data           (wm_axis_user_data  ),
    .m_axis_user_user           (wm_axis_user_user  ),
    .m_axis_user_keep           (wm_axis_user_keep  ),
    .m_axis_user_last           (wm_axis_user_last  ),
    .m_axis_user_valid          (wm_axis_user_valid ),
    .s_axis_user_data           (wm_axis_user_data  ),
    .s_axis_user_user           (wm_axis_user_user  ),
    .s_axis_user_keep           (wm_axis_user_keep  ),
    .s_axis_user_last           (wm_axis_user_last  ),
    .s_axis_user_valid          (wm_axis_user_valid ),
    .s_axis_user_ready          ( ) 
    //板卡主动发送模式
    // .m_axis_user_data           (wm_axis_user_data  ),
    // .m_axis_user_user           (wm_axis_user_user  ),
    // .m_axis_user_keep           (wm_axis_user_keep  ),
    // .m_axis_user_last           (wm_axis_user_last  ),
    // .m_axis_user_valid          (wm_axis_user_valid ),
    // .s_axis_user_data           (ws_axis_user_data  ),
    // .s_axis_user_user           (ws_axis_user_user  ),
    // .s_axis_user_keep           (ws_axis_user_keep  ),
    // .s_axis_user_last           (ws_axis_user_last  ),
    // .s_axis_user_valid          (ws_axis_user_valid ),
    // .s_axis_user_ready          (ws_axis_user_ready ) 
);


TEN_GIG_ETH_PCSPMA TEN_GIG_ETH_PCSPMA_u0(
    .i_gt_refclk            (w_gt_refclk        ),
    .i_sys_clk              (w_sys_clk          ),
    .i_rst                  (0),
    .i_qplllock             (w_qplllock         ),
    .i_qplloutclk           (w_qplloutclk       ),
    .i_qplloutrefclk        (w_qplloutrefclk    ),
    .o_qpllreset            (w_qpllreset        ),
    .txp                    (o_gt_txp           ),
    .txn                    (o_gt_txn           ),
    .rxp                    (i_gt_rxp           ),
    .rxn                    (i_gt_rxn           ),
    .i_sim_speedup_control  (r_sim_ctrl),
    .o_xgmii_clk            (w_xgmii_clk        ),   
    .i_xgmii_txd            (w_xgmii_txd        ),
    .i_xgmii_txc            (w_xgmii_txc        ),
    .o_xgmii_rxd            (w_xgmii_rxd        ),
    .o_xgmii_rxc            (w_xgmii_rxc        ),
    .o_block_sync           (w_block_sync       ),
    .o_rst_done             (w_rst_done         ),
    .o_pma_link             (w_pma_link         ),
    .o_pcs_rx_link          (w_pcs_rx_link      ),
    .o_tx_disable           (w_tx_disable       ) 
);

always @(posedge w_xgmii_clk)begin
    if(!w_sys_rst)
    r_sim_ctrl <= 'd1;
end

endmodule
