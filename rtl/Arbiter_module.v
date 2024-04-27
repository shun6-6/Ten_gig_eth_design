`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/24 18:22:27
// Design Name: 
// Module Name: Abiter_module
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


module Arbiter_module#(
    parameter       P_ARBITER_LAYER = "MAC"
)(
    input           i_clk               ,
    input           i_rst               ,

    input  [63:0]   s_axis_c0_data      ,
    input  [79:0]   s_axis_c0_user      ,
    input  [7 :0]   s_axis_c0_keep      ,
    input           s_axis_c0_last      ,
    input           s_axis_c0_valid     ,
    output          s_axis_c0_ready     ,

    input  [63:0]   s_axis_c1_data      ,
    input  [79:0]   s_axis_c1_user      ,
    input  [7 :0]   s_axis_c1_keep      ,
    input           s_axis_c1_last      ,
    input           s_axis_c1_valid     ,
    output          s_axis_c1_ready     ,

    output [63:0]   m_axis_out_data     ,
    output [79:0]   m_axis_out_user     ,
    output [7 :0]   m_axis_out_keep     ,
    output          m_axis_out_last     ,
    output          m_axis_out_valid    ,
    input           m_axis_out_ready     
);
/******************************function*****************************/

/******************************parameter****************************/

/******************************mechine******************************/

/******************************reg**********************************/
reg         rs_axis_c0_valid        ;
reg         rs_axis_c1_valid        ;

reg         r_fifo_c0_data_rden     ;
reg         r_fifo_c0_keep_rden     ;
reg         r_fifo_c0_user_rden     ;
reg         r_fifo_c1_data_rden     ;
reg         r_fifo_c1_keep_rden     ;
reg         r_fifo_c1_user_rden     ;

reg         r_fifo_c0_user_rden_1d  ;
reg         r_fifo_c1_user_rden_1d  ;
reg         r_fifo_data_rden_1d     ;
reg         r_fifo_keep_rden_1d     ;
reg         r_fifo_user_rden_1d     ;

reg         r_arbiter_flag          ;
reg         r_arbiter_lock          ;
reg         r_arbiter_lock_1d       ;
reg  [15:0] r_send_cnt              ;
reg  [15:0] r_pkt_64bit_len               ;

reg  [63:0] rm_axis_out_data        ;
reg  [79:0] rm_axis_out_user        ;
reg  [7 :0] rm_axis_out_keep        ;
reg         rm_axis_out_last        ;
reg         rm_axis_out_valid       ;
reg         rs_axis_c0_ready        ;
reg         rs_axis_c1_ready        ;
/******************************wire*********************************/
wire        w_c0_valid_pos          ;
wire        w_c1_valid_pos          ;

wire [63:0] w_fifo_c0_data_dout     ;
wire        w_fifo_c0_data_full     ;
wire        w_fifo_c0_data_empty    ;
wire [7 :0] w_fifo_c0_keep_dout     ;
wire        w_fifo_c0_keep_full     ;
wire        w_fifo_c0_keep_empty    ;
wire [79:0] w_fifo_c0_user_dout     ;
wire        w_fifo_c0_user_full     ;
wire        w_fifo_c0_user_empty    ;
wire [63:0] w_fifo_c1_data_dout     ;
wire        w_fifo_c1_data_full     ;
wire        w_fifo_c1_data_empty    ;
wire [7 :0] w_fifo_c1_keep_dout     ;
wire        w_fifo_c1_keep_full     ;
wire        w_fifo_c1_keep_empty    ;
wire [79:0] w_fifo_c1_user_dout     ;
wire        w_fifo_c1_user_full     ;
wire        w_fifo_c1_user_empty    ;

wire        w_arbiter_lock_pos      ;
wire [15:0] w_ip_byte_len  ;
wire [15:0] w_mac_byte_len  ;
/******************************component****************************/
FIFO_64X256 FIFO_64X256_c0_data (
  .clk          (i_clk                  ),
  .srst         (i_rst                  ),  
  .din          (s_axis_c0_data         ),
  .wr_en        (s_axis_c0_valid        ),
  .rd_en        (r_fifo_c0_data_rden    ),
  .dout         (w_fifo_c0_data_dout    ),
  .full         (w_fifo_c0_data_full    ),
  .empty        (w_fifo_c0_data_empty   ) 
);

FIFO_8X32 FIFO_8X32_c0_keep (
  .clk          (i_clk                  ),  
  .srst         (i_rst                  ),    
  .din          (s_axis_c0_keep         ),  
  .wr_en        (s_axis_c0_last         ),  
  .rd_en        (r_fifo_c0_keep_rden    ),  
  .dout         (w_fifo_c0_keep_dout    ),  
  .full         (w_fifo_c0_keep_full    ),  
  .empty        (w_fifo_c0_keep_empty   ) 
);

FIFO_80X32 FIFO_8X32_c0_user (
  .clk          (i_clk                  ),  
  .srst         (i_rst                  ),    
  .din          (s_axis_c0_user         ),  
  .wr_en        (w_c0_valid_pos         ),  
  .rd_en        (r_fifo_c0_user_rden    ),  
  .dout         (w_fifo_c0_user_dout    ),  
  .full         (w_fifo_c0_user_full    ),  
  .empty        (w_fifo_c0_user_empty   ) 
);

FIFO_64X256 FIFO_64X256_c1_data (
  .clk          (i_clk                  ),
  .srst         (i_rst                  ),  
  .din          (s_axis_c1_data         ),
  .wr_en        (s_axis_c1_valid        ),
  .rd_en        (r_fifo_c1_data_rden    ),
  .dout         (w_fifo_c1_data_dout    ),
  .full         (w_fifo_c1_data_full    ),
  .empty        (w_fifo_c1_data_empty   ) 
);

FIFO_8X32 FIFO_8X32_c1_keep (
  .clk          (i_clk                  ),  
  .srst         (i_rst                  ),    
  .din          (s_axis_c1_keep         ),  
  .wr_en        (s_axis_c1_last         ),  
  .rd_en        (r_fifo_c1_keep_rden    ),  
  .dout         (w_fifo_c1_keep_dout    ),  
  .full         (w_fifo_c1_keep_full    ),  
  .empty        (w_fifo_c1_keep_empty   ) 
);

FIFO_80X32 FIFO_8X32_c1_user (
  .clk          (i_clk                  ),  
  .srst         (i_rst                  ),    
  .din          (s_axis_c1_user         ),  
  .wr_en        (w_c1_valid_pos         ),  
  .rd_en        (r_fifo_c1_user_rden    ),  
  .dout         (w_fifo_c1_user_dout    ),  
  .full         (w_fifo_c1_user_full    ),  
  .empty        (w_fifo_c1_user_empty   ) 
);
/******************************assign*******************************/
assign s_axis_c0_ready = rs_axis_c0_ready   ;
assign s_axis_c1_ready = rs_axis_c1_ready   ;
assign w_c0_valid_pos  = s_axis_c0_valid & !rs_axis_c0_valid   ;
assign w_c1_valid_pos  = s_axis_c1_valid & !rs_axis_c1_valid   ;
assign w_arbiter_lock_pos = r_arbiter_lock && !r_arbiter_lock_1d;
assign m_axis_out_data  = rm_axis_out_data      ;
assign m_axis_out_user  = rm_axis_out_user      ;
assign m_axis_out_keep  = rm_axis_out_keep      ;
assign m_axis_out_last  = rm_axis_out_last      ;
assign m_axis_out_valid = rm_axis_out_valid     ;

assign w_ip_byte_len = P_ARBITER_LAYER == "IP" && r_fifo_c0_user_rden_1d ? 
                    w_fifo_c0_user_dout[55:40] : w_fifo_c1_user_dout[55:40];
assign w_mac_byte_len = P_ARBITER_LAYER == "MAC" && r_fifo_c0_user_rden_1d ? 
                    w_fifo_c0_user_dout[79:64] : w_fifo_c1_user_dout[79:64];
/******************************always*******************************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        rs_axis_c0_valid <= 'd0;
        rs_axis_c1_valid <= 'd0;
        r_fifo_c0_user_rden_1d <= 'd0;
        r_fifo_c1_user_rden_1d <= 'd0;
    end else begin
        rs_axis_c0_valid <= s_axis_c0_valid;
        rs_axis_c1_valid <= s_axis_c1_valid;
        r_fifo_c0_user_rden_1d <= r_fifo_c0_user_rden;
        r_fifo_c1_user_rden_1d <= r_fifo_c1_user_rden;
    end
end

//r_arbiter_flag = 0表示通道0响应仲裁，为1表示通道1响应仲裁
//通道0具有更高的相应优先级
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_arbiter_flag <= 'd0;
    else if(!w_fifo_c0_user_empty && !r_arbiter_lock && m_axis_out_ready)
        r_arbiter_flag <= 'd0;
    else if(!w_fifo_c1_user_empty && !r_arbiter_lock && m_axis_out_ready)
        r_arbiter_flag <= 'd1;
    else
        r_arbiter_flag <= r_arbiter_flag;  
end

//r_arbiter_lock表示仲裁锁，得到一次仲裁结果后，
//只有当前仲裁的通道将一个数据包完整输出后才可以响应下一次仲裁
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_arbiter_lock <= 'd0;
    else if(r_send_cnt == r_pkt_64bit_len && r_arbiter_lock && r_pkt_64bit_len != 0)
        r_arbiter_lock <= 'd0; 
    else if(!r_arbiter_lock && !w_fifo_c0_user_empty && m_axis_out_ready)
        r_arbiter_lock <= 'd1; 
    else if(!r_arbiter_lock && !w_fifo_c1_user_empty && m_axis_out_ready)
        r_arbiter_lock <= 'd1; 
    else
        r_arbiter_lock <= r_arbiter_lock;  
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_arbiter_lock_1d <= 'd0;
    else
        r_arbiter_lock_1d <= r_arbiter_lock;  
end

//r_arbiter_lock锁定后即可开始输出
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_c0_user_rden <= 'd0;
    else if(w_arbiter_lock_pos && !r_arbiter_flag && !w_fifo_c0_user_empty && m_axis_out_ready)
        r_fifo_c0_user_rden <= 'd1;
    else
        r_fifo_c0_user_rden <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_c1_user_rden <= 'd0;
    else if(w_arbiter_lock_pos && r_arbiter_flag && !w_fifo_c1_user_empty && m_axis_out_ready)
        r_fifo_c1_user_rden <= 'd1;
    else
        r_fifo_c1_user_rden <= 'd0;
end

//记录数据包长度信息
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_pkt_64bit_len <= 'd0;
    else if(P_ARBITER_LAYER == "IP")begin//IP层的仲裁
        if((r_fifo_c0_user_rden_1d || r_fifo_c1_user_rden_1d) && w_ip_byte_len[2:0] != 0)
            r_pkt_64bit_len <= (w_ip_byte_len >> 3) + 1;
        else if((r_fifo_c0_user_rden_1d || r_fifo_c1_user_rden_1d) && w_ip_byte_len[2:0] == 0)
            r_pkt_64bit_len <= w_ip_byte_len >> 3;        
        else
            r_pkt_64bit_len <= r_pkt_64bit_len;
    end
    else if(P_ARBITER_LAYER == "MAC")begin//MAC层的仲裁
        if((r_fifo_c0_user_rden_1d || r_fifo_c1_user_rden_1d) && w_mac_byte_len[2:0] != 0)
            r_pkt_64bit_len <= (w_mac_byte_len >> 3) + 1;
        else if((r_fifo_c0_user_rden_1d || r_fifo_c1_user_rden_1d) && w_mac_byte_len[2:0] == 0)
            r_pkt_64bit_len <= w_mac_byte_len >> 3;        
        else
            r_pkt_64bit_len <= r_pkt_64bit_len;
    end
    else
        r_pkt_64bit_len <= r_pkt_64bit_len; 
end


always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_send_cnt <= 'd0;
    else if(r_send_cnt == r_pkt_64bit_len && r_pkt_64bit_len != 0)
        r_send_cnt <= 'd0;
    else if(r_fifo_data_rden_1d)
        r_send_cnt <= r_send_cnt + 'd1;
    else
        r_send_cnt <= r_send_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_fifo_data_rden_1d <= 'd0;
        r_fifo_keep_rden_1d <= 'd0;
        r_fifo_user_rden_1d <= 'd0;
    end
    else begin
        r_fifo_data_rden_1d <= r_fifo_c0_data_rden || r_fifo_c1_data_rden;
        r_fifo_keep_rden_1d <= r_fifo_c0_keep_rden || r_fifo_c1_keep_rden;
        r_fifo_user_rden_1d <= r_fifo_c0_user_rden || r_fifo_c1_user_rden;
    end   
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_c0_data_rden <= 'd0;
    else if(r_send_cnt == r_pkt_64bit_len - 2)
        r_fifo_c0_data_rden <= 'd0;
    else if(r_fifo_c0_user_rden)
        r_fifo_c0_data_rden <= 'd1;
    else
        r_fifo_c0_data_rden <= r_fifo_c0_data_rden;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_c1_data_rden <= 'd0;
    else if(r_send_cnt == r_pkt_64bit_len - 2)
        r_fifo_c1_data_rden <= 'd0;
    else if(r_fifo_c1_user_rden)
        r_fifo_c1_data_rden <= 'd1;
    else
        r_fifo_c1_data_rden <= r_fifo_c1_data_rden;
end


always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_c0_keep_rden <= 'd0;
    else if(r_send_cnt == r_pkt_64bit_len - 3)
        r_fifo_c0_keep_rden <= 'd1;
    else
        r_fifo_c0_keep_rden <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_c1_keep_rden <= 'd0;
    else if(r_send_cnt == r_pkt_64bit_len - 3)
        r_fifo_c1_keep_rden <= 'd1;
    else
        r_fifo_c1_keep_rden <= 'd0;
end

//axis数据流
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_out_data <= 'd0;
    else if(r_fifo_data_rden_1d && !r_arbiter_flag)
        rm_axis_out_data <= w_fifo_c0_data_dout;
    else if(r_fifo_data_rden_1d && r_arbiter_flag)
        rm_axis_out_data <= w_fifo_c1_data_dout;
    else
        rm_axis_out_data <= rm_axis_out_data;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_out_user <= 'd0;
    else if(r_fifo_user_rden_1d && !r_arbiter_flag)
        rm_axis_out_user <= w_fifo_c0_user_dout;
    else if(r_fifo_user_rden_1d && r_arbiter_flag)
        rm_axis_out_user <= w_fifo_c1_user_dout;
    else
        rm_axis_out_user <= rm_axis_out_user;
end


always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_out_keep <= 8'hff;
    else if(r_send_cnt == r_pkt_64bit_len - 1 && !r_arbiter_flag)
        rm_axis_out_keep <= w_fifo_c0_keep_dout;
    else if(r_send_cnt == r_pkt_64bit_len - 1 && r_arbiter_flag)
        rm_axis_out_keep <= w_fifo_c1_keep_dout;
    else
        rm_axis_out_keep <= 8'hff;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_out_last <= 'd0;
    else if(r_send_cnt == r_pkt_64bit_len - 1)
        rm_axis_out_last <= 'd1;
    else
        rm_axis_out_last <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_out_valid <= 'd0;
    else if(rm_axis_out_last)
        rm_axis_out_valid <= 'd0;
    else if(r_fifo_data_rden_1d)
        rm_axis_out_valid <= 'd1;
    else
        rm_axis_out_valid <= rm_axis_out_valid;
end



always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rs_axis_c0_ready <= 'd1;
    else if(s_axis_c0_last)
        rs_axis_c0_ready <= 'd0;
    else if(w_fifo_c0_data_empty)
        rs_axis_c0_ready <= 'd1;
    else
        rs_axis_c0_ready <= rs_axis_c0_ready;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rs_axis_c1_ready <= 'd1;
    else if(s_axis_c1_last)
        rs_axis_c1_ready <= 'd0;
    else if(w_fifo_c1_data_empty)
        rs_axis_c1_ready <= 'd1;
    else
        rs_axis_c1_ready <= rs_axis_c1_ready;
end


endmodule
