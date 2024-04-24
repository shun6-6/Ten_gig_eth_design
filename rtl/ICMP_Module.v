`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 10:45:36
// Design Name: 
// Module Name: ICMP_Module
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


module ICMP_Module(
    input           i_clk               ,
    input           i_rst               ,

    input  [63:0]   s_axis_ip_data      ,
    input  [55:0]   s_axis_ip_user      ,//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    input  [7 :0]   s_axis_ip_keep      ,
    input           s_axis_ip_last      ,
    input           s_axis_ip_valid     ,

    output [63:0]   m_axis_ip_data      ,
    output [55:0]   m_axis_ip_user      ,//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    output [7 :0]   m_axis_ip_keep      ,
    output          m_axis_ip_last      ,
    output          m_axis_ip_valid     ,
    input           m_axis_ip_ready     
);

wire [15:0]         w_Identifier        ;
wire [15:0]         w_Sequence          ;
wire                w_trigger           ;

ICMP_TX ICMP_TX_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),

    .m_axis_ip_data         (m_axis_ip_data     ),
    .m_axis_ip_user         (m_axis_ip_user     ),//1'bMF,16'dlen,1'bsplit,8'dtype,13'doffset,16'dID
    .m_axis_ip_keep         (m_axis_ip_keep     ),
    .m_axis_ip_last         (m_axis_ip_last     ),
    .m_axis_ip_valid        (m_axis_ip_valid    ),
    .m_axis_ip_ready        (m_axis_ip_ready    ),

    .i_Identifier           (w_Identifier       ),
    .i_Sequence             (w_Sequence         ),
    .i_trigger              (w_trigger          )
);

ICMP_RX ICMP_RX_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),
    
    .s_axis_ip_data         (s_axis_ip_data     ),
    .s_axis_ip_user         (s_axis_ip_user     ),//1'bMF,16'dlen,1'bsplit,8'dtype,13'doffset,16'dID
    .s_axis_ip_keep         (s_axis_ip_keep     ),
    .s_axis_ip_last         (s_axis_ip_last     ),
    .s_axis_ip_valid        (s_axis_ip_valid    ),
    
    .o_Identifier           (w_Identifier       ),
    .o_Sequence             (w_Sequence         ),
    .o_trigger              (w_trigger          )
);
endmodule
