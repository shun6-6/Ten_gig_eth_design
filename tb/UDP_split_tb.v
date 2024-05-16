`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/14 10:42:31
// Design Name: 
// Module Name: UDP_split_tb
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


module UDP_split_tb();
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

reg  [63:0]   rs_axis_ip_data       ;
reg  [55:0]   rs_axis_ip_user       ;
reg  [7 :0]   rs_axis_ip_keep       ;
reg           rs_axis_ip_last       ;
reg           rs_axis_ip_valid      ;
wire [63:0]   wm_axis_user_data     ;
wire [31:0]   wm_axis_user_user     ;
wire [7 :0]   wm_axis_user_keep     ;
wire          wm_axis_user_last     ;
wire          wm_axis_user_valid    ;
wire        ws_axis_user_ready;

wire [63:0]   m_axis_tdata  ;
wire [31:0]   m_axis_tuser  ;
wire [7 :0]   m_axis_tkeep  ;
wire          m_axis_tlast  ;
wire          m_axis_tvalid ;

wire wm_axis_ip_last;
reg rm_axis_ip_ready;

UDP_RX#(
    .P_SRC_UDP_PORT         (16'h8080),
    .P_DST_UDP_PORT         (16'h8080)
)UDP_RX_u0(
    .i_clk                  (clk),
    .i_rst                  (rst),
    .i_dymanic_src_port     ('d0),
    .i_dymanic_src_valid    ('d0),
    .s_axis_ip_data         (rs_axis_ip_data         ),
    .s_axis_ip_user         (rs_axis_ip_user         ),
    .s_axis_ip_keep         (rs_axis_ip_keep         ),
    .s_axis_ip_last         (rs_axis_ip_last         ),
    .s_axis_ip_valid        (rs_axis_ip_valid        ),
    .m_axis_user_data       (wm_axis_user_data       ),
    .m_axis_user_user       (wm_axis_user_user       ),
    .m_axis_user_keep       (wm_axis_user_keep       ),
    .m_axis_user_last       (wm_axis_user_last       ),
    .m_axis_user_valid      (wm_axis_user_valid      ) 
);

UDP_TX#(
    .P_SRC_UDP_PORT         (16'h8080),
    .P_DST_UDP_PORT         (16'h8080)
)UDP_TX_u0(
    .i_clk                  (clk                  ),
    .i_rst                  (rst                  ),
    .i_dymanic_src_port     ('d0),
    .i_dymanic_src_valid    ('d0),
    .i_dymanic_dst_port     ('d0),
    .i_dymanic_dst_valid    ('d0),
    .m_axis_ip_data         (        ),
    .m_axis_ip_user         (        ),
    .m_axis_ip_keep         (        ),
    .m_axis_ip_last         (wm_axis_ip_last),
    .m_axis_ip_valid        (        ),
    .m_axis_ip_ready        (rm_axis_ip_ready),
    .s_axis_user_data       (m_axis_tdata ),
    .s_axis_user_user       (m_axis_tuser ),
    .s_axis_user_keep       (m_axis_tkeep ),
    .s_axis_user_last       (m_axis_tlast ),
    .s_axis_user_valid      (m_axis_tvalid),
    .s_axis_user_ready      (ws_axis_user_ready) 
);

AXIS_test_module#(
    .P_SEND_PKT_LEN (16'd408)
)AXIS_test_module_u0(
    .i_clk              (clk),
    .i_rst              (rst),
    .m_axis_tdata       (m_axis_tdata ),
    .m_axis_tuser       (m_axis_tuser ),
    .m_axis_tkeep       (m_axis_tkeep ),
    .m_axis_tlast       (m_axis_tlast ),
    .m_axis_tvalid      (m_axis_tvalid),
    .s_axis_tready      (ws_axis_user_ready)
);

initial begin
    rs_axis_ip_data  = 'd0;
    rs_axis_ip_user  = 'd0;
    rs_axis_ip_keep  = 'd0;
    rs_axis_ip_last  = 'd0;
    rs_axis_ip_valid = 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);

        udp_big_pkt_send();
    
end

initial begin
    rm_axis_ip_ready = 'd1;
    wait(!rst);
    repeat(10)@(posedge clk);

        udp_ready();
    
end

task udp_ready();
begin
    rm_axis_ip_ready <= 'd1;
    forever begin
        wait(wm_axis_ip_last);
        rm_axis_ip_ready <= 'd0;
        repeat(3)@(posedge clk);
        rm_axis_ip_ready <= 'd1;
    end
end

endtask

task udp_big_pkt_send();
begin:udp_big_pkt_send
    integer i;
    rs_axis_ip_data  <= 'd0;
    rs_axis_ip_user  <= 'd0;
    rs_axis_ip_keep  <= 'd0;
    rs_axis_ip_last  <= 'd0;
    rs_axis_ip_valid <= 'd0;
    @(posedge clk);
    for(i = 0; i < (1480 >> 3); i = i + 1)begin
        if(i == 0)
            rs_axis_ip_data  <= {16'h8080,16'h8080,16'd1480,16'd0};
        else
            rs_axis_ip_data  <= i;

        rs_axis_ip_user  <= {16'd1480,3'b001,8'd17,13'd0,16'd1};
        rs_axis_ip_keep  <= 8'hff;
        rs_axis_ip_valid <= 'd1;
        if(i == (1480 >> 3) - 1)
            rs_axis_ip_last  <= 'd1;
        else
            rs_axis_ip_last  <= 'd0;   
        @(posedge clk);     
    end
    rs_axis_ip_data  <= 'd0;
    rs_axis_ip_user  <= 'd0;
    rs_axis_ip_keep  <= 'd0;
    rs_axis_ip_last  <= 'd0;
    rs_axis_ip_valid <= 'd0;
    repeat(10)@(posedge clk);
    for(i = 0; i < (1480 >> 3); i = i + 1)begin
        rs_axis_ip_data  <= i;
        rs_axis_ip_user  <= {16'd1480,3'b001,8'd17,13'd185,16'd1};
        rs_axis_ip_keep  <= 8'hff;
        rs_axis_ip_valid <= 'd1;
        if(i == (1480 >> 3) - 1)
            rs_axis_ip_last  <= 'd1;
        else
            rs_axis_ip_last  <= 'd0;  
        @(posedge clk);     
    end
    rs_axis_ip_data  <= 'd0;
    rs_axis_ip_user  <= 'd0;
    rs_axis_ip_keep  <= 'd0;
    rs_axis_ip_last  <= 'd0;
    rs_axis_ip_valid <= 'd0;
    repeat(10)@(posedge clk);
    for(i = 0; i < (512 >> 3); i = i + 1)begin
        rs_axis_ip_data  <= i;
        rs_axis_ip_user  <= {16'd512,3'b000,8'd17,13'd370,16'd1};
        rs_axis_ip_keep  <= 8'hff;
        rs_axis_ip_valid <= 'd1;
        if(i == (512 >> 3) - 1)
            rs_axis_ip_last  <= 'd1;
        else
            rs_axis_ip_last  <= 'd0;  
        @(posedge clk);     
    end
    rs_axis_ip_data  <= 'd0;
    rs_axis_ip_user  <= 'd0;
    rs_axis_ip_keep  <= 'd0;
    rs_axis_ip_last  <= 'd0;
    rs_axis_ip_valid <= 'd0;

    repeat(2000)@(posedge clk);
    for(i = 0; i < (512 >> 3); i = i + 1)begin
        if(i == 0)
            rs_axis_ip_data  <= {16'h8080,16'h8080,16'd512,16'd0};
        else
            rs_axis_ip_data  <= i;

        rs_axis_ip_user  <= {16'd512,3'b010,8'd17,13'd0,16'd1};
        rs_axis_ip_keep  <= 8'hff;
        rs_axis_ip_valid <= 'd1;
        if(i == (512 >> 3) - 1)
            rs_axis_ip_last  <= 'd1;
        else
            rs_axis_ip_last  <= 'd0;  
        @(posedge clk);     
    end
    rs_axis_ip_data  <= 'd0;
    rs_axis_ip_user  <= 'd0;
    rs_axis_ip_keep  <= 'd0;
    rs_axis_ip_last  <= 'd0;
    rs_axis_ip_valid <= 'd0;
end
endtask


endmodule
