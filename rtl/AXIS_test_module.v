`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/15 11:16:49
// Design Name: 
// Module Name: AXIS_test_module
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


module AXIS_test_module#(
    parameter P_SEND_PKT_LEN = 16'd408
)(
    input           i_clk   ,
    input           i_rst   ,

    output [63:0]   m_axis_tdata        ,
    // output [79:0]   m_axis_tuser        ,
    output [31:0]   m_axis_tuser        ,
    output [7 :0]   m_axis_tkeep        ,
    output          m_axis_tlast        ,
    output          m_axis_tvalid       ,
    input           s_axis_tready       
);

localparam      P_SEND_LEN = P_SEND_PKT_LEN;
localparam      P_SEND_PKT_NUM = 20;

reg  [63:0]     rm_axis_tdata     ;
reg  [79:0]     rm_axis_tuser     ;
reg  [7 :0]     rm_axis_tkeep     ;
reg             rm_axis_tlast     ;
reg             rm_axis_tvalid    ;

reg  [11:0]      r_init_cnt      ;
reg  [15:0]     r_send_cnt      ;
reg  [7 :0]     r_pkt_cnt       ;

reg  [7 :0]     r_pkt_num_cnt;

wire w_axis_active  ;
wire [15:0] w_byte_len ;
assign w_byte_len = 8 * (P_SEND_LEN - 1) + r_pkt_cnt + 1;

assign w_axis_active = rm_axis_tvalid & s_axis_tready;

assign m_axis_tdata  = rm_axis_tdata  ;
assign m_axis_tuser  = rm_axis_tuser  ;
assign m_axis_tkeep  = rm_axis_tkeep  ;
assign m_axis_tlast  = rm_axis_tlast  ;
assign m_axis_tvalid = rm_axis_tvalid ;



always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_pkt_num_cnt <= 'd0;
    // else if(r_pkt_num_cnt == P_SEND_PKT_NUM && rm_axis_tlast)
    //     r_pkt_num_cnt <= r_pkt_num_cnt;
    else if(r_pkt_num_cnt == P_SEND_PKT_NUM - 1 && rm_axis_tlast)
        r_pkt_num_cnt <= 'd0;
    else if(rm_axis_tlast && rm_axis_tvalid)
        r_pkt_num_cnt <= r_pkt_num_cnt + 'd1;
    else
        r_pkt_num_cnt <= r_pkt_num_cnt; 
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_pkt_cnt <= 'd0;
    else if(r_pkt_cnt == 7 && rm_axis_tlast)
        r_pkt_cnt <= 'd0;
    else if(rm_axis_tlast && rm_axis_tvalid)
        r_pkt_cnt <= r_pkt_cnt + 'd1;
    else
        r_pkt_cnt <= r_pkt_cnt; 
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_init_cnt <= 'd0;
    else if(&r_init_cnt)
        r_init_cnt <= r_init_cnt;
    else
        r_init_cnt <= r_init_cnt + 'd1;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_tvalid <= 'd0;
    else if(rm_axis_tlast || (r_pkt_num_cnt == P_SEND_PKT_NUM))
        rm_axis_tvalid <= 'd0;
    else if(&r_init_cnt && s_axis_tready)
        rm_axis_tvalid <= 'd1;
    else
        rm_axis_tvalid <= rm_axis_tvalid;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_send_cnt <= 'd0;
    else if(r_send_cnt == P_SEND_LEN - 1 && w_axis_active)
        r_send_cnt <= 'd0;
    else if(w_axis_active)
        r_send_cnt <= r_send_cnt + 'd1;
    else
        r_send_cnt <= r_send_cnt;
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_tlast <= 'd0;
    else if(r_send_cnt == P_SEND_LEN - 1 && w_axis_active)
        rm_axis_tlast <= 'd0;
    else if(r_send_cnt == P_SEND_LEN - 2 && w_axis_active)
        rm_axis_tlast <= 'd1;
    else
        rm_axis_tlast <= 'd0; 
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_tuser <= 'd0;
    else
        rm_axis_tuser <= {16'd0,w_byte_len};  
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_tdata <= 'd0;
    else if(w_axis_active)
        rm_axis_tdata <= {4{r_send_cnt + 16'd1}};
    else
        rm_axis_tdata <= rm_axis_tdata; 
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        rm_axis_tkeep <= 8'hff;
    else if(r_send_cnt == P_SEND_LEN - 1 && w_axis_active)
        rm_axis_tkeep <= 8'hff;
    else if(r_send_cnt == P_SEND_LEN - 2 && w_axis_active)
        case (r_pkt_cnt)
            7   : rm_axis_tkeep <= 8'b1111_1111;
            6   : rm_axis_tkeep <= 8'b1111_1110;
            5   : rm_axis_tkeep <= 8'b1111_1100;
            4   : rm_axis_tkeep <= 8'b1111_1000;
            3   : rm_axis_tkeep <= 8'b1111_0000;
            2   : rm_axis_tkeep <= 8'b1110_0000;
            1   : rm_axis_tkeep <= 8'b1100_0000;
            0   : rm_axis_tkeep <= 8'b1000_0000;
            default: rm_axis_tkeep <= 8'b1111_1111;
        endcase
        
    else
        rm_axis_tkeep <= 8'hff;
end


endmodule
