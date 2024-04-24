`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 10:45:36
// Design Name: 
// Module Name: ICMP_RX
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


module ICMP_RX(
    input           i_clk               ,
    input           i_rst               ,

    input  [63:0]   s_axis_ip_data      ,
    input  [55:0]   s_axis_ip_user      ,//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    input  [7 :0]   s_axis_ip_keep      ,
    input           s_axis_ip_last      ,
    input           s_axis_ip_valid     ,

    output [15:0]   o_Identifier        ,
    output [15:0]   o_Sequence          ,
    output          o_trigger           
);

reg  [63:0]         rs_axis_ip_data     ;
reg  [55:0]         rs_axis_ip_user     ;
reg  [7 :0]         rs_axis_ip_keep     ;
reg                 rs_axis_ip_last     ;
reg                 rs_axis_ip_valid    ;
reg  [15:0]         r_cnt               ;
reg                 r_request           ;
reg  [15:0]         ro_Identifier       ; 
reg  [15:0]         ro_Sequence         ; 
reg                 ro_trigger          ;
reg                 r_icmp_pkt_valid    ;

assign o_Identifier = ro_Identifier     ;
assign o_Sequence   = ro_Sequence       ;
assign o_trigger    = ro_trigger        ;

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        rs_axis_ip_data  <= 'd0;
        rs_axis_ip_user  <= 'd0;
        rs_axis_ip_keep  <= 'd0;
        rs_axis_ip_last  <= 'd0;
        rs_axis_ip_valid <= 'd0;
    end else begin
        rs_axis_ip_data  <= s_axis_ip_data ;
        rs_axis_ip_user  <= s_axis_ip_user ;
        rs_axis_ip_keep  <= s_axis_ip_keep ;
        rs_axis_ip_last  <= s_axis_ip_last ;
        rs_axis_ip_valid <= s_axis_ip_valid;
    end    
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_icmp_pkt_valid <= 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid && s_axis_ip_user[36:29] != 16'd1)
        r_icmp_pkt_valid <= 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid && s_axis_ip_user[36:29] == 16'd1)
        r_icmp_pkt_valid <= 'd1;
    else        
        r_icmp_pkt_valid <= r_icmp_pkt_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(rs_axis_ip_valid)
        r_cnt <= r_cnt + 1;
    else        
        r_cnt <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_request <= 'd0;
    else if(ro_trigger)
        r_request <= 'd0;
    else if(rs_axis_ip_valid && r_cnt == 0 && rs_axis_ip_data[63:48] == 16'h0800 && r_icmp_pkt_valid)
        r_request <= 'd1;
    else if(rs_axis_ip_valid && r_cnt == 0 && rs_axis_ip_data[63:48] != 16'h0800 && r_icmp_pkt_valid)
        r_request <= 'd0;
    else 
        r_request <= r_request;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_Identifier <= 'd0;
    else if(rs_axis_ip_valid && r_cnt == 0)
        ro_Identifier <= rs_axis_ip_data[31:16];
    else 
        ro_Identifier <= ro_Identifier;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_Sequence <= 'd0;
    else if(rs_axis_ip_valid && r_cnt == 0)
        ro_Sequence <= rs_axis_ip_data[15:0];
    else 
        ro_Sequence <= ro_Sequence;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_trigger <= 'd0;
    else if(r_request && !s_axis_ip_valid && rs_axis_ip_valid)
        ro_trigger <= 'd1;
    else 
        ro_trigger <= 'd0;
end

endmodule
