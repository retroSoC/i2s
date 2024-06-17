// Copyright (c) 2023 Beijing Institute of Open Source Chip
// i2s is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_I2S_TEST_SV
`define INC_I2S_TEST_SV

`include "apb4_master.sv"
`include "i2s_define.sv"

class I2STest extends APB4Master;
  string                 name;
  int                    wr_val;
  virtual apb4_if.master apb4;
  virtual i2s_if.tb      i2s;

  extern function new(string name = "i2s_test", virtual apb4_if.master apb4, virtual i2s_if.tb i2s);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_clk_div(input bit [31:0] run_times = 10);
  extern task automatic test_send(input bit [31:0] run_times = 10);
  extern task automatic test_irq(input bit [31:0] run_times = 10);
endclass

function I2STest::new(string name, virtual apb4_if.master apb4, virtual i2s_if.tb i2s);
  super.new("apb4_master", apb4);
  this.name   = name;
  this.wr_val = 0;
  this.apb4   = apb4;
  this.i2s    = i2s;
endfunction

task automatic I2STest::test_reset_reg();
  super.test_reset_reg();
  // verilog_format: off
  this.rd_check(`I2S_CTRL_ADDR, "CTRL REG", 32'b0 & {`I2S_CTRL_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`I2S_DIV_ADDR, "DIV REG", 32'b0 & {`I2S_DIV_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  // verilog_format: on
endtask

task automatic I2STest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    this.wr_rd_check(`I2S_CTRL_ADDR, "CTRL REG", $random & {`I2S_CTRL_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`I2S_DIV_ADDR, "DIV REG", $random & {`I2S_DIV_WIDTH{1'b1}}, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic I2STest::test_clk_div(input bit [31:0] run_times = 10);
  $display("=== [test i2s clk div] ===");
  repeat (2000 * 6) @(posedge this.apb4.pclk);
  this.write(`I2S_CTRL_ADDR, 32'b0);
  this.write(`I2S_DIV_ADDR, 32'd1);
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`I2S_CTRL_ADDR, 32'b0_0001);
endtask

task automatic I2STest::test_send(input bit [31:0] run_times = 10);
  $display("=== [test i2s send] ===");
  repeat (200 * 6) @(posedge this.apb4.pclk);
  this.write(`I2S_CTRL_ADDR, 32'b0);
  this.write(`I2S_DIV_ADDR, 32'd1); // just for test
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`I2S_CTRL_ADDR, 32'b0_0001);
  repeat (50) @(posedge this.apb4.pclk);
  this.write(`I2S_TXR_ADDR, 32'b1011);
endtask

task automatic I2STest::test_irq(input bit [31:0] run_times = 10);
  super.test_irq();
endtask
`endif
