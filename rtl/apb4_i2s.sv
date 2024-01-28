// Copyright (c) 2023 Beijing Institute of Open Source Chip
// i2s is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "register.sv"
`include "fifo.sv"
`include "i2s_define.sv"

module apb4_i2s #(
    parameter int FIFO_DEPTH     = 64,
    parameter int LOG_FIFO_DEPTH = $clog2(FIFO_DEPTH)
) (
    apb4_if.slave apb4,
    i2s_if.dut    i2s
);

  logic [3:0] s_apb4_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  logic [`I2S_CTRL_WIDTH-1:0] s_i2s_ctrl_d, s_i2s_ctrl_q;
  logic s_i2s_ctrl_en;
  logic [`I2S_DIV_WIDTH-1:0] s_i2s_div_d, s_i2s_div_q;
  logic s_i2s_div_en;
  logic [`I2S_STAT_WIDTH-1:0] s_i2s_stat_d, s_i2s_stat_q;
  // bit
  logic s_bit_en, s_bit_txie, s_bit_rxie, s_bit_clr, s_bit_msr;
  logic s_bit_pol, s_bit_lsb, s_bit_chl;
  logic [1:0] s_bit_wm, s_bit_fmt, s_bit_chm, s_bit_dal;
  logic [4:0] s_bit_txth, s_bit_rxth;
  logic s_bit_txif, s_bit_rxif, s_busy;

  assign s_apb4_addr     = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready     = 1'b1;
  assign apb4.pslverr    = 1'b0;

  assign s_bit_en        = s_i2s_ctrl_q[0];
  assign s_bit_txie      = s_i2s_ctrl_q[1];
  assign s_bit_rxie      = s_i2s_ctrl_q[2];
  assign s_bit_clr       = s_i2s_ctrl_q[3];
  assign s_bit_msr       = s_i2s_ctrl_q[4];
  assign s_bit_pol       = s_i2s_ctrl_q[5];
  assign s_bit_lsb       = s_i2s_ctrl_q[6];
  assign s_bit_wm        = s_i2s_ctrl_q[8:7];
  assign s_bit_fmt       = s_i2s_ctrl_q[10:9];
  assign s_bit_chm       = s_i2s_ctrl_q[12:11];
  assign s_bit_chl       = s_i2s_ctrl_q[13];
  assign s_bit_dal       = s_i2s_ctrl_q[15:14];
  assign s_bit_txth      = s_i2s_ctrl_q[20:16];
  assign s_bit_rxth      = s_i2s_ctrl_q[25:21];
  assign s_bit_txif      = s_i2s_stat_q[0];
  assign s_bit_rxif      = s_i2s_stat_q[1];
  assign s_busy          = 1'b0;  // TODO:

  assign s_i2s_ctrl_en   = s_apb4_wr_hdshk && s_apb4_addr == `I2S_CTRL && ~s_busy;
  assign s_i2s_ctrl_d    = s_i2s_ctrl_en ? apb4.pwdata[`I2S_CTRL_WIDTH-1:0] : s_i2s_ctrl_q;
  dffer #(`I2S_CTRL_WIDTH) u_i2s_ctrl_dffer (
      apb4.pclk,
      apb4.presetn,
      s_i2s_ctrl_en,
      s_i2s_ctrl_d,
      s_i2s_ctrl_q
  );

  assign s_i2s_div_en = s_apb4_wr_hdshk && s_apb4_addr == `I2S_DIV && ~s_busy;
  assign s_i2s_div_d  = s_i2s_div_en ? apb4.pwdata[`I2S_DIV_WIDTH-1:0] : s_i2s_div_q;
  dffer #(`I2S_DIV_WIDTH) u_i2s_div_dffer (
      apb4.pclk,
      apb4.presetn,
      s_i2s_div_en,
      s_i2s_div_d,
      s_i2s_div_q
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `I2S_CTRL: apb4.prdata[`I2S_CTRL_WIDTH-1:0] = s_i2s_ctrl_q;
        `I2S_DIV:  apb4.prdata[`I2S_DIV_WIDTH-1:0] = s_i2s_div_q;
        default:   apb4.prdata = '0;
      endcase
    end
  end
endmodule
