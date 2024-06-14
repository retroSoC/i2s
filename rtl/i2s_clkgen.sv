// Copyright (c) 2023 Beijing Institute of Open Source Chip
// i2s is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "i2s_define.sv"

// MCLK(clk_i) / LRCK(ws_o) is constant value(256, 384, 512, 768, 1024)
// first left chnl(ws=0), second right chnl(ws=1)
module i2s_clkgen (
    input  logic                      clk_i,
    input  logic                      rst_n_i,
    input  logic                      en_i,
    input  logic                      pol_i,
    input  logic [               1:0] chl_i,
    input  logic [`I2S_DIV_WIDTH-1:0] div_i,
    output logic                      sck_o,
    output logic                      ws_o
);

  logic [`I2S_DIV_WIDTH-1:0] s_sck_cnt_d, s_sck_cnt_q;
  logic [7:0] s_ws_cnt_d, s_ws_cnt_q;
  logic s_sck_d, s_sck_q;
  logic s_ws_d, s_ws_q;
  logic s_sck_cnt_zero, s_ws_cnt_zero;

  assign sck_o          = s_sck_q;
  assign ws_o           = s_ws_q;
  assign s_sck_cnt_zero = s_sck_cnt_q == '0;
  assign s_ws_cnt_zero  = s_ws_cnt_q == '0;

  assign s_sck_cnt_d    = (~en_i || s_sck_cnt_zero) ? div_i : s_sck_cnt_q - 1'b1;
  dffr #(`I2S_DIV_WIDTH) u_sck_cnt_dffr (
      clk_i,
      rst_n_i,
      s_sck_cnt_d,
      s_sck_cnt_q
  );

  always_comb begin
    s_sck_d = s_sck_q;
    if (~en_i) begin
      s_sck_d = pol_i;
    end else if (en_i && s_sck_cnt_zero) begin
      s_sck_d = ~s_sck_q;
    end
  end
  dffr #(1) u_sck_dffr (
      clk_i,
      rst_n_i,
      s_sck_d,
      s_sck_q
  );

  always_comb begin
    s_ws_cnt_d = s_ws_cnt_q;
    if (~en_i || s_ws_cnt_zero) begin
      unique case (chl_i)
        `I2S_CHL_8_BITS:  s_ws_cnt_d = 8'd31;
        `I2S_CHL_16_BITS: s_ws_cnt_d = 8'd63;
        `I2S_CHL_24_BITS: s_ws_cnt_d = 8'd95;
        `I2S_CHL_32_BITS: s_ws_cnt_d = 8'd127;
        default:          s_ws_cnt_d = 8'd31;
      endcase
    end else begin
      s_ws_cnt_d = s_ws_cnt_q - 1'b1;
    end
  end
  dffr #(8) u_ws_cnt_dffr (
      clk_i,
      rst_n_i,
      s_ws_cnt_d,
      s_ws_cnt_q
  );

  always_comb begin
    s_ws_d = s_ws_q;
    if (~en_i) begin
      s_ws_d = ~pol_i;
    end else if (en_i && s_ws_cnt_zero) begin
      s_ws_d = ~s_ws_q;
    end
  end
  dffr #(1) u_ws_dffr (
      clk_i,
      rst_n_i,
      s_ws_d,
      s_ws_q
  );

endmodule
