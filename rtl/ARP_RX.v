`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 16:00:51
// Design Name: 
// Module Name: ARP_RX
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


module ARP_RX#(
    parameter       P_SRC_IP_ADDR   = {8'd192,8'd168,8'd100,8'd99},
    parameter       P_SRC_MAC_ADDR  = 48'h01_02_03_04_05_06
)(
    input           i_clk               ,
    input           i_rst               ,

    output [47:0]   o_recv_target_mac   ,
    output [31:0]   o_recv_target_ip    ,
    output          o_recv_target_valid ,
    output          o_arp_reply         ,
    input  [31:0]   i_dymanic_src_ip    ,
    input           i_src_ip_valid      ,

    input  [63:0]   s_axis_mac_data     ,
    input  [79:0]   s_axis_mac_user     ,
    input  [7 :0]   s_axis_mac_keep     ,
    input           s_axis_mac_last     ,
    input           s_axis_mac_valid    
);
/******************************function*****************************/

/******************************parameter****************************/
localparam      P_ARP_REPLY     = 16'd2 ;
localparam      P_ARP_REQUEST   = 16'd1 ;
/******************************mechine******************************/

/******************************reg**********************************/
reg  [63:0]     rs_axis_mac_data    ;
reg  [79:0]     rs_axis_mac_user    ;
reg  [7 :0]     rs_axis_mac_keep    ;
reg             rs_axis_mac_last    ;
reg             rs_axis_mac_valid   ;
(* MARK_DEBUG = "TRUE" *)reg  [47:0]     ro_recv_target_mac  ;
(* MARK_DEBUG = "TRUE" *)reg  [31:0]     ro_recv_target_ip   ;
(* MARK_DEBUG = "TRUE" *)reg             ro_recv_target_valid;
reg  [31:0]     r_dymanic_src_ip    ;

reg  [15:0]     r_recv_cnt          ;
reg  [15:0]     r_arp_option        ;
reg             r_arp_pkt_valid     ;
(* MARK_DEBUG = "TRUE" *)reg             ro_arp_reply        ;
reg  [31:0]     r_arp_target_ip     ;
/******************************wire*********************************/

/******************************component****************************/
ila_arp_rx ila_arp_rx0 (
	.clk(i_clk), // input wire clk
	.probe0(ro_recv_target_mac  ), // input wire [47:0]  probe0  
	.probe1(ro_recv_target_ip   ), // input wire [31:0]  probe1 
	.probe2(ro_recv_target_valid), // input wire [0:0]  probe2 
	.probe3(ro_arp_reply        ), // input wire [0:0]  probe3 
	.probe4(rs_axis_mac_data    ), // input wire [63:0]  probe4 
	.probe5(rs_axis_mac_user    ), // input wire [79:0]  probe5 
	.probe6(rs_axis_mac_keep    ), // input wire [7:0]  probe6 
	.probe7(rs_axis_mac_last    ), // input wire [0:0]  probe7 
	.probe8(rs_axis_mac_valid   ) // input wire [0:0]  probe8
);
/******************************assign*******************************/
assign o_recv_target_mac   = ro_recv_target_mac     ;
assign o_recv_target_ip    = ro_recv_target_ip      ;
assign o_recv_target_valid = ro_recv_target_valid   ;
assign o_arp_reply = ro_arp_reply;
/******************************always*******************************/

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_dymanic_src_ip <= P_SRC_IP_ADDR;
    else if(i_src_ip_valid)
        r_dymanic_src_ip <= i_dymanic_src_ip;
    else
        r_dymanic_src_ip <= r_dymanic_src_ip;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        rs_axis_mac_data  <= 'd0;
        rs_axis_mac_user  <= 'd0;
        rs_axis_mac_keep  <= 'd0;
        rs_axis_mac_last  <= 'd0;
        rs_axis_mac_valid <= 'd0;
    end
    else begin
        rs_axis_mac_data  <= s_axis_mac_data ;
        rs_axis_mac_user  <= s_axis_mac_user ;
        rs_axis_mac_keep  <= s_axis_mac_keep ;
        rs_axis_mac_last  <= s_axis_mac_last ;
        rs_axis_mac_valid <= s_axis_mac_valid;
    end  
end

//判断当前数据包是否是arp
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_arp_pkt_valid <= 'd0;
    else if(s_axis_mac_valid && !rs_axis_mac_valid && s_axis_mac_user[15:0] == 16'h0806)
        r_arp_pkt_valid <= 'd1;
    else if(s_axis_mac_valid && !rs_axis_mac_valid && s_axis_mac_user[15:0] != 16'h0806)
        r_arp_pkt_valid <= 'd0;
    else
        r_arp_pkt_valid <= r_arp_pkt_valid;
end

//接收计数器
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_recv_cnt <= 'd0;
    else if(rs_axis_mac_valid)
        r_recv_cnt <= r_recv_cnt + 'd1;
    else
        r_recv_cnt <= 'd0;
end

//获取arp操作类型
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_arp_option <= 'd0;
    else if(r_recv_cnt == 0 && rs_axis_mac_valid && r_arp_pkt_valid)
        r_arp_option <= rs_axis_mac_data[15:0];
    else
        r_arp_option <= r_arp_option;
end

//此处target含义表示对于本地来说的目的地址，所以需要获取的是报文当中的源地址字段
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        ro_recv_target_mac <= 'd0;
    else if(r_recv_cnt == 1 && r_arp_pkt_valid)
        ro_recv_target_mac <= rs_axis_mac_data[63:16];
    else
        ro_recv_target_mac <= 'd0;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        ro_recv_target_ip <= 'd0;
    else if(r_recv_cnt == 1 && r_arp_pkt_valid)
        ro_recv_target_ip <= {rs_axis_mac_data[15:0],s_axis_mac_data[63:48]};
    else
        ro_recv_target_ip <= 'd0;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        ro_recv_target_valid <= 'd0;
    else if(r_recv_cnt == 1 && r_arp_pkt_valid)
        ro_recv_target_valid <= 'd1;
    else
        ro_recv_target_valid <= 'd0;
end

//接收到的ARP报文当中的目的IP字段
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_arp_target_ip <= 'd0;
    else if(r_recv_cnt == 3 && r_arp_pkt_valid)
        r_arp_target_ip <= rs_axis_mac_data[63:32];
    else
        r_arp_target_ip <= 'd0;
end

//该请求报文目的IP是本地IP才会产生ARP回复报文
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        ro_arp_reply <= 'd0;
    else if(r_arp_option == P_ARP_REQUEST && r_recv_cnt == 4 && (r_arp_target_ip == r_dymanic_src_ip))
        ro_arp_reply <= 'd1;
    else
        ro_arp_reply <= 'd0;
end


endmodule
