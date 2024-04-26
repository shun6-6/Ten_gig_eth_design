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
    //parameter       P_DST_MAC = 48'h3c_fd_fe_d2_37_0a
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
(* MARK_DEBUG = "TRUE" *)wire [63 : 0]   w_xgmii_txd     ;
(* MARK_DEBUG = "TRUE" *)wire [7  : 0]   w_xgmii_txc     ;
(* MARK_DEBUG = "TRUE" *)wire [63 : 0]   w_xgmii_rxd     ;
(* MARK_DEBUG = "TRUE" *)wire [7  : 0]   w_xgmii_rxc     ;

wire            w_block_sync    ;
wire            w_rst_done      ;
wire            w_pma_link      ;
wire            w_pcs_rx_link   ;

(* MARK_DEBUG = "TRUE" *)wire [63:0]     m_axis_rdata        ;
(* MARK_DEBUG = "TRUE" *)wire [79:0]     m_axis_ruser        ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]     m_axis_rkeep        ;
(* MARK_DEBUG = "TRUE" *)wire            m_axis_rlast        ;
(* MARK_DEBUG = "TRUE" *)wire            m_axis_rvalid       ;
(* MARK_DEBUG = "TRUE" *)wire            w_crc_error         ;
(* MARK_DEBUG = "TRUE" *)wire            w_crc_valid         ;

wire [63:0]     s_axis_tdata        ;
wire [79:0]     s_axis_tuser        ;
wire [7 :0]     s_axis_tkeep        ;
wire            s_axis_tlast        ;
wire            s_axis_tvalid       ;
wire            s_axis_tready       ;


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

// AXIS_test_module AXIS_test_module_u0(
//     .i_clk                  (w_xgmii_clk        ),
//     .i_rst                  (w_xgmii_rst || (!w_block_sync)),
//     .m_axis_tdata           (s_axis_tdata       ),
//     .m_axis_tuser           (s_axis_tuser       ),
//     .m_axis_tkeep           (s_axis_tkeep       ),
//     .m_axis_tlast           (s_axis_tlast       ),
//     .m_axis_tvalid          (s_axis_tvalid      ),
//     .s_axis_tready          (s_axis_tready      )
// );



TEN_GIG_MAC_module #(
    .P_SRC_MAC              (P_SRC_MAC),
    .P_DST_MAC              (P_DST_MAC)
)TEN_GIG_MAC_module_u0(
    .i_xgmii_clk            (w_xgmii_clk        ),
    .i_xgmii_rst            (w_xgmii_rst        ),
    .i_xgmii_rxd            (w_xgmii_rxd        ),
    .i_xgmii_rxc            (w_xgmii_rxc        ),
    .o_xgmii_txd            (w_xgmii_txd        ),
    .o_xgmii_txc            (w_xgmii_txc        ),
    
    .i_dynamic_src_mac      (48'd0),
    .i_dynamic_src_valid    (0),
    .i_dynamic_dst_mac      (48'd0),
    .i_dynamic_dst_valid    (0),

    .m_axis_rdata           (m_axis_rdata       ),
    .m_axis_ruser           (m_axis_ruser       ),
    .m_axis_rkeep           (m_axis_rkeep       ),
    .m_axis_rlast           (m_axis_rlast       ),
    .m_axis_rvalid          (m_axis_rvalid      ),
    .o_crc_error            (w_crc_error        ),
    .o_crc_valid            (w_crc_valid        ),
    .s_axis_tdata           (s_axis_tdata       ),
    .s_axis_tuser           (s_axis_tuser       ),
    .s_axis_tkeep           (s_axis_tkeep       ),
    .s_axis_tlast           (s_axis_tlast       ),
    .s_axis_tvalid          (s_axis_tvalid      ),
    .s_axis_tready          (s_axis_tready      )
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
