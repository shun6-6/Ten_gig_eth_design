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
wire            ws_axis_tready      ;
//ip tx test
reg  [63:0]     rs_axis_upper_data  ;
reg  [55:0]     rs_axis_upper_user  ;
reg  [7 :0]     rs_axis_upper_keep  ;
reg             rs_axis_upper_last  ;
reg             rs_axis_upper_valid ;
wire            ws_axis_upper_ready ;
wire [63:0]     wm_axis_mac_data    ;
wire [79:0]     wm_axis_mac_user    ;
wire [7 :0]     wm_axis_mac_keep    ;
wire            wm_axis_mac_last    ;
wire            wm_axis_mac_valid   ;



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
    .s_axis_tready          (ws_axis_tready),
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

IP_module#(
    .P_SRC_IP_ADDR   ({8'd192,8'd168,8'd100,8'd100 }) ,
    .P_DST_IP_ADDR   ({8'd192,8'd168,8'd100,8'd100})
)IP_module_u0(
    .i_clk                  (clk),
    .i_rst                  (rst),
    .i_dynamic_src_ip       (0),
    .i_dynamic_src_valid    (0),
    .i_dynamic_dst_ip       (0),
    .i_dynamic_dst_valid    (0),
    .m_axis_mac_data        (wm_axis_mac_data ),
    .m_axis_mac_user        (wm_axis_mac_user ),
    .m_axis_mac_keep        (wm_axis_mac_keep ),
    .m_axis_mac_last        (wm_axis_mac_last ),
    .m_axis_mac_valid       (wm_axis_mac_valid),
    .s_axis_mac_data        (wm_axis_mac_data ),
    .s_axis_mac_user        (wm_axis_mac_user ),
    .s_axis_mac_keep        (wm_axis_mac_keep ),
    .s_axis_mac_last        (wm_axis_mac_last ),
    .s_axis_mac_valid       (wm_axis_mac_valid),
    .m_axis_upper_data      (),
    .m_axis_upper_user      (),
    .m_axis_upper_keep      (),
    .m_axis_upper_last      (),
    .m_axis_upper_valid     (),
    .s_axis_upper_data      (rs_axis_upper_data ),
    .s_axis_upper_user      (rs_axis_upper_user ),
    .s_axis_upper_keep      (rs_axis_upper_keep ),
    .s_axis_upper_last      (rs_axis_upper_last ),
    .s_axis_upper_valid     (rs_axis_upper_valid),
    .s_axis_upper_ready     (ws_axis_upper_ready) 
);

reg  [63:0]   rs_axis_mac2arp_data  ;
reg  [79:0]   rs_axis_mac2arp_user  ;
reg  [7 :0]   rs_axis_mac2arp_keep  ;
reg           rs_axis_mac2arp_last  ;
reg           rs_axis_mac2arp_valid ;
wire [63:0]   wm_axis_arp_data      ;
wire [79:0]   wm_axis_arp_user      ;
wire [7 :0]   wm_axis_arp_keep      ;
wire          wm_axis_arp_last      ;
wire          wm_axis_arp_valid     ;

wire [47:0]   wo_seek_mac           ;
wire          wo_seek_mac_valid     ;
reg  [31:0]   ri_seek_ip            ;
reg           ri_seek_valid         ;
reg           ri_arp_active         ;
reg  [31:0]   ri_arp_active_dst_ip  ;


ARP_module#(
    .P_SRC_IP_ADDR          ({8'd192,8'd168,8'd100,8'd100 }),
    .P_SRC_MAC_ADDR         (48'h01_02_03_04_05_06)
)ARP_module_u0(
    .i_clk                  (clk),
    .i_rst                  (rst),
    .i_dymanic_src_ip       (0),
    .i_src_ip_valid         (0),
    .i_dymanic_src_mac      (0),
    .i_src_mac_valid        (0),
    .i_arp_active           (ri_arp_active),
    .i_arp_active_dst_ip    (ri_arp_active_dst_ip),
    .i_seek_ip              (ri_seek_ip             ),
    .i_seek_valid           (ri_seek_valid          ),
    .o_seek_mac             (wo_seek_mac            ),
    .o_seek_mac_valid       (wo_seek_mac_valid      ),
    .s_axis_mac_data        (wm_axis_arp_data       ),
    .s_axis_mac_user        (wm_axis_arp_user       ),
    .s_axis_mac_keep        (wm_axis_arp_keep       ),
    .s_axis_mac_last        (wm_axis_arp_last       ),
    .s_axis_mac_valid       (wm_axis_arp_valid      ),
    .m_axis_arp_data        (wm_axis_arp_data       ),
    .m_axis_arp_user        (wm_axis_arp_user       ),
    .m_axis_arp_keep        (wm_axis_arp_keep       ),
    .m_axis_arp_last        (wm_axis_arp_last       ),
    .m_axis_arp_valid       (wm_axis_arp_valid      ) 
);

reg  [63:0]     rs_axis_ip2icmp_data         ;
reg  [55:0]     rs_axis_ip2icmp_user         ;
reg  [7 :0]     rs_axis_ip2icmp_keep         ;
reg             rs_axis_ip2icmp_last         ;
reg             rs_axis_ip2icmp_valid        ;

ICMP_Module ICMP_Module_u0(
    .i_clk                 (clk                          ),
    .i_rst                 (rst                          ),

    .s_axis_ip_data        (rs_axis_ip2icmp_data                ),
    .s_axis_ip_user        (rs_axis_ip2icmp_user                ),
    .s_axis_ip_keep        (rs_axis_ip2icmp_keep                ),
    .s_axis_ip_last        (rs_axis_ip2icmp_last                ),
    .s_axis_ip_valid       (rs_axis_ip2icmp_valid               ),

    .m_axis_ip_data        (),
    .m_axis_ip_user        (),
    .m_axis_ip_keep        (),
    .m_axis_ip_last        (),
    .m_axis_ip_valid       (),
    .m_axis_ip_ready       ()
);

wire [63:0]   wm_axis_ip2udp_data ;
wire [55:0]   wm_axis_ip2udp_user ;
wire [7 :0]   wm_axis_ip2udp_keep ;
wire          wm_axis_ip2udp_last ;
wire          wm_axis_ip2udp_valid;

reg  [63:0]   rs_axis_user_data     ;
reg  [31:0]   rs_axis_user_user     ;
reg  [7 :0]   rs_axis_user_keep     ;
reg           rs_axis_user_last     ;
reg           rs_axis_user_valid    ;
wire          ws_axis_user_ready    ;

UDP_module#(
    .P_SRC_UDP_PORT         (16'h0808),
    .P_DST_UDP_PORT         (16'h0808)
)UDP_module_u0(
    .i_clk                  (clk),
    .i_rst                  (rst),
    .i_dymanic_src_port     (0),
    .i_dymanic_src_valid    (0),
    .i_dymanic_dst_port     (0),
    .i_dymanic_dst_valid    (0),
    .m_axis_ip_data         (wm_axis_ip2udp_data ),
    .m_axis_ip_user         (wm_axis_ip2udp_user ),//用户自定义{16'dlen,3'bflag,8'dtype,13'doffset,16'dID}
    .m_axis_ip_keep         (wm_axis_ip2udp_keep ),
    .m_axis_ip_last         (wm_axis_ip2udp_last ),
    .m_axis_ip_valid        (wm_axis_ip2udp_valid),
    .m_axis_ip_ready        (1),
    .s_axis_ip_data         (wm_axis_ip2udp_data ),
    .s_axis_ip_user         (wm_axis_ip2udp_user ),
    .s_axis_ip_keep         (wm_axis_ip2udp_keep ),
    .s_axis_ip_last         (wm_axis_ip2udp_last ),
    .s_axis_ip_valid        (wm_axis_ip2udp_valid),

    .m_axis_user_data       (),
    .m_axis_user_user       (),
    .m_axis_user_keep       (),
    .m_axis_user_last       (),
    .m_axis_user_valid      (),
    .s_axis_user_data       (rs_axis_user_data ),
    .s_axis_user_user       (rs_axis_user_user ),
    .s_axis_user_keep       (rs_axis_user_keep ),
    .s_axis_user_last       (rs_axis_user_last ),
    .s_axis_user_valid      (rs_axis_user_valid),
    .s_axis_user_ready      (ws_axis_user_ready)
);

initial begin
    r_xgmii_rxd = 'd0;
    r_xgmii_rxc = 'd0; 
    wait(!rst);
    repeat(20) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0000_0001);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0000_0010);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0000_0100);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0000_1000);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0001_0000);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0010_0000);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof7(8'b0100_0000);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof7(8'b1000_0000);

    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0000_0001);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0000_0010);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0000_0100);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0000_1000);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0001_0000);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0010_0000);
    repeat(2) @(posedge clk);
    xgmii_rxd_send_sof4(8'b0100_0000);
    repeat(2) @(posedge clk);
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
    wait(ws_axis_tready);
    mac_tx(8'b1111_1110);
    wait(ws_axis_tready);
    mac_tx(8'b1111_1100);
    wait(ws_axis_tready);
    mac_tx(8'b1111_1000);
    wait(ws_axis_tready);
    mac_tx(8'b1111_0000);
    wait(ws_axis_tready);
    mac_tx(8'b1110_0000);
    wait(ws_axis_tready);
    mac_tx(8'b1100_0000);
    wait(ws_axis_tready);
    mac_tx(8'b1000_0000);
end

reg [7:0] ip_tx_cnt;

initial begin:ip_tx_test
    ip_tx_cnt       = 'd0;
    rs_axis_upper_data   = 'd0;
    rs_axis_upper_user   = 'd0;
    rs_axis_upper_keep   = 'd0;
    rs_axis_upper_last   = 'd0;
    rs_axis_upper_valid  = 'd0; 
    wait(!rst);
    repeat(10)@(posedge clk);
    ip_tx(8'b1111_1111);
    wait(ws_axis_upper_ready);
    ip_tx(8'b1111_1110);
    wait(ws_axis_upper_ready);
    ip_tx(8'b1111_1100);
    wait(ws_axis_upper_ready);
    ip_tx(8'b1111_1000);
    wait(ws_axis_upper_ready);
    ip_tx(8'b1111_0000);
    wait(ws_axis_upper_ready);
    ip_tx(8'b1110_0000);
    wait(ws_axis_upper_ready);
    ip_tx(8'b1100_0000);
    wait(ws_axis_upper_ready);
    ip_tx(8'b1000_0000);
end

initial begin
    ri_arp_active = 0;
    ri_arp_active_dst_ip = 0;
    ri_seek_ip    = 0;
    ri_seek_valid = 0;
    wait(!rst);
    repeat(10)@(posedge clk);
    arp_active();
    repeat(100)@(posedge clk);
    arp_active();
    repeat(10)@(posedge clk);
    arp_seek();
end

initial
begin
    rs_axis_ip2icmp_data  = 'd0;
    rs_axis_ip2icmp_user  = 'd0;
    rs_axis_ip2icmp_keep  = 'd0;
    rs_axis_ip2icmp_last  = 'd0;
    rs_axis_ip2icmp_valid = 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);
    icmp_send();
    repeat(10)@(posedge clk);

    icmp_send();
    repeat(10)@(posedge clk);
end

initial begin
    rs_axis_user_data  = 0;
    rs_axis_user_user  = 0;
    rs_axis_user_keep  = 0;
    rs_axis_user_last  = 0;
    rs_axis_user_valid = 0;
    wait(!rst);
    repeat(10)@(posedge clk);
    udp_tx(8'b1111_1111);
    wait(ws_axis_user_ready);
    udp_tx(8'b1111_1110);
    wait(ws_axis_user_ready);
    udp_tx(8'b1111_1100);
    wait(ws_axis_user_ready);
    udp_tx(8'b1111_1000);
    wait(ws_axis_user_ready);
    udp_tx(8'b1111_0000);
    wait(ws_axis_user_ready);
    udp_tx(8'b1110_0000);
    wait(ws_axis_user_ready);
    udp_tx(8'b1100_0000);
    wait(ws_axis_user_ready);
    udp_tx(8'b1000_0000);
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
    @(posedge clk);
end
endtask

task ip_tx(input [7 :0]keep);
begin : ip_tx
    integer i;
    ip_tx_cnt <= 'd0;
    rs_axis_upper_data  <= 'd0;
    rs_axis_upper_user  <= 'd0;
    rs_axis_upper_keep  <= 'd0;
    rs_axis_upper_last  <= 'd0;
    rs_axis_upper_valid <= 'd0; 
    @(posedge clk);
    for(i = 0; i < 10; i = i + 1)begin
        
        rs_axis_upper_data  <= {8{ip_tx_cnt}};
        rs_axis_upper_user  <= {16'd10,3'b010,8'd17,13'd0,16'd0};
        rs_axis_upper_valid <= 'd1;  
        if(i == 9)begin
            rs_axis_upper_keep  <= keep;
            rs_axis_upper_last  <= 'd1;   
        end else begin
            rs_axis_upper_keep  <= 8'hff;
            rs_axis_upper_last  <= 'd0;               
        end
        ip_tx_cnt <= i + 1;
        @(posedge clk);
    end
    rs_axis_upper_data  <= 'd0;
    rs_axis_upper_user  <= 'd0;
    rs_axis_upper_keep  <= 'd0;
    rs_axis_upper_last  <= 'd0;
    rs_axis_upper_valid <= 'd0; 
    @(posedge clk);
end
endtask

task arp_active();
begin:arp_active
    ri_arp_active <= 'd0;
    ri_arp_active_dst_ip <= 'd0;
    @(posedge clk);
    repeat(10)@(posedge clk);
    ri_arp_active <= 'd1;
    ri_arp_active_dst_ip <= {8'd192,8'd168,8'd100,8'd100 };
    @(posedge clk);
    ri_arp_active <= 'd0;  
    ri_arp_active_dst_ip <= 'd0;
end
endtask

task arp_seek();
begin:arp_seek
    ri_seek_ip    <= 'd0;
    ri_seek_valid <= 'd0;
    @(posedge clk);
    repeat(10)@(posedge clk);
    ri_seek_valid <= 'd1;
    ri_seek_ip <= {8'd192,8'd168,8'd100,8'd100 };
    @(posedge clk);
    ri_seek_ip <= 'd0;  
    ri_seek_valid <= 'd0;
end
endtask


task icmp_send();
begin:icmp_send_task
    rs_axis_ip2icmp_data  <= 'd0;
    rs_axis_ip2icmp_user  <= 'd0;
    rs_axis_ip2icmp_keep  <= 'd0;
    rs_axis_ip2icmp_last  <= 'd0;
    rs_axis_ip2icmp_valid <= 'd0;
    @(posedge clk);
    rs_axis_ip2icmp_data  <= {16'h0800,16'h0000,16'd1,16'd2};
    rs_axis_ip2icmp_user  <= {16'd5,3'b010,8'd1,13'd0,16'd1};
    rs_axis_ip2icmp_keep  <= 8'b1111_1111;
    rs_axis_ip2icmp_last  <= 'd0;
    rs_axis_ip2icmp_valid <= 'd1;
    @(posedge clk);
    rs_axis_ip2icmp_data  <= {64'h6162636465666768};
    rs_axis_ip2icmp_user  <= {16'd5,3'b010,8'd1,13'd0,16'd1};
    rs_axis_ip2icmp_keep  <= 8'b1111_1111;
    rs_axis_ip2icmp_last  <= 'd0;
    rs_axis_ip2icmp_valid <= 'd1;
    @(posedge clk);
    rs_axis_ip2icmp_data  <= {64'h696a6b6c6d6e6f70};
    rs_axis_ip2icmp_user  <= {16'd5,3'b010,8'd1,13'd0,16'd1};
    rs_axis_ip2icmp_keep  <= 8'b1111_1111;
    rs_axis_ip2icmp_last  <= 'd0;
    rs_axis_ip2icmp_valid <= 'd1;
    @(posedge clk);
    rs_axis_ip2icmp_data  <= {64'h7172737475767761};
    rs_axis_ip2icmp_user  <= {16'd5,3'b010,8'd1,13'd0,16'd1};
    rs_axis_ip2icmp_keep  <= 8'b1111_1111;
    rs_axis_ip2icmp_last  <= 'd0;
    rs_axis_ip2icmp_valid <= 'd1;
    @(posedge clk);
    rs_axis_ip2icmp_data  <= {64'h6263646566676869};
    rs_axis_ip2icmp_user  <= {16'd5,3'b010,8'd1,13'd0,16'd1};
    rs_axis_ip2icmp_keep  <= 8'b1111_1111;
    rs_axis_ip2icmp_last  <= 'd1;
    rs_axis_ip2icmp_valid <= 'd1;
    @(posedge clk);
    rs_axis_ip2icmp_data  <= 'd0;
    rs_axis_ip2icmp_user  <= 'd0;
    rs_axis_ip2icmp_keep  <= 'd0;
    rs_axis_ip2icmp_last  <= 'd0;
    rs_axis_ip2icmp_valid <= 'd0;
    @(posedge clk);
end
endtask



reg [15:0]udp_tx_cnt;  
task udp_tx(input [7 :0]keep);
begin : udp_tx
    integer i;
    udp_tx_cnt <= 'd0;
    rs_axis_user_data  <= 'd0;
    rs_axis_user_user  <= 'd0;
    rs_axis_user_keep  <= 'd0;
    rs_axis_user_last  <= 'd0;
    rs_axis_user_valid <= 'd0; 
    @(posedge clk);
    for(i = 0; i < 10; i = i + 1)begin
        
        rs_axis_user_data  <= {8{udp_tx_cnt}};
        rs_axis_user_user  <= {16'd0,(16'd80)};
        rs_axis_user_valid <= 'd1;  
        if(i == 9)begin
            rs_axis_user_keep  <= keep;
            rs_axis_user_last  <= 'd1;   
        end else begin
            rs_axis_user_keep  <= 8'hff;
            rs_axis_user_last  <= 'd0;               
        end
        udp_tx_cnt <= i + 1;
        @(posedge clk);
    end
    rs_axis_user_data  <= 'd0;
    rs_axis_user_user  <= 'd0;
    rs_axis_user_keep  <= 'd0;
    rs_axis_user_last  <= 'd0;
    rs_axis_user_valid <= 'd0; 
    @(posedge clk);
end
endtask

endmodule
