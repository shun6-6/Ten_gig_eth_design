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
wire [79:0]     m_axis_ruser        ;
wire [7 :0]     m_axis_rkeep        ;
wire            m_axis_rlast        ;
wire            m_axis_rvalid       ;
wire            w_crc_error         ;
wire            w_crc_valid         ;
wire [63:0]     s_axis_tdata        ;
wire [79:0]     s_axis_tuser        ;
wire [7 :0]     s_axis_tkeep        ;
wire            s_axis_tlast        ;
wire            s_axis_tvalid       ;
wire            s_axis_tready       ;

wire [63:0]     m_crc_axis_rdata    ;
wire [79:0]     m_crc_axis_ruser    ;
wire [7 :0]     m_crc_axis_rkeep    ;
wire            m_crc_axis_rlast    ;
wire            m_crc_axis_rvalid   ;

reg             r_crc_error         ;
reg             r_crc_valid         ;

reg  [63:0]     rs_axis_tdata       ;
reg  [79:0]     rs_axis_tuser       ;
reg  [7 :0]     rs_axis_tkeep       ;
reg             rs_axis_tlast       ;
reg             rs_axis_tvalid      ;

// TEN_GIG_MAC_module #(
//     .P_SRC_MAC              (48'h01_02_03_04_05_06),
//     .P_DST_MAC              (48'h01_02_03_04_05_06)
// )TEN_GIG_MAC_module_u0(
//     .i_xgmii_clk            (clk        ),
//     .i_xgmii_rst            (rst        ),
//     .i_xgmii_rxd            (r_xgmii_rxd        ),
//     .i_xgmii_rxc            (r_xgmii_rxc        ),
//     .o_xgmii_txd            (w_xgmii_txd        ),
//     .o_xgmii_txc            (w_xgmii_txc        ),
    
//     .i_dynamic_src_mac      (0),
//     .i_dynamic_src_valid    (0),
//     .i_dynamic_dst_mac      (0),
//     .i_dynamic_dst_valid    (0),

//     .m_axis_rdata           (m_axis_rdata       ),
//     .m_axis_ruser           (m_axis_ruser       ),
//     .m_axis_rkeep           (m_axis_rkeep       ),
//     .m_axis_rlast           (m_axis_rlast       ),
//     .m_axis_rvalid          (m_axis_rvalid      ),
//     .o_crc_error            (w_crc_error        ),
//     .o_crc_valid            (w_crc_valid        ),
//     .s_axis_tdata           (s_axis_tdata       ),
//     .s_axis_tuser           (s_axis_tuser       ),
//     .s_axis_tkeep           (s_axis_tkeep       ),
//     .s_axis_tlast           (s_axis_tlast       ),
//     .s_axis_tvalid          (s_axis_tvalid      ),
//     .s_axis_tready          ()
// );


TEN_GIG_MAC_TX#(
    .P_SRC_MAC              (48'h01_02_03_04_05_06),
    .P_DST_MAC              (48'h01_02_03_04_05_06)
)TEN_GIG_MAC_TX_u0(
    .i_clk                  (clk        ),
    .i_rst                  (rst        ),
    .i_dynamic_src_mac      (0),
    .i_dynamic_src_valid    (0),
    .i_dynamic_dst_mac      (0),
    .i_dynamic_dst_valid    (0),
    .s_axis_tdata           (rs_axis_tdata       ),
    .s_axis_tuser           (rs_axis_tuser       ),
    .s_axis_tkeep           (rs_axis_tkeep       ),
    .s_axis_tlast           (rs_axis_tlast       ),
    .s_axis_tvalid          (rs_axis_tvalid      ),
    .s_axis_tready          (),
    .o_xgmii_txd            (),
    .o_xgmii_txc            () 
);

TEN_GIG_MAC_RX TEN_GIG_MAC_RX_u0(
    .i_clk              (clk ),
    .i_rst              (rst ),
    .i_dynamic_src_mac      (0),
    .i_dynamic_src_valid    (0),
    .i_dynamic_dst_mac      (0),
    .i_dynamic_dst_valid    (0),
    .i_xgmii_rxd        (r_xgmii_rxd        ),
    .i_xgmii_rxc        (r_xgmii_rxc        ),
    .m_axis_rdata       (m_axis_rdata   ),
    .m_axis_ruser       (m_axis_ruser   ),
    .m_axis_rkeep       (m_axis_rkeep   ),
    .m_axis_rlast       (m_axis_rlast   ),
    .m_axis_rvalid      (m_axis_rvalid  ),
    .o_crc_error        (w_crc_error        ),
    .o_crc_valid        (w_crc_valid        )
);

CRC_process CRC_process_u0(
    .i_clk                  (clk                ),
    .i_rst                  (rst                ),
    .s_axis_rdata           (m_axis_rdata       ),
    .s_axis_ruser           (m_axis_ruser       ),
    .s_axis_rkeep           (m_axis_rkeep       ),
    .s_axis_rlast           (m_axis_rlast       ),
    .s_axis_rvalid          (m_axis_rvalid      ),
    .i_crc_error            (r_crc_error        ),
    .i_crc_valid            (r_crc_valid        ),
    .m_axis_rdata           (m_crc_axis_rdata   ),
    .m_axis_ruser           (m_crc_axis_ruser   ),
    .m_axis_rkeep           (m_crc_axis_rkeep   ),
    .m_axis_rlast           (m_crc_axis_rlast   ),
    .m_axis_rvalid          (m_crc_axis_rvalid  ) 
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

initial begin
    r_crc_error = 'd0;
    r_crc_valid = 'd0;
    wait(!rst);
    repeat(20) @(posedge clk);
    forever begin
        crc_error();
    end
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

task crc_error();
begin : crc_error
    integer i;
    r_crc_error <= 'd0;
    r_crc_valid <= 'd0;
//第一次crc正确
    @(posedge clk);
    wait(w_crc_valid);
    r_crc_error <= 'd0;
    r_crc_valid <= 'd1;
    @(posedge clk);
    r_crc_error <= 'd0;
    r_crc_valid <= 'd0;
//第二次crc错误
    @(posedge clk);
    wait(w_crc_valid);
    r_crc_error <= 'd1;
    r_crc_valid <= 'd1;
    @(posedge clk);
    r_crc_error <= 'd0;
    r_crc_valid <= 'd0;
//第三次crc正确
    @(posedge clk);
    wait(w_crc_valid);
    r_crc_error <= 'd0;
    r_crc_valid <= 'd1;
    @(posedge clk);
    r_crc_error <= 'd0;
    r_crc_valid <= 'd0;
//第四次crc错误
    @(posedge clk);
    wait(w_crc_valid);
    r_crc_error <= 'd1;
    r_crc_valid <= 'd1;
    @(posedge clk);
    r_crc_error <= 'd0;
    r_crc_valid <= 'd0;

//第五次crc错误
    @(posedge clk);
    wait(w_crc_valid);
    r_crc_error <= 'd1;
    r_crc_valid <= 'd1;
    @(posedge clk);
    r_crc_error <= 'd0;
    r_crc_valid <= 'd0;

//第六次crc正确
    @(posedge clk);
    wait(w_crc_valid);
    r_crc_error <= 'd0;
    r_crc_valid <= 'd1;
    @(posedge clk);
    r_crc_error <= 'd0;
    r_crc_valid <= 'd0;
    
end
endtask

reg [7:0] cnt;

initial begin
    cnt             = 'd0;
    rs_axis_tdata   = 'd0;
    rs_axis_tuser   = 'd0;
    rs_axis_tkeep   = 'd0;
    rs_axis_tlast   = 'd0;
    rs_axis_tvalid  = 'd0; 
    wait(!rst);
    repeat(10)@(posedge clk);
    mac_tx(8'b1111_1111);
    repeat(15)@(posedge clk);
    mac_tx(8'b1111_1110);
    repeat(15)@(posedge clk);
    mac_tx(8'b1111_1100);
    repeat(15)@(posedge clk);
    mac_tx(8'b1111_1000);
    repeat(15)@(posedge clk);
    mac_tx(8'b1111_0000);
    repeat(15)@(posedge clk);
    mac_tx(8'b1110_0000);
    repeat(15)@(posedge clk);
    mac_tx(8'b1100_0000);
    repeat(15)@(posedge clk);
    mac_tx(8'b1000_0000);
end


task mac_tx(input [7 :0]keep);
begin : mac_tx
    integer i;
    cnt <= 'd0;
    rs_axis_tdata  <= 'd0;
    rs_axis_tuser  <= 'd0;
    rs_axis_tkeep  <= 'd0;
    rs_axis_tlast  <= 'd0;
    rs_axis_tvalid <= 'd0; 
    @(posedge clk);
    for(i = 0; i < 10; i = i + 1)begin
        
        rs_axis_tdata  <= {8'h11,8'h22,8'h33,8'h44,8'h55,8'h66,8'h77,8'h88};
        rs_axis_tuser  <= {16'd10,48'd0,16'h0800};
        rs_axis_tvalid <= 'd1;  
        if(i == 9)begin
            rs_axis_tkeep  <= keep;
            rs_axis_tlast  <= 'd1;   
        end else begin
            rs_axis_tkeep  <= 8'hff;
            rs_axis_tlast  <= 'd0;               
        end
        cnt <= i + 1;
        @(posedge clk);
    end
    rs_axis_tdata  <= 'd0;
    rs_axis_tuser  <= 'd0;
    rs_axis_tkeep  <= 'd0;
    rs_axis_tlast  <= 'd0;
    rs_axis_tvalid <= 'd0; 
end
endtask

endmodule
