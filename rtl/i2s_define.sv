// Copyright (c) 2023 Beijing Institute of Open Source Chip
// i2s is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_I2S_DEF_SV
`define INC_I2S_DEF_SV

/* register mapping
 * I2S_CTRL:
 * BITS:   | 31:3 | 2   | 1  | 0    |
 * FIELDS: | RES  | CLR | EN | OVIE |
 * PERMS:  | NONE | RW  | RW | RW   |
 * ----------------------------------
 * I2S_PSCR:
 * BITS:   | 31:16 | 15:0 |
 * FIELDS: | RES   | PSCR |
 * PERMS:  | NONE  | RW   |
 * ----------------------------------
 * I2S_STAT:
 * BITS:   | 31:1  | 0    |
 * FIELDS: | RES   | OVIF |
 * PERMS:  | NONE  | R    |
 * ----------------------------------
*/

interface i2s_if (
    logic aud_clk_i,
    logic aud_rst_n_i
);
  logic mclk_o;
  logic sck_o;
  logic ws_o;
  logic sd_o;
  logic sd_i;
  logic irq_o;
endinterface
`endif
