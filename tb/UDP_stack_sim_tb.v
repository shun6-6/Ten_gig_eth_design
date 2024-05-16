`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/27 10:28:35
// Design Name: 
// Module Name: UDP_stack_sim_tb
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


module UDP_stack_sim_tb();

reg clk,rst;

always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end

initial begin
    rst = 1;
    #20;
    @(posedge clk) rst = 0;
end

wire [63:0] ws_axis_user_data   ;
wire [31:0] ws_axis_user_user   ;
wire [7 :0] ws_axis_user_keep   ;
wire        ws_axis_user_last   ;
wire        ws_axis_user_valid  ;
wire        ws_axis_user_ready  ;

wire [63:0] wm_axis_user_data   ;
wire [31:0] wm_axis_user_user   ;
wire [7 :0] wm_axis_user_keep   ;
wire        wm_axis_user_last   ;
wire        wm_axis_user_valid  ;

wire [63:0]   w_xgmii_txd   ;
wire [7 :0]   w_xgmii_txc   ;
wire [63:0]   o_xgmii_txd   ;
wire [7 :0]   o_xgmii_txc   ;
wire [63:0]   w_xgmii_rxd_7h55   ;
wire [7 :0]   w_xgmii_rxc_7h55   ;

reg         r_arp_active        ;
reg  [31:0] r_arp_active_dst_ip ;

assign o_xgmii_txd = {w_xgmii_txd[7 :0],w_xgmii_txd[15:8],w_xgmii_txd[23:16],w_xgmii_txd[31:24],
                            w_xgmii_txd[39:32],w_xgmii_txd[47:40],w_xgmii_txd[55:48],w_xgmii_txd[63:56]};
assign o_xgmii_txc = {w_xgmii_txc[0],w_xgmii_txc[1],w_xgmii_txc[2],w_xgmii_txc[3],
                            w_xgmii_txc[4],w_xgmii_txc[5],w_xgmii_txc[6],w_xgmii_txc[7]};

initial begin
    r_arp_active        = 'd0;
    r_arp_active_dst_ip = 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);
    r_arp_active        = 'd1;
    r_arp_active_dst_ip = {8'd192,8'd168,8'd100,8'd99};
    @(posedge clk);
    r_arp_active        = 'd0;
    r_arp_active_dst_ip = 'd0;
end

AXIS_test_module#(
    .P_SEND_PKT_LEN (16'd24)
) AXIS_test_module_u0(
    .i_clk              (clk),
    .i_rst              (rst),
    .m_axis_tdata       (ws_axis_user_data ),
    .m_axis_tuser       (ws_axis_user_user ),
    .m_axis_tkeep       (ws_axis_user_keep ),
    .m_axis_tlast       (ws_axis_user_last ),
    .m_axis_tvalid      (ws_axis_user_valid),
    .s_axis_tready      (ws_axis_user_ready) 
);

UDP_10G_Stack#(
    .P_SRC_MAC        (48'h01_02_03_04_05_06        ),
    //.P_DST_MAC        (48'h01_02_03_04_05_06        ),
    .P_DST_MAC        (48'h00_ff_ff_ff_ff_ff        ),
    .P_SRC_IP_ADDR    ({8'd192,8'd168,8'd100,8'd99} ),
    .P_DST_IP_ADDR    ({8'd192,8'd168,8'd100,8'd99} ),
    .P_SRC_UDP_PORT   (16'h8080                     ),
    .P_DST_UDP_PORT   (16'h8080                     )

)UDP_10G_Stack_u0(
    .i_xgmii_clk                (clk        ),
    .i_xgmii_rst                (rst        ),
    .i_xgmii_rxd                (w_xgmii_txd        ),
    .i_xgmii_rxc                (w_xgmii_txc        ),
    .o_xgmii_txd                (w_xgmii_txd        ),
    .o_xgmii_txc                (w_xgmii_txc        ),
    .i_dynamic_src_mac          (0),
    .i_dynamic_src_mac_valid    (0),
    .i_dynamic_dst_mac          (0),
    .i_dynamic_dst_mac_valid    (0),
    .i_dymanic_src_port         (0),
    .i_dymanic_src_port_valid   (0),
    .i_dymanic_dst_port         (0),
    .i_dymanic_dst_port_valid   (0),
    .i_dynamic_src_ip           (0),
    .i_dynamic_src_ip_valid     (0),
    .i_dynamic_dst_ip           (0),
    .i_dynamic_dst_ip_valid     (0),
    // .i_arp_active               (r_arp_active       ),
    // .i_arp_active_dst_ip        (r_arp_active_dst_ip),
    .i_arp_active               (0),
    .i_arp_active_dst_ip        (0),
    /****user data****/
    .m_axis_user_data           (),
    .m_axis_user_user           (),
    .m_axis_user_keep           (),
    .m_axis_user_last           (),
    .m_axis_user_valid          (),
    .s_axis_user_data           (ws_axis_user_data  ),
    .s_axis_user_user           (ws_axis_user_user  ),
    .s_axis_user_keep           (ws_axis_user_keep  ),
    .s_axis_user_last           (ws_axis_user_last  ),
    .s_axis_user_valid          (ws_axis_user_valid ),
    .s_axis_user_ready          (ws_axis_user_ready) 
);

MAC_RX_header MAC_RX_header_u0(
    .i_clk                  (clk            ),
    .i_rst                  (rst            ),

    .i_xgmii_rxd            (o_xgmii_txd            ),
    .i_xgmii_rxc            (o_xgmii_txc            ),

    .o_xgmii_rxd            (w_xgmii_rxd_7h55       ),
    .o_xgmii_rxc            (w_xgmii_rxc_7h55       )
);


TEN_GIG_MAC_RX#(
    .P_SRC_MAC              (48'h01_02_03_04_05_66),
    .P_DST_MAC              (48'h00_ff_ff_ff_ff_ff)
) TEN_GIG_MAC_RX_u0(
    .i_clk                  (clk        ),
    .i_rst                  (rst        ),
    .i_dynamic_src_mac      (0),
    .i_dynamic_src_valid    (0),
    .i_dynamic_dst_mac      (0),
    .i_dynamic_dst_valid    (0),    
    .i_xgmii_rxd            (w_xgmii_rxd_7h55),
    .i_xgmii_rxc            (w_xgmii_rxc_7h55),


    .m_axis_rdata           (),
    .m_axis_ruser           (),
    .m_axis_rkeep           (),
    .m_axis_rlast           (),
    .m_axis_rvalid          (),
    .o_crc_error            (),
    .o_crc_valid            ()
);

endmodule
