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
    input  logic [                1:0] chl_i,
    output logic                       busy_o,
    output logic                       chd_o,
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

  logic s_ws_d, s_ws_q, s_sck_re, s_ws_re, s_ws_fe;
  logic s_chd_d, s_chd_q;
  logic s_i2s_fsm_d, s_i2s_fsm_q;

  logic [3:0] s_sd;

  assign busy_o     = tx_valid_i && tx_ready_o;
  assign chd_o      = s_chd_q;
  assign rx_valid_o = '0;
  assign rx_data_o  = '0;

  always_comb begin
    s_chd_d = s_chd_q;
    if (s_ws_re) s_chd_d = 1'b1;
    else if (s_ws_fe) s_chd_d = 1'b0;
  end
  dffr #(1) u_chd_dffr (
      clk_i,
      rst_n_i,
      s_chd_d,
      s_chd_q
  );

  always_comb begin
    s_i2s_fsm_d = s_i2s_fsm_q;
    if (~tx_valid_i) begin
      s_i2s_fsm_d = `I2S_FSM_IDLE;
    end else if (tx_valid_i && tx_ready_o) begin  // after first trans
      s_i2s_fsm_d = `I2S_FSM_BUSY;
    end
  end
  dffr #(1) u_i2s_fsm_dffr (
      clk_i,
      rst_n_i,
      s_i2s_fsm_d,
      s_i2s_fsm_q
  );

  assign s_ws_d = i2s_ws_i;
  dffr #(1) u_ws_dffr (
      i2s_sck_i,
      rst_n_i,
      s_ws_d,
      s_ws_q
  );

  edge_det_sync_re #(
      .DATA_WIDTH(1)
  ) u_sck_edge_det_sync_re (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .dat_i  (i2s_sck_i),
      .re_o   (s_sck_re)
  );

  edge_det_sync #(
      .DATA_WIDTH(1)
  ) u_ws_edge_det_sync (
      .clk_i  (i2s_sck_i),
      .rst_n_i(rst_n_i),
      .dat_i  (s_ws_q),
      .re_o   (s_ws_re),
      .fe_o   (s_ws_fe)
  );

  always_comb begin
    unique case (s_i2s_fsm_q)
      `I2S_FSM_IDLE: tx_ready_o = s_ws_fe;
      `I2S_FSM_BUSY: tx_ready_o = s_ws_re | s_ws_fe;
      default:       tx_ready_o = s_ws_fe;
    endcase
  end
  for (genvar i = 1; i <= 4; i++) begin : I2S_TX_SHIFT_ONE_BLOCK
    shift_reg #(
        .DATA_WIDTH(8 * i),
        .SHIFT_NUM (1)
    ) u_i2s_tx_shift_reg (
        .clk_i     (clk_i),
        .rst_n_i   (rst_n_i),
        .type_i    (`SHIFT_REG_TYPE_LOGIC),
        .dir_i     ({1'b0, lsb_i}),
        .ld_en_i   (tx_valid_i && tx_ready_o),                          // BUG:
        .sft_en_i  (s_sck_re),
        .ser_dat_i (1'b0),
        .par_data_i(tx_data_i[`I2S_DATA_WIDTH-1:`I2S_DATA_WIDTH-8*i]),
        .ser_dat_o (s_sd[i-1]),
        .par_data_o()
    );
  end

  always_comb begin
    unique case (chl_i)
      `I2S_DAT_8_BITS:  i2s_sd_o = s_sd[0];
      `I2S_DAT_16_BITS: i2s_sd_o = s_sd[1];
      `I2S_DAT_24_BITS: i2s_sd_o = s_sd[2];
      `I2S_DAT_32_BITS: i2s_sd_o = s_sd[3];
      default:          i2s_sd_o = s_sd[0];
    endcase
  end

endmodule
