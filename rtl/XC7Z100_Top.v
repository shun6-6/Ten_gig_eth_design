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


module XC7Z100_Top(
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

(* MARK_DEBUG = "TRUE" *)wire w_tx_disable;

wire            w_sys_clk       ;
wire            w_sys_rst       ;
wire            w_gt_refclk     ;
(* MARK_DEBUG = "TRUE" *)wire            w_qplllock      ;
wire            w_qplloutclk    ;
wire            w_qplloutrefclk ;
wire            w_qpllreset     ;

wire            w_xgmii_clk     ;
wire            w_xgmii_rst     ;
(* MARK_DEBUG = "TRUE" *)wire [63 : 0]   w_xgmii_txd     ;
(* MARK_DEBUG = "TRUE" *)wire [7  : 0]   w_xgmii_txc     ;
(* MARK_DEBUG = "TRUE" *)wire [63 : 0]   w_xgmii_rxd     ;
(* MARK_DEBUG = "TRUE" *)wire [7  : 0]   w_xgmii_rxc     ;

(* MARK_DEBUG = "TRUE" *)wire            w_block_sync    ;
(* MARK_DEBUG = "TRUE" *)wire            w_rst_done      ;
(* MARK_DEBUG = "TRUE" *)wire            w_pma_link      ;
(* MARK_DEBUG = "TRUE" *)wire            w_pcs_rx_link   ;

wire [63:0]     w_xgmii_rxd_little  ;
wire [7 :0]     w_xgmii_rxc_little  ;
wire [63:0]     w_xgmii_txd_little  ;
wire [7 :0]     w_xgmii_txc_little  ;

wire [63:0]     m_axis_rdata        ;
wire [31:0]     m_axis_ruser        ;
wire [7 :0]     m_axis_rkeep        ;
wire            m_axis_rlast        ;
wire            m_axis_rvalid       ;
wire [63:0]     s_axis_tdata        ;
wire [31:0]     s_axis_tuser        ;
wire [7 :0]     s_axis_tkeep        ;
wire            s_axis_tlast        ;
wire            s_axis_tvalid       ;
wire            s_axis_tready       ;


assign w_xgmii_rxd   = {w_xgmii_rxd_little[7 :0],w_xgmii_rxd_little[15:8],w_xgmii_rxd_little[23:16],w_xgmii_rxd_little[31:24],
                        w_xgmii_rxd_little[39:32],w_xgmii_rxd_little[47:40],w_xgmii_rxd_little[55:48],w_xgmii_rxd_little[63:56]};
assign w_xgmii_rxc   = {w_xgmii_rxc_little[0],w_xgmii_rxc_little[1],w_xgmii_rxc_little[2],w_xgmii_rxc_little[3],
                        w_xgmii_rxc_little[4],w_xgmii_rxc_little[5],w_xgmii_rxc_little[6],w_xgmii_rxc_little[7]};
assign w_xgmii_txd_little = {w_xgmii_txd[7 :0],w_xgmii_txd[15:8],w_xgmii_txd[23:16],w_xgmii_txd[31:24],
                            w_xgmii_txd[39:32],w_xgmii_txd[47:40],w_xgmii_txd[55:48],w_xgmii_txd[63:56]};
assign w_xgmii_txc_little = {w_xgmii_txc[0],w_xgmii_txc[1],w_xgmii_txc[2],w_xgmii_txc[3],
                            w_xgmii_txc[4],w_xgmii_txc[5],w_xgmii_txc[6],w_xgmii_txc[7]};

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


TenG_PCAPMA_Test TenG_PCAPMA_Test_u0(
    .i_xgmii_clk                    (w_xgmii_clk        ),
    .i_xgmii_rst                    (w_xgmii_rst        ),
    .i_xgmii_rxd                    (w_xgmii_rxd        ),
    .i_xgmii_rxc                    (w_xgmii_rxc        ),
    .o_xgmii_txd                    (w_xgmii_txd        ),
    .o_xgmii_txc                    (w_xgmii_txc        )  
);  

TEN_GIG_MAC_module TEN_GIG_MAC_module_u0(
    .i_xgmii_clk            (w_xgmii_clk        ),
    .i_xgmii_rst            (w_xgmii_rst        ),
    .i_xgmii_rxd            (w_xgmii_rxd        ),
    .i_xgmii_rxc            (w_xgmii_rxc        ),
    .o_xgmii_txd            (w_xgmii_txd        ),
    .o_xgmii_txc            (w_xgmii_txc        ),
    .m_axis_rdata           (m_axis_rdata       ),
    .m_axis_ruser           (m_axis_ruser       ),
    .m_axis_rkeep           (m_axis_rkeep       ),
    .m_axis_rlast           (m_axis_rlast       ),
    .m_axis_rvalid          (m_axis_rvalid      ),
    .s_axis_tdata           (0),
    .s_axis_tuser           (0),
    .s_axis_tkeep           (0),
    .s_axis_tlast           (0),
    .s_axis_tvalid          (0),
    .s_axis_tready          ()
);


TEN_GIG_ETH_PCSPMA TEN_GIG_ETH_PCSPMA_u0(
    .i_gt_refclk            (w_gt_refclk        ),
    .i_sys_clk              (w_sys_clk          ),
    .i_rst                  (w_sys_rst          ),
    .i_qplllock             (w_qplllock         ),
    .i_qplloutclk           (w_qplloutclk       ),
    .i_qplloutrefclk        (w_qplloutrefclk    ),
    .o_qpllreset            (w_qpllreset        ),
    .txp                    (o_gt_txp           ),
    .txn                    (o_gt_txn           ),
    .rxp                    (i_gt_rxp           ),
    .rxn                    (i_gt_rxn           ),
    .i_sim_speedup_control  (0),
    .o_xgmii_clk            (w_xgmii_clk        ),   
    .i_xgmii_txd            (w_xgmii_txd_little ),
    .i_xgmii_txc            (w_xgmii_txc_little ),
    .o_xgmii_rxd            (w_xgmii_rxd_little ),
    .o_xgmii_rxc            (w_xgmii_rxc_little ),
    .o_block_sync           (w_block_sync       ),
    .o_rst_done             (w_rst_done         ),
    .o_pma_link             (w_pma_link         ),
    .o_pcs_rx_link          (w_pcs_rx_link      ),
    .o_tx_disable           (w_tx_disable       ) 
);


endmodule
