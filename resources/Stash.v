`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 00:19 AM
// Design Name:     EE3 lab1
// Module Name:     Stash
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     a Stash that stores all the samples in order upon sample_in and sample_in_valid.
//                  It exposes the chosen sample by sample_out and the exposed sample can be changed by next_sample. 
// Dependencies:    Lim_Inc
//
// Revision         1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stash(clk, reset, sample_in, sample_in_valid, next_sample, sample_out);

   parameter DEPTH = 5;
   
   input clk, reset, sample_in_valid, next_sample;
   input [7:0] sample_in;
   output [7:0] sample_out;
  
   // FILL HERE
   reg [7:0] samples [0 : DEPTH-1];  // store samples
   reg [$clog2(DEPTH)-1 : 0] w_ptr;
   reg [$clog2(DEPTH)-1 : 0] r_ptr;
   
   wire [$clog2(DEPTH)-1 : 0] nxt_w_ptr;
   wire [$clog2(DEPTH)-1 : 0] nxt_r_ptr;
   wire w_co;
   wire r_co;
   
   reg [$clog2(DEPTH)-1 : 0] size;
   
   
   Lim_Inc #(.L(DEPTH)) lim_inc_write(
   .a(w_ptr),
   .ci(1'b1),
   .sum(nxt_w_ptr),
   .co(w_co)
   );
   
   Lim_Inc #(.L(DEPTH)) lim_inc_read(
   .a(r_ptr),
   .ci(1'b1),
   .sum(nxt_r_ptr),
   .co(r_co)
   );
   
   integer i;
   always @ (posedge clk) begin
    if (reset) begin
     size <= 0;
     w_ptr <= 0;
     r_ptr <= 0;
     for (i=0; i< DEPTH; i=i+1) samples[i] <= 0;
    end else begin
     if(sample_in_valid) begin
      samples[w_ptr] <= sample_in;
      r_ptr <= w_ptr;
      w_ptr <= nxt_w_ptr;
      if (size < DEPTH) size <= size + 1;
      
     end else if (next_sample && (size > 0)) begin
       if(nxt_r_ptr < r_ptr || size == DEPTH) r_ptr <= nxt_r_ptr;
       else r_ptr <= 0;
     end 
    end
   end
   
   assign sample_out = (sample_in_valid)? sample_in : samples[r_ptr];
endmodule
