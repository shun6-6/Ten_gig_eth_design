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

wire [63:0]   o_xgmii_txd   ;
wire [7 :0]   o_xgmii_txc   ;

reg         r_arp_active        ;
reg  [31:0] r_arp_active_dst_ip ;

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

AXIS_test_module AXIS_test_module_u0(
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
    .P_DST_MAC        (48'h01_02_03_04_05_06        ),
    //.P_DST_MAC        (48'hff_ff_ff_ff_ff_ff        ),
    .P_SRC_IP_ADDR    ({8'd192,8'd168,8'd100,8'd99} ),
    .P_DST_IP_ADDR    ({8'd192,8'd168,8'd100,8'd99} ),
    .P_SRC_UDP_PORT   (16'h0808                     ),
    .P_DST_UDP_PORT   (16'h0808                     )

)UDP_10G_Stack_u0(
    .i_xgmii_clk                (clk        ),
    .i_xgmii_rst                (rst        ),
    .i_xgmii_rxd                (o_xgmii_txd        ),
    .i_xgmii_rxc                (o_xgmii_txc        ),
    .o_xgmii_txd                (o_xgmii_txd        ),
    .o_xgmii_txc                (o_xgmii_txc        ),
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


endmodule
