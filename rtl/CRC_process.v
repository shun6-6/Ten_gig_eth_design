`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 15:52:25
// Design Name: 
// Module Name: CRC_process
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


module CRC_process(
    input           i_clk               ,
    input           i_rst               ,

    input  [63:0]   s_axis_rdata        ,
    input  [79:0]   s_axis_ruser        ,
    input  [7 :0]   s_axis_rkeep        ,
    input           s_axis_rlast        ,
    input           s_axis_rvalid       ,
    input           i_crc_error         ,
    input           i_crc_valid         ,
    
    output [63:0]   m_axis_rdata        ,
    output [79:0]   m_axis_ruser        ,
    output [7 :0]   m_axis_rkeep        ,
    output          m_axis_rlast        ,
    output          m_axis_rvalid       
);
/******************************function*****************************/

/******************************parameter****************************/

/******************************mechine******************************/

/******************************reg**********************************/
(* MARK_DEBUG = "TRUE" *)reg  [63:0]     rs_axis_rdata       ;
(* MARK_DEBUG = "TRUE" *)reg  [79:0]     rs_axis_ruser       ;
(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     rs_axis_rkeep       ;
(* MARK_DEBUG = "TRUE" *)reg             rs_axis_rlast       ;
(* MARK_DEBUG = "TRUE" *)reg             rs_axis_rvalid      ;
(* MARK_DEBUG = "TRUE" *)reg             ri_crc_error        ;
(* MARK_DEBUG = "TRUE" *)reg             ri_crc_valid        ;
reg             ri_crc_error_1d     ;
reg             ri_crc_valid_1d     ;
(* MARK_DEBUG = "TRUE" *)reg  [63:0]     rm_axis_rdata       ;
(* MARK_DEBUG = "TRUE" *)reg  [79:0]     rm_axis_ruser       ;
(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     rm_axis_rkeep       ;
(* MARK_DEBUG = "TRUE" *)reg             rm_axis_rlast       ;
(* MARK_DEBUG = "TRUE" *)reg             rm_axis_rvalid      ;

(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     r_ram_data_addra    ;
(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     r_ram_data_addrb    ;
(* MARK_DEBUG = "TRUE" *)reg             r_ram_data_enb      ;
reg             r_ram_data_enb_1d   ;
reg             r_ram_data_enb_2d   ;

(* MARK_DEBUG = "TRUE" *)reg  [4 :0]     r_ram_len_addra     ;
(* MARK_DEBUG = "TRUE" *)reg  [4 :0]     r_ram_len_addrb     ;
(* MARK_DEBUG = "TRUE" *)reg             r_ram_len_enb       ;
reg             r_ram_len_enb_1d    ;

(* MARK_DEBUG = "TRUE" *)reg  [4 :0]     r_ram_keep_addra    ;
(* MARK_DEBUG = "TRUE" *)reg  [4 :0]     r_ram_keep_addrb    ;
(* MARK_DEBUG = "TRUE" *)reg             r_ram_keep_enb      ;
reg             r_ram_keep_enb_1d   ;

(* MARK_DEBUG = "TRUE" *)reg  [4 :0]     r_ram_user_addra    ;
(* MARK_DEBUG = "TRUE" *)reg  [4 :0]     r_ram_user_addrb    ;
(* MARK_DEBUG = "TRUE" *)reg             r_ram_user_enb      ;
reg             r_ram_user_enb_1d   ;

(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     r_recv_flag         ;
(* MARK_DEBUG = "TRUE" *)reg  [7 :0]     r_send_flag         ;

reg  [7 :0]     r_data_start_addra  ;
reg  [4 :0]     r_len_start_addra   ;
reg  [4 :0]     r_keep_start_addra  ;
reg  [4 :0]     r_user_start_addra  ;
reg             r_run               ;
reg             r_run_1d            ;
reg  [15:0]     r_send_cnt          ;
reg  [15:0]     r_data_len          ;
reg  [7 :0]     r_tail_keep         ;
reg  [63:0]     r_user              ;

/******************************wire*********************************/
(* MARK_DEBUG = "TRUE" *)wire [63:0]     w_ram_data_doutb    ;
(* MARK_DEBUG = "TRUE" *)wire [15:0]     w_ram_len_doutb     ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]     w_ram_keep_doutb    ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]     w_ram_user_doutb    ;
/******************************component****************************/
BRAM_SD_64X256 BRAM_SD_64X256_data (
  .clka         (i_clk              ), // input wire clka
  .ena          (rs_axis_rvalid     ), // input wire ena
  .wea          (rs_axis_rvalid     ), // input wire [0 : 0] wea
  .addra        (r_ram_data_addra   ), // input wire [7 : 0] addra
  .dina         (rs_axis_rdata      ), // input wire [63 : 0] dina
  .clkb         (i_clk              ), // input wire clkb
  .enb          (r_ram_data_enb     ), // input wire enb
  .addrb        (r_ram_data_addrb   ), // input wire [7 : 0] addrb
  .doutb        (w_ram_data_doutb   )  // output wire [63 : 0] doutb
);
  
BRAM_SD_16X32 BRAM_SD_16X32_len (
  .clka         (i_clk              ), // input wire clka             
  .ena          (rs_axis_rlast      ), // input wire ena              
  .wea          (rs_axis_rlast      ), // input wire [0 : 0] wea      
  .addra        (r_ram_len_addra    ), // input wire [4 : 0] addra    
  .dina         (rs_axis_ruser[79:64]), // input wire [15 : 0] dina    
  .clkb         (i_clk              ), // input wire clkb             
  .enb          (r_ram_len_enb      ), // input wire enb              
  .addrb        (r_ram_len_addrb    ), // input wire [4 : 0] addrb    
  .doutb        (w_ram_len_doutb    )  // output wire [15 : 0] doutb  
);

BRAM_SD_8X32 BRAM_SD_8X32_keep (
  .clka         (i_clk              ),  // input wire clka            
  .ena          (rs_axis_rlast      ),  // input wire ena             
  .wea          (rs_axis_rlast      ),  // input wire [0 : 0] wea     
  .addra        (r_ram_keep_addra   ),  // input wire [4 : 0] addra   
  .dina         (rs_axis_rkeep      ),  // input wire [7 : 0] dina    
  .clkb         (i_clk              ),  // input wire clkb            
  .enb          (r_ram_keep_enb     ),  // input wire enb             
  .addrb        (r_ram_keep_addrb   ),  // input wire [4 : 0] addrb   
  .doutb        (w_ram_keep_doutb   )   // output wire [7 : 0] doutb  
);

BRAM_SD_64X32 BRAM_SD_64X32_user (
  .clka         (i_clk              ),  // input wire clka
  .ena          (rs_axis_rlast      ),  // input wire ena
  .wea          (rs_axis_rlast      ),  // input wire [0 : 0] wea
  .addra        (r_ram_user_addra   ),  // input wire [4 : 0] addra
  .dina         (rs_axis_ruser[63:0]),  // input wire [63 : 0] dina
  .clkb         (i_clk              ),  // input wire clkb
  .enb          (r_ram_user_enb     ),  // input wire enb
  .addrb        (r_ram_user_addrb   ),  // input wire [4 : 0] addrb
  .doutb        (w_ram_user_doutb   )   // output wire [63 : 0] doutb
);
/******************************assign*******************************/
assign m_axis_rdata     =   rm_axis_rdata   ;
assign m_axis_ruser     =   rm_axis_ruser   ;
assign m_axis_rkeep     =   rm_axis_rkeep   ;
assign m_axis_rlast     =   rm_axis_rlast   ;
assign m_axis_rvalid    =   rm_axis_rvalid  ;
/******************************always*******************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        rs_axis_rdata   <= 'd0;
        rs_axis_ruser   <= 'd0;
        rs_axis_rkeep   <= 'd0;
        rs_axis_rlast   <= 'd0;
        rs_axis_rvalid  <= 'd0;
        ri_crc_error    <= 'd0;
        ri_crc_valid    <= 'd0;  
        ri_crc_error_1d <= 'd0;
        ri_crc_valid_1d <= 'd0;  
    end
    else begin
        rs_axis_rdata   <= s_axis_rdata ;
        rs_axis_ruser   <= s_axis_ruser ;
        rs_axis_rkeep   <= s_axis_rkeep ;
        rs_axis_rlast   <= s_axis_rlast ;
        rs_axis_rvalid  <= s_axis_rvalid;
        ri_crc_error    <= i_crc_error  ;
        ri_crc_valid    <= i_crc_valid  ;  
        ri_crc_error_1d <= ri_crc_error;
        ri_crc_valid_1d <= ri_crc_valid;  
    end
end

//输入数据进如ram，起始地址由r_data_start_addra决定,len和keep同理
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_data_addra <= 'd0;
    else if(ri_crc_valid_1d && ri_crc_error_1d)
        r_ram_data_addra <= r_data_start_addra;//crc错误则回退到上次起始地址写入新数据
    else if(rs_axis_rvalid)
        r_ram_data_addra <= r_ram_data_addra + 1;
    else
        r_ram_data_addra <= r_ram_data_addra;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_len_addra <= 'd0;
    else if(ri_crc_valid_1d && ri_crc_error_1d)
        r_ram_len_addra <= r_len_start_addra;//crc错误则回退到上次起始地址写入新数据
    else if(rs_axis_rlast)
        r_ram_len_addra <= r_ram_len_addra + 1;
    else
        r_ram_len_addra <= r_ram_len_addra;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_keep_addra <= 'd0;
    else if(ri_crc_valid_1d && ri_crc_error_1d)
        r_ram_keep_addra <= r_keep_start_addra;//crc错误则回退到上次起始地址写入新数据
    else if(rs_axis_rlast)
        r_ram_keep_addra <= r_ram_keep_addra + 1;
    else
        r_ram_keep_addra <= r_ram_keep_addra;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_user_addra <= 'd0;
    else if(ri_crc_valid_1d && ri_crc_error_1d)
        r_ram_user_addra <= r_user_start_addra;//crc错误则回退到上次起始地址写入新数据
    else if(rs_axis_rlast)
        r_ram_user_addra <= r_ram_user_addra + 1;
    else
        r_ram_user_addra <= r_ram_user_addra;
end

// 当数据CRC正确，那么记录此时地址，作为下一帧数据的开始地址，否则保持不变，
// 下一帧数据进来后依旧从上上帧数据结束位置开始写入，即覆盖（丢掉了）CRC错误数据
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_data_start_addra <= 'd0;
        r_len_start_addra  <= 'd0;
        r_keep_start_addra <= 'd0;
        r_user_start_addra <= 'd0;
    end
    else if(ri_crc_valid && !ri_crc_error)begin
        r_data_start_addra <= r_ram_data_addra;
        r_len_start_addra  <= r_ram_len_addra ;
        r_keep_start_addra <= r_ram_keep_addra;
        r_user_start_addra <= r_ram_user_addra;
    end
    else begin
        r_data_start_addra <= r_data_start_addra;
        r_len_start_addra  <= r_len_start_addra ;
        r_keep_start_addra <= r_keep_start_addra;
        r_user_start_addra <= r_user_start_addra;
    end
end

//得到一次正确数据r_recv_flag加1，输出一次数据r_send_flag加1
//俩者不相等说明此时ram里存在数据，拉高r_run
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_flag <= 'd0;
    else if(ri_crc_valid && !ri_crc_error)
        r_recv_flag <= r_recv_flag + 'd1;
    else
        r_recv_flag <= r_recv_flag;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_send_flag <= 'd0;
    else if(rm_axis_rlast)
        r_send_flag <= r_send_flag + 'd1;
    else
        r_send_flag <= r_send_flag;
end

//r_run指示当前正在输出数据
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_run <= 'd0;
    else if(rm_axis_rlast)
        r_run <= 'd0;
    else if((r_recv_flag != r_send_flag) && !rm_axis_rvalid)
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

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_ram_data_enb_1d <= 'd0;
        r_ram_data_enb_2d <= 'd0;
        r_ram_len_enb_1d  <= 'd0;
        r_ram_keep_enb_1d <= 'd0;
        r_ram_user_enb_1d <= 'd0;
    end
    else begin
        r_ram_data_enb_1d <= r_ram_data_enb;
        r_ram_data_enb_2d <= r_ram_data_enb_1d;
        r_ram_len_enb_1d  <= r_ram_len_enb ;
        r_ram_keep_enb_1d <= r_ram_keep_enb;
        r_ram_user_enb_1d <= r_ram_user_enb;
    end
end

//================= 输出数据逻辑 ====================//
//取出数据长度信息
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_len_enb <= 'd0;
    else if(r_run && !r_run_1d)
        r_ram_len_enb <= 'd1;
    else
        r_ram_len_enb <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_data_len <= 'd0;
    else if(rm_axis_rlast)
        r_data_len <= 'd0;
    else if(r_ram_len_enb_1d)
        r_data_len <= w_ram_len_doutb;
    else
        r_data_len <= r_data_len;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_len_addrb <= 'd0;
    else if(r_ram_len_enb)
        r_ram_len_addrb <= r_ram_len_addrb + 'd1;
    else
        r_ram_len_addrb <= r_ram_len_addrb;
end

//取出尾端keep信息
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_keep_enb <= 'd0;
    else if(r_run && !r_run_1d)
        r_ram_keep_enb <= 'd1;
    else
        r_ram_keep_enb <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_tail_keep <= 'd0;
    else if(r_ram_keep_enb_1d)
        r_tail_keep <= w_ram_keep_doutb;
    else
        r_tail_keep <= r_tail_keep; 
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_keep_addrb <= 'd0;
    else if(r_ram_keep_enb)
        r_ram_keep_addrb <= r_ram_keep_addrb + 'd1;
    else
        r_ram_keep_addrb <= r_ram_keep_addrb;
end

//取出user用户自定义信息
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_user_enb <= 'd0;
    else if(r_run && !r_run_1d)
        r_ram_user_enb <= 'd1;
    else
        r_ram_user_enb <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_user <= 'd0;
    else if(r_ram_user_enb_1d)
        r_user <= w_ram_user_doutb;
    else
        r_user <= r_user; 
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_user_addrb <= 'd0;
    else if(r_ram_user_enb)
        r_ram_user_addrb <= r_ram_user_addrb + 'd1;
    else
        r_ram_user_addrb <= r_ram_user_addrb;
end

//取出data
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_data_enb <= 'd0;
    else if(r_send_cnt == r_data_len - 1)
        r_ram_data_enb <= 'd0;
    else if(r_ram_len_enb_1d)
        r_ram_data_enb <= 'd1;
    else
        r_ram_data_enb <= r_ram_data_enb;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_send_cnt <= 'd0;
    else if(r_ram_data_enb && !r_ram_data_enb_1d)
        r_send_cnt <= r_send_cnt + 'd1;
    else if(r_send_cnt == r_data_len)
        r_send_cnt <= 'd0;
    else if(r_ram_data_enb)
        r_send_cnt <= r_send_cnt + 'd1;
    else
        r_send_cnt <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_data_addrb <= 'd0;
    else if(r_ram_data_enb)
        r_ram_data_addrb <= r_ram_data_addrb + 'd1;
    else
        r_ram_data_addrb <= r_ram_data_addrb;
end

//输出AXIS流
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rdata <= 'd0;
    else if(r_ram_data_enb_1d)
        rm_axis_rdata <= w_ram_data_doutb;
    else
        rm_axis_rdata <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rvalid <= 'd0;
    else if(rm_axis_rlast)
        rm_axis_rvalid <= 'd0;
    else if(r_ram_data_enb_1d && !r_ram_data_enb_2d)
        rm_axis_rvalid <= 'd1;
    else
        rm_axis_rvalid <= rm_axis_rvalid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rkeep <= 'd0;
    else if(r_send_cnt == r_data_len && rm_axis_rvalid)
        rm_axis_rkeep <= r_tail_keep;
    else
        rm_axis_rkeep <= 8'hff;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_rlast <= 'd0;
    else if(r_send_cnt == r_data_len && rm_axis_rvalid)
        rm_axis_rlast <= 'd1;
    else
        rm_axis_rlast <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        rm_axis_ruser <= 'd0;
    else if(r_ram_data_enb_1d && !r_ram_data_enb_2d)
        rm_axis_ruser <= {w_ram_len_doutb,w_ram_user_doutb};
    else
        rm_axis_ruser <= rm_axis_ruser;
end
 
endmodule
