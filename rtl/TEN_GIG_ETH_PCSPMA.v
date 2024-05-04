`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/10 01:19:43
// Design Name: 
// Module Name: TEN_GIG_ETH_PCSPMA
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


module TEN_GIG_ETH_PCSPMA(
    input               i_gt_refclk             ,
    input               i_sys_clk               ,
    input               i_rst                   ,
    input               i_qplllock              ,
    input               i_qplloutclk            ,
    input               i_qplloutrefclk         ,
    output              o_qpllreset             ,
    output              txp                     ,
    output              txn                     ,
    input               rxp                     ,
    input               rxn                     ,
    input               i_sim_speedup_control   ,
    output              o_xgmii_clk             ,   
    input  [63 : 0]     i_xgmii_txd             ,
    input  [7  : 0]     i_xgmii_txc             ,
    output [63 : 0]     o_xgmii_rxd             ,
    output [7  : 0]     o_xgmii_rxc             ,

    output              o_block_sync            ,
    output              o_rst_done              ,
    output              o_pma_link              ,
    output              o_pcs_rx_link           ,
    output              o_tx_disable            
);

wire                coreclk                 ;
wire                txusrclk                ;
wire                txusrclk2               ;
wire                txoutclk                ;
wire                areset_coreclk          ;
wire                gttxreset               ;
wire                gtrxreset               ;
wire                txuserrdy               ;
wire                reset_counter_done      ;
wire                tx_resetdone            ;
wire                rx_resetdone            ;

wire [7 :0]         core_status             ;
wire [447:0]        status_vector           ;
wire [535:0]        configuration_vector    ;
wire                drp_gnt                 ;
wire                drp_req                 ;
wire                drp_den_o               ;
wire                drp_dwe_o               ;
wire [15 : 0]       drp_daddr_o             ;
wire [15 : 0]       drp_di_o                ;
wire                drp_drdy_o              ;
wire [15 : 0]       drp_drpdo_o             ;
wire                drp_den_i               ;
wire                drp_dwe_i               ;
wire [15 : 0]       drp_daddr_i             ;
wire [15 : 0]       drp_di_i                ;
wire                drp_drdy_i              ;
wire [15 : 0]       drp_drpdo_i             ;

assign drp_gnt = drp_req;
assign drp_den_i = drp_den_o;
assign drp_dwe_i = drp_dwe_o;
assign drp_daddr_i = drp_daddr_o;
assign drp_di_i = drp_di_o;
assign drp_drdy_i = drp_drdy_o;
assign drp_drpdo_i = drp_drpdo_o;

assign o_xgmii_clk      = coreclk;
assign o_block_sync     = core_status[0];
assign o_rst_done       = tx_resetdone & rx_resetdone;
assign o_pma_link       = status_vector[18];
assign o_pcs_rx_link    = status_vector[226];
assign configuration_vector[399:384] = 16'h4C4B;
assign configuration_vector[535:400] = 136'd0;
assign configuration_vector[383:1]   = 383'd0;
assign configuration_vector[0:0]     = 0;//PMA LOOPBACK

ten_gig_eth_pcs_pma_0_shared_clock_and_reset ten_gig_eth_pcs_pma_shared_clock_reset_block
(
    .areset                 (i_rst              ),
    .refclk                 (i_gt_refclk        ),
    .coreclk                (coreclk            ),
    .txoutclk               (txoutclk           ),
    .qplllock               (i_qplllock         ),
    .areset_coreclk         (areset_coreclk     ),
    .gttxreset              (gttxreset          ),
    .gtrxreset              (gtrxreset          ),
    .txuserrdy              (txuserrdy          ),
    .txusrclk               (txusrclk           ),
    .txusrclk2              (txusrclk2          ),
    .qpllreset              (o_qpllreset        ),
    .reset_counter_done     (reset_counter_done )
);

ten_gig_eth_pcs_pma_0 ten_gig_eth_pcs_pma_u0 (
    .rxrecclk_out           (                       ),  // output wire rxrecclk_out
    .coreclk                (coreclk                ),  // input wire coreclk
    .dclk                   (i_sys_clk              ),  // input wire dclk
    .txusrclk               (txusrclk               ),  // input wire txusrclk
    .txusrclk2              (txusrclk2              ),  // input wire txusrclk2
    .areset                 (i_rst                  ),  // input wire areset
    .txoutclk               (txoutclk               ),  // output wire txoutclk
    .areset_coreclk         (areset_coreclk         ),  // input wire areset_coreclk
    .gttxreset              (gttxreset              ),  // input wire gttxreset
    .gtrxreset              (gtrxreset              ),  // input wire gtrxreset
    .txuserrdy              (txuserrdy              ),  // input wire txuserrdy
    .qplllock               (i_qplllock             ),  // input wire qplllock
    .qplloutclk             (i_qplloutclk           ),  // input wire qplloutclk
    .qplloutrefclk          (i_qplloutrefclk        ),  // input wire qplloutrefclk
    .reset_counter_done     (reset_counter_done     ),  // input wire reset_counter_done
    .txp                    (txp                    ),  // output wire txp
    .txn                    (txn                    ),  // output wire txn
    .rxp                    (rxp                    ),  // input wire rxp
    .rxn                    (rxn                    ),  // input wire rxn
    .sim_speedup_control    (i_sim_speedup_control  ),  // input wire sim_speedup_control
    .xgmii_txd              (i_xgmii_txd            ),  // input wire [63 : 0] xgmii_txd
    .xgmii_txc              (i_xgmii_txc            ),  // input wire [7 : 0] xgmii_txc
    .xgmii_rxd              (o_xgmii_rxd            ),  // output wire [63 : 0] xgmii_rxd
    .xgmii_rxc              (o_xgmii_rxc            ),  // output wire [7 : 0] xgmii_rxc
    .configuration_vector   (configuration_vector   ),  // input wire [535 : 0] configuration_vector
    .status_vector          (status_vector          ),  // output wire [447 : 0] status_vector
    .core_status            (core_status            ),  // output wire [7 : 0] core_status
    .tx_resetdone           (tx_resetdone           ),  // output wire tx_resetdone
    .rx_resetdone           (rx_resetdone           ),  // output wire rx_resetdone
    .signal_detect          (1                      ),  // input wire signal_detect
    .tx_fault               (0                      ),  // input wire tx_fault
    .drp_req                (drp_req                ),  // output wire drp_req
    .drp_gnt                (drp_gnt                ),  // input wire drp_gnt
    .drp_den_o              (drp_den_o              ),  // output wire drp_den_o
    .drp_dwe_o              (drp_dwe_o              ),  // output wire drp_dwe_o
    .drp_daddr_o            (drp_daddr_o            ),  // output wire [15 : 0] drp_daddr_o
    .drp_di_o               (drp_di_o               ),  // output wire [15 : 0] drp_di_o
    .drp_drdy_o             (drp_drdy_o             ),  // output wire drp_drdy_o
    .drp_drpdo_o            (drp_drpdo_o            ),  // output wire [15 : 0] drp_drpdo_o
    .drp_den_i              (drp_den_i              ),  // input wire drp_den_i
    .drp_dwe_i              (drp_dwe_i              ),  // input wire drp_dwe_i
    .drp_daddr_i            (drp_daddr_i            ),  // input wire [15 : 0] drp_daddr_i
    .drp_di_i               (drp_di_i               ),  // input wire [15 : 0] drp_di_i
    .drp_drdy_i             (drp_drdy_i             ),  // input wire drp_drdy_i
    .drp_drpdo_i            (drp_drpdo_i            ),  // input wire [15 : 0] drp_drpdo_i
    .tx_disable             (o_tx_disable           ),  // output wire tx_disable
    .pma_pmd_type           (3'b111                 )   // input wire [2 : 0] pma_pmd_type
);


endmodule
