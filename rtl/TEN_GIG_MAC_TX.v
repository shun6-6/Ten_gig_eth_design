`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 15:52:25
// Design Name: 
// Module Name: 10G_MAC_TX
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


module TEN_GIG_MAC_TX#(
    parameter       P_SRC_MAC = 48'h00_00_00_00_00_00,
    parameter       P_DST_MAC = 48'h00_00_00_00_00_00
)(
    input           i_clk               ,
    input           i_rst               ,

    input  [47:0]   i_dynamic_src_mac   ,
    input           i_dynamic_src_valid ,
    input  [47:0]   i_dynamic_dst_mac   ,
    input           i_dynamic_dst_valid ,

    input  [63:0]   s_axis_tdata        ,
    input  [79:0]   s_axis_tuser        ,
    input  [7 :0]   s_axis_tkeep        ,
    input           s_axis_tlast        ,
    input           s_axis_tvalid       ,
    output          s_axis_tready       ,

    output [63:0]   o_xgmii_txd         ,
    output [7 :0]   o_xgmii_txc         
);
/******************************function*****************************/

/******************************parameter****************************/
localparam      P_FRAME_IDLE    = 8'h07 ,
                P_FRAME_START   = 8'hFB ,
                P_FRAME_END     = 8'hFD ,
                P_FRAME_EEROR   = 8'hFE ;
localparam      P_READY_CNT     = 5'd6 ;
/******************************mechine******************************/

/******************************reg**********************************/
reg  [47:0]     ri_dynamic_src_mac      ;
reg  [47:0]     ri_dynamic_dst_mac      ;
reg  [63:0]     rs_axis_tdata           ;
reg  [79:0]     rs_axis_tuser           ;
reg  [7 :0]     rs_axis_tkeep           ;
reg             rs_axis_tlast           ;
reg             rs_axis_tvalid          ;
reg             rs_axis_tready          ;
reg  [63:0]     ro_xgmii_txd            ;
reg  [7 :0]     ro_xgmii_txc            ;

reg             r_fifo_data_rden        ;
//reg             r_fifo_data_rden_1d     ;
reg             r_fifo_user_rden    ;
reg             r_fifo_user_rden_1d ;
reg             r_fifo_keep_rden        ;
reg             r_fifo_keep_rden_1d     ;

reg  [63:0]     r_fifo_data_dout        ;
reg  [15:0]     r_pkt_64bit_len              ;
reg  [15:0]     r_data_type             ;
reg  [7 :0]     r_tail_keep             ;
reg  [7 :0]     r_tail_keep_1d          ;
reg  [47:0]     r_dst_mac_addr          ;

reg  [15:0]     r_pkt_cnt               ;
reg  [15:0]     r_pkt_cnt_1d            ;
reg  [15:0]     r_pkt_cnt_2d            ;
reg  [15:0]     r_pkt_cnt_3d            ;
reg             r_run                   ;
reg             r_run_1d                ;
reg  [5 :0]     r_run_gap               ;
//CRC
reg  [63:0]     r_crc_data              ;
reg  [7 :0]     r_crc_keep              ;
reg             r_crc_en                ;
reg             r_crc_end               ;
reg  [7 :0]     r_crc_keep_1d           ;
reg             r_crc_end_1d            ;
reg  [31:0]     r_crc_result            ;

reg  [63:0]     r_xgmii_txd             ;
reg  [63:0]     r_xgmii_txd_1d          ;
reg  [63:0]     r_xgmii_txd_2d          ;
reg  [7 :0]     r_xgmii_txc             ;
reg  [7 :0]     r_xgmii_txc_1d          ;
reg  [7 :0]     r_xgmii_txc_2d          ;

reg             r_send_data             ;

//流控
reg  [4 :0]     r_ready_cnt             ;
/******************************wire*********************************/
wire [63:0]     w_fifo_data_dout        ;
wire            w_fifo_data_full        ;
wire            w_fifo_data_empty       ;
wire [79:0]     w_fifo_user_dout    ;
wire            w_fifo_user_full    ;
wire            w_fifo_user_empty   ;
wire [7 :0]     w_fifo_keep_dout        ;
wire            w_fifo_keep_full        ;
wire            w_fifo_keep_empty       ;

wire            w_sof                   ;
wire            w_eof                   ;

wire [15:0]     w_pkt_byte_len          ;
wire [15:0]     w_pkt_64bit_len         ;
wire [47:0]     w_dst_mac_addr          ;

wire [31:0]     w_crc_8                 ;
wire [31:0]     w_crc_1                 ;
wire [31:0]     w_crc_2                 ;
wire [31:0]     w_crc_3                 ;
wire [31:0]     w_crc_4                 ;
wire [31:0]     w_crc_5                 ;
wire [31:0]     w_crc_6                 ;
wire [31:0]     w_crc_7                 ;
wire [31:0]     w_crc_8_big             ;
wire [31:0]     w_crc_1_big             ;
wire [31:0]     w_crc_2_big             ;
wire [31:0]     w_crc_3_big             ;
wire [31:0]     w_crc_4_big             ;
wire [31:0]     w_crc_5_big             ;
wire [31:0]     w_crc_6_big             ;
wire [31:0]     w_crc_7_big             ;
/******************************component****************************/
FIFO_64X256 FIFO_64X256_data_tx (
  .clk          (i_clk              ),
  .srst         (i_rst              ),  
  .din          (rs_axis_tdata      ),
  .wr_en        (rs_axis_tvalid     ),
  .rd_en        (r_fifo_data_rden   ),
  .dout         (w_fifo_data_dout   ),
  .full         (w_fifo_data_full   ),
  .empty        (w_fifo_data_empty  ) 
);

FIFO_80X32 FIFO_80X32_user (
  .clk          (i_clk              ), 
  .srst         (i_rst              ),      
  .din          (rs_axis_tuser      ),     
  .wr_en        (rs_axis_tlast      ),  
  .rd_en        (r_fifo_user_rden   ),  
  .dout         (w_fifo_user_dout   ),  
  .full         (w_fifo_user_full   ),  
  .empty        (w_fifo_user_empty  )  
);

FIFO_8X32 FIFO_8X32_tail_keep (
  .clk          (i_clk              ),  
  .srst         (i_rst              ),    
  .din          (rs_axis_tkeep      ),  
  .wr_en        (rs_axis_tlast      ),  
  .rd_en        (r_fifo_keep_rden   ),  
  .dout         (w_fifo_keep_dout   ),  
  .full         (w_fifo_keep_full   ),  
  .empty        (w_fifo_keep_empty  ) 
);

CRC32_64bKEEP CRC32_64bKEEP_u0(
  .i_clk        (i_clk              ),
  .i_rst        (i_rst              ),
  .i_en         (r_crc_en           ),
  .i_data       (r_crc_data[63:56]  ),
  .i_data_1     (r_crc_data[55:48]  ),
  .i_data_2     (r_crc_data[47:40]  ),
  .i_data_3     (r_crc_data[39:32]  ),
  .i_data_4     (r_crc_data[31:24]  ),
  .i_data_5     (r_crc_data[23:16]  ),
  .i_data_6     (r_crc_data[15: 8]  ),
  .i_data_7     (r_crc_data[7 : 0]  ),
  .o_crc_8      (w_crc_8_big        ),
  .o_crc_1      (w_crc_1_big        ),
  .o_crc_2      (w_crc_2_big        ),
  .o_crc_3      (w_crc_3_big        ),
  .o_crc_4      (w_crc_4_big        ),
  .o_crc_5      (w_crc_5_big        ),
  .o_crc_6      (w_crc_6_big        ),
  .o_crc_7      (w_crc_7_big        ) 
);
/******************************assign*******************************/
assign s_axis_tready = rs_axis_tready;
assign o_xgmii_txd = ro_xgmii_txd;
assign o_xgmii_txc = ro_xgmii_txc;
assign w_sof = r_run && !r_run_1d;
assign w_eof = r_pkt_cnt > 2 && r_pkt_cnt == r_pkt_64bit_len + 1;
//crc小端模式发送
assign w_crc_8  = {w_crc_8_big[7:0],w_crc_8_big[15:8],w_crc_8_big[23:16],w_crc_8_big[31:24]};
assign w_crc_1  = {w_crc_1_big[7:0],w_crc_1_big[15:8],w_crc_1_big[23:16],w_crc_1_big[31:24]};
assign w_crc_2  = {w_crc_2_big[7:0],w_crc_2_big[15:8],w_crc_2_big[23:16],w_crc_2_big[31:24]};
assign w_crc_3  = {w_crc_3_big[7:0],w_crc_3_big[15:8],w_crc_3_big[23:16],w_crc_3_big[31:24]};
assign w_crc_4  = {w_crc_4_big[7:0],w_crc_4_big[15:8],w_crc_4_big[23:16],w_crc_4_big[31:24]};
assign w_crc_5  = {w_crc_5_big[7:0],w_crc_5_big[15:8],w_crc_5_big[23:16],w_crc_5_big[31:24]};
assign w_crc_6  = {w_crc_6_big[7:0],w_crc_6_big[15:8],w_crc_6_big[23:16],w_crc_6_big[31:24]};
assign w_crc_7  = {w_crc_7_big[7:0],w_crc_7_big[15:8],w_crc_7_big[23:16],w_crc_7_big[31:24]};
//数据字节长度和64bit长度
assign w_pkt_byte_len  = w_fifo_user_dout[79:64];
assign w_pkt_64bit_len = w_pkt_byte_len[2:0] == 0 ? (w_pkt_byte_len >> 3)
                            : (w_pkt_byte_len >> 3) + 1 ;

assign w_dst_mac_addr = w_fifo_user_dout[63:16];
/******************************always*******************************/
//动态配置MAC
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ri_dynamic_src_mac <= P_SRC_MAC;
    else if(i_dynamic_src_valid)
        ri_dynamic_src_mac <= i_dynamic_src_mac;
    else
        ri_dynamic_src_mac <= ri_dynamic_src_mac;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ri_dynamic_dst_mac <= P_DST_MAC;
    else if(i_dynamic_dst_valid)
        ri_dynamic_dst_mac <= i_dynamic_dst_mac;
    else
        ri_dynamic_dst_mac <= ri_dynamic_dst_mac;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        rs_axis_tdata  <= 'd0;
        rs_axis_tuser  <= 'd0;
        rs_axis_tkeep  <= 'd0;
        rs_axis_tlast  <= 'd0;
        rs_axis_tvalid <= 'd0;
        r_fifo_user_rden_1d <= 'd0;
        r_fifo_keep_rden_1d     <= 'd0;
        r_fifo_keep_rden_1d     <= 'd0;
    end
    else begin
        rs_axis_tdata  <= s_axis_tdata ;
        rs_axis_tuser  <= s_axis_tuser ;
        rs_axis_tkeep  <= s_axis_tkeep ;
        rs_axis_tlast  <= s_axis_tlast ;
        rs_axis_tvalid <= s_axis_tvalid; 
        r_fifo_user_rden_1d <= r_fifo_user_rden;
        r_fifo_keep_rden_1d     <= r_fifo_keep_rden    ;
        r_fifo_keep_rden_1d     <= r_fifo_keep_rden    ;
    end
end

//FIFO不为空开始运行
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_run <= 'd0;
    else if(w_eof)
        r_run <= 'd0;
    else if(!w_fifo_user_empty && !r_run && r_run_gap >= 2)
        r_run <= 'd1;
    else
        r_run <= r_run;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_run_1d <= 'd0;
    else
        r_run_1d <= r_run;
end
//俩次run之间至少俩个时钟周期间隔，才能满足以太网帧间隔要求
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_run_gap <= 'd1;
    else if(r_run && !r_run_1d)
        r_run_gap <= 'd0;
    else if(!r_run)
        r_run_gap <= r_run_gap + 'd1;
    else
        r_run_gap <= r_run_gap;
end


//提取长度类型和尾端keep信息
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_fifo_user_rden <= 'd0;
        r_fifo_keep_rden     <= 'd0;
    end
    else if(r_run && !r_run_1d)begin
        r_fifo_user_rden <= 'd1;
        r_fifo_keep_rden     <= 'd1;
    end
    else begin
        r_fifo_user_rden <= 'd0;
        r_fifo_keep_rden     <= 'd0;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_pkt_64bit_len  <= 'd0;
        r_data_type <= 'd0;
        r_tail_keep <= 'd0;
        r_dst_mac_addr <= 'd0;
    end     
    else if(r_fifo_user_rden_1d)begin
        r_pkt_64bit_len  <= w_pkt_64bit_len;
        r_data_type <= w_fifo_user_dout[15: 0];
        r_tail_keep <= w_fifo_keep_dout;
        r_dst_mac_addr <= w_fifo_user_dout[63:16];
    end 
    else begin
        r_pkt_64bit_len  <= r_pkt_64bit_len ;
        r_data_type <= r_data_type;
        r_tail_keep <= r_tail_keep;
        r_dst_mac_addr <= r_dst_mac_addr;
    end       
end
             
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_tail_keep_1d <= 'd0;
    else
        r_tail_keep_1d <= r_tail_keep;
    end
//产生xgmii输出数据
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_data_rden <= 'd0;
    else if(r_pkt_cnt > 2 && r_pkt_cnt == r_pkt_64bit_len)
        r_fifo_data_rden <= 'd0;
    else if(r_fifo_user_rden)
        r_fifo_data_rden <= 'd1;
    else
        r_fifo_data_rden <= r_fifo_data_rden;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_pkt_cnt <= 'd0;
    else if(r_pkt_cnt == r_pkt_64bit_len + 3)
        r_pkt_cnt <= 'd0;
    else if(r_fifo_user_rden || r_pkt_cnt)
        r_pkt_cnt <= r_pkt_cnt + 'd1;
    else
        r_pkt_cnt <= r_pkt_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_pkt_cnt_1d <= 'd0;
        r_pkt_cnt_2d <= 'd0;
        r_pkt_cnt_3d <= 'd0;
    end else begin
        r_pkt_cnt_1d <= r_pkt_cnt;
        r_pkt_cnt_2d <= r_pkt_cnt_1d;
        r_pkt_cnt_3d <= r_pkt_cnt_2d;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_data_dout <= 'd0;
    else
        r_fifo_data_dout <= w_fifo_data_dout;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_xgmii_txd <= {8{P_FRAME_IDLE}};
    else if(r_fifo_user_rden | ((r_pkt_cnt <= r_pkt_64bit_len + 2) && (r_pkt_cnt > 0)))
        case (r_pkt_cnt)
            0       : r_xgmii_txd <= 64'hfb55_5555_5555_5555;
            1       : r_xgmii_txd <= {8'hd5,w_dst_mac_addr,ri_dynamic_src_mac[47:40]};
            2       : r_xgmii_txd <= {ri_dynamic_src_mac[39:0],r_data_type,w_fifo_data_dout[63:56]};
            default : r_xgmii_txd <= {r_fifo_data_dout[55:0],w_fifo_data_dout[63:56]};
        endcase       
    else
        r_xgmii_txd <= {8{P_FRAME_IDLE}};
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_xgmii_txd_1d <= {8{P_FRAME_IDLE}};
        r_xgmii_txd_2d <= {8{P_FRAME_IDLE}};
    end
    else begin
        r_xgmii_txd_1d <= r_xgmii_txd;
        r_xgmii_txd_2d <= r_xgmii_txd_1d;
    end
end

//r_xgmii_txc还需要考虑最后多加4byte的CRC
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_xgmii_txc <= 8'b1111_1111;
    else if(r_fifo_user_rden)
        r_xgmii_txc <= 8'b1000_0000;
    else if(r_pkt_cnt == r_pkt_64bit_len + 3 && r_tail_keep >= 8'b1111_1000)
        case (r_tail_keep)
            8'b1111_1111    : r_xgmii_txc <= 8'b0001_1111;
            8'b1111_1110    : r_xgmii_txc <= 8'b0011_1111;
            8'b1111_1100    : r_xgmii_txc <= 8'b0111_1111;
            8'b1111_1000    : r_xgmii_txc <= 8'b1111_1111;
            default         : r_xgmii_txc <= 8'b0000_0000;
        endcase
    else if(r_pkt_cnt == r_pkt_64bit_len + 2 && r_tail_keep < 8'b1111_1000)
        case (r_tail_keep)      
            8'b1111_0000    : r_xgmii_txc <= 8'b0000_0001;
            8'b1110_0000    : r_xgmii_txc <= 8'b0000_0011;
            8'b1100_0000    : r_xgmii_txc <= 8'b0000_0111;
            8'b1000_0000    : r_xgmii_txc <= 8'b0000_1111;
            default         : r_xgmii_txc <= 8'b0000_0000;
        endcase
    else if(r_send_data)
        r_xgmii_txc <= 8'b0000_0000;
    else
        r_xgmii_txc <= 8'b1111_1111;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_send_data <= 'd0;
    else if(r_pkt_cnt == r_pkt_64bit_len + 3 && r_tail_keep >= 8'b1111_1000)
        r_send_data <= 'd0;
    else if(r_pkt_cnt == r_pkt_64bit_len + 2 && r_tail_keep < 8'b1111_1000)
        r_send_data <= 'd0;
    else if(r_fifo_user_rden)
        r_send_data <= 'd1;
    else
        r_send_data <= r_send_data;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_xgmii_txd <= {8{P_FRAME_IDLE}};
    else if(r_pkt_cnt_3d == r_pkt_64bit_len + 2)
        case (r_tail_keep_1d)
            8'b1111_1111    : ro_xgmii_txd <= {r_xgmii_txd_2d[63: 8],r_crc_result[31:24]};
            8'b1111_1110    : ro_xgmii_txd <= {r_xgmii_txd_2d[63:16],r_crc_result[31:16]};
            8'b1111_1100    : ro_xgmii_txd <= {r_xgmii_txd_2d[63:24],r_crc_result[31: 8]};
            8'b1111_1000    : ro_xgmii_txd <= {r_xgmii_txd_2d[63:32],r_crc_result[31: 0]};
            8'b1111_0000    : ro_xgmii_txd <= {r_xgmii_txd_2d[63:40],r_crc_result[31: 0],P_FRAME_END};
            8'b1110_0000    : ro_xgmii_txd <= {r_xgmii_txd_2d[63:48],r_crc_result[31: 0],P_FRAME_END,P_FRAME_IDLE};
            8'b1100_0000    : ro_xgmii_txd <= {r_xgmii_txd_2d[63:56],r_crc_result[31: 0],P_FRAME_END,P_FRAME_IDLE,P_FRAME_IDLE};
            8'b1000_0000    : ro_xgmii_txd <= {r_crc_result[31: 0],P_FRAME_END,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE};
            default         : ro_xgmii_txd <= {8{P_FRAME_IDLE}};
        endcase 
    else if(r_pkt_cnt_3d == r_pkt_64bit_len + 3 && r_tail_keep >= 8'b1111_1000)
        case (r_tail_keep_1d)      
            8'b1111_1111    : ro_xgmii_txd <= {r_crc_result[23:0],P_FRAME_END,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE};  
            8'b1111_1110    : ro_xgmii_txd <= {r_crc_result[15:0],P_FRAME_END,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE};  
            8'b1111_1100    : ro_xgmii_txd <= {r_crc_result[7 :0],P_FRAME_END,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE};  
            8'b1111_1000    : ro_xgmii_txd <= {P_FRAME_END,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE,P_FRAME_IDLE};
            default         : ro_xgmii_txd <= {8{P_FRAME_IDLE}};
        endcase      
    else
        ro_xgmii_txd <= r_xgmii_txd_2d;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_xgmii_txc    <= 8'b1111_1111;
        r_xgmii_txc_1d  <= 8'b1111_1111;
        r_xgmii_txc_2d  <= 8'b1111_1111;
    end
    else begin
        r_xgmii_txc_1d <= r_xgmii_txc;
        r_xgmii_txc_2d <= r_xgmii_txc_1d;        
        ro_xgmii_txc <= r_xgmii_txc_2d;
    end
end


//===============================================================//
//========================= 计算CRC =============================//
//===============================================================//

//先产生需要进行CRC计算的数据
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_data <= 'd0;
    else if(w_sof | r_pkt_cnt)
        case (r_pkt_cnt)
            0       : r_crc_data <= 'd0;
            1       : r_crc_data <= {w_dst_mac_addr,ri_dynamic_src_mac[47:32]};
            2       : r_crc_data <= {ri_dynamic_src_mac[31:0],r_data_type,w_fifo_data_dout[63:48]};
            default : r_crc_data <= {r_fifo_data_dout[47:0],w_fifo_data_dout[63:48]};
        endcase       
    else
        r_crc_data <= 'd0;
end

 
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_keep <= 8'b0000_0000;
    else if(r_pkt_cnt == r_pkt_64bit_len + 2 && r_tail_keep >= 8'b1110_0000)
        case (r_tail_keep)
            8'b1111_1111    : r_crc_keep <= 8'b1111_1100;
            8'b1111_1110    : r_crc_keep <= 8'b1111_1000;
            8'b1111_1100    : r_crc_keep <= 8'b1111_0000;
            8'b1111_1000    : r_crc_keep <= 8'b1110_0000;
            8'b1111_0000    : r_crc_keep <= 8'b1100_0000;
            8'b1110_0000    : r_crc_keep <= 8'b1000_0000;
            default         : r_crc_keep <= 8'b0000_0000;
        endcase
    else if(r_pkt_cnt == r_pkt_64bit_len + 1 && r_tail_keep < 8'b1110_0000)
        case (r_tail_keep)
            8'b1100_0000    : r_crc_keep <= 8'b1111_1111;
            8'b1000_0000    : r_crc_keep <= 8'b1111_1110;
            default         : r_crc_keep <= 8'b0000_0000;
        endcase        
    else
        r_crc_keep <= 8'b0000_0000;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_en <= 'd0;
    else if(r_crc_end)
        r_crc_en <= 'd0;
    else if(r_pkt_cnt == 1)
        r_crc_en <= 'd1;
    else
        r_crc_en <= r_crc_en;
end
  
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_end <= 'd0;
    else if(r_pkt_cnt > 2 && r_pkt_cnt == r_pkt_64bit_len + 2 && r_tail_keep >= 8'b1110_0000)
        r_crc_end <= 'd1;
    else if(r_pkt_cnt > 2 && r_pkt_cnt == r_pkt_64bit_len + 1 && r_tail_keep < 8'b1110_0000)
        r_crc_end <= 'd1;
    else
        r_crc_end <= 'd0;
end
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_crc_end_1d <= 'd0;
        r_crc_keep_1d <= 'd0;
    end
    else begin
        r_crc_end_1d <= r_crc_end;
        r_crc_keep_1d <= r_crc_keep;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_result <= 'd0;
    else if(r_crc_end_1d)
        case (r_crc_keep_1d)
            8'b1111_1111    : r_crc_result <= w_crc_8;
            8'b1111_1110    : r_crc_result <= w_crc_7;
            8'b1111_1100    : r_crc_result <= w_crc_6;
            8'b1111_1000    : r_crc_result <= w_crc_5;
            8'b1111_0000    : r_crc_result <= w_crc_4;
            8'b1110_0000    : r_crc_result <= w_crc_3;
            8'b1100_0000    : r_crc_result <= w_crc_2;
            8'b1000_0000    : r_crc_result <= w_crc_1;
            default         : r_crc_result <= r_crc_result;
        endcase
    else
        r_crc_result <= r_crc_result;
end


//流控，以太网帧间隔96byte，即12周期（这是针对XGMII接口数据，用户AXIS这边需要16）
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rs_axis_tready <= 'd1;
    else if(s_axis_tlast)
        rs_axis_tready <= 'd0;
    else if(r_ready_cnt == P_READY_CNT - 2)
        rs_axis_tready <= 'd1;
    else
        rs_axis_tready <= rs_axis_tready;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ready_cnt <= 'd0;
    else if(r_ready_cnt == P_READY_CNT - 2)
        r_ready_cnt <= 'd0;
    else if(rs_axis_tlast | r_ready_cnt)
        r_ready_cnt <= r_ready_cnt + 'd1;
    else
        r_ready_cnt <= r_ready_cnt;
end



endmodule
