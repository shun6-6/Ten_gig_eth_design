module CRC32_64bKEEP(
  input             i_clk       ,
  input             i_rst       ,
  input             i_en        ,
  input  [7 :0]     i_data      ,
  input  [7 :0]     i_data_1    ,
  input  [7 :0]     i_data_2    ,
  input  [7 :0]     i_data_3    ,
  input  [7 :0]     i_data_4    ,
  input  [7 :0]     i_data_5    ,
  input  [7 :0]     i_data_6    ,
  input  [7 :0]     i_data_7    ,
  output [31:0]     o_crc_8     ,//8个byte全部参与校验的结果
  output [31:0]     o_crc_1     ,//1个byte全部参与校验的结果
  output [31:0]     o_crc_2     ,//2个byte全部参与校验的结果
  output [31:0]     o_crc_3     ,//3个byte全部参与校验的结果
  output [31:0]     o_crc_4     ,//4个byte全部参与校验的结果
  output [31:0]     o_crc_5     ,//5个byte全部参与校验的结果
  output [31:0]     o_crc_6     ,//6个byte全部参与校验的结果
  output [31:0]     o_crc_7      //7个byte全部参与校验的结果
);

  

    reg  [31:0] crc;

    wire [7 :0] d[0:7];

    wire [31:0] c[0:7];

    wire [31:0] newcrc[0:7];
    reg  [31:0] ro_crc[0:7];
    
    assign o_crc_8 = ro_crc[7];
    assign o_crc_1 = ro_crc[0];
    assign o_crc_2 = ro_crc[1];
    assign o_crc_3 = ro_crc[2];
    assign o_crc_4 = ro_crc[3];
    assign o_crc_5 = ro_crc[4];
    assign o_crc_6 = ro_crc[5];
    assign o_crc_7 = ro_crc[6];

    assign d[0] = {i_data[0],i_data[1],i_data[2],i_data[3],i_data[4],i_data[5],i_data[6],i_data[7]}; 
    assign d[1] = {i_data_1[0],i_data_1[1],i_data_1[2],i_data_1[3],i_data_1[4],i_data_1[5],i_data_1[6],i_data_1[7]};
    assign d[2] = {i_data_2[0],i_data_2[1],i_data_2[2],i_data_2[3],i_data_2[4],i_data_2[5],i_data_2[6],i_data_2[7]};
    assign d[3] = {i_data_3[0],i_data_3[1],i_data_3[2],i_data_3[3],i_data_3[4],i_data_3[5],i_data_3[6],i_data_3[7]};
    assign d[4] = {i_data_4[0],i_data_4[1],i_data_4[2],i_data_4[3],i_data_4[4],i_data_4[5],i_data_4[6],i_data_4[7]};
    assign d[5] = {i_data_5[0],i_data_5[1],i_data_5[2],i_data_5[3],i_data_5[4],i_data_5[5],i_data_5[6],i_data_5[7]};
    assign d[6] = {i_data_6[0],i_data_6[1],i_data_6[2],i_data_6[3],i_data_6[4],i_data_6[5],i_data_6[6],i_data_6[7]};
    assign d[7] = {i_data_7[0],i_data_7[1],i_data_7[2],i_data_7[3],i_data_7[4],i_data_7[5],i_data_7[6],i_data_7[7]};

    assign c[0]  = crc;

                  
genvar i ;
generate for(i = 0 ; i < 8 ; i = i + 1)
begin

    assign newcrc[i][0]  = i_en ? d[i][6] ^ d[i][0] ^ c[i][24] ^ c[i][30] : 'd0;
    assign newcrc[i][1]  = i_en ? d[i][7] ^ d[i][6] ^ d[i][1] ^ d[i][0] ^ c[i][24] ^ c[i][25] ^ c[i][30] ^ c[i][31]: 'd0;
    assign newcrc[i][2]  = i_en ? d[i][7] ^ d[i][6] ^ d[i][2] ^ d[i][1] ^ d[i][0] ^ c[i][24] ^ c[i][25] ^ c[i][26] ^ c[i][30] ^ c[i][31]: 'd0;
    assign newcrc[i][3]  = i_en ? d[i][7] ^ d[i][3] ^ d[i][2] ^ d[i][1] ^ c[i][25] ^ c[i][26] ^ c[i][27] ^ c[i][31]: 'd0;
    assign newcrc[i][4]  = i_en ? d[i][6] ^ d[i][4] ^ d[i][3] ^ d[i][2] ^ d[i][0] ^ c[i][24] ^ c[i][26] ^ c[i][27] ^ c[i][28] ^ c[i][30]: 'd0;
    assign newcrc[i][5]  = i_en ? d[i][7] ^ d[i][6] ^ d[i][5] ^ d[i][4] ^ d[i][3] ^ d[i][1] ^ d[i][0] ^ c[i][24] ^ c[i][25] ^ c[i][27] ^ c[i][28] ^ c[i][29] ^ c[i][30] ^ c[i][31]: 'd0;
    assign newcrc[i][6]  = i_en ? d[i][7] ^ d[i][6] ^ d[i][5] ^ d[i][4] ^ d[i][2] ^ d[i][1] ^ c[i][25] ^ c[i][26] ^ c[i][28] ^ c[i][29] ^ c[i][30] ^ c[i][31]: 'd0;
    assign newcrc[i][7]  = i_en ? d[i][7] ^ d[i][5] ^ d[i][3] ^ d[i][2] ^ d[i][0] ^ c[i][24] ^ c[i][26] ^ c[i][27] ^ c[i][29] ^ c[i][31]: 'd0;
    assign newcrc[i][8]  = i_en ? d[i][4] ^ d[i][3] ^ d[i][1] ^ d[i][0] ^ c[i][0] ^ c[i][24] ^ c[i][25] ^ c[i][27] ^ c[i][28]: 'd0;
    assign newcrc[i][9]  = i_en ? d[i][5] ^ d[i][4] ^ d[i][2] ^ d[i][1] ^ c[i][1] ^ c[i][25] ^ c[i][26] ^ c[i][28] ^ c[i][29]: 'd0;
    assign newcrc[i][10] = i_en ? d[i][5] ^ d[i][3] ^ d[i][2] ^ d[i][0] ^ c[i][2] ^ c[i][24] ^ c[i][26] ^ c[i][27] ^ c[i][29]: 'd0;
    assign newcrc[i][11] = i_en ? d[i][4] ^ d[i][3] ^ d[i][1] ^ d[i][0] ^ c[i][3] ^ c[i][24] ^ c[i][25] ^ c[i][27] ^ c[i][28]: 'd0;
    assign newcrc[i][12] = i_en ? d[i][6] ^ d[i][5] ^ d[i][4] ^ d[i][2] ^ d[i][1] ^ d[i][0] ^ c[i][4] ^ c[i][24] ^ c[i][25] ^ c[i][26] ^ c[i][28] ^ c[i][29] ^ c[i][30]: 'd0;
    assign newcrc[i][13] = i_en ? d[i][7] ^ d[i][6] ^ d[i][5] ^ d[i][3] ^ d[i][2] ^ d[i][1] ^ c[i][5] ^ c[i][25] ^ c[i][26] ^ c[i][27] ^ c[i][29] ^ c[i][30] ^ c[i][31]: 'd0;
    assign newcrc[i][14] = i_en ? d[i][7] ^ d[i][6] ^ d[i][4] ^ d[i][3] ^ d[i][2] ^ c[i][6] ^ c[i][26] ^ c[i][27] ^ c[i][28] ^ c[i][30] ^ c[i][31]: 'd0;
    assign newcrc[i][15] = i_en ? d[i][7] ^ d[i][5] ^ d[i][4] ^ d[i][3] ^ c[i][7] ^ c[i][27] ^ c[i][28] ^ c[i][29] ^ c[i][31]: 'd0;
    assign newcrc[i][16] = i_en ? d[i][5] ^ d[i][4] ^ d[i][0] ^ c[i][8] ^ c[i][24] ^ c[i][28] ^ c[i][29]: 'd0;
    assign newcrc[i][17] = i_en ? d[i][6] ^ d[i][5] ^ d[i][1] ^ c[i][9] ^ c[i][25] ^ c[i][29] ^ c[i][30]: 'd0;
    assign newcrc[i][18] = i_en ? d[i][7] ^ d[i][6] ^ d[i][2] ^ c[i][10] ^ c[i][26] ^ c[i][30] ^ c[i][31]: 'd0;
    assign newcrc[i][19] = i_en ? d[i][7] ^ d[i][3] ^ c[i][11] ^ c[i][27] ^ c[i][31]: 'd0;
    assign newcrc[i][20] = i_en ? d[i][4] ^ c[i][12] ^ c[i][28]: 'd0;
    assign newcrc[i][21] = i_en ? d[i][5] ^ c[i][13] ^ c[i][29]: 'd0;
    assign newcrc[i][22] = i_en ? d[i][0] ^ c[i][14] ^ c[i][24]: 'd0;
    assign newcrc[i][23] = i_en ? d[i][6] ^ d[i][1] ^ d[i][0] ^ c[i][15] ^ c[i][24] ^ c[i][25] ^ c[i][30]: 'd0;
    assign newcrc[i][24] = i_en ? d[i][7] ^ d[i][2] ^ d[i][1] ^ c[i][16] ^ c[i][25] ^ c[i][26] ^ c[i][31]: 'd0;
    assign newcrc[i][25] = i_en ? d[i][3] ^ d[i][2] ^ c[i][17] ^ c[i][26] ^ c[i][27]: 'd0;
    assign newcrc[i][26] = i_en ? d[i][6] ^ d[i][4] ^ d[i][3] ^ d[i][0] ^ c[i][18] ^ c[i][24] ^ c[i][27] ^ c[i][28] ^ c[i][30]: 'd0;
    assign newcrc[i][27] = i_en ? d[i][7] ^ d[i][5] ^ d[i][4] ^ d[i][1] ^ c[i][19] ^ c[i][25] ^ c[i][28] ^ c[i][29] ^ c[i][31]: 'd0;
    assign newcrc[i][28] = i_en ? d[i][6] ^ d[i][5] ^ d[i][2] ^ c[i][20] ^ c[i][26] ^ c[i][29] ^ c[i][30]: 'd0;
    assign newcrc[i][29] = i_en ? d[i][7] ^ d[i][6] ^ d[i][3] ^ c[i][21] ^ c[i][27] ^ c[i][30] ^ c[i][31]: 'd0;
    assign newcrc[i][30] = i_en ? d[i][7] ^ d[i][4] ^ c[i][22] ^ c[i][28] ^ c[i][31]: 'd0;
    assign newcrc[i][31] = i_en ? d[i][5] ^ c[i][23] ^ c[i][29]: 'd0;

    if(i > 0) begin
        assign c[i] = newcrc[i - 1];
    end

    
always@(posedge i_clk,posedge i_rst)
begin
  if(i_rst)
    ro_crc[i] <= 'd0;
  else 
    ro_crc[i] <= ~{
                  newcrc[i][0],newcrc[i][1],newcrc[i][2],newcrc[i][3],newcrc[i][4],newcrc[i][5],newcrc[i][6],newcrc[i][7],
                  newcrc[i][8],newcrc[i][9],newcrc[i][10],newcrc[i][11],newcrc[i][12],newcrc[i][13],newcrc[i][14],newcrc[i][15],
                  newcrc[i][16],newcrc[i][17],newcrc[i][18],newcrc[i][19],newcrc[i][20],newcrc[i][21],newcrc[i][22],newcrc[i][23],
                  newcrc[i][24],newcrc[i][25],newcrc[i][26],newcrc[i][27],newcrc[i][28],newcrc[i][29],newcrc[i][30],newcrc[i][31]
                  };
end
end
endgenerate

    


always@(posedge i_clk,posedge i_rst)
begin
  if(i_rst || !i_en)
    crc <= 32'hffffffff;
  else if(i_en)
    crc <= newcrc[7];
  else 
    crc <= crc;
end

endmodule
