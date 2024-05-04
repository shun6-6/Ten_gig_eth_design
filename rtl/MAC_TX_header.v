`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/16 09:54:30
// Design Name: 
// Module Name: MAC_TX_header
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


module MAC_TX_header(
    input           i_clk           ,
    input           i_rst           ,

    input  [63:0]   i_xgmii_txd     ,
    input  [7 :0]   i_xgmii_txc     ,

    output [63:0]   o_xgmii_txd     ,
    output [7 :0]   o_xgmii_txc     
);

localparam      P_FRAME_IDLE    = 8'h07 ;

reg  [63:0]         ri_xgmii_txd    ;
reg  [7 :0]         ri_xgmii_txc    ;
reg  [63:0]         ro_xgmii_txd    ;
reg  [7 :0]         ro_xgmii_txc    ;
reg                 r_run           ;

wire                w_sof           ;

assign o_xgmii_txd = ro_xgmii_txd   ;
assign o_xgmii_txc = ro_xgmii_txc   ;
assign w_sof       = ri_xgmii_txd[63:56] == 8'hFB && ri_xgmii_txc[7] == 1;
assign w_eof = (ri_xgmii_txc[0] && ri_xgmii_txd[7 :  0] == 8'hFD) ||
               (ri_xgmii_txc[1] && ri_xgmii_txd[15:  8] == 8'hFD) ||
               (ri_xgmii_txc[2] && ri_xgmii_txd[23: 16] == 8'hFD) ||
               (ri_xgmii_txc[3] && ri_xgmii_txd[31: 24] == 8'hFD) ||
               (ri_xgmii_txc[4] && ri_xgmii_txd[39: 32] == 8'hFD) ||
               (ri_xgmii_txc[5] && ri_xgmii_txd[47: 40] == 8'hFD) ||
               (ri_xgmii_txc[6] && ri_xgmii_txd[55: 48] == 8'hFD) ||
               (ri_xgmii_txc[7] && ri_xgmii_txd[63: 56] == 8'hFD)  ;

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_xgmii_txd <= {8{P_FRAME_IDLE}};
        ri_xgmii_txc <= 8'b1111_1111;
    end else begin
        ri_xgmii_txd <= i_xgmii_txd;
        ri_xgmii_txc <= i_xgmii_txc;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_run <= 'd0;
    else if(w_eof)
        r_run <= 'd0;
    else if(w_sof)
        r_run <= 'd1;
    else 
        r_run <= r_run;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)    
        ro_xgmii_txd <= {8{P_FRAME_IDLE}};
    else if(w_sof)
        ro_xgmii_txd <= {ri_xgmii_txd[63:8],i_xgmii_txd[63:56]};
    else if(r_run)
        ro_xgmii_txd <= {ri_xgmii_txd[55:0],i_xgmii_txd[63:56]};
    else
        ro_xgmii_txd <= ri_xgmii_txd;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)  
        ro_xgmii_txc <= 8'b1111_1111;
    else if(w_sof)       
        ro_xgmii_txc <= ri_xgmii_txc;
    else 
        ro_xgmii_txc <= {ri_xgmii_txc[6 :0],i_xgmii_txc[7]};
end     

endmodule
