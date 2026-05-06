`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     00:00:00  AM 05/05/2019 
// Design Name:     EE3 lab1
// Module Name:     Counter_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bench for Counter module
// Dependencies:    Counter
//
// Revision:        3.0
// Revision:        3.1 - changed  9999999 to 99999999 for a proper, 1sec delay, 
//                        in the inner test loop.
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Counter_tb();

    reg clk, init_regs, count_enabled, correct, loop_was_skipped;
    wire [7:0] time_reading;
    wire [3:0] tens_seconds_wire;
    wire [3:0] ones_seconds_wire;
    integer ts,os,sync,exp_tens,exp_ones,exp_total;
    
    // Instantiate the UUT (Unit Under Test)
    // TODO
    Counter #(.CLK_FREQ(100000000)) uut(
        .clk(clk),
        .init_regs(init_regs),
        .count_enabled(count_enabled),
        .time_reading(time_reading)
    ) ;
    
    assign tens_seconds_wire = time_reading[7:4];
    assign ones_seconds_wire = time_reading[3:0];
    
    initial begin 
        #1
        sync = 0;
        //count_sample = 0;
        //show_sample = 0;
        correct = 1;
        loop_was_skipped = 1;
        clk = 1;
        init_regs = 1;
        count_enabled = 0;
        #20
        init_regs = 0;
        count_enabled = 1;
        exp_total = 0;        
        // Remember that every 1000000 clocks are 10 milliseconds
        for( ts=0; ts<1; ts=ts+1 ) begin // not more than 10*10 seconds check
            for( os=0; os<2; os=os+1 ) begin // not more than 10*1 seconds check
                            #(999999999 + sync)// sync at first check is zero and then one forever
                            // FILL HERE THE "correct" signal MAINTENANCE 
                            // sync right time value so exp_total will store time in minutes
                            sync = sync | 1;
                            exp_total = exp_total + 1;
                            exp_tens = exp_total / 10;
                            exp_ones = exp_total % 10;    
                            loop_was_skipped = 0;
                            // check DUT 
                            #10 // wait for update (1 cycle)
                            if ((tens_seconds_wire !== exp_tens[3:0]) || (ones_seconds_wire !== exp_ones[3:0])) begin
                                correct = 0;
                            end    
                    
           end
        end
        
        #5
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
endmodule
