// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// i2s is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "setting.sv"

module mic #(
    parameter int DATA_WIDTH = 24
) (
    input  logic sck_i,
    input  logic ws_i,
    output logic sd_o
);

  reg [DATA_WIDTH-1:0] r_right_chnl_dat = '0;
  reg [DATA_WIDTH-1:0] r_left_chnl_dat = '0;

  always @(negedge ws_i) r_left_chnl_dat <= #`REGISTER_DELAY $random;
  always @(posedge ws_i) r_right_chnl_dat <= #`REGISTER_DELAY $random;

  always @(posedge sck_i)
    if (~ws_i) begin
      sd_o            <= #`REGISTER_DELAY r_left_chnl_dat[DATA_WIDTH-1];
      r_left_chnl_dat <= #`REGISTER_DELAY r_left_chnl_dat << 1;
    end else begin
      sd_o             <= #`REGISTER_DELAY r_right_chnl_dat[DATA_WIDTH-1];
      r_right_chnl_dat <= #`REGISTER_DELAY r_right_chnl_dat << 1;
    end

endmodule
