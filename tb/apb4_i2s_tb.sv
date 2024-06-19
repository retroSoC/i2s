// Copyright (c) 2023 Beijing Institute of Open Source Chip
// i2s is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "apb4_if.sv"
`include "gpio_pad.sv"
`include "i2s_define.sv"

module apb4_i2s_tb ();
  localparam real CLK_PEROID = 81.38;  // ~12.288M just for sim

  logic rst_n_i, clk_i;
  wire s_i2s_sck_pad, s_i2s_ws_pad;

  initial begin
    clk_i = 1'b0;
    forever begin
      #(CLK_PEROID / 2) clk_i <= ~clk_i;
    end
  end

  task sim_reset(int delay);
    rst_n_i = 1'b0;
    repeat (delay) @(posedge clk_i);
    #1 rst_n_i = 1'b1;
  endtask

  initial begin
    sim_reset(40);
  end

  apb4_if u_apb4_if (
      clk_i,
      rst_n_i
  );

  i2s_if u_i2s_if ();


  tri_pd_pad_h u_i2s_sck_pad (
      .i_i   (u_i2s_if.sck_o),
      .oen_i (u_i2s_if.sck_en_o),
      .ren_i (),
      .c_o   (u_i2s_if.sck_i),
      .pad_io(s_i2s_sck_pad)
  );
  tri_pd_pad_h u_i2s_ws_pad (
      .i_i   (u_i2s_if.ws_o),
      .oen_i (u_i2s_if.ws_en_o),
      .ren_i (),
      .c_o   (u_i2s_if.ws_i),
      .pad_io(s_i2s_ws_pad)
  );

  test_top u_test_top (
      .apb4(u_apb4_if.master),
      .i2s (u_i2s_if.tb)
  );
  apb4_i2s u_apb4_i2s (
      .apb4(u_apb4_if.slave),
      .i2s (u_i2s_if.dut)
  );

  mic u_mic (
      .sck_i(s_i2s_sck_pad),
      .ws_i (s_i2s_ws_pad),
      .sd_o (u_i2s_if.sd_i)
  );

endmodule
