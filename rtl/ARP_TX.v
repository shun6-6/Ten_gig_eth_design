`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 15:56:26
// Design Name: 
// Module Name: ARP_TX
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


module ARP_TX#(
    parameter       P_DST_IP_ADDR   = {8'd192,8'd168,8'd100,8'd100},
    parameter       P_SRC_IP_ADDR   = {8'd192,8'd168,8'd100,8'd99},
    parameter       P_SRC_MAC_ADDR  = 48'h01_02_03_04_05_06
)(
    input           i_clk               ,
    input           i_rst               ,

    input  [31:0]   i_dymanic_src_ip    ,
    input           i_src_ip_valid      ,
    input  [47:0]   i_dymanic_src_mac   ,
    input           i_src_mac_valid     ,
    input  [47:0]   i_recv_target_mac   ,
    input  [31:0]   i_recv_target_ip    ,
    input           i_recv_target_valid ,
    input           i_arp_reply         ,
    input           i_arp_active        ,
    input  [31:0]   i_arp_active_dst_ip ,
    input           i_ip2arp_active         ,   
    input  [31:0]   i_ip2arp_active_dst_ip  ,

    output [63:0]   m_axis_arp_data     ,
    output [79:0]   m_axis_arp_user     ,
    output [7 :0]   m_axis_arp_keep     ,
    output          m_axis_arp_last     ,
    output          m_axis_arp_valid    ,
    input           m_axis_arp_ready    
);
/******************************function*****************************/

/******************************parameter****************************/
localparam      P_ARP_REPLY     = 16'd2 ;
localparam      P_ARP_REQUEST   = 16'd1 ;
/******************************mechine******************************/

/******************************reg**********************************/
reg  [47:0]     ri_recv_target_mac      ;
reg  [31:0]     ri_recv_target_ip       ;
reg             ri_arp_reply            ;
reg             ri_arp_active           ;
reg  [31:0]     ri_arp_active_dst_ip    ;
reg             ri_ip2arp_active        ;
reg  [31:0]     ri_ip2arp_active_dst_ip ;
reg             r_active_type           ;//0:active 1:ip2arp_active

reg  [63:0]     rm_axis_arp_data        ;
reg  [79:0]     rm_axis_arp_user        ;
//reg  [7 :0]     rm_axis_arp_keep        ;
reg             rm_axis_arp_last        ;
reg             rm_axis_arp_valid       ;
reg  [31:0]     r_dymanic_src_ip        ;
reg  [47:0]     r_dymanic_src_mac       ;

reg  [15:0]     r_arp_option            ;
reg  [15:0]     r_pkt_cnt               ;
reg  [7 :0]     r_active_cnt            ;
/******************************wire*********************************/

/******************************component****************************/

/******************************assign*******************************/
assign m_axis_arp_data  = rm_axis_arp_data  ;
assign m_axis_arp_user  = rm_axis_arp_user  ;
assign m_axis_arp_keep  = 8'hff             ;
assign m_axis_arp_last  = rm_axis_arp_last  ;
assign m_axis_arp_valid = rm_axis_arp_valid ;
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
    if(i_rst)
        r_dymanic_src_mac <= P_SRC_MAC_ADDR;
    else if(i_src_mac_valid)
        r_dymanic_src_mac <= i_dymanic_src_mac;
    else
        r_dymanic_src_mac <= r_dymanic_src_mac;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        ri_recv_target_mac <= 'd0;
        ri_recv_target_ip  <= 'd0;
    end
    else if(i_recv_target_valid)begin
        ri_recv_target_mac <= i_recv_target_mac;
        ri_recv_target_ip  <= i_recv_target_ip ;
    end  
    else begin
        ri_recv_target_mac <= ri_recv_target_mac;
        ri_recv_target_ip  <= ri_recv_target_ip ;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        ri_arp_reply  <= 'd0;
        ri_arp_active <= 'd0;
        ri_ip2arp_active <= 'd0;
    end 
    else begin
        ri_arp_reply  <= i_arp_reply;
        ri_arp_active <= i_arp_active || (r_active_cnt == 200);
        ri_ip2arp_active <= i_ip2arp_active;
    end
end
//上电主动进arp
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_active_cnt <= 'd0;
    else if(r_active_cnt == 201)
        r_active_cnt <= r_active_cnt;
    else
        r_active_cnt <= r_active_cnt + 1;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        ri_arp_active_dst_ip <= P_DST_IP_ADDR;
    else if(i_arp_active)
        ri_arp_active_dst_ip <= i_arp_active_dst_ip;
    else
        ri_arp_active_dst_ip <= ri_arp_active_dst_ip;
end
  
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        ri_ip2arp_active_dst_ip <= 'd0;
    else if(i_ip2arp_active)
        ri_ip2arp_active_dst_ip <= i_ip2arp_active_dst_ip;
    else
        ri_ip2arp_active_dst_ip <= ri_ip2arp_active_dst_ip;
end      


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_arp_option <= 'd0;
    else if(ri_arp_active || ri_ip2arp_active)
        r_arp_option <= P_ARP_REQUEST;
    else if(ri_arp_reply)
        r_arp_option <= P_ARP_REPLY;
    else
        r_arp_option <= r_arp_option;
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_active_type <= 'd0;
    else if(ri_arp_active)
        r_active_type <= 'd0;
    else if(ri_ip2arp_active)
        r_active_type <= 'd1;
    else
        r_active_type <= r_active_type;
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_pkt_cnt <= 'd0;
    else if(r_pkt_cnt == 5)
        r_pkt_cnt <= 'd0;
    else if(((ri_arp_reply || ri_arp_active || ri_ip2arp_active) && m_axis_arp_ready) || r_pkt_cnt)
        r_pkt_cnt <= r_pkt_cnt + 'd1;
    else
        r_pkt_cnt <= r_pkt_cnt; 
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_arp_data <= 'd0;   
    else
        case (r_pkt_cnt)
            0       : rm_axis_arp_data <= (ri_arp_active || ri_ip2arp_active) ?   {16'd1,16'h0800,8'd6,8'd4,P_ARP_REQUEST} : 
                                                            {16'd1,16'h0800,8'd6,8'd4,P_ARP_REPLY} ;

            1       : rm_axis_arp_data <= {r_dymanic_src_mac,r_dymanic_src_ip[31:16]};

            2       : rm_axis_arp_data <= r_arp_option == P_ARP_REQUEST ? {r_dymanic_src_ip[15:0],48'd0}
                                                            : {r_dymanic_src_ip[15:0],ri_recv_target_mac};

            3       : rm_axis_arp_data <= (r_arp_option == P_ARP_REQUEST) ? 
                                                    r_active_type ? {ri_ip2arp_active_dst_ip,32'd0} : {ri_arp_active_dst_ip,32'd0}
                                                            : {ri_recv_target_ip,32'd0};   

            4       : rm_axis_arp_data <= 'd0;
            5       : rm_axis_arp_data <= 'd0;
            default : rm_axis_arp_data <= 'd0;
        endcase
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_arp_last <= 'd0;
    else if(r_pkt_cnt == 5)
        rm_axis_arp_last <= 'd1;
    else
        rm_axis_arp_last <= 'd0;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_arp_valid <= 'd0;
    else if(rm_axis_arp_last)
        rm_axis_arp_valid <= 'd0;
    else if((ri_arp_reply || ri_arp_active || ri_ip2arp_active) && m_axis_arp_ready)
        rm_axis_arp_valid <= 'd1;
    else
        rm_axis_arp_valid <= rm_axis_arp_valid;
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_arp_user <= 'd0;
    else if(ri_arp_active || ri_ip2arp_active)
        rm_axis_arp_user <= {16'd48,48'hff_ff_ff_ff_ff_ff,16'h0806};
    else if(ri_arp_reply)
        rm_axis_arp_user <= {16'd48,ri_recv_target_mac,16'h0806};
    else
        rm_axis_arp_user <= rm_axis_arp_user;
end

endmodule
