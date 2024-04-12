`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/03 21:24:51
// Design Name: 
// Module Name: TenG_PCAPMA_Test
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


module TenG_PCAPMA_Test(
    input           i_xgmii_clk         ,
    input           i_xgmii_rst         ,
    input  [63:0]   i_xgmii_rxd         ,
    input  [7 :0]   i_xgmii_rxc         ,
    output [63:0]   o_xgmii_txd         ,
    output [7 :0]   o_xgmii_txc           
);  

localparam          P_TARGER_GAP = 100  ;
localparam          P_SEND_LEN = 10     ;

reg  [63:0]         ro_xgmii_txd        ;
reg  [7 :0]         ro_xgmii_txc        ;
reg  [15:0]         r_cnt               ;
reg                 r_triger            ;
reg  [15:0]         r_triger_cnt        ;
reg                 r_run               ;

assign o_xgmii_txd = ro_xgmii_txd       ;
assign o_xgmii_txc = ro_xgmii_txc       ;

always@(posedge i_xgmii_clk,posedge i_xgmii_rst)
begin
    if(i_xgmii_rst)
        r_triger_cnt <= 'd0;
    else if(r_triger_cnt == P_TARGER_GAP - 1)
        r_triger_cnt <= 'd0;
    else if(!r_run)   
        r_triger_cnt <= r_triger_cnt + 1;
    else    
        r_triger_cnt <= 'd0;
end

always@(posedge i_xgmii_clk,posedge i_xgmii_rst)
begin
    if(i_xgmii_rst)
        r_run <= 'd0;
    else if(r_cnt == P_SEND_LEN - 1)
        r_run <= 'd0;
    else if(r_triger)   
        r_run <= 'd1;
    else 
        r_run <= r_run;
end

always@(posedge i_xgmii_clk,posedge i_xgmii_rst)
begin
    if(i_xgmii_rst)
        r_triger <= 'd0;
    else if(r_triger_cnt == P_TARGER_GAP - 1)
        r_triger <= 'd1;
    else 
        r_triger <= 'd0;
end

always@(posedge i_xgmii_clk,posedge i_xgmii_rst)
begin
    if(i_xgmii_rst)
        r_cnt <= 'd0;
    else if(r_cnt == P_SEND_LEN - 1)
        r_cnt <= 'd0;
    else if(r_run || r_cnt)
        r_cnt <= r_cnt + 1;
    else    
        r_cnt <= r_cnt;
end

always@(posedge i_xgmii_clk,posedge i_xgmii_rst)
begin
    if(i_xgmii_rst)
        ro_xgmii_txd <= 64'h07070707_07070707;
    else if(!r_run)
        ro_xgmii_txd <= 64'h07070707_07070707;
    else case(r_cnt)
        0           :ro_xgmii_txd <= 64'hFB555555_55555555;
        1           :ro_xgmii_txd <= 64'hD5000102_03040506;
        2           :ro_xgmii_txd <= 64'h0708090a_0b0c0d0e;
        3           :ro_xgmii_txd <= 64'h0f101112_13141516;
        4           :ro_xgmii_txd <= 64'h1718191a_1b1c1d1e;
        5           :ro_xgmii_txd <= 64'h1f202122_23242526;
        6           :ro_xgmii_txd <= 64'h2728292a_2b2c2d2e;
        7           :ro_xgmii_txd <= 64'h2f303132_33343536;
        8           :ro_xgmii_txd <= 64'h3738393a_3b3c3d3e;
        9           :ro_xgmii_txd <= 64'h3f404142_434445FE;
        default     :ro_xgmii_txd <= 'd0;
    endcase
end

always@(posedge i_xgmii_clk,posedge i_xgmii_rst)
begin
    if(i_xgmii_rst)
        ro_xgmii_txc <= 8'b1111_1111;
    else if(r_run && r_cnt == 0)
        ro_xgmii_txc <= 8'b1000_0000;
    else if(r_run && r_cnt == 9)
        ro_xgmii_txc <= 8'b0000_0001;
    else if(r_run)
        ro_xgmii_txc <= 8'b0000_0000;
    else 
        ro_xgmii_txc <= 8'b1111_1111;
end

endmodule
