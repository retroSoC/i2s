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

module i2s_core (
    input  logic                       clk_i,
    input  logic                       rst_n_i,
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
endmodule
