`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 00:19 AM
// Design Name:     EE3 lab1
// Module Name:     Counter
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     a counter that advances its reading as long as time_reading 
//                  signal is high and zeroes its reading upon init_regs=1 input.
//                  the time_reading output represents: 
//                  {dekaseconds,seconds}
// Dependencies:    Lim_Inc
//
// Revision         3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Counter(clk, init_regs, count_enabled, time_reading);

   parameter CLK_FREQ = 100000000;// in Hz
   
   input clk, init_regs, count_enabled;
   output [7:0] time_reading;

   reg [$clog2(CLK_FREQ)-1:0] clk_cnt;
   reg [3:0] ones_seconds;    
   reg [3:0] tens_seconds;      
   
   wire co_sec;
   wire [3:0] sum_sec;
   wire co_tsec;
   wire [3:0] sum_tsec;
   wire tick_1hz;
   wire [$clog2(CLK_FREQ)-1:0] clk_cnt_sum;
   
  
   // FILL HERE THE LIMITED-COUNTER INSTANCES
   Lim_Inc #(.L(10)) Lim_Inc_sec(.a(ones_seconds), 
   .ci(tick_1hz & count_enabled), 
   .sum(sum_sec), .co(co_sec)
   );
   Lim_Inc #(.L(10)) Lim_Inc_tsec(.a(tens_seconds), 
   .ci(co_sec & count_enabled), 
   .sum(sum_tsec), 
   .co(co_tsec)
   );
   Lim_Inc #(.L(CLK_FREQ)) Lim_Inc(.a(clk_cnt), 
   .ci(1'b1), 
   .sum(clk_cnt_sum), 
   .co(tick_1hz)
   );

   always @(posedge clk)
     begin
		if (init_regs) begin
		  ones_seconds <= 4'b0;
		  tens_seconds <= 4'b0;
		  clk_cnt      <= 0;
		end else if (count_enabled) begin
		  clk_cnt <= clk_cnt_sum;
		  if (tick_1hz) begin
		      ones_seconds <= sum_sec;
		      tens_seconds <= sum_tsec;
		  end
		end
     end
     
     assign time_reading = {tens_seconds, ones_seconds};

endmodule