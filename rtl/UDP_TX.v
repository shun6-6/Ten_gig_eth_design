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
    parameter       P_SRC_UDP_PORT  = 16'h0808,
    parameter       P_DST_UDP_PORT  = 16'h0808
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
reg  [63:0]     rs_axis_user_data   ;
reg  [31:0]     rs_axis_user_user   ;
reg  [7 :0]     rs_axis_user_keep   ;
reg             rs_axis_user_last   ;
reg             rs_axis_user_valid  ;
reg             rs_axis_user_ready  ;
reg  [63:0]     rm_axis_ip_data     ;
reg  [55:0]     rm_axis_ip_user     ;
reg  [7 :0]     rm_axis_ip_keep     ;
reg             rm_axis_ip_last     ;
reg             rm_axis_ip_valid    ;

reg  [15:0]     r_pkt_cnt           ;
reg             r_fifo_data_rden    ;
reg  [7 :0]     r_tail_keep         ;
reg  [15:0]     r_byte_len           ;

/******************************wire*********************************/
wire [63:0]     w_fifo_data_dout    ;
wire            w_fifo_data_full    ;
wire            w_fifo_data_empty   ;
wire [15:0]     w_64bit_len         ;
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
FIFO_64X256 FIFO_64X256_UDP_data_tx (
  .clk          (i_clk              ),
  .srst         (i_rst              ),  
  .din          (rs_axis_user_data  ),
  .wr_en        (rs_axis_user_valid ),
  .rd_en        (r_fifo_data_rden   ),
  .dout         (w_fifo_data_dout   ),
  .full         (w_fifo_data_full   ),
  .empty        (w_fifo_data_empty  ) 
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
        rs_axis_user_ready <= 'd0;
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

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_byte_len <= 'd0;
    else if(s_axis_user_valid && !rs_axis_user_valid)
        r_byte_len <= s_axis_user_user[15:0];
    else
        r_byte_len <= r_byte_len; 
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_fifo_data_rden <= 'd0;
    else if(r_pkt_cnt == w_64bit_len - 1)
        r_fifo_data_rden <= 'd0;
    else if(!w_fifo_data_empty && m_axis_ip_ready)
        r_fifo_data_rden <= 'd1;
    else
        r_fifo_data_rden <= r_fifo_data_rden;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_pkt_cnt <= 'd0;
    else if(r_pkt_cnt == w_64bit_len && w_64bit_len != 0)
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
            0       : rm_axis_ip_data <= {  ri_dymanic_src_port,ri_dymanic_dst_port,
                                            (r_byte_len + 16'd8),16'd0};
            default : rm_axis_ip_data <= w_fifo_data_dout;
        endcase      
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_ip_user <= 'd0;
    else
        rm_axis_ip_user <= {r_byte_len + 16'd8, 3'b010, 8'd17, 13'd0, 16'd0};
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_ip_keep <= 8'hff;
    else if(r_pkt_cnt == w_64bit_len && w_64bit_len != 0)
        rm_axis_ip_keep <= r_tail_keep;
    else
        rm_axis_ip_keep <= 8'hff;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_ip_last <= 'd0;
    else if(r_pkt_cnt == w_64bit_len && w_64bit_len != 0)
        rm_axis_ip_last <= 'd1;
    else
        rm_axis_ip_last <= 'd0;
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
