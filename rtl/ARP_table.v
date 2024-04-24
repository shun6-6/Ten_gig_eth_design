`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 15:56:26
// Design Name: 
// Module Name: ARP_table
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


module ARP_table(
    input           i_clk               ,
    input           i_rst               ,

    input  [47:0]   i_recv_target_mac   ,
    input  [31:0]   i_recv_target_ip    ,
    input           i_recv_target_valid ,

    input  [31:0]   i_seek_ip           ,
    input           i_seek_valid        ,
    output [47:0]   o_seek_mac          ,
    output          o_seek_mac_valid    
);
/******************************function*****************************/

/******************************parameter****************************/

/******************************mechine******************************/

/******************************reg**********************************/
reg  [47:0]     ri_recv_target_mac      ;
reg  [31:0]     ri_recv_target_ip       ;
reg             ri_recv_target_valid    ;
reg             ri_recv_target_valid_1d ;
reg  [47:0]     ro_seek_mac             ;
reg             ro_seek_mac_valid       ;

reg  [31:0]     r_ram_ip[7 :0]          ;
reg  [47:0]     r_ram_mac[7 :0]         ;
reg  [2 :0]     r_ram_addr              ;
reg  [7 :0]     r_rewrite               ;
reg  [7 :0]     r_rewrite_1d            ;
reg             r_write_new_ip_mac      ;
/******************************wire*********************************/

/******************************component****************************/

/******************************assign*******************************/
assign o_seek_mac       = ro_seek_mac      ;
assign o_seek_mac_valid = ro_seek_mac_valid;
/******************************always*******************************/
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        ri_recv_target_mac <= 'd0;
        ri_recv_target_ip  <= 'd0;        
    end
    else if(i_recv_target_valid)begin
        ri_recv_target_mac <= i_recv_target_mac;
        ri_recv_target_ip  <= i_recv_target_ip ;           
    end
    else begin
        ri_recv_target_mac <= ri_recv_target_mac;
        ri_recv_target_ip  <= ri_recv_target_ip;           
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        ri_recv_target_valid <= 'd0;
        ri_recv_target_valid_1d <= 'd0;
    end else begin
        ri_recv_target_valid <= i_recv_target_valid;
        ri_recv_target_valid_1d <= ri_recv_target_valid;
    end
end

//先检查当前ARP表当中是否有需要记录的IP和MAC，如果有则将对应IP的MAC重新写一次
genvar check_i;
generate
    for(check_i = 0; check_i < 8; check_i = check_i + 1)begin:check_ip

        always @(posedge i_clk or posedge i_rst) begin
            if(i_rst)
                r_rewrite[check_i] <= 'd0;  
            else if(i_recv_target_valid && i_recv_target_ip == r_ram_ip[check_i])    
                r_rewrite[check_i] <= 'd1;
            else
                r_rewrite[check_i] <= 'd0;
        end

    end
endgenerate

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_rewrite_1d <= 'd0;
    else
        r_rewrite_1d <= r_rewrite;
end

//arp表没有当前ip，则写入该新ip与对应mac,写完需要地址加1
//否则r_ram_addr保持不变，因为当前需要重写某一ip,不需要写新的ip和mac
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_ram_addr <= 'd0;
    else if(r_rewrite != 0 && ri_recv_target_valid)
        r_ram_addr <= r_ram_addr;
    else if(r_write_new_ip_mac)
        r_ram_addr <= r_ram_addr + 1;
    else
        r_ram_addr <= r_ram_addr;
end


genvar write_i;
generate
    for(write_i = 0; write_i < 8; write_i = write_i + 1)begin:write_ip

        always @(posedge i_clk or posedge i_rst) begin
            if(i_rst)
                r_ram_ip[write_i] <= 'd0;  
            else if(r_rewrite_1d[write_i] && ri_recv_target_valid_1d)    
                r_ram_ip[write_i] <= ri_recv_target_ip;
            else if(r_rewrite_1d == 0 && write_i == r_ram_addr && ri_recv_target_valid_1d)    
                r_ram_ip[write_i] <= ri_recv_target_ip;
            else
                r_ram_ip[write_i] <= r_ram_ip[write_i];
        end

        always @(posedge i_clk or posedge i_rst) begin
            if(i_rst)
                r_ram_mac[write_i] <= 'd0;  
            else if(r_rewrite_1d[write_i] && ri_recv_target_valid_1d)    
                r_ram_mac[write_i] <= ri_recv_target_mac;
            else if(r_rewrite_1d == 0 && write_i == r_ram_addr && ri_recv_target_valid_1d)    
                r_ram_mac[write_i] <= ri_recv_target_mac;
            else
                r_ram_mac[write_i] <= r_ram_mac[write_i];
        end

    end
endgenerate

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_write_new_ip_mac <= 'd0;
    else if(r_rewrite_1d == 0 && ri_recv_target_valid_1d)
        r_write_new_ip_mac <= 'd1;
    else
        r_write_new_ip_mac <= 'd0; 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_seek_mac <= 48'hff_ff_ff_ff_ff_ff;
    else if(i_seek_valid && i_seek_ip == r_ram_ip[0])
        ro_seek_mac <= r_ram_mac[0];
    else if(i_seek_valid && i_seek_ip == r_ram_ip[1])
        ro_seek_mac <= r_ram_mac[1];
    else if(i_seek_valid && i_seek_ip == r_ram_ip[2])
        ro_seek_mac <= r_ram_mac[2];
    else if(i_seek_valid && i_seek_ip == r_ram_ip[3])
        ro_seek_mac <= r_ram_mac[3];
    else if(i_seek_valid && i_seek_ip == r_ram_ip[4])
        ro_seek_mac <= r_ram_mac[4];
    else if(i_seek_valid && i_seek_ip == r_ram_ip[5])
        ro_seek_mac <= r_ram_mac[5];
    else if(i_seek_valid && i_seek_ip == r_ram_ip[6])
        ro_seek_mac <= r_ram_mac[6];
    else if(i_seek_valid && i_seek_ip == r_ram_ip[7])
        ro_seek_mac <= r_ram_mac[7];
    else 
        ro_seek_mac <= 48'hff_ff_ff_ff_ff_ff;
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)
        ro_seek_mac_valid <= 'd0;
    else if(i_seek_valid)
        ro_seek_mac_valid <= 'd1;
    else
        ro_seek_mac_valid <= 'd0;
end



endmodule
