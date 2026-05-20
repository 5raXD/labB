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
 
    wire reset, trig, split, toggle, sample;
    wire init_regs, count_enabled;
    wire trig_ctl, split_ctl;
    wire [7:0] time_reading;
    wire [7:0] stash_out;
    wire [7:0] time_out;
 
    reg selected;
    reg split_active;
    reg [7:0] snapshot;
 
    Debouncer #(.COUNTER_BITS(20)) deb_reset  (.clk(clk), .input_unstable(btnC), .output_stable(reset));
    Debouncer #(.COUNTER_BITS(20)) deb_trig   (.clk(clk), .input_unstable(btnU), .output_stable(trig));
    Debouncer #(.COUNTER_BITS(20)) deb_split  (.clk(clk), .input_unstable(btnR), .output_stable(split));
    Debouncer #(.COUNTER_BITS(20)) deb_toggle (.clk(clk), .input_unstable(btnL), .output_stable(toggle));
    Debouncer #(.COUNTER_BITS(20)) deb_sample (.clk(clk), .input_unstable(btnD), .output_stable(sample));
 
    assign trig_ctl  = (~selected) ? trig  : 1'b0;
    assign split_ctl = (~selected) ? split : 1'b0;
 
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
        .time_reading(time_reading)
    );
 
    Stash #(.DEPTH(5)) stash(
        .clk(clk),
        .reset(reset),
        .sample_in(time_reading),
        .sample_in_valid(sample),
        .next_sample(selected ? trig : 1'b0),
        .sample_out(stash_out)
    );
 
    Seg_7_Display display(
        .x({time_out, stash_out}),
        .clk(clk),
        .clr(reset),
        .a_to_g(seg),
        .an(an),
        .dp(dp)
    );
 
    always @(posedge clk) begin
        if (reset)
            selected <= 1'b0;
        else if (toggle)
            selected <= ~selected;
    end
 
    always @(posedge clk) begin
        if (reset || init_regs) begin
            split_active <= 1'b0;
            snapshot     <= 8'h00;
        end else if (count_enabled && split_ctl) begin
            snapshot     <= time_reading;
            split_active <= 1'b1;
        end else if (~count_enabled) begin
            split_active <= 1'b0;
        end
    end
 
    assign time_out  = split_active ? snapshot : time_reading;
    assign led_left  = {3{~selected}};
    assign led_right = {3{selected}};
 
endmodule
