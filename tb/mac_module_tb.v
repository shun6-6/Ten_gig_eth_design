`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/12 09:28:35
// Design Name: 
// Module Name: mac_module_tb
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


module mac_module_tb();

reg clk,rst;

always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end

initial begin
    rst = 1;
    #20;
    @(posedge clk) rst = 0;
end

wire [63 : 0]   w_xgmii_txd         ;
wire [7  : 0]   w_xgmii_txc         ;
reg  [63 : 0]   r_xgmii_rxd         ;
reg  [7  : 0]   r_xgmii_rxc         ;

wire [63:0]     m_axis_rdata        ;
wire [31:0]     m_axis_ruser        ;
wire [7 :0]     m_axis_rkeep        ;
wire            m_axis_rlast        ;
wire            m_axis_rvalid       ;
wire [63:0]     s_axis_tdata        ;
wire [31:0]     s_axis_tuser        ;
wire [7 :0]     s_axis_tkeep        ;
wire            s_axis_tlast        ;
wire            s_axis_tvalid       ;
wire            s_axis_tready       ;

TEN_GIG_MAC_module TEN_GIG_MAC_module_u0(
    .i_xgmii_clk            (clk                ),
    .i_xgmii_rst            (rst                ),
    .i_xgmii_rxd            (r_xgmii_rxd        ),
    .i_xgmii_rxc            (r_xgmii_rxc        ),
    .o_xgmii_txd            (w_xgmii_txd        ),
    .o_xgmii_txc            (w_xgmii_txc        ),
    .m_axis_rdata           (m_axis_rdata       ),
    .m_axis_ruser           (m_axis_ruser       ),
    .m_axis_rkeep           (m_axis_rkeep       ),
    .m_axis_rlast           (m_axis_rlast       ),
    .m_axis_rvalid          (m_axis_rvalid      ),
    .s_axis_tdata           (0),
    .s_axis_tuser           (0),
    .s_axis_tkeep           (0),
    .s_axis_tlast           (0),
    .s_axis_tvalid          (0),
    .s_axis_tready          ()
);

initial begin
    r_xgmii_rxd = 'd0;
    r_xgmii_rxc = 'd0; 
    wait(!rst);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0000_0001);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0000_0010);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0000_0100);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0000_1000);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0001_0000);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0010_0000);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0100_0000);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof7(8'b1000_0000);

    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0000_0001);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0000_0010);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0000_0100);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0000_1000);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0001_0000);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0010_0000);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0100_0000);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof4(8'b1000_0000);
end

task xgmii_rxd_send_sof7(input[7:0] eof_location);
begin : xgmii_txd_send7
    integer i;
    r_xgmii_rxd <= 'd0;
    r_xgmii_rxc <= 'd0;
    @(posedge clk);
    r_xgmii_rxd <= 64'hfb55_5555_5555_5555;
    r_xgmii_rxc <= 8'b1000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'hd5ff_ffff_ffff_ff01;
    r_xgmii_rxc <= 8'b0000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'h0203_0405_0608_00ff;//ff表示data第一个byte
    r_xgmii_rxc <= 8'b0000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'h0102_0304_0506_0708;
    r_xgmii_rxc <= 8'b0000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'h090a_0b0c_0d0e_0f10;
    r_xgmii_rxc <= 8'b0000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'hfdfd_fdfd_fdfd_fdfd;
    r_xgmii_rxc <= eof_location;
    @(posedge clk);
    r_xgmii_rxd <= 'd0;
    r_xgmii_rxc <= 'd0;
    @(posedge clk);
end
endtask

task xgmii_rxd_send_sof4(input[7:0] eof_location);
begin : xgmii_txd_send4
    integer i;
    r_xgmii_rxd <= 'd0;
    r_xgmii_rxc <= 'd0;
    @(posedge clk);
    r_xgmii_rxd <= 64'h0707_0707_fb55_5555;
    r_xgmii_rxc <= 8'b0000_1000;
    @(posedge clk);
    r_xgmii_rxd <= 64'h5555_5555_d5ff_ffff;
    r_xgmii_rxc <= 8'b0000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'hffff_ff01_0203_0405;
    r_xgmii_rxc <= 8'b0000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'h0608_00ff_0102_0304;//ff表示data第一个byte
    r_xgmii_rxc <= 8'b0000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'h0506_0708_090a_0b0c;
    r_xgmii_rxc <= 8'b0000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'h0d0e_0f10_1112_1314;
    r_xgmii_rxc <= 8'b0000_0000;
    @(posedge clk);
    r_xgmii_rxd <= 64'hfdfd_fdfd_fdfd_fdfd;
    r_xgmii_rxc <= eof_location;
    @(posedge clk);
    r_xgmii_rxd <= 'd0;
    r_xgmii_rxc <= 'd0;
    @(posedge clk);
end
endtask

endmodule
