// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2019 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0

module t (/*AUTOARG*/
   // Inputs
   clk
   );
   input clk;

   integer      cyc = 0;
   reg [63:0]   crc;
   reg [63:0]   sum;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [63:0]          result;                 // From test of Test.v
   // End of automatics
   Test test (.*);

   // Test loop
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n", $time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63] ^ crc[2] ^ crc[0]};
      sum <= result ^ {sum[62:0], sum[63] ^ sum[2] ^ sum[0]};
      if (cyc==0) begin
         // Setup
         crc <= 64'h5aef0c8d_d70a4497;
         sum <= '0;
      end
      else if (cyc<10) begin
         sum <= '0;
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
         $write("[%0t] cyc==%0d crc=%x sum=%x\n", $time, cyc, crc, sum);
         if (crc !== 64'hc77bb9b3784ea091) $stop;
         // What checksum will we end up with (above print should match)
`define EXPECTED_SUM 64'hd55eb7da9ba3354a
         if (sum !== `EXPECTED_SUM) $stop;
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end

endmodule

module Test
  (
   input              clk,
   input [63:0]       crc,
   input [31:0]       cyc,
   output wire [63:0] result);

   wire         enable = crc[32];
   wire [7:0]  d = crc[7:0];


   logic [7:0] d0_r;
   always @(d iff enable) begin
      d0_r <= d;
   end

   logic [7:0] d1_r;
   always @(posedge d iff enable) begin
      d1_r <= d;
   end

   logic [7:0] d2_r;
   always @(negedge d iff enable) begin
      d2_r <= d;
   end

   logic [7:0] d3_r;
   always @(edge d iff enable) begin
      d3_r <= d;
   end

   wire reset = (cyc < 10);
   assert property (@(posedge clk iff enable)
                    disable iff (reset)
                    (crc != '0));

   // Aggregate outputs into a single result vector
   assign result = {32'h0, d3_r, d2_r, d1_r, d0_r};

endmodule
