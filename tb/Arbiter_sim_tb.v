`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/25 09:52:15
// Design Name: 
// Module Name: Arbiter_sim_tb
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


module Arbiter_sim_tb();

reg   clk,rst;

initial begin
    rst = 1;
    #100 @(posedge clk)rst <= 0;
end

always
begin
    clk = 1;
    #10;
    clk = 0;
    #10;
end

reg  [63:0]     rs_axis_c0_data     ;
reg  [79:0]     rs_axis_c0_user     ;
reg  [7 :0]     rs_axis_c0_keep     ;
reg             rs_axis_c0_last     ;
reg             rs_axis_c0_valid    ;
reg  [63:0]     rs_axis_c1_data     ;
reg  [79:0]     rs_axis_c1_user     ;
reg  [7 :0]     rs_axis_c1_keep     ;
reg             rs_axis_c1_last     ;
reg             rs_axis_c1_valid    ;

Arbiter_module#(
    .P_ARBITER_LAYER         ("IP"               )   
)       
Arbiter_module_u0     
(       
    .i_clk                  (clk                ),
    .i_rst                  (rst                ),

    .s_axis_c0_data         (rs_axis_c0_data    ),
    .s_axis_c0_user         (rs_axis_c0_user    ),
    .s_axis_c0_keep         (rs_axis_c0_keep    ),
    .s_axis_c0_last         (rs_axis_c0_last    ),
    .s_axis_c0_valid        (rs_axis_c0_valid   ),
    .s_axis_c0_ready        (),

    .s_axis_c1_data         (rs_axis_c1_data    ),
    .s_axis_c1_user         (rs_axis_c1_user    ),
    .s_axis_c1_keep         (rs_axis_c1_keep    ),
    .s_axis_c1_last         (rs_axis_c1_last    ),
    .s_axis_c1_valid        (rs_axis_c1_valid   ),
    .s_axis_c1_ready        (                 ),

    .m_axis_out_data         (),
    .m_axis_out_user         (),
    .m_axis_out_keep         (),
    .m_axis_out_last         (),
    .m_axis_out_valid        (),
    .m_axis_out_ready        (1)
);


initial begin
    rs_axis_c0_data  = 'd0;
    rs_axis_c0_user  = 'd0;
    rs_axis_c0_keep  = 'd0;
    rs_axis_c0_last  = 'd0;
    rs_axis_c0_valid = 'd0;
    rs_axis_c1_data  = 'd0;
    rs_axis_c1_user  = 'd0;
    rs_axis_c1_keep  = 'd0;
    rs_axis_c1_last  = 'd0;
    rs_axis_c1_valid = 'd0;
    wait(!rst);
    fork
        begin
            repeat(10)@(posedge clk);
             send_c0();
             repeat(10)@(posedge clk);
             send_c0();
             repeat(10)@(posedge clk);
             send_c0();
        end    
        begin    
            repeat(10)@(posedge clk);
             send_c1();
             repeat(10)@(posedge clk);
             send_c1();
        end
    join
     
end

reg [7 :0] r_cnt_c0;
task send_c0();
begin:send_c0_task
    integer i;
    rs_axis_c0_data  <= 'd0;
    rs_axis_c0_user  <= 'd0;
    rs_axis_c0_keep  <= 'd0;
    rs_axis_c0_last  <= 'd0;
    rs_axis_c0_valid <= 'd0;
    r_cnt_c0 <= 'd1;
    @(posedge clk);
    for(i = 0 ;i < 10 ;i =i + 1)
    begin
    rs_axis_c0_data  <= {8{r_cnt_c0}};
    rs_axis_c0_user  <= {16'd10,3'b010,8'd1,13'd0,16'd1};
    //rs_axis_c0_user  <= {16'd10,48'd0,16'd0806};
    
    if(i == 10 - 1)begin
        rs_axis_c0_last  <= 'd1;
        rs_axis_c0_keep  <= 8'b1111_1100;
    end else begin
        rs_axis_c0_last  <= 'd0;
        rs_axis_c0_keep  <= 8'b1111_1111;
    end
    rs_axis_c0_valid <= 'd1;
    r_cnt_c0 <= r_cnt_c0 + 1;
    @(posedge clk);
    end
    rs_axis_c0_data  <= 'd0;
    rs_axis_c0_user  <= 'd0;
    rs_axis_c0_keep  <= 'd0;
    rs_axis_c0_last  <= 'd0;
    rs_axis_c0_valid <= 'd0;
    r_cnt_c0 <= 'd1;
    @(posedge clk);
end
endtask

reg [7 :0] r_cnt_c1;
task send_c1();
begin:send_c1_task
    integer i;
    rs_axis_c1_data  <= 'd0;
    rs_axis_c1_user  <= 'd0;
    rs_axis_c1_keep  <= 'd0;
    rs_axis_c1_last  <= 'd0;
    rs_axis_c1_valid <= 'd0;
    r_cnt_c1 <= 'd1;
    @(posedge clk);
    for(i = 0 ;i < 200 ;i =i + 1)
    begin
    rs_axis_c1_data  <= {8{r_cnt_c1}};
    rs_axis_c1_user  <= {16'd200,3'b010,8'd1,13'd0,16'd1};
    //rs_axis_c1_user  <= {16'd200,48'd0,16'd0800};

    if(i == 200 - 1)begin
        rs_axis_c1_last  <= 'd1;
        rs_axis_c1_keep  <= 8'b1111_1100;
    end else begin
        rs_axis_c1_last  <= 'd0;
        rs_axis_c1_keep  <= 8'b1111_1111;
    end

    rs_axis_c1_valid <= 'd1;
    r_cnt_c1 <= r_cnt_c1 + 1;
    @(posedge clk);
    end
    rs_axis_c1_data  <= 'd0;
    rs_axis_c1_user  <= 'd0;
    rs_axis_c1_keep  <= 'd0;
    rs_axis_c1_last  <= 'd0;
    rs_axis_c1_valid <= 'd0;
    r_cnt_c1 <= 'd1;
    @(posedge clk);
end
endtask

endmodule
