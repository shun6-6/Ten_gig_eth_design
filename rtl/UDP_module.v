`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/25 14:02:39
// Design Name: 
// Module Name: UDP_module
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


module UDP_module#(
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

    input  [63:0]   s_axis_ip_data      ,
    input  [55:0]   s_axis_ip_user      ,
    input  [7 :0]   s_axis_ip_keep      ,
    input           s_axis_ip_last      ,
    input           s_axis_ip_valid     ,

    /****user data****/
    output [63:0]   m_axis_user_data    ,
    output [31:0]   m_axis_user_user    ,
    output [7 :0]   m_axis_user_keep    ,
    output          m_axis_user_last    ,
    output          m_axis_user_valid   ,

    input  [63:0]   s_axis_user_data    ,
    input  [31:0]   s_axis_user_user    ,
    input  [7 :0]   s_axis_user_keep    ,
    input           s_axis_user_last    ,
    input           s_axis_user_valid   ,
    output          s_axis_user_ready   
);

UDP_TX#(
    .P_SRC_UDP_PORT         (P_SRC_UDP_PORT),
    .P_DST_UDP_PORT         (P_DST_UDP_PORT)
)UDP_TX_u0(
    .i_clk                  (i_clk                  ),
    .i_rst                  (i_rst                  ),
    .i_dymanic_src_port     (i_dymanic_src_port     ),
    .i_dymanic_src_valid    (i_dymanic_src_valid    ),
    .i_dymanic_dst_port     (i_dymanic_dst_port     ),
    .i_dymanic_dst_valid    (i_dymanic_dst_valid    ),
    .m_axis_ip_data         (m_axis_ip_data         ),
    .m_axis_ip_user         (m_axis_ip_user         ),
    .m_axis_ip_keep         (m_axis_ip_keep         ),
    .m_axis_ip_last         (m_axis_ip_last         ),
    .m_axis_ip_valid        (m_axis_ip_valid        ),
    .m_axis_ip_ready        (m_axis_ip_ready        ),
    .s_axis_user_data       (s_axis_user_data       ),
    .s_axis_user_user       (s_axis_user_user       ),
    .s_axis_user_keep       (s_axis_user_keep       ),
    .s_axis_user_last       (s_axis_user_last       ),
    .s_axis_user_valid      (s_axis_user_valid      ),
    .s_axis_user_ready      (s_axis_user_ready      ) 
);

UDP_RX#(
    .P_SRC_UDP_PORT         (P_SRC_UDP_PORT),
    .P_DST_UDP_PORT         (P_DST_UDP_PORT)
)UDP_RX_u0(
    .i_clk                  (i_clk                  ),
    .i_rst                  (i_rst                  ),
    .i_dymanic_src_port     (i_dymanic_src_port     ),
    .i_dymanic_src_valid    (i_dymanic_src_valid    ),
    .s_axis_ip_data         (s_axis_ip_data         ),
    .s_axis_ip_user         (s_axis_ip_user         ),
    .s_axis_ip_keep         (s_axis_ip_keep         ),
    .s_axis_ip_last         (s_axis_ip_last         ),
    .s_axis_ip_valid        (s_axis_ip_valid        ),
    .m_axis_user_data       (m_axis_user_data       ),
    .m_axis_user_user       (m_axis_user_user       ),
    .m_axis_user_keep       (m_axis_user_keep       ),
    .m_axis_user_last       (m_axis_user_last       ),
    .m_axis_user_valid      (m_axis_user_valid      ) 
);

endmodule
