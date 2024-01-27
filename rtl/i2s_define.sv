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
 * BITS:   | 31:22 | 21:18 | 17:13 | 12:11 | 10:9 | 8:7 | 6   | 5   | 4   | 3   | 2    | 1    | 0  |
 * FIELDS: | RES   | RXTH  | TXTH  | CH    | FMT  | WM  | LSB | POL | MSR | CLR | RXIE | TXIE | EN |
 * PERMS:  | NONE  | RW    | RW    | RW    | RW   | RW  | RW  | RW  | RW  | RW  | RW   | RW   | RW |
 * ---------------------------------------------------------
 * I2S_PSCR:
 * BITS:   | 31:16 | 15:0 |
 * FIELDS: | RES   | PSCR |
 * PERMS:  | NONE  | RW   |
 * -----------------------------------
 * I2S_TXR:
 * BITS:   | 31:0   |
 * FIELDS: | TXDATA |
 * PERMS:  | W      |
 * ----------------------------------
 * I2S_RXR:
 * BITS:   | 31:0   |
 * FIELDS: | RXDATA |
 * PERMS:  | R      |
 * ----------------------------------
 * I2S_STAT:
 * BITS:   | 31:5 | 4    | 3    | 2    | 1    | 0    |
 * FIELDS: | RES  | RETY | TFUL | BUSY | RXIF | TXIF |
 * PERMS:  | NONE | R    | R    | R    | R    | R    |
 * ----------------------------------
*/

// verilog_format: off
`define I2S_CTRL 4'b0000 // BASEADDR + 0x00
`define I2S_PSCR 4'b0001 // BASEADDR + 0x04
`define I2S_TXR  4'b0010 // BASEADDR + 0x08
`define I2S_RXR  4'b0011 // BASEADDR + 0x0C
`define I2S_STAT 4'b0100 // BASEADDR + 0x10

`define I2S_CTRL_ADDR {26'b00, `I2S_CTRL, 2'b00}
`define I2S_PSCR_ADDR {26'b00, `I2S_PSCR, 2'b00}
`define I2S_TXR_ADDR  {26'b00, `I2S_TXR , 2'b00}
`define I2S_RXR_ADDR  {26'b00, `I2S_RXR , 2'b00}
`define I2S_STAT_ADDR {26'b00, `I2S_STAT, 2'b00}

`define I2S_CTRL_WIDTH 22
`define I2S_PSCR_WIDTH 16
`define I2S_TXR_WIDTH  32
`define I2S_RXR_WIDTH  32
`define I2S_STAT_WIDTH 5

`define I2S_WM_SEND 2'b00
`define I2S_WM_RECV 2'b01
`define I2S_WM_TEST 2'b10

`define I2S_FMT_I2S 2'b00
`define I2S_FMT_MSB 2'b01
`define I2S_FMT_LSB 2'b10

`define I2S_CH_STERO 2'b00
`define I2S_CH_LEFT  2'b01
`define I2S_CH_RIGHT 2'b10
// verilog_format: on

interface i2s_if (
    logic aud_clk_i,
    logic aud_rst_n_i
);
  logic mclk_o;
  logic sck_o;
  logic sck_i;
  logic sck_en_o,
  logic ws_o;
  logic ws_i;
  logic ws_en_o;
  logic sd_o;
  logic sd_i;
  logic irq_o;
endinterface
`endif
