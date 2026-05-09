`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Stash_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bennch for the stash.
// Dependencies:    None
//
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stash_tb();

    reg clk, reset, sample_in_valid, next_sample, correct, loop_was_skipped;
    reg [7:0] sample_in;
    wire [7:0] sample_out;
    integer ini;
    
    // Instantiate the UUT (Unit Under Test)
    //FILL HERE
    Stash #(.DEPTH(5)) uut (
    .clk(clk),
    .reset(reset),
    .sample_in(sample_in),
    .sample_in_valid(sample_in_valid),
    .next_sample(next_sample),
    .sample_out(sample_out)
    );
    initial begin
        correct = 1;
        clk = 0; 
        reset = 1; 
        loop_was_skipped = 1;
        sample_in = 8'h00;
        sample_in_valid = 0;
        next_sample = 0;
        //FILL HERE
        #6;
        reset = 0;

        for( ini=0; ini<7; ini=ini+1 ) begin
            //FILL HERE
            // Set up sample_in before the rising edge
            sample_in = (ini + 1) * 10; // values: 10, 20, 30, 40, 50, 60, 70
            sample_in_valid = 1;
            #1;
            correct = correct & (sample_out == (ini + 1) * 10);
            #9;
            sample_in_valid = 0;
            #10;
            loop_was_skipped = 0;
        end
        correct = correct & (sample_out == 70);

        // rd_ptr=1 -> 2(30) -> 3(40) -> 4(50) -> 0(60) -> 1(70)
        next_sample = 1; #10;
        next_sample = 0; #10;
        correct = correct & (sample_out == 30); // rd_ptr=2

        next_sample = 1; #10;
        next_sample = 0; #10;
        correct = correct & (sample_out == 40); // rd_ptr=3

        next_sample = 1; #10;
        next_sample = 0; #10;
        correct = correct & (sample_out == 50); // rd_ptr=4

        next_sample = 1; #10;
        next_sample = 0; #10;
        correct = correct & (sample_out == 60); // rd_ptr=0, wrapped around

        next_sample = 1; #10;
        next_sample = 0; #10;
        correct = correct & (sample_out == 70); // rd_ptr=1, back to start
        #5
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
    
endmodule
