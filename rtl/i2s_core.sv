// Copyright (c) 2023 Beijing Institute of Open Source Chip
// i2s is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "shift_reg.sv"
`include "edge_det.sv"
`include "i2s_define.sv"

module i2s_core (
    input  logic                       clk_i,
    input  logic                       rst_n_i,
    input  logic                       en_i,
    input  logic                       lsb_i,
    input  logic [                1:0] wm_i,
    input  logic [                1:0] fmt_i,
    input  logic [                1:0] chm_i,
    input  logic                       chl_i,
    input  logic [                1:0] dal_i,
    output logic                       busy_o,
    input  logic                       tx_valid_i,
    output logic                       tx_ready_o,
    input  logic [`I2S_DATA_WIDTH-1:0] tx_data_i,
    output logic                       rx_valid_o,
    input  logic                       rx_ready_i,
    output logic [`I2S_DATA_WIDTH-1:0] rx_data_o,
    input  logic                       i2s_sck_i,
    input  logic                       i2s_ws_i,
    output logic                       i2s_sd_o,
    input  logic                       i2s_sd_i
);

  logic [7:0] s_tran_cnt_d, s_tran_cnt_q;
  logic [`I2S_DATA_WIDTH-1:0] s_tx_data;
  logic [               15:0] s_tx_16b_data;
  logic s_tran_done, s_tx_trg, s_rx_trg, s_ws_re_trg, s_ws_fe_trg, s_sck_fe_trg;
  logic s_i2s_16b_sdo, s_i2s_32b_sdo;

  //   assign busy_o        = en_i && ~s_tran_done;
  assign busy_o        = 1'b0;
  assign tx_ready_o    = en_i && s_tran_done;
  assign rx_valid_o    = 1'b0;
  assign rx_data_o     = '0;
  assign i2s_sd_o      = chl_i == `I2S_CHL_16_BITS ? s_i2s_16b_sdo : s_i2s_32b_sdo;
  assign s_tx_16b_data = `I2S_FMT_LSB ? s_tx_data[15:0] : s_tx_data[31:16];
  assign s_tran_done   = ~(|s_tran_cnt_q);

  // tx/rx counter
  always_comb begin
    s_tran_cnt_d = s_tran_cnt_q;
    if (~s_tran_done && en_i) begin
      s_tran_cnt_d = s_tran_cnt_q - 1'b1;
    end else begin
      unique case (chl_i)
        `I2S_CHL_16_BITS: s_tran_cnt_d = 8'd16;
        `I2S_CHL_32_BITS: s_tran_cnt_d = 8'd32;
      endcase
    end
  end
  dffrh #(8) u_tran_cnt_dffrh (
      clk_i,
      rst_n_i,
      s_tran_cnt_d,
      s_tran_cnt_q
  );

  always_comb begin
    s_tx_data = '0;
    unique case (fmt_i)
      `I2S_FMT_LSB: begin
        unique case (chl_i)
          `I2S_CHL_16_BITS: s_tx_data = tx_data_i[15:0];
          `I2S_CHL_32_BITS: s_tx_data = tx_data_i[31:0];
        endcase
      end
      `I2S_FMT_I2S: begin
        unique case (dal_i)
          `I2S_DAL_8_BITS:  s_tx_data[31:24] = tx_data_i[7:0];
          `I2S_DAL_16_BITS: s_tx_data[31:16] = tx_data_i[15:0];
          `I2S_DAL_24_BITS: s_tx_data[31:8] = tx_data_i[23:0];  // only to adopt to CHL 32bits
          `I2S_DAL_32_BITS: s_tx_data[31:0] = tx_data_i[31:0];
        endcase
      end
      `I2S_FMT_MSB: begin
        unique case (dal_i)
          `I2S_DAL_8_BITS:  s_tx_data[31:24] = tx_data_i[7:0];
          `I2S_DAL_16_BITS: s_tx_data[31:16] = tx_data_i[15:0];
          `I2S_DAL_24_BITS: s_tx_data[31:8] = tx_data_i[23:0];
          `I2S_DAL_32_BITS: s_tx_data[31:0] = tx_data_i[31:0];
        endcase
      end
      default: s_tx_data = '0;
    endcase
  end

  edge_det_sync_re #(
      .DATA_WIDTH(1)
  ) u_ws_re (
      clk_i,
      rst_n_i,
      i2s_ws_i,
      s_ws_re_trg
  );

  edge_det_sync_fe #(
      .DATA_WIDTH(1)
  ) u_ws_fe (
      clk_i,
      rst_n_i,
      i2s_ws_i,
      s_ws_fe_trg
  );

  edge_det_sync_fe #(
      .DATA_WIDTH(1)
  ) u_sck_fe (
      clk_i,
      rst_n_i,
      i2s_sck_i,
      s_sck_fe_trg
  );

  assign s_tx_trg = en_i && wm_i == `I2S_WM_SEND && s_sck_fe_trg && ~s_tran_done;
  shift_reg #(
      .DATA_WIDTH(16),
      .SHIFT_NUM (1)
  ) u_i2s_tx_16b_shift_reg (
      .clk_i     (clk_i),
      .rst_n_i   (rst_n_i),
      .type_i    (`SHIFT_REG_TYPE_LOGIC),
      .dir_i     ({1'b0, lsb_i}),
      .ld_en_i   (tx_valid_i && tx_ready_o),
      .sft_en_i  (s_tx_trg),
      .ser_dat_i (1'b0),
      .par_data_i(s_tx_16b_data),
      .ser_dat_o (s_i2s_16b_sdo),
      .par_data_o()
  );

  shift_reg #(
      .DATA_WIDTH(32),
      .SHIFT_NUM (1)
  ) u_i2s_tx_32b_shift_reg (
      .clk_i     (clk_i),
      .rst_n_i   (rst_n_i),
      .type_i    (`SHIFT_REG_TYPE_LOGIC),
      .dir_i     ({1'b0, lsb_i}),
      .ld_en_i   (tx_valid_i && tx_ready_o),
      .sft_en_i  (s_tx_trg),
      .ser_dat_i (1'b0),
      .par_data_i(s_tx_data),
      .ser_dat_o (s_i2s_32b_sdo),
      .par_data_o()
  );

endmodule
