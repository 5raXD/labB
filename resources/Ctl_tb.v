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

    reg clk, reset, trig, split, correct/*, loop_was_skipped*/;
    wire init_regs, count_enabled;
    integer i,j,sync;
    wire [2:0] state;
    reg [2:0] exp_state;
    localparam IDLE  = 3'b001, COUNTING = 3'b010, PAUSED = 3'b100 ;
    // drive state wire 
    assign state = uut.state;
    // calc exp_state at next clk edge and keep the past value for 1ns after clkedge to check if state wire was driven correctly
    // change inputs only at negedges 
    always @(negedge clk)
     begin
        if (reset) begin
          exp_state = IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (trig) exp_state = COUNTING;
                end 
                
                COUNTING: begin
                    if (trig) exp_state = PAUSED;
                end 
                
                PAUSED: begin
                    if (trig) begin 
                    exp_state = COUNTING;
                    end else if (split) begin 
                    exp_state = IDLE;
                    end
                end 
                
                default: begin 
                    exp_state = IDLE;
                end 
           
            endcase
        end                        
     end
     
        
        
    // Instantiate and connect the UUT (Unit Under Test)
    Ctl uut(
    .clk(clk), 
    .reset(reset), 
    .trig(trig), 
    .split(split), 
    .init_regs(init_regs), 
    .count_enabled(count_enabled)
    );    
    initial begin // posedges on : 5,15,25,35,...
        sync = 0;
        correct = 1;
        clk = 0; 
        reset = 1;
        trig = 0;
        split = 0;
        #10
        reset = 0; 
        correct = correct & init_regs & ~count_enabled;
        #20
        for (i=0; i < 2; i = i + 1) begin
          for (j=0; j < 2; j = j + 1) begin
           trig = i;
           split = j;
           #10
           if ( exp_state != state)  correct = 0;
          end
       end   
        
        #10        
        
          
        if (correct)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
    
endmodule
