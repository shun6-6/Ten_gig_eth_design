`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/22 14:58:35
// Design Name: 
// Module Name: IP_TX
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


module IP_TX#(
    parameter       P_SRC_IP_ADDR   = {8'd192,8'd168,8'd100,8'd99},
    parameter       P_DST_IP_ADDR   = {8'd192,8'd168,8'd100,8'd100}
)(
    input           i_clk               ,
    input           i_rst               ,
    input  [31:0]   i_dynamic_src_ip    ,
    input           i_dynamic_src_valid ,
    input  [31:0]   i_dynamic_dst_ip    ,
    input           i_dynamic_dst_valid ,

    output [31:0]   o_seek_ip           ,
    output          o_seek_ip_valid     ,
    input  [47:0]   i_seek_mac          ,
    input           i_seek_mac_valid    ,
    output          o_arp_active        ,
    output [31:0]   o_arp_active_dst_ip ,
    /*****MAC AXIS interface*****/
    output [63:0]   m_axis_mac_data     ,
    output [79:0]   m_axis_mac_user     ,//用户自定义{16'dlen,r_src_mac[47:0],16'dr_type}
    output [7 :0]   m_axis_mac_keep     ,
    output          m_axis_mac_last     ,
    output          m_axis_mac_valid    ,
    input           m_axis_mac_ready    ,
    /*****upper layer AXIS interface*****/
    input  [63:0]   s_axis_upper_data   ,
    input  [55:0]   s_axis_upper_user   ,//用户自定义{16'dlen,3'flag,8'dtype,13'doffset,16'dID}
    input  [7 :0]   s_axis_upper_keep   ,
    input           s_axis_upper_last   ,
    input           s_axis_upper_valid  ,
    output          s_axis_upper_ready  
);
/******************************function*****************************/

/******************************parameter****************************/

/******************************mechine******************************/

/******************************reg**********************************/
reg  [31:0]     r_dynamic_src_ip    ;
reg  [31:0]     r_dynamic_dst_ip    ;
reg  [63:0]     rm_axis_mac_data    ;
reg  [79:0]     rm_axis_mac_user    ;
reg  [7 :0]     rm_axis_mac_keep    ;
reg             rm_axis_mac_last    ;
reg             rm_axis_mac_valid   ;
reg  [63:0]     rs_axis_upper_data  ;
reg  [55:0]     rs_axis_upper_user  ;
reg  [7 :0]     rs_axis_upper_keep  ;
reg             rs_axis_upper_last  ;
reg             rs_axis_upper_valid ;
reg             rs_axis_upper_ready ;
reg             rs_axis_upper_valid_1d;

reg  [31:0]     ro_seek_ip          ;
reg             ro_seek_ip_valid    ;
reg  [47:0]     ri_seek_mac         ;

reg  [31:0]     r_checksum          ;
reg  [15:0]     r_recv_cnt          ;
reg  [7 :0]     r_tail_keep         ;

reg             r_data_fifo_rden    ;
reg  [15:0]     r_pkt_cnt           ;
reg  [63:0]     r_data_fifo_dout    ;
reg             r_data_fifo_empty   ;
reg             r_data_fifo_empty_1d;

reg             r_get_mac_faild     ;
reg             r_get_mac_faild_1d  ;
reg  [15:0]     r_pkt_byte_len      ;
reg             ro_arp_active       ;
reg  [31:0]     ro_arp_active_dst_ip;
/******************************wire*********************************/
wire [63:0]     w_data_fifo_dout    ;
wire            w_data_fifo_full    ;
wire            w_data_fifo_empty   ;
//user信息 {16'dlen,3'flag,8'dtype,13'doffset,16'dID}
wire [15:0]     w_ip_byte_len       ;
wire [2 :0]     w_upper_flags       ;
wire [7 :0]     w_upper_type        ;
wire [12:0]     w_upper_offset      ;
wire [15:0]     w_upper_ID          ;  

wire [15:0]     w_ip_64bit_len      ;

wire            w_fifo_empty_pos    ;
wire            w_fifo_empty_pos_1d ;
wire            w_get_mac_faild     ;
/******************************component****************************/
FIFO_64X256 FIFO_64X256_IP_DATA_TX (
  .clk      (i_clk              ), // input wire clk
  .srst     (i_rst              ), // input wire srst
  .din      (rs_axis_upper_data ), // input wire [63 : 0] din
  .wr_en    (rs_axis_upper_valid), // input wire wr_en
  .rd_en    (r_data_fifo_rden   ), // input wire rd_en
  .dout     (w_data_fifo_dout   ), // output wire [63 : 0] dout
  .full     (w_data_fifo_full   ), // output wire full
  .empty    (w_data_fifo_empty  )  // output wire empty
);
/******************************assign*******************************/
assign m_axis_mac_data  = rm_axis_mac_data  ;
assign m_axis_mac_user  = rm_axis_mac_user  ;
assign m_axis_mac_keep  = rm_axis_mac_keep  ;
assign m_axis_mac_last  = rm_axis_mac_last  ;
assign m_axis_mac_valid = rm_axis_mac_valid ;
assign s_axis_upper_ready = rs_axis_upper_ready;

assign w_ip_byte_len      = rs_axis_upper_user[55:40] + 16'd20;
assign w_upper_flags    = rs_axis_upper_user[39:37];
assign w_upper_type     = rs_axis_upper_user[36:29];
assign w_upper_offset   = rs_axis_upper_user[28:16];
assign w_upper_ID       = rs_axis_upper_user[15 :0];

assign w_fifo_empty_pos    = w_data_fifo_empty & !r_data_fifo_empty;
assign w_fifo_empty_pos_1d = r_data_fifo_empty & !r_data_fifo_empty_1d;

assign w_ip_64bit_len = r_pkt_byte_len[2:0] == 0 ? (r_pkt_byte_len >> 3)
                            : (r_pkt_byte_len >> 3) + 1 ;

assign o_seek_ip        = ro_seek_ip        ;  
assign o_seek_ip_valid  = ro_seek_ip_valid  ;
assign o_arp_active        = ro_arp_active          ;
assign o_arp_active_dst_ip = ro_arp_active_dst_ip   ;
assign w_get_mac_faild = i_seek_mac_valid && (&i_seek_mac) ? 1 : 
                            (&ri_seek_mac) ? 1 : 0;
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
        rs_axis_upper_data  <= 'd0;
        rs_axis_upper_user  <= 'd0;
        rs_axis_upper_keep  <= 'd0;
        rs_axis_upper_last  <= 'd0;
        rs_axis_upper_valid <= 'd0;
        r_data_fifo_dout     <= 'd0;
        r_data_fifo_empty    <= 'd1;
        r_data_fifo_empty_1d <= 'd1;
        rs_axis_upper_valid_1d <= 'd0;
        r_get_mac_faild_1d <= 'd0;
    end
    else begin
        rs_axis_upper_data  <= s_axis_upper_data ;
        rs_axis_upper_user  <= s_axis_upper_user ;
        rs_axis_upper_keep  <= s_axis_upper_keep ;
        rs_axis_upper_last  <= s_axis_upper_last ;
        rs_axis_upper_valid <= s_axis_upper_valid;
        r_data_fifo_dout     <= w_data_fifo_dout;
        r_data_fifo_empty    <= w_data_fifo_empty;
        r_data_fifo_empty_1d <= r_data_fifo_empty;
        rs_axis_upper_valid_1d <= rs_axis_upper_valid;
        r_get_mac_faild_1d <= r_get_mac_faild;
    end
end

//当有数据要发送时，进行MAC查询    
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_seek_ip <= 'd0;
    else
        ro_seek_ip <= r_dynamic_dst_ip;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_seek_ip_valid <= 'd0;
    else if((s_axis_upper_valid && !rs_axis_upper_valid) || (r_get_mac_faild))
        ro_seek_ip_valid <= 'd1;
    else
        ro_seek_ip_valid <= 'd0;
end

//获得查询结果
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ri_seek_mac <= 'd0;
    else if(i_seek_mac_valid)
        ri_seek_mac <= i_seek_mac;
    else
        ri_seek_mac <= ri_seek_mac;
end

//当查询结果为48'hffffffffffff时，说明没有该IP对应的MAC，需要触发一次arp请求
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_get_mac_faild <= 'd0;
    else if(i_seek_mac_valid && (&i_seek_mac))
        r_get_mac_faild <= 'd1;
    else if(i_seek_mac_valid && !(&i_seek_mac))
        r_get_mac_faild <= 'd0;
    else
        r_get_mac_faild <= r_get_mac_faild;
end
       

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_arp_active <= 'd0;
    else if(r_get_mac_faild && !r_get_mac_faild_1d)
        ro_arp_active <= 'd1;
    else
        ro_arp_active <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_arp_active_dst_ip <= 'd0;
    else if(r_get_mac_faild && !r_get_mac_faild_1d)
        ro_arp_active_dst_ip <= ro_seek_ip;
    else
        ro_arp_active_dst_ip <= ro_arp_active_dst_ip;
end



always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_pkt_byte_len <= 'd0;
    else if(r_recv_cnt == 0 && s_axis_upper_valid)
        r_pkt_byte_len <= s_axis_upper_user[55:40] + 16'd20;
    else
        r_pkt_byte_len <= r_pkt_byte_len;
end

//计算checksum
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_checksum <= 'd0;
    else if(r_recv_cnt == 1)
        r_checksum <= 16'h4500 + r_pkt_byte_len +
                        w_upper_ID + {w_upper_flags,w_upper_offset} + 
                        {8'd128,w_upper_type} + 16'd0 + 
                        r_dynamic_src_ip[31:16] + r_dynamic_src_ip[15:0] + 
                        r_dynamic_dst_ip[31:16] + r_dynamic_dst_ip[15:0];
    else if(r_recv_cnt == 2)
        r_checksum <= r_checksum[15:0] + r_checksum[31:16];    
    else
        r_checksum <= r_checksum;
end

//接受计数器，用于计算首部校验和
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_cnt <= 'd0;
    else if(s_axis_upper_valid)
        r_recv_cnt <= r_recv_cnt + 'd1;
    else
        r_recv_cnt <= 'd0;
end

//FIFO不为空，组包计数器开始,同时启动读FIFO
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_pkt_cnt <= 'd0; 
    else if(rm_axis_mac_last)
        r_pkt_cnt <= 'd0; 
    else if((r_pkt_cnt == 0 && !w_data_fifo_empty && m_axis_mac_ready && !w_get_mac_faild) || r_pkt_cnt)
        r_pkt_cnt <= r_pkt_cnt + 'd1; 
    else
        r_pkt_cnt <= r_pkt_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_data_fifo_rden <= 'd0;
    else if(w_data_fifo_empty)
        r_data_fifo_rden <= 'd0 ;
    else if(r_pkt_cnt == 0 && !w_data_fifo_empty && m_axis_mac_ready && !w_get_mac_faild)
        r_data_fifo_rden <= 'd1 ;
    else
        r_data_fifo_rden <= r_data_fifo_rden;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_mac_data <= 'd0;
    else
        case (r_pkt_cnt)
            0       : rm_axis_mac_data <= {4'b0100,4'b0101,8'd0,{r_pkt_byte_len},
                                            w_upper_ID,w_upper_flags,w_upper_offset};

            1       : rm_axis_mac_data <= {8'd128,w_upper_type,(~r_checksum[15:0]),
                                            r_dynamic_src_ip};

            2       : rm_axis_mac_data <= {r_dynamic_dst_ip,w_data_fifo_dout[63:32]};

            default : rm_axis_mac_data <= {r_data_fifo_dout[31:0],w_data_fifo_dout[63:32]};
        endcase
end

//axis接口
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_mac_valid <= 'd0;
    else if(rm_axis_mac_last)
        rm_axis_mac_valid <= 'd0;
    else if(r_pkt_cnt == 0 && !w_data_fifo_empty && m_axis_mac_ready && !w_get_mac_faild)
        rm_axis_mac_valid <= 'd1;
    else
        rm_axis_mac_valid <= rm_axis_mac_valid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_tail_keep <= 'd0;
    else if(rs_axis_upper_last)
        r_tail_keep <= rs_axis_upper_keep;
    else
        r_tail_keep <= r_tail_keep;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_mac_keep <= 8'hff;
    else if(w_fifo_empty_pos && r_tail_keep <= 8'b1111_0000)
        case (r_tail_keep)
            8'b1111_0000 : rm_axis_mac_keep <= 8'b1111_1111;
            8'b1110_0000 : rm_axis_mac_keep <= 8'b1111_1110;
            8'b1100_0000 : rm_axis_mac_keep <= 8'b1111_1100;
            8'b1000_0000 : rm_axis_mac_keep <= 8'b1111_1000;
            default      : rm_axis_mac_keep <= 8'hff; 
        endcase
    else if(w_fifo_empty_pos_1d && r_tail_keep > 8'b1111_0000)
        case (r_tail_keep)
            8'b1111_1000 : rm_axis_mac_keep <= 8'b1000_0000;
            8'b1111_1100 : rm_axis_mac_keep <= 8'b1100_0000;
            8'b1111_1110 : rm_axis_mac_keep <= 8'b1110_0000;
            8'b1111_1111 : rm_axis_mac_keep <= 8'b1111_0000;
            default      : rm_axis_mac_keep <= 8'hff; 
        endcase
    else
        rm_axis_mac_keep <= 8'hff;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_mac_last <= 'd0;
    else if(w_fifo_empty_pos && r_tail_keep <= 8'b1111_0000)
        rm_axis_mac_last <= 'd1;
    else if(w_fifo_empty_pos_1d && r_tail_keep > 8'b1111_0000)
        rm_axis_mac_last <= 'd1;
    else
        rm_axis_mac_last <= 'd0;
end
//用户自定义{16'dlen,r_src_mac[47:0],16'dr_type}
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_mac_user <= 'd0;
    else if(i_seek_mac_valid)
        rm_axis_mac_user <= {r_pkt_byte_len,i_seek_mac,16'h0800}; 
end

//当前数据发完，上层数据可以继续发送
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rs_axis_upper_ready <= 'd1;
    else if(s_axis_upper_last)
        rs_axis_upper_ready <= 'd0;
    else if(rm_axis_mac_last)
        rs_axis_upper_ready <= 'd1;
    else
        rs_axis_upper_ready <= rs_axis_upper_ready;
end

endmodule
