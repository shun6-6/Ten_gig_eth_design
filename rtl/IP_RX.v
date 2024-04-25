`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/22 14:58:35
// Design Name: 
// Module Name: IP_RX
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


module IP_RX#(
    parameter       P_SRC_IP_ADDR   = {8'd192,8'd168,8'd100,8'd99},
    parameter       P_DST_IP_ADDR   = {8'd192,8'd168,8'd100,8'd100}
)(
    input           i_clk               ,
    input           i_rst               ,
    input  [31:0]   i_dynamic_src_ip    ,
    input           i_dynamic_src_valid ,
    input  [31:0]   i_dynamic_dst_ip    ,
    input           i_dynamic_dst_valid ,
    /*****MAC AXIS interface*****/
    input  [63:0]   s_axis_mac_data     ,
    input  [79:0]   s_axis_mac_user     ,//用户自定义{16'dlen,r_src_mac[47:0],16'dr_type}
    input  [7 :0]   s_axis_mac_keep     ,
    input           s_axis_mac_last     ,
    input           s_axis_mac_valid    ,
    /*****upper layer AXIS interface*****/
    output [63:0]   m_axis_upper_data   ,
    output [55:0]   m_axis_upper_user   ,//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    output [7 :0]   m_axis_upper_keep   ,
    output          m_axis_upper_last   ,
    output          m_axis_upper_valid  
);
/******************************function*****************************/

/******************************parameter****************************/

/******************************mechine******************************/

/******************************reg**********************************/
reg  [31:0]     r_dynamic_src_ip    ;
reg  [31:0]     r_dynamic_dst_ip    ;
reg  [63:0]     rs_axis_mac_data    ;
reg  [79:0]     rs_axis_mac_user    ;
reg  [7 :0]     rs_axis_mac_keep    ;
reg             rs_axis_mac_last    ;
reg             rs_axis_mac_valid   ;
reg  [63:0]     rm_axis_upper_data  ;
reg  [37:0]     rm_axis_upper_user  ;
reg  [7 :0]     rm_axis_upper_keep  ;
reg             rm_axis_upper_last  ;
reg             rm_axis_upper_valid ;

reg  [15:0]     r_recv_cnt          ;
reg  [15:0]     r_ip_total_length   ;
reg  [15:0]     r_Identification    ;
reg  [2 :0]     r_flags             ;
reg  [12:0]     r_offset            ;
reg  [7 :0]     r_protocol_type     ;
reg  [31:0]     r_recv_src_ip       ;
reg  [31:0]     r_recv_dst_ip       ;
reg             r_ip_access         ;
/******************************wire*********************************/
wire        w_ip_pkt_valid  ;
wire [15:0] w_ip_pkt_64bit_len    ;
wire [15:0] w_ip_pkt_payload_len    ;
/******************************component****************************/

/******************************assign*******************************/
assign m_axis_upper_data  = rm_axis_upper_data  ;
assign m_axis_upper_user  = rm_axis_upper_user  ;
assign m_axis_upper_keep  = rm_axis_upper_keep  ;
assign m_axis_upper_last  = rm_axis_upper_last  ;
assign m_axis_upper_valid = rm_axis_upper_valid ;
assign w_ip_pkt_valid     = rs_axis_mac_user[15:0] == 16'h0800;
assign w_ip_pkt_payload_len = r_ip_total_length - 16'd20;
assign w_ip_pkt_64bit_len = w_ip_pkt_payload_len[2:0] == 0 ? w_ip_pkt_payload_len >> 3
                            :  ((w_ip_pkt_payload_len >> 3) + 16'd1);
/******************************always*******************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_dynamic_src_ip <= P_SRC_IP_ADDR;
    else if(i_dynamic_src_valid)
        r_dynamic_src_ip <= i_dynamic_src_ip;
    else
        r_dynamic_src_ip <= r_dynamic_src_ip;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_dynamic_dst_ip <= P_DST_IP_ADDR;
    else if(i_dynamic_dst_valid)
        r_dynamic_dst_ip <= i_dynamic_dst_ip;
    else
        r_dynamic_dst_ip <= r_dynamic_dst_ip;
end

always @(posedge i_clk or posedge i_rst)begin
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

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_cnt <= 'd0;
    else if(rs_axis_mac_valid)
        r_recv_cnt <= r_recv_cnt + 'd1;
    else
        r_recv_cnt <= 'd0;
end

//解析关键字段信息
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ip_total_length <= 'd0;
    else if(rs_axis_mac_valid && r_recv_cnt == 0)
        r_ip_total_length <= rs_axis_mac_data[47:32];
    else
        r_ip_total_length <= r_ip_total_length;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_Identification <= 'd0;
    else if(rs_axis_mac_valid && r_recv_cnt == 0)
        r_Identification <= rs_axis_mac_data[31:16];
    else
        r_Identification <= r_Identification;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_flags <= 'd0;
    else if(rs_axis_mac_valid && r_recv_cnt == 0)
        r_flags <= rs_axis_mac_data[15:13];
    else
        r_flags <= r_flags;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_offset <= 'd0;
    else if(rs_axis_mac_valid && r_recv_cnt == 0)
        r_offset <= rs_axis_mac_data[12:0];
    else
        r_offset <= r_offset;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_protocol_type <= 'd0;
    else if(rs_axis_mac_valid && r_recv_cnt == 1)
        r_protocol_type <= rs_axis_mac_data[55:48];
    else
        r_protocol_type <= r_protocol_type;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_src_ip <= 'd0;
    else if(rs_axis_mac_valid && r_recv_cnt == 1)
        r_recv_src_ip <= rs_axis_mac_data[31:0];
    else
        r_recv_src_ip <= r_recv_dst_ip;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_dst_ip <= 'd0;
    else if(rs_axis_mac_valid && r_recv_cnt == 2)
        r_recv_dst_ip <= rs_axis_mac_data[63:32];
    else
        r_recv_dst_ip <= r_recv_dst_ip;
end
//r_ip_access是提前拉高的，以此来判断rm_axis_upper_valid是否可拉高
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ip_access <= 'd0;
    else if(w_ip_pkt_valid && rs_axis_mac_valid && (r_recv_cnt == 1) && (s_axis_mac_data[63:32] != r_dynamic_src_ip))
        r_ip_access <= 'd0;
    else if(w_ip_pkt_valid && rs_axis_mac_valid && (r_recv_cnt == 1) && (s_axis_mac_data[63:32] == r_dynamic_src_ip))
        r_ip_access <= 'd1;
    else
        r_ip_access <= r_ip_access; 
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_upper_data <= 'd0;
    else
        rm_axis_upper_data <= {rs_axis_mac_data[31:0],s_axis_mac_data[63:32]};
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_upper_user <= 'd0;
    else
        rm_axis_upper_user <= {w_ip_pkt_payload_len,r_flags,r_protocol_type,r_offset,r_Identification};
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_upper_keep <= 8'b1111_1111;
    else if(s_axis_mac_last && s_axis_mac_keep <= 8'b1111_0000)
        case (s_axis_mac_keep)
            8'b1111_0000 : rm_axis_upper_keep <= 8'b1111_1111;
            8'b1110_0000 : rm_axis_upper_keep <= 8'b1111_1110;
            8'b1100_0000 : rm_axis_upper_keep <= 8'b1111_1100;
            8'b1000_0000 : rm_axis_upper_keep <= 8'b1111_1000;
            default      : rm_axis_upper_keep <= 8'b1111_1111;
        endcase
    else if(rs_axis_mac_last && rs_axis_mac_keep > 8'b1111_0000)
        case (rs_axis_mac_keep)
            8'b1111_1111 : rm_axis_upper_keep <= 8'b1111_0000;
            8'b1111_1110 : rm_axis_upper_keep <= 8'b1110_0000;
            8'b1111_1100 : rm_axis_upper_keep <= 8'b1100_0000;
            8'b1111_1000 : rm_axis_upper_keep <= 8'b1000_0000;
            default      : rm_axis_upper_keep <= 8'b1111_1111;
        endcase    
    else
        rm_axis_upper_keep <= 8'b1111_1111;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_upper_last <= 'd0;
    else if(s_axis_mac_last && s_axis_mac_keep <= 8'b1111_0000)
        rm_axis_upper_last <= 'd1;
    else if(rs_axis_mac_last && rs_axis_mac_keep > 8'b1111_0000)
        rm_axis_upper_last <= 'd1;
    else
        rm_axis_upper_last <= 'd0; 
end

//当前数据包发送完成上层可继续发
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_upper_valid <= 'd0;
    else if(rm_axis_upper_last)
        rm_axis_upper_valid <= 'd0;
    else if(rs_axis_mac_valid && r_recv_cnt == 2 && r_ip_access)
        rm_axis_upper_valid <= 'd1;
    else
        rm_axis_upper_valid <= rm_axis_upper_valid;
end




endmodule
