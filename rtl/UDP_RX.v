`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/25 14:02:39
// Design Name: 
// Module Name: UDP_RX
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


module UDP_RX#(
    parameter       P_SRC_UDP_PORT  = 16'h0808,
    parameter       P_DST_UDP_PORT  = 16'h0808
)(
    input           i_clk               ,
    input           i_rst               ,
    input  [15:0]   i_dymanic_src_port  ,
    input           i_dymanic_src_valid ,
    /****next layer data****/
    input  [63:0]   s_axis_ip_data      ,
    input  [55:0]   s_axis_ip_user      ,
    input  [7 :0]   s_axis_ip_keep      ,
    input           s_axis_ip_last      ,
    input           s_axis_ip_valid     ,
    /****user data****/
    output [63:0]   m_axis_user_data    ,
    output [31:0]   m_axis_user_user    ,
    output [7 :0]   m_axis_user_keep    ,
    output          m_axis_user_last    ,
    output          m_axis_user_valid   
);
/******************************function*****************************/

/******************************parameter****************************/

/******************************mechine******************************/

/******************************reg**********************************/
reg  [15:0]     ri_dymanic_src_port ;
reg  [63:0]     rs_axis_ip_data     ;
reg  [55:0]     rs_axis_ip_user     ;
reg  [7 :0]     rs_axis_ip_keep     ;
reg             rs_axis_ip_last     ;
reg             rs_axis_ip_valid    ;
reg  [63:0]     rm_axis_user_data   ;
reg  [31:0]     rm_axis_user_user   ;
reg  [7 :0]     rm_axis_user_keep   ;
reg             rm_axis_user_last   ;
reg             rm_axis_user_valid  ;

reg  [15:0]     r_recv_cnt          ;
reg  [15:0]     r_recv_src_port     ;
reg  [15:0]     r_recv_dst_port     ;
reg  [15:0]     r_recv_pkt_len      ;
reg             r_udp_pkt_valid     ;
reg             r_udp_access        ;
/******************************wire*********************************/
wire [15:0]     w_64bit_len         ;
wire [15:0]     w_byte_len          ;
/******************************assign*******************************/
assign m_axis_user_data  = rm_axis_user_data    ;
assign m_axis_user_user  = rm_axis_user_user    ;
assign m_axis_user_keep  = rm_axis_user_keep    ;
assign m_axis_user_last  = rm_axis_user_last    ;
assign m_axis_user_valid = rm_axis_user_valid   ;

assign w_byte_len  = rs_axis_ip_user[55:40];
assign w_64bit_len = w_byte_len[2:0] == 0 ? (w_byte_len >> 3) 
                        : (w_byte_len >> 3) + 1;
/******************************component****************************/

/******************************always*******************************/
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        ri_dymanic_src_port <= P_SRC_UDP_PORT;
    else if(i_dymanic_src_valid)
        ri_dymanic_src_port <= i_dymanic_src_port;
    else
        ri_dymanic_src_port <= ri_dymanic_src_port;
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        rs_axis_ip_data  <= 'd0;
        rs_axis_ip_user  <= 'd0;
        rs_axis_ip_keep  <= 'd0;
        rs_axis_ip_last  <= 'd0;
        rs_axis_ip_valid <= 'd0;
    end
    else begin
        rs_axis_ip_data  <= s_axis_ip_data ;
        rs_axis_ip_user  <= s_axis_ip_user ;
        rs_axis_ip_keep  <= s_axis_ip_keep ;
        rs_axis_ip_last  <= s_axis_ip_last ;
        rs_axis_ip_valid <= s_axis_ip_valid;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_udp_pkt_valid <= 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid && s_axis_ip_user[36:29] != 8'd17)
        r_udp_pkt_valid <= r_recv_cnt + 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid && s_axis_ip_user[36:29] == 8'd17)
        r_udp_pkt_valid <= r_recv_cnt + 'd1;
    else
        r_udp_pkt_valid <= r_udp_pkt_valid;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_recv_cnt <= 'd0;
    else if(rs_axis_ip_valid && r_udp_pkt_valid)
        r_recv_cnt <= r_recv_cnt + 'd1;
    else
        r_recv_cnt <= 'd0;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_recv_src_port <= 'd0;
    else if(r_recv_cnt == 0 && rs_axis_ip_valid)
        r_recv_src_port <= rs_axis_ip_data[63:48];
    else
        r_recv_src_port <= r_recv_src_port;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_recv_dst_port <= 'd0;
    else if(r_recv_cnt == 0 && rs_axis_ip_valid)
        r_recv_dst_port <= rs_axis_ip_data[47:32];
    else
        r_recv_dst_port <= r_recv_dst_port;
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_udp_access <= 'd0;
    else if(r_recv_cnt == 0 && rs_axis_ip_valid && rs_axis_ip_data[47:32] != ri_dymanic_src_port && r_udp_pkt_valid)
        r_udp_access <= 'd0;
    else if(r_recv_cnt == 0 && rs_axis_ip_valid && rs_axis_ip_data[47:32] == ri_dymanic_src_port && r_udp_pkt_valid)
        r_udp_access <= 'd1;
    else
        r_udp_access <= r_udp_access;
end

//长度是以8字节为单位的，因为一拍数据是64比特
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_recv_pkt_len <= 'd0;
    else if(r_recv_cnt == 0 && rs_axis_ip_valid)
        r_recv_pkt_len <= w_64bit_len;
    else
        r_recv_pkt_len <= r_recv_pkt_len;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_data <= 'd0;
    else if(r_recv_cnt >= 1)
        rm_axis_user_data <= rs_axis_ip_data;
    else
        rm_axis_user_data <= rm_axis_user_data;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_user <= 'd0;
    else
        rm_axis_user_user <= {16'd0,(w_byte_len - 16'd8)};
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_keep <= 8'hff;
    else if(rs_axis_ip_last)
        rm_axis_user_keep <= rs_axis_ip_keep;
    else
        rm_axis_user_keep <= 8'hff;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_last <= 'd0;
    else if(rs_axis_ip_last)
        rm_axis_user_last <= 'd1;
    else
        rm_axis_user_last <= 'd0;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_valid <= 'd0;
    else if(rm_axis_user_last)
        rm_axis_user_valid <= 'd0;
    else if(r_recv_cnt == 1 && r_udp_access)
        rm_axis_user_valid <= 'd1;
    else
        rm_axis_user_valid <= rm_axis_user_valid;
end

endmodule
