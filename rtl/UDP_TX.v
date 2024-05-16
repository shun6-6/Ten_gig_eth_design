`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/25 14:02:39
// Design Name: 
// Module Name: UDP_TX
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


module UDP_TX#(
    parameter       P_SRC_UDP_PORT  = 16'h8080,
    parameter       P_DST_UDP_PORT  = 16'h8080
)(
    input           i_clk               ,
    input           i_rst               ,
    input  [15:0]   i_dymanic_src_port  ,
    input           i_dymanic_src_valid ,
    input  [15:0]   i_dymanic_dst_port  ,
    input           i_dymanic_dst_valid ,
    /****next layer data****/
    output [63:0]   m_axis_ip_data      ,
    output [55:0]   m_axis_ip_user      ,//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    output [7 :0]   m_axis_ip_keep      ,
    output          m_axis_ip_last      ,
    output          m_axis_ip_valid     ,
    input           m_axis_ip_ready     ,
    /****user data****/
    input  [63:0]   s_axis_user_data    ,
    input  [31:0]   s_axis_user_user    ,
    input  [7 :0]   s_axis_user_keep    ,
    input           s_axis_user_last    ,
    input           s_axis_user_valid   ,
    output          s_axis_user_ready   
);
/******************************function*****************************/

/******************************parameter****************************/

/******************************mechine******************************/

/******************************reg**********************************/
reg  [15:0]     ri_dymanic_src_port ;
reg  [15:0]     ri_dymanic_dst_port ;
(* MARK_DEBUG = "TRUE" *)reg  [63:0]     rs_axis_user_data   ;
(* MARK_DEBUG = "TRUE" *)reg  [31:0]     rs_axis_user_user   ;
(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     rs_axis_user_keep   ;
(* MARK_DEBUG = "TRUE" *)reg             rs_axis_user_last   ;
(* MARK_DEBUG = "TRUE" *)reg             rs_axis_user_valid  ;
(* MARK_DEBUG = "TRUE" *)reg             rs_axis_user_ready  ;
(* MARK_DEBUG = "TRUE" *)reg  [63:0]     rm_axis_ip_data     ;
(* MARK_DEBUG = "TRUE" *)reg  [55:0]     rm_axis_ip_user     ;
(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     rm_axis_ip_keep     ;
(* MARK_DEBUG = "TRUE" *)reg             rm_axis_ip_last     ;
(* MARK_DEBUG = "TRUE" *)reg             rm_axis_ip_valid    ;
reg             rm_axis_ip_last_1d  ;

(* MARK_DEBUG = "TRUE" *)reg  [15:0]     r_pkt_cnt           ;
(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     r_tail_keep         ;
(* MARK_DEBUG = "TRUE" *)reg  [15:0]     r_byte_len          ;

//fifo 信号
(* MARK_DEBUG = "TRUE" *)reg             r_fifo_data_rden    ;

//分片指示信号
(* MARK_DEBUG = "TRUE" *)reg             r_split_flag        ;
(* MARK_DEBUG = "TRUE" *)reg             r_first_split       ;
(* MARK_DEBUG = "TRUE" *)reg             r_split_run         ;
(* MARK_DEBUG = "TRUE" *)reg  [12:0]     r_offset            ;
/******************************wire*********************************/
(* MARK_DEBUG = "TRUE" *)wire [63:0]     w_fifo_data_dout    ;
(* MARK_DEBUG = "TRUE" *)wire            w_fifo_data_full    ;
(* MARK_DEBUG = "TRUE" *)wire            w_fifo_data_empty   ;
(* MARK_DEBUG = "TRUE" *)wire [15:0]     w_64bit_len         ;
/******************************assign*******************************/
assign m_axis_ip_data  = rm_axis_ip_data    ;
assign m_axis_ip_user  = rm_axis_ip_user    ;
assign m_axis_ip_keep  = rm_axis_ip_keep    ;
assign m_axis_ip_last  = rm_axis_ip_last    ;
assign m_axis_ip_valid = rm_axis_ip_valid   ;
assign s_axis_user_ready = rs_axis_user_ready   ;
assign w_64bit_len = r_byte_len[2:0] == 0 ? (r_byte_len >> 3) 
                    : (r_byte_len >> 3) + 1 ;
/******************************component****************************/
FIFO_64X2048 FIFO_64X2048_UDP_TX (
  .clk      (i_clk              ),  // input wire clk
  .srst     (i_rst              ),  // input wire srst
  .din      (rs_axis_user_data  ),  // input wire [63 : 0] din
  .wr_en    (rs_axis_user_valid ),  // input wire wr_en
  .rd_en    (r_fifo_data_rden   ),  // input wire rd_en
  .dout     (w_fifo_data_dout   ),  // output wire [63 : 0] dout
  .full     (w_fifo_data_full   ),  // output wire full
  .empty    (w_fifo_data_empty  )   // output wire empty
);

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
    if(i_rst)
        ri_dymanic_dst_port <= P_DST_UDP_PORT;
    else if(i_dymanic_dst_valid)
        ri_dymanic_dst_port <= i_dymanic_dst_port;
    else
        ri_dymanic_dst_port <= ri_dymanic_dst_port;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        rs_axis_user_data  <= 'd0;
        rs_axis_user_user  <= 'd0;
        rs_axis_user_keep  <= 'd0;
        rs_axis_user_last  <= 'd0;
        rs_axis_user_valid <= 'd0;
    end
    else begin
        rs_axis_user_data  <= s_axis_user_data ;
        rs_axis_user_user  <= s_axis_user_user ;
        rs_axis_user_keep  <= s_axis_user_keep ;
        rs_axis_user_last  <= s_axis_user_last ;
        rs_axis_user_valid <= s_axis_user_valid;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rs_axis_user_ready <= 'd1;
    else if(s_axis_user_last)
        rs_axis_user_ready <= 'd0;
    else if(w_fifo_data_empty)
        rs_axis_user_ready <= 'd1;
    else
        rs_axis_user_ready <= rs_axis_user_ready;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_tail_keep <= 'd0;
    else if(s_axis_user_last)
        r_tail_keep <= s_axis_user_keep;
    else
        r_tail_keep <= r_tail_keep; 
end

//r_first_split为1表示当前是第一个包（可能有后续分片也可能就这么一片数据）
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_first_split <= 'd0;
    else if(rm_axis_ip_last)
        r_first_split <= 'd0;
    else if(s_axis_user_valid && !rs_axis_user_valid)
        r_first_split <= 'd1;
    else
        r_first_split <= r_first_split; 
end
//用户数据字节长度，每次发送结束后更新，
//如果是第一个包，当其小于1472则不用分片
//如果不是第一个包，当其小于1480则不用继续分片
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_byte_len <= 'd0;
    else if(s_axis_user_valid && !rs_axis_user_valid)
        r_byte_len <= s_axis_user_user[15:0];
    else if(r_first_split && rm_axis_ip_last && r_split_flag)
        r_byte_len <= r_byte_len - 1472;
    else if(rm_axis_ip_last && r_split_flag)
        r_byte_len <= r_byte_len - 1480;
    else
        r_byte_len <= r_byte_len;
end

//根据r_byte_len数值判断是否继续分片
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_split_flag <= 'd0;
    else if(s_axis_user_valid && !rs_axis_user_valid && s_axis_user_user[15:0] <= 1472)
        r_split_flag <= 'd0;
    else if(s_axis_user_valid && !rs_axis_user_valid && s_axis_user_user[15:0] > 1472)
        r_split_flag <= 'd1;
    else if(r_split_flag && rm_axis_ip_last_1d && r_byte_len > 1480)
        r_split_flag <= 'd1;
    else if(r_split_flag && rm_axis_ip_last_1d && r_byte_len <= 1480)
        r_split_flag <= 'd0;
    else
        r_split_flag <= r_split_flag;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_offset <= 'd0;
    else if(r_split_flag && rm_axis_ip_last)
        r_offset <= r_offset + 16'd185;
    else if(r_split_run && !r_split_flag && rm_axis_ip_last)
        r_offset <= 'd0;
    else
        r_offset <= r_offset;
end

//用于指示当前输出的包都是某个巨帧的一个分片
//处于分片状态下时候的中间分片不需要包头，所以通过计数器产生尾端last时候要区别处理，该处理通过r_split_run
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_split_run <= 'd0;
    else if(r_split_flag)
        r_split_run <= 'd1;
    else if(!r_split_flag && rm_axis_ip_last)
        r_split_run <= 'd0;
    else
        r_split_run <= r_split_run;
end


//开始组包
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_fifo_data_rden <= 'd0;
    else if(r_first_split && r_split_flag && r_pkt_cnt == 185 - 1)
        r_fifo_data_rden <= 'd0;
    else if(r_split_flag && r_pkt_cnt == 185 - 1)
        r_fifo_data_rden <= 'd0;
    else if(!r_split_flag && r_split_run && r_pkt_cnt == w_64bit_len - 1)
        r_fifo_data_rden <= 'd0;
    else if(!r_split_run && r_pkt_cnt == w_64bit_len - 1 && r_pkt_cnt != 0)
        r_fifo_data_rden <= 'd0;
    else if(!w_fifo_data_empty && m_axis_ip_ready && !rm_axis_ip_last)
        r_fifo_data_rden <= 'd1;
    else
        r_fifo_data_rden <= r_fifo_data_rden;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_pkt_cnt <= 'd0;
    else if(r_first_split && r_pkt_cnt == 185 - 1 && r_split_flag)
        r_pkt_cnt <= 'd0;
    else if(!r_first_split && r_pkt_cnt == 185 - 1 && r_split_flag)
        r_pkt_cnt <= 'd0;
    else if(r_pkt_cnt == w_64bit_len - 1 && !r_split_flag && r_split_run)
        r_pkt_cnt <= 'd0;
    else if(r_pkt_cnt == w_64bit_len && !r_split_run && r_pkt_cnt != 0)
        r_pkt_cnt <= 'd0;
    else if(r_fifo_data_rden)
        r_pkt_cnt <= r_pkt_cnt + 'd1;
    else
        r_pkt_cnt <= r_pkt_cnt;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_ip_data <= 'd0;
    else
        case (r_pkt_cnt)
            0       : begin
                if(r_first_split && r_split_flag)
                    rm_axis_ip_data <= {  ri_dymanic_src_port,ri_dymanic_dst_port,
                    16'd1480,16'd0};     
                else if(!r_first_split && r_split_run)
                    rm_axis_ip_data <= w_fifo_data_dout;
                else
                    rm_axis_ip_data <= {  ri_dymanic_src_port,ri_dymanic_dst_port,
                    (r_byte_len + 16'd8),16'd0};          
            end
            default : rm_axis_ip_data <= w_fifo_data_dout;
        endcase      
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_ip_user <= 'd0;
    else if(r_first_split && !r_split_flag)//只有包头需要+8
        rm_axis_ip_user <= {r_byte_len + 16'd8, 3'b010, 8'd17, r_offset, 16'd0};
    else if(r_split_flag)
        rm_axis_ip_user <= {16'd1480, 3'b001, 8'd17, r_offset, 16'd0};
    else
        rm_axis_ip_user <= {r_byte_len, 3'b000, 8'd17, r_offset, 16'd0};
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_ip_keep <= 8'hff;
    else if(r_split_flag)
        rm_axis_ip_keep <= 8'hff;
    else if(r_pkt_cnt == w_64bit_len - 1 && r_split_run)
        rm_axis_ip_keep <= r_tail_keep;
    else if(r_pkt_cnt == w_64bit_len && !r_split_run && r_pkt_cnt != 0)
        rm_axis_ip_keep <= r_tail_keep;
    else
        rm_axis_ip_keep <= 8'hff;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_ip_last <= 'd0;
    else if(r_split_flag && r_pkt_cnt == 185 - 1)
        rm_axis_ip_last <= 'd1;
    else if(r_pkt_cnt == w_64bit_len - 1 && r_split_run)
        rm_axis_ip_last <= 'd1;
    else if(r_pkt_cnt == w_64bit_len && !r_split_run && r_pkt_cnt != 0)
        rm_axis_ip_last <= 'd1;
    else
        rm_axis_ip_last <= 'd0;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_ip_last_1d <= 'd0;
    else
        rm_axis_ip_last_1d <= rm_axis_ip_last;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_ip_valid <= 'd0;
    else if(rm_axis_ip_last)
        rm_axis_ip_valid <= 'd0;
    else if(r_fifo_data_rden)
        rm_axis_ip_valid <= 'd1;
    else
        rm_axis_ip_valid <= rm_axis_ip_valid;
end


endmodule
