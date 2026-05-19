`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 01:28AM
// Design Name:     EE3 lab1
// Module Name:     Stopwatch
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     Top module of the stopwatch circuit. Displays 2 independent 
//                  stopwatches on the 4 digits of the 7-segment component.
//                  Uses btnC as reset, btnU as trigger, and btnR as split button to
//                  control the currently selected stopwatch.
//                  Pressing btnL at any time - toggles the selection between the 
//                  left hand side (LHS) and the RHS stopwatches.
//                  The stopwatch's time reading is outputted using an, seg and dp signals
//                  that should be connected to the 4-digit-7-segment display and driven
//                  by 100MHz clock. 
// Dependencies:    Debouncer, Ctl, Counter, Seg_7_Display
//
// Revision:        3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stopwatch(clk, btnC, btnU, btnR, btnL, btnD, seg, an, dp, led_left, led_right);

    input              clk, btnC, btnU, btnR, btnL, btnD;
    output  wire [6:0] seg;
    output  wire [3:0] an;
    output  wire       dp; 
    output  wire [2:0] led_left;
    output  wire [2:0] led_right;

    wire [15:0] time_reading;
    wire trig, split, reset, toggle, sample; // button inputs - stable
    
//    wire trig_right, split_right, init_regs_right, count_enabled_right;
//    wire trig_left, split_left, init_regs_left, count_enabled_left;
    
    // time values
    wire [7:0] time_reading_counter;
    wire [7:0] time_reading_stash;

    reg selected_stopwatch = 1'b0; // 0 for stopWatch, 1 for stash
    wire init_regs, count_enabled; // control signals
    
    //snapshot
    reg [7:0] snapshot;
    reg split_active;
    wire trig_ctl, split_ctl;
    wire [7:0] counter2display;
    
    
	// FILL HERE INSTANTIATIONS 
	
	// Internal Assigns
	assign time_reading =  16'h0000 | {counter2display, time_reading_stash};
	assign counter2display = split_active? snapshot : time_reading_counter;
	assign trig_ctl  = (selected_stopwatch == 1'b0) ? trig  : 1'b0;
	assign split_ctl = (selected_stopwatch == 1'b0) ? split : 1'b0;
	
	
	// Buttons Stabilization
	Debouncer #(.COUNTER_BITS(20)) debounce_reset(
	.clk(clk),
	.input_unstable(btnC),
	.output_stable(reset)
	);
	
	Debouncer #(.COUNTER_BITS(20)) debounce_trigger(
	.clk(clk),
	.input_unstable(btnU),
	.output_stable(trig)
	);
	
	Debouncer #(.COUNTER_BITS(20)) debounce_split(
	.clk(clk),
	.input_unstable(btnR),
	.output_stable(split)
	);
	
	Debouncer #(.COUNTER_BITS(20)) debounce_toggle(
	.clk(clk),
	.input_unstable(btnL),
	.output_stable(toggle)
	);
	
	Debouncer #(.COUNTER_BITS(20)) debounce_btnD(
	.clk(clk),
	.input_unstable(btnD),
	.output_stable(sample)
	);
	
	Ctl control(
	.clk(clk), 
	.reset(reset),
	.trig(trig_ctl),
	.split(split_ctl), 
	.init_regs(init_regs), 
	.count_enabled(count_enabled)
	);
	
	Counter #(.CLK_FREQ(100000000)) counter(
	.clk(clk), 
	.init_regs(init_regs), 
	.count_enabled(count_enabled), 
	.time_reading(time_reading_counter)
	);
	
	Stash #(.DEPTH(5)) stash(
	.clk(clk), 
	.reset(reset), 
	.sample_in(time_reading_counter), 
	.sample_in_valid(sample), 
	.next_sample(selected_stopwatch? trig : 1'b0), // if in stash mode btnU is next_sample
	.sample_out(time_reading_stash)
	);
	
	Seg_7_Display seg_7(
	.x(time_reading),
	.clk(clk),
	.clr(reset),
	.a_to_g(seg),
	.an(an),
	.dp(dp)
	);
	
	always @ (posedge clk) begin  // toggle mode: stopWatch/stash
	 if(reset) selected_stopwatch <= 0;
	 else if(toggle) selected_stopwatch <= ~selected_stopwatch;
	end
	
	always @(posedge clk) begin
	 if(reset) begin
	  split_active <= 1'b0;
	  snapshot <= 8'h00;
	 end else begin
	  if(trig_ctl) split_active <= 1'b0; // PAUSE + trig press
	  else if(count_enabled && split_ctl) begin 
	   snapshot <= time_reading_counter;
	   split_active <= 1'b1;
	  end
	  
	 end
	end
	
	assign led_left  = (selected_stopwatch == 1'b0) ? 3'b111 : 3'b000; // stopwatch
    assign led_right = (selected_stopwatch == 1'b1) ? 3'b111 : 3'b000; // stash

endmodule
