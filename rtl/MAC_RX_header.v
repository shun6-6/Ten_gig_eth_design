`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/15 10:48:50
// Design Name: 
// Module Name: MAC_RX_header
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


module MAC_RX_header(
    input           i_clk               ,
    input           i_rst               ,

    input  [63:0]   i_xgmii_rxd         ,
    input  [7 :0]   i_xgmii_rxc         ,

    output [63:0]   o_xgmii_rxd         ,
    output [7 :0]   o_xgmii_rxc         
);


reg  [63:0]         ri_xgmii_rxd        ;
reg  [7 :0]         ri_xgmii_rxc        ;
reg  [7 :0]         ri_xgmii_rxc_1d     ;
reg  [63:0]         ri_xgmii_rxd_1d     ;
reg  [63:0]         ro_xgmii_rxd        ;
reg  [7 :0]         ro_xgmii_rxc        ;

wire                w_sof               ;
wire                w_sof_local         ;
wire                w_eof               ;


assign o_xgmii_rxd = ro_xgmii_rxd       ;
assign o_xgmii_rxc = ro_xgmii_rxc       ;
assign w_sof = (ri_xgmii_rxc[7] && ri_xgmii_rxd[63:56] == 8'hFB) || 
               (ri_xgmii_rxc[3] && ri_xgmii_rxd[31:24] == 8'hFB) ;
assign w_sof_local = (ri_xgmii_rxc[7] && ri_xgmii_rxd[63:56] == 8'hFB) ? 0 : 1;

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_xgmii_rxd <= 'd0;
        ri_xgmii_rxc <= 'd0;
        ri_xgmii_rxc_1d <= 'd0;
        ri_xgmii_rxd_1d <= 'd0;
    end else begin
        ri_xgmii_rxd <= i_xgmii_rxd;
        ri_xgmii_rxc <= i_xgmii_rxc;
        ri_xgmii_rxc_1d <= ri_xgmii_rxc;
        ri_xgmii_rxd_1d <= ri_xgmii_rxd;
    end  
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)   
        ro_xgmii_rxd <= 'd0;
    else if(w_sof && w_sof_local == 0)
        ro_xgmii_rxd <= {ri_xgmii_rxd[63:56],8'h55,ri_xgmii_rxd[55:8]};
    else if(w_sof && w_sof_local == 1)
        ro_xgmii_rxd <= {ri_xgmii_rxd[63:32],ri_xgmii_rxd[31:24],8'h55,ri_xgmii_rxd[23:8]};
    else 
        ro_xgmii_rxd <= {ri_xgmii_rxd_1d[7 :0],ri_xgmii_rxd[63:8]};
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)   
        ro_xgmii_rxc <= 'd0;
    else if(w_sof && w_sof_local == 0)
        ro_xgmii_rxc <= ri_xgmii_rxc;
    else if(w_sof && w_sof_local == 1)
        ro_xgmii_rxc <= ri_xgmii_rxc;
    else 
        ro_xgmii_rxc <= {ri_xgmii_rxc_1d[0],ri_xgmii_rxc[7:1]};
end
endmodule
