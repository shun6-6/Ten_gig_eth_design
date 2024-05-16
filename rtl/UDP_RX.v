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
    parameter       P_SRC_UDP_PORT  = 16'h8080,
    parameter       P_DST_UDP_PORT  = 16'h8080
)(
    input           i_clk               ,
    input           i_rst               ,
    input  [15:0]   i_dymanic_src_port  ,
    input           i_dymanic_src_valid ,
    /****next layer data****/
    input  [63:0]   s_axis_ip_data      ,
    input  [55:0]   s_axis_ip_user      ,//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
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
(* MARK_DEBUG = "TRUE" *)reg  [63:0]     rs_axis_ip_data     ;
(* MARK_DEBUG = "TRUE" *)reg  [55:0]     rs_axis_ip_user     ;
(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     rs_axis_ip_keep     ;
(* MARK_DEBUG = "TRUE" *)reg             rs_axis_ip_last     ;
(* MARK_DEBUG = "TRUE" *)reg             rs_axis_ip_valid    ;
(* MARK_DEBUG = "TRUE" *)reg  [63:0]     rm_axis_user_data   ;
(* MARK_DEBUG = "TRUE" *)reg  [31:0]     rm_axis_user_user   ;
(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     rm_axis_user_keep   ;
(* MARK_DEBUG = "TRUE" *)reg             rm_axis_user_last   ;
(* MARK_DEBUG = "TRUE" *)reg             rm_axis_user_valid  ;

reg  [15:0]     r_recv_cnt          ;
reg  [15:0]     r_recv_src_port     ;
reg  [15:0]     r_recv_dst_port     ;
(* MARK_DEBUG = "TRUE" *)reg  [15:0]     r_recv_pkt_64bit_len      ;
(* MARK_DEBUG = "TRUE" *)reg             r_udp_pkt_valid     ;
(* MARK_DEBUG = "TRUE" *)reg             r_udp_access        ;
reg  [7 :0]     r_tail_keep         ;
(* MARK_DEBUG = "TRUE" *)reg             r_run               ;
reg  [15:0]     r_out_cnt           ;

//分片指示信号
reg             r_udp_split         ;
reg             r_udp_more_split    ;
(* MARK_DEBUG = "TRUE" *)reg             r_udp_header        ;
reg  [12:0]     r_udp_offset        ;

//BRAM 信号
(* MARK_DEBUG = "TRUE" *)reg  [10:0]     r_bram_addr_a       ;
(* MARK_DEBUG = "TRUE" *)reg  [10:0]     r_bram_addr_b       ;
(* MARK_DEBUG = "TRUE" *)reg             r_bram_enb          ;
reg             r_bram_enb_1d       ;

//fifo single
(* MARK_DEBUG = "TRUE" *)reg             r_fifo_len_rden     ;
/******************************wire*********************************/
(* MARK_DEBUG = "TRUE" *)wire [15:0]     w_64bit_len         ;
(* MARK_DEBUG = "TRUE" *)wire [15:0]     w_byte_len          ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]     w_bram_dout_b       ;

(* MARK_DEBUG = "TRUE" *)wire [2:0]      w_ip_flags          ;
(* MARK_DEBUG = "TRUE" *)wire            w_recv_pkt_end      ;

(* MARK_DEBUG = "TRUE" *)wire [15:0]     w_fifo_len_dout     ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]     w_fifo_keep_dout    ;
wire            w_fifo_len_full     ;
wire            w_fifo_len_empty    ;
wire            w_fifo_keep_full    ;
wire            w_fifo_keep_empty   ;

(* MARK_DEBUG = "TRUE" *)wire [15:0]     w_last_byte_len     ;
/******************************assign*******************************/
assign m_axis_user_data  = rm_axis_user_data    ;
assign m_axis_user_user  = rm_axis_user_user    ;
assign m_axis_user_keep  = rm_axis_user_keep    ;
assign m_axis_user_last  = rm_axis_user_last    ;
assign m_axis_user_valid = rm_axis_user_valid   ;
assign w_ip_flags = s_axis_ip_user[39:37];

assign w_last_byte_len =    w_fifo_keep_dout == 8'b1000_0000 ? 1 :
                            w_fifo_keep_dout == 8'b1100_0000 ? 2 :
                            w_fifo_keep_dout == 8'b1110_0000 ? 3 :
                            w_fifo_keep_dout == 8'b1111_0000 ? 4 :
                            w_fifo_keep_dout == 8'b1111_1000 ? 5 :
                            w_fifo_keep_dout == 8'b1111_1100 ? 6 :
                            w_fifo_keep_dout == 8'b1111_1110 ? 7 :
                            w_fifo_keep_dout == 8'b1111_1111 ? 8 : 0;

assign w_byte_len  =( (w_fifo_len_dout - 1) << 3) + w_last_byte_len;
assign w_64bit_len = w_byte_len[2:0] == 0 ? (w_byte_len >> 3) 
                        : (w_byte_len >> 3) + 1;

//完整的一个包输入指示信号
//表示没有分片，那么last到来即一个包结束; 分片但是当前分片后没有更多片
assign w_recv_pkt_end = r_udp_pkt_valid && ((rs_axis_ip_last && r_udp_split == 0 && r_udp_offset == 0) || 
                        (rs_axis_ip_last && r_udp_split == 1 && r_udp_more_split == 0));

/******************************component****************************/
//完整的一个UDP数据进入后才开始输出

BRAM_64X1280 BRAM_64X2048_udp_rx (
    .clka   (i_clk              ),  // input wire clka
    .ena    (rs_axis_ip_valid   ),  // input wire ena
    .wea    (rs_axis_ip_valid   ),  // input wire [0 : 0] wea
    .addra  (r_bram_addr_a      ),  // input wire [10 : 0] addra
    .dina   (rs_axis_ip_data    ),  // input wire [63 : 0] dina
    .clkb   (i_clk              ),  // input wire clkb
    .enb    (r_bram_enb         ),  // input wire enb
    .addrb  (r_bram_addr_b      ),  // input wire [10 : 0] addrb
    .doutb  (w_bram_dout_b      )   // output wire [63 : 0] doutb
);

FIFO_16X512 FIFO_16X512_pkt_len (
  .clk      (i_clk              ),  // input wire clk
  .srst     (i_rst              ),  // input wire srst
  .din      (r_recv_pkt_64bit_len     ),  // input wire [15 : 0] din
  .wr_en    (w_recv_pkt_end && rs_axis_ip_last),  // input wire wr_en
  .rd_en    (r_fifo_len_rden    ),  // input wire rd_en
  .dout     (w_fifo_len_dout    ),  // output wire [15 : 0] dout
  .full     (w_fifo_len_full    ),  // output wire full
  .empty    (w_fifo_len_empty   )   // output wire empty
);

FIFO_8X512 FIFO_8X512_tail_keep (
  .clk      (i_clk              ),  // input wire clk
  .srst     (i_rst              ),  // input wire srst
  .din      (r_tail_keep        ),  // input wire [7 : 0] din
  .wr_en    (w_recv_pkt_end && rs_axis_ip_last),    // input wire wr_en
  .rd_en    (r_fifo_len_rden    ),  // input wire rd_en
  .dout     (w_fifo_keep_dout   ),  // output wire [7 : 0] dout
  .full     (w_fifo_keep_full   ),  // output wire full
  .empty    (w_fifo_keep_empty  )   // output wire empty
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

//检测是否为UDP数据包,通过user当中的type字段判断即可
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_udp_pkt_valid <= 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid && s_axis_ip_user[36:29] == 8'd17 && w_ip_flags[2] == 0)//分片udp没有包头
        r_udp_pkt_valid <= 'd1;
    else if(s_axis_ip_valid && !rs_axis_ip_valid && ((s_axis_ip_user[36:29] != 8'd17) || (s_axis_ip_data[47:32] != ri_dymanic_src_port)))
        r_udp_pkt_valid <= 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid && s_axis_ip_user[36:29] == 8'd17 && s_axis_ip_data[47:32] == ri_dymanic_src_port)
        r_udp_pkt_valid <= 'd1;
    else
        r_udp_pkt_valid <= r_udp_pkt_valid;
end

//偏移为0才表示当前udp数据包是第一个包，当分片时只有第一个udp包带包头信息
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_udp_header <= 'd0;
    else if(rs_axis_ip_last)
        r_udp_header <= 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid && s_axis_ip_user[28:16] == 'd0)
        r_udp_header <= 'd1;
    else
        r_udp_header <= r_udp_header;
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
    else if(r_recv_cnt == 0 && rs_axis_ip_valid && r_udp_header)
        r_recv_src_port <= rs_axis_ip_data[63:48];
    else
        r_recv_src_port <= r_recv_src_port;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_recv_dst_port <= 'd0;
    else if(r_recv_cnt == 0 && rs_axis_ip_valid && r_udp_header)
        r_recv_dst_port <= rs_axis_ip_data[47:32];
    else
        r_recv_dst_port <= r_recv_dst_port;
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_udp_access <= 'd0;
    else if(r_recv_cnt == 0 && rs_axis_ip_valid && rs_axis_ip_data[47:32] != ri_dymanic_src_port)
        r_udp_access <= 'd0;
    else if(r_recv_cnt == 0 && rs_axis_ip_valid && rs_axis_ip_data[47:32] == ri_dymanic_src_port)
        r_udp_access <= 'd1;
    else
        r_udp_access <= r_udp_access;
end
//r_udp_split为1表示分片
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_udp_split <= 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid)
        r_udp_split <= ~w_ip_flags[1];
    else
        r_udp_split <= r_udp_split;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_udp_offset <= 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid)
        r_udp_offset <= s_axis_ip_user[28:16];
    else
        r_udp_offset <= r_udp_offset;
end


//r_udp_more_split为1表示后面还有更多分片，即当前报文并非最后一片。
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_udp_more_split <= 'd0;
    else if(s_axis_ip_valid && !rs_axis_ip_valid)
        r_udp_more_split <= w_ip_flags[0];
    else
        r_udp_more_split <= r_udp_more_split;
end

//控制输入的数据进入环形RAM
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_bram_addr_a <= 'd0;
    // else if(w_recv_pkt_end)
    //     r_bram_addr_a <= r_bram_addr_a + 1;
    else if(rs_axis_ip_valid && r_recv_cnt == 0 && r_udp_header)//包含UDP头时，去掉第一个8byte的包头
        r_bram_addr_a <= r_bram_addr_a;
    else if(rs_axis_ip_valid && r_udp_pkt_valid)
        r_bram_addr_a <= r_bram_addr_a + 'd1;
    else
        r_bram_addr_a <= r_bram_addr_a;
end

//完整数据长度记录，此时是包含UDP包头的
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_recv_pkt_64bit_len <= 'd0;
    else if(w_recv_pkt_end && rs_axis_ip_last)
        r_recv_pkt_64bit_len <= 'd0;
    else if(rs_axis_ip_valid && r_udp_pkt_valid)
        r_recv_pkt_64bit_len <= r_recv_pkt_64bit_len + 1;
    else
        r_recv_pkt_64bit_len <= r_recv_pkt_64bit_len;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_tail_keep <= 8'hff;
    else if(s_axis_ip_last)
        r_tail_keep <= s_axis_ip_keep;
    else
        r_tail_keep <= r_tail_keep;
end


//当长度和keep FIFO不为空则说明有一个完整数据包进入了，开始读RAM

//输出指示信号，当一个数据输出后才可以继续读FIFO当中的长度信息，开启下一次数据
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_run <= 'd0;
    else if(rm_axis_user_last)
        r_run <= 'd0;
    else if(!w_fifo_len_empty && !r_run)
        r_run <= 'd1;
    else
        r_run <= r_run;
end
//read pkt len
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_fifo_len_rden <= 'd0;
    else if(!w_fifo_len_empty && !r_run)
        r_fifo_len_rden <= 'd1;
    else
        r_fifo_len_rden <= 'd0;
end
//输出计数器
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_out_cnt <= 'd0;
    else if(r_out_cnt == w_fifo_len_dout - 1 && r_out_cnt != 0)
        r_out_cnt <= 'd0;
    else if(r_bram_enb)
        r_out_cnt <= r_out_cnt + 'd1;
    else
        r_out_cnt <= r_out_cnt;
end
//读ram
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_bram_enb <= 'd0;
    else if(r_out_cnt == w_fifo_len_dout - 1 && r_out_cnt != 0)
        r_bram_enb <= 'd0;
    else if(r_fifo_len_rden)
        r_bram_enb <= 'd1;
    else
        r_bram_enb <= r_bram_enb;
end       

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_bram_enb_1d <= 'd0;
    else
        r_bram_enb_1d <= r_bram_enb;
end
//读ram地址
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_bram_addr_b <= 'd0;
    else if(r_bram_enb)
        r_bram_addr_b <= r_bram_addr_b + 'd1;
    else
        r_bram_addr_b <= r_bram_addr_b;
end   

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_data <= 'd0;
    else if(r_bram_enb_1d)
        rm_axis_user_data <= w_bram_dout_b;
    else
        rm_axis_user_data <= 'd0;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_user <= 'd0;
    else
        rm_axis_user_user <= {16'd0,w_byte_len};
end

//分片时候除了最后一个分片，其余分片全是8的倍数
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_keep <= 8'hff;
    else if(!r_bram_enb && r_bram_enb_1d)
        rm_axis_user_keep <= w_fifo_keep_dout;
    else
        rm_axis_user_keep <= 8'hff;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_last <= 'd0;
    else if(!r_bram_enb && r_bram_enb_1d)
        rm_axis_user_last <= 'd1;
    else
        rm_axis_user_last <= 'd0;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_user_valid <= 'd0;
    else if(rm_axis_user_last)
        rm_axis_user_valid <= 'd0;
    else if(r_bram_enb_1d)
        rm_axis_user_valid <= 'd1;
    else
        rm_axis_user_valid <= rm_axis_user_valid;
end


endmodule
