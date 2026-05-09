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
   localparam PTR_WIDTH = $clog2(DEPTH);

   
   input clk, reset, sample_in_valid, next_sample;
   input [7:0] sample_in;
   output [7:0] sample_out;
  
   // FILL HERE
   reg [7:0] stack [DEPTH - 1 : 0]; 
   reg [PTR_WIDTH-1:0] wr_ptr;
   wire [PTR_WIDTH-1:0] wr_ptr_ns;
   reg [PTR_WIDTH-1:0] rd_ptr;
   wire [PTR_WIDTH-1:0] rd_ptr_ns;
   reg [7:0] sample_out_ns;
    
   // integer declaration
   integer i;

   //modules instances
   Lim_Inc #(DEPTH) rd_ptr_inc(.a(rd_ptr), .ci(next_sample && ~sample_in_valid), .sum(rd_ptr_ns), .co());
   Lim_Inc #(DEPTH) wr_ptr_inc(.a(wr_ptr), .ci(sample_in_valid), .sum(wr_ptr_ns), .co());
    
   //always block
   always @(posedge clk) begin
       if(reset)begin
           for (i=0; i < DEPTH; i=i+1) begin
               stack[i] <= 8'b0;
           end
           wr_ptr <= 0;
           rd_ptr <= 0;
           sample_out_ns <= 0;
       end else begin
           if (sample_in_valid)begin 
               stack[wr_ptr] <= sample_in;
               sample_out_ns <= sample_in;
               wr_ptr <= wr_ptr_ns;
               rd_ptr <= wr_ptr;
           end else begin
                   rd_ptr <= rd_ptr_ns;
                   wr_ptr <= wr_ptr_ns;
           end
       end
   end

   assign sample_out = sample_in_valid ? sample_in : stack[rd_ptr];

endmodule
