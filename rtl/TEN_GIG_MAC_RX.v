`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 15:52:25
// Design Name: 
// Module Name: 10G_MAC_RX
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


module TEN_GIG_MAC_RX(
    input           i_clk               ,
    input           i_rst               ,
    input  [63:0]   i_xgmii_rxd         ,
    input  [7 :0]   i_xgmii_rxc         ,
    
    output [63:0]   m_axis_rdata        ,
    output [79:0]   m_axis_ruser        ,//用户自定义{16'dlen,r_src_mac[47:0],16'dr_type}
    output [7 :0]   m_axis_rkeep        ,
    output          m_axis_rlast        ,
    output          m_axis_rvalid       ,

    output          o_crc_error         ,
    output          o_crc_valid         
);
/******************************function*****************************/

/******************************parameter****************************/
localparam      P_FRAME_IDLE    = 8'h07 ,
                P_FRAME_START   = 8'hFB ,
                P_FRAME_END     = 8'hFD ,
                P_FRAME_EEROR   = 8'hFE ;
/******************************mechine******************************/

/******************************reg**********************************/
reg  [63:0]     ri_xgmii_rxd        ;
reg  [7 :0]     ri_xgmii_rxc        ;
reg  [63:0]     ri_xgmii_rxd_1d     ;
reg  [7 :0]     ri_xgmii_rxc_1d     ;
reg  [63:0]     ri_xgmii_rxd_2d     ;
reg  [7 :0]     ri_xgmii_rxc_2d     ;

reg  [63:0]     rm_axis_rdata       ;
reg  [63:0]     rm_axis_rdata_1d    ;
reg  [79:0]     rm_axis_ruser       ;
reg  [7 :0]     rm_axis_rkeep       ;
reg  [7 :0]     rm_axis_rkeep_1d    ;
reg             rm_axis_rlast       ;
reg             rm_axis_rlast_1d    ;
reg             rm_axis_rvalid      ;
reg  [15:0]     r_data_len          ;
//解析接收数据
reg  [15:0]     r_recv_cnt          ;
reg             r_comma             ;
reg  [47:0]     r_dst_mac           ;
reg  [47:0]     r_src_mac           ;
reg  [15:0]     r_type              ;
reg             r_data_run          ;//开始产生axis输出数据
reg             r_data_run_1d       ;
reg             r_data_run_2d       ;
reg             r_data_run_3d       ;

reg             r_sof               ;
reg             r_eof               ;
reg  [2 :0]     r_sof_location      ;
reg  [2 :0]     r_eof_location      ;
//CRC处理
reg             r_crc_run           ;//校验数据的产生，与rm_axis_rdata不同，从目的MAC开始的字段就需要进行CRC校验
reg             r_crc_run_1d        ;
reg             r_crc_run_2d        ;
reg  [63:0]     r_crc_data          ;
reg  [7 :0]     r_crc_keep          ;
reg  [7 :0]     r_crc_keep_1d       ;
reg             r_crc_end           ;
reg             r_crc_en            ;
reg             r_crc_en_1d         ;
reg  [31:0]     r_crc_result        ;
reg             ro_crc_valid        ;

reg  [31:0]     r_crc_recv          ;
reg             ro_crc_error        ;
reg             r_crc_check         ;
/******************************wire*********************************/
wire            w_sof               ;
wire            w_eof               ;
wire [2 :0]     w_sof_location      ;
wire [2 :0]     w_eof_location      ;

wire [31:0]     w_crc_8             ;
wire [31:0]     w_crc_1             ;
wire [31:0]     w_crc_2             ;
wire [31:0]     w_crc_3             ;
wire [31:0]     w_crc_4             ;
wire [31:0]     w_crc_5             ;
wire [31:0]     w_crc_6             ;
wire [31:0]     w_crc_7             ;
/******************************component****************************/
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
  .o_crc_8      (w_crc_8            ),
  .o_crc_1      (w_crc_1            ),
  .o_crc_2      (w_crc_2            ),
  .o_crc_3      (w_crc_3            ),
  .o_crc_4      (w_crc_4            ),
  .o_crc_5      (w_crc_5            ),
  .o_crc_6      (w_crc_6            ),
  .o_crc_7      (w_crc_7            ) 
);
/******************************assign*******************************/
assign m_axis_rdata  = rm_axis_rdata_1d ;
assign m_axis_ruser  = rm_axis_ruser    ;
assign m_axis_rkeep  = rm_axis_rkeep_1d ;
assign m_axis_rlast  = rm_axis_rlast_1d ;
assign m_axis_rvalid = rm_axis_rvalid   ;

assign o_crc_valid   = ro_crc_valid     ;
assign o_crc_error   = ro_crc_error     ;
//进入该模块的数据已经全部被转换为大端模式
//开始字符以及位置判断
assign w_sof =  ((ri_xgmii_rxd[63:56] == P_FRAME_START) && (ri_xgmii_rxc[7] == 1)) || 
                ((ri_xgmii_rxd[31:24] == P_FRAME_START) && (ri_xgmii_rxc[3] == 1));
assign w_sof_location = ((ri_xgmii_rxd[63:56] == P_FRAME_START) && (ri_xgmii_rxc[7] == 1)) ? 7 : 
                        ((ri_xgmii_rxd[31:24] == P_FRAME_START) && (ri_xgmii_rxc[3] == 1)) ? 3 :0;
//结束字符以及位置判断
assign w_eof =  ((ri_xgmii_rxd[63:56] == P_FRAME_END) && (ri_xgmii_rxc[7] == 1)) || 
                ((ri_xgmii_rxd[55:48] == P_FRAME_END) && (ri_xgmii_rxc[6] == 1)) ||
                ((ri_xgmii_rxd[47:40] == P_FRAME_END) && (ri_xgmii_rxc[5] == 1)) ||
                ((ri_xgmii_rxd[39:32] == P_FRAME_END) && (ri_xgmii_rxc[4] == 1)) ||
                ((ri_xgmii_rxd[31:24] == P_FRAME_END) && (ri_xgmii_rxc[3] == 1)) ||
                ((ri_xgmii_rxd[23:16] == P_FRAME_END) && (ri_xgmii_rxc[2] == 1)) ||
                ((ri_xgmii_rxd[15: 8] == P_FRAME_END) && (ri_xgmii_rxc[1] == 1)) ||
                ((ri_xgmii_rxd[7 : 0] == P_FRAME_END) && (ri_xgmii_rxc[0] == 1));

assign w_eof_location = ((ri_xgmii_rxd[63:56] == P_FRAME_END) && (ri_xgmii_rxc[7] == 1)) ? 7 : 
                        ((ri_xgmii_rxd[55:48] == P_FRAME_END) && (ri_xgmii_rxc[6] == 1)) ? 6 :
                        ((ri_xgmii_rxd[47:40] == P_FRAME_END) && (ri_xgmii_rxc[5] == 1)) ? 5 :
                        ((ri_xgmii_rxd[39:32] == P_FRAME_END) && (ri_xgmii_rxc[4] == 1)) ? 4 :
                        ((ri_xgmii_rxd[31:24] == P_FRAME_END) && (ri_xgmii_rxc[3] == 1)) ? 3 :
                        ((ri_xgmii_rxd[23:16] == P_FRAME_END) && (ri_xgmii_rxc[2] == 1)) ? 2 :
                        ((ri_xgmii_rxd[15: 8] == P_FRAME_END) && (ri_xgmii_rxc[1] == 1)) ? 1 :
                        ((ri_xgmii_rxd[7 : 0] == P_FRAME_END) && (ri_xgmii_rxc[0] == 1)) ? 0 : 0;
/******************************always*******************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_xgmii_rxd    <= 'd0;
        ri_xgmii_rxc    <= 'd0;
        ri_xgmii_rxd_1d <= 'd0;
        ri_xgmii_rxc_1d <= 'd0;
        ri_xgmii_rxd_2d <= 'd0;
        ri_xgmii_rxc_2d <= 'd0;
    end
    else begin
        ri_xgmii_rxd    <= i_xgmii_rxd      ;
        ri_xgmii_rxc    <= i_xgmii_rxc      ;
        ri_xgmii_rxd_1d <= ri_xgmii_rxd     ;
        ri_xgmii_rxc_1d <= ri_xgmii_rxc     ;
        ri_xgmii_rxd_2d <= ri_xgmii_rxd_1d;
        ri_xgmii_rxc_2d <= ri_xgmii_rxc_1d;
    end
end

//======================= 关键字段信息提取过程 =============================//

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst || rm_axis_rlast)begin
        r_sof           <= 'd0;
        r_sof_location  <= 'd0;
    end
    else if(w_sof)begin
        r_sof           <= w_sof            ;
        r_sof_location  <= w_sof_location   ;
    end
    else begin
        r_sof           <= 'd0            ;
        r_sof_location  <= r_sof_location   ;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst || rm_axis_rlast)begin
        r_eof           <= 'd0;
        r_eof_location  <= 'd0;
    end
    else if(w_eof)begin
        r_eof           <= w_eof            ;
        r_eof_location  <= w_eof_location   ;
    end
    else begin
        r_eof           <= 'd0            ;
        r_eof_location  <= r_eof_location   ;    
    end
end 

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_comma <= 'd0;
    else if(r_eof)
        r_comma <= 'd0;
    else if((r_sof_location == 7) && (ri_xgmii_rxd_1d[55:0] == 56'h55_5555_5555_5555) && (ri_xgmii_rxd[63:56] == 8'hd5))
        r_comma <= 'd1;
    else if((r_sof_location == 3) && (ri_xgmii_rxd_1d[23:0] == 24'h55_5555) && (ri_xgmii_rxd[63:24] == 40'h55_5555_55d5))
        r_comma <= 'd1;
    else
        r_comma <= r_comma;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_cnt <= 'd0;
    else if(r_eof)
        r_recv_cnt <= 'd0;
    else if(r_sof | r_recv_cnt)
        r_recv_cnt <= r_recv_cnt + 'd1;
    else
        r_recv_cnt <= r_recv_cnt;
end
   
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_dst_mac <= 'd0;
    else if(r_sof_location == 7 && r_recv_cnt == 1)
        r_dst_mac <= ri_xgmii_rxd_1d[55:8];
    else if(r_sof_location == 3 && r_recv_cnt == 1)
        r_dst_mac <= {ri_xgmii_rxd_1d[23:0],ri_xgmii_rxd[63:40]};
    else
        r_dst_mac <= r_dst_mac;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_src_mac <= 'd0;
    else if(r_sof_location == 7 && r_recv_cnt == 1)
        r_src_mac <= {ri_xgmii_rxd_1d[7:0],ri_xgmii_rxd[63:24]};
    else if(r_sof_location == 3 && r_recv_cnt == 2)
        r_src_mac <= {ri_xgmii_rxd_1d[39:0],ri_xgmii_rxd[63:56]};
    else
        r_src_mac <= r_src_mac;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_type <= 'd0;
    else if(r_sof_location == 7 && r_recv_cnt == 2)
        r_type <= ri_xgmii_rxd_1d[23:8];
    else if(r_sof_location == 3 && r_recv_cnt == 3)
        r_type <= ri_xgmii_rxd_1d[55:40];
    else
        r_type <= r_type;
end


//======================= CRC提取以及计算对比过程 =============================//

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_run <= 'd0;
    else if(rm_axis_rlast)
        r_crc_run <= 'd0;
    else if(r_sof_location == 7 || r_sof_location == 3)
        r_crc_run <= 'd1;
    else
        r_crc_run <= r_crc_run;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_crc_run_1d <= 'd0;
        r_crc_run_2d <= 'd0;
    end
    else begin
        r_crc_run_1d <= r_crc_run   ;
        r_crc_run_2d <= r_crc_run_1d;
    end
end
//处理CRC在r_sof_location == 3处需要延后一拍才能处理尾端KEEP，这是因为它左移字节数会超过8，来到上一个时钟周期
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_data <= 'd0;
    else if(r_sof_location == 7 && r_crc_run)
        r_crc_data <= {ri_xgmii_rxd_1d[55:0],ri_xgmii_rxd[63:56]};
    else if(r_sof_location == 3 && r_crc_run_1d)
        r_crc_data <= {ri_xgmii_rxd_2d[23:0],ri_xgmii_rxd_1d[63:24]};
    else
        r_crc_data <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_keep <= 8'b1111_1111;
    else if(r_sof_location == 7 && w_eof && w_eof_location >= 2)
        case (w_eof_location)
            7       : r_crc_keep <= 8'b1110_0000;
            6       : r_crc_keep <= 8'b1111_0000;
            5       : r_crc_keep <= 8'b1111_1000;
            4       : r_crc_keep <= 8'b1111_1100;
            3       : r_crc_keep <= 8'b1111_1110;
            2       : r_crc_keep <= 8'b1111_1111;
            default : r_crc_keep <= 8'b1111_1111;
        endcase
    else if(r_sof_location == 7 && r_eof && r_eof_location < 2)
        case (r_eof_location)
            1       : r_crc_keep <= 8'b1000_0000;
            0       : r_crc_keep <= 8'b1100_0000;
            default : r_crc_keep <= 8'b1111_1111;
    endcase
    else if(r_sof_location == 3 && w_eof && w_eof_location >= 6)
        case (w_eof_location)
            7       : r_crc_keep <= 8'b1111_1110;//提前一个周期
            6       : r_crc_keep <= 8'b1111_1111;//提前一个周期
            default : r_crc_keep <= 8'b1111_1111;
        endcase
    else if(r_sof_location == 3 && r_eof && r_eof_location < 6)
        case (r_eof_location)
            5       : r_crc_keep <= 8'b1000_0000;
            4       : r_crc_keep <= 8'b1100_0000;
            3       : r_crc_keep <= 8'b1110_0000;
            2       : r_crc_keep <= 8'b1111_0000;
            1       : r_crc_keep <= 8'b1111_1000;
            0       : r_crc_keep <= 8'b1111_1100;
            default : r_crc_keep <= 8'b1111_1111;
        endcase
    else
        r_crc_keep <= 8'b1111_1111;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_end <= 'd0;
    else if(r_sof_location == 7 && w_eof && w_eof_location >= 2)
        r_crc_end <= 'd1;
    else if(r_sof_location == 7 && r_eof && r_eof_location < 2)
        r_crc_end <= 'd1;
    else if(r_sof_location == 3 && w_eof && w_eof_location >= 6)
        r_crc_end <= 'd1;
    else if(r_sof_location == 3 && r_eof && r_eof_location < 6)
        r_crc_end <= 'd1;
    else
        r_crc_end <= 'd0;
end


always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_recv <= 'd0;
    else if(ro_crc_valid)
        r_crc_recv <= 'd0;
    else if(r_eof)
        case (r_eof_location)
            7       : r_crc_recv <= ri_xgmii_rxd_2d[31:0];
            6       : r_crc_recv <= {ri_xgmii_rxd_2d[23:0],ri_xgmii_rxd_1d[63:56]};
            5       : r_crc_recv <= {ri_xgmii_rxd_2d[15:0],ri_xgmii_rxd_1d[63:48]};
            4       : r_crc_recv <= {ri_xgmii_rxd_2d[7 :0],ri_xgmii_rxd_1d[63:40]};
            3       : r_crc_recv <= {ri_xgmii_rxd_1d[63:32]};
            2       : r_crc_recv <= {ri_xgmii_rxd_1d[55:24]};
            1       : r_crc_recv <= {ri_xgmii_rxd_1d[47:16]};
            0       : r_crc_recv <= {ri_xgmii_rxd_1d[39: 8]};
            default : r_crc_recv <= r_crc_recv;
        endcase
    else
        r_crc_recv <= r_crc_recv;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_en <= 'd0;
    else if(r_crc_end)
        r_crc_en <= 'd0;
    else if(r_sof_location == 7 && r_crc_run && !r_crc_run_1d)
        r_crc_en <= 'd1;
    else if(r_sof_location == 3 && r_crc_run_1d && !r_crc_run_2d)
        r_crc_en <= 'd1;
    else
        r_crc_en <= r_crc_en;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_en_1d <= 'd0;
    else
        r_crc_en_1d <= r_crc_en;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_keep_1d <= 'd0;
    else
        r_crc_keep_1d <= r_crc_keep;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_result <= 'd0;
    else if(!r_crc_en && r_crc_en_1d)
        case (r_crc_keep_1d)
            8'b1000_0000    : r_crc_result <= w_crc_1;
            8'b1100_0000    : r_crc_result <= w_crc_2;
            8'b1110_0000    : r_crc_result <= w_crc_3;
            8'b1111_0000    : r_crc_result <= w_crc_4;
            8'b1111_1000    : r_crc_result <= w_crc_5; 
            8'b1111_1100    : r_crc_result <= w_crc_6; 
            8'b1111_1110    : r_crc_result <= w_crc_7; 
            8'b1111_1111    : r_crc_result <= w_crc_8; 
            default         : r_crc_result <= 'd0; 
        endcase
    else
        r_crc_result <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_crc_check <= 'd0;
    else if(!r_crc_en && r_crc_en_1d)
        r_crc_check <= 'd1;
    else
        r_crc_check <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_crc_error <= 'd0;
    else if(r_crc_check)
        ro_crc_error <= (r_crc_result == r_crc_recv) ? 'd0 : 'd1;
    else
        ro_crc_error <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_crc_valid <= 'd0;
    else if(r_crc_check)
        ro_crc_valid <= 'd1;
    else
        ro_crc_valid <= 'd0;
end

//======================= AXIS数据转化过程 =============================//

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_data_run <= 'd0;
    else if(rm_axis_rlast)
        r_data_run <= 'd0;
    else if(r_sof_location == 7 && r_recv_cnt == 1)
        r_data_run <= 'd1;
    else if(r_sof_location == 3 && r_recv_cnt == 2)
        r_data_run <= 'd1;
    else
        r_data_run <= r_data_run;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_data_run_1d <= 'd0;
        r_data_run_2d <= 'd0;
        r_data_run_3d <= 'd0;
    end
    else begin
        r_data_run_1d <= r_data_run;
        r_data_run_2d <= r_data_run_1d;
        r_data_run_3d <= r_data_run_2d;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rkeep <= 8'b1111_1111;
    else if(r_sof_location == 7 && w_eof && w_eof_location >= 4)
        case (w_eof_location)
            7       : rm_axis_rkeep <= 8'b1111_1000;//提前一个周期
            6       : rm_axis_rkeep <= 8'b1111_1100;//提前一个周期
            5       : rm_axis_rkeep <= 8'b1111_1110;//提前一个周期
            4       : rm_axis_rkeep <= 8'b1111_1111;//提前一个周期
            default : rm_axis_rkeep <= 8'b1111_1111;
        endcase
    else if(r_sof_location == 7 && r_eof && r_eof_location < 4)
        case (r_eof_location)
            3       : rm_axis_rkeep <= 8'b1000_0000;
            2       : rm_axis_rkeep <= 8'b1100_0000;
            1       : rm_axis_rkeep <= 8'b1110_0000;
            0       : rm_axis_rkeep <= 8'b1111_0000;
            default : rm_axis_rkeep <= 8'b1111_1111;
    endcase
    else if(r_sof_location == 3 && r_eof)
        case (r_eof_location)
            7       : rm_axis_rkeep <= 8'b1000_0000;
            6       : rm_axis_rkeep <= 8'b1100_0000;
            5       : rm_axis_rkeep <= 8'b1110_0000;
            4       : rm_axis_rkeep <= 8'b1111_0000;
            3       : rm_axis_rkeep <= 8'b1111_1000;
            2       : rm_axis_rkeep <= 8'b1111_1100;
            1       : rm_axis_rkeep <= 8'b1111_1110;
            0       : rm_axis_rkeep <= 8'b1111_1111;
            default : rm_axis_rkeep <= 8'b1111_1111;
        endcase
    else
        rm_axis_rkeep <= 8'b1111_1111;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rdata <= 'd0;
    else if(r_sof_location == 7 && r_data_run_1d)
        rm_axis_rdata <= {ri_xgmii_rxd_2d[7:0],ri_xgmii_rxd_1d[63:8]};
    else if(r_sof_location == 3 && r_data_run_1d)
        rm_axis_rdata <= {ri_xgmii_rxd_2d[39:0],ri_xgmii_rxd_1d[63:40]};
    else
        rm_axis_rdata <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rlast <= 'd0;
    else if(r_sof_location == 7 && w_eof && w_eof_location >= 4)
        rm_axis_rlast <= 'd1;
    else if(r_sof_location == 7 && r_eof && r_eof_location < 4)
        rm_axis_rlast <= 'd1;
    else if(r_sof_location == 3 && r_eof)
        rm_axis_rlast <= 'd1;
    else
        rm_axis_rlast <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rlast_1d <= 'd0;
    else
        rm_axis_rlast_1d <= rm_axis_rlast; 
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rvalid <= 'd0;
    else if(rm_axis_rlast_1d)
        rm_axis_rvalid <= 'd0; 
    else if(r_data_run_2d && !r_data_run_3d)
        rm_axis_rvalid <= 'd1; 
    else
        rm_axis_rvalid <= rm_axis_rvalid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rdata_1d <= 'd0;
    else
        rm_axis_rdata_1d <= rm_axis_rdata;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rkeep_1d <= 'd0;
    else
        rm_axis_rkeep_1d <= rm_axis_rkeep;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_ruser <= 'd0;
    else
        rm_axis_ruser <= {r_data_len + 16'd1,r_src_mac,r_type};
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_data_len <= 'd0;
    else if(rm_axis_rlast_1d)
        r_data_len <= 'd0;
    else if((r_data_run_2d && !r_data_run_3d) || r_data_len)
        r_data_len <= r_data_len + 1;
    else
        r_data_len <= r_data_len;
end

endmodule
