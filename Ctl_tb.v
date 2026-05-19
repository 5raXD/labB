`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Ctl_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bennch for the control.
// Dependencies:    None
//
// Revision: 		3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Ctl_tb();
 
    reg clk, reset, trig, split, correct, loop_was_skipped;
    wire init_regs, count_enabled;
    //integer ai,cii;
    
    // Internal state access for checking
    wire [2:0] state;
    localparam IDLE = 3'b001, COUNTING = 3'b010, PAUSED = 3'b100;
    assign state = uut.state;
    
    // Instantiate the UUT (Unit Under Test)
    Ctl uut(
        .clk(clk),
        .reset(reset),
        .trig(trig),
        .split(split),
        .init_regs(init_regs),
        .count_enabled(count_enabled)
    );
    
    initial begin
        correct = 1;
        clk = 0; 
        reset = 1; 
        trig = 0;
        split = 0;
        #10
        reset = 0; 
        correct = correct & init_regs & ~count_enabled;
        #20

        #10;
 
        // IDLE -> COUNTING (01*/10): assert trig
        trig = 1;
        #10;
        trig = 0;
        #10;

        // COUNTING self-loop (00*/01): no inputs, stay COUNTING
        #10;

        // COUNTING -> PAUSED (01*/00): assert trig
        trig = 1;
        #10;
        trig = 0;
        #10;

        // PAUSED self-loop (000/00): no inputs, stay PAUSED
        #10;

        // PAUSED -> COUNTING (01*/01): assert trig
        trig = 1;
        #10;
        trig = 0;
        #10;

        // Reset from COUNTING (1**/01 -> IDLE): assert reset
        reset = 1;
        #10;
        reset = 0;
        #10;

        // PAUSED -> IDLE via split (001/00):
        trig = 1; #10; trig = 0; #10;
        trig = 1; #10; trig = 0; #10;
        split = 1;
        #10;
        split = 0;
        #10;

        // Reset from PAUSED (1**/00 -> IDLE):
        trig = 1; #10; trig = 0; #10;
        trig = 1; #10; trig = 0; #10;
        reset = 1;
        #10;
        reset = 0;
        #10;

        // Reset from IDLE (1**/10 -> IDLE): self-loop via reset
        reset = 1;
        #10;
        reset = 0;
        #10;

 
        // IDLE self-loop with split asserted (00*/10 -> IDLE):
        split = 1;
        #10;
        split = 0;
        #10;

 
        // COUNTING self-loop with split (00*/01):
        trig = 1; #10; trig = 0; #10;  // IDLE -> COUNTING
        split = 1;
        #10;
        split = 0;
        #10;
 
        #10        
        
          
        if (correct)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
    
endmodule