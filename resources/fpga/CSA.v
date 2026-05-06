`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     11/10/2018 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     CSA
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Variable length binary adder. The parameter N determines
//                  the bit width of the operands. Implemented according to 
//                  Conditional Sum Adder.
// 
// Dependencies:    FA
// 
// Revision:        2.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module CSA(a, b, ci, sum, co);

    parameter N=4;
    parameter K = N >> 1;
    
    input [N-1:0] a;
    input [N-1:0] b;
    input ci;
    output [N-1:0] sum;
    output co;
    
	
    // FILL HERE
    
    generate
        if (N == 1) begin : base_case
            // Base case: single bit adder
            FA fa_inst(.a(a[0]), .b(b[0]), .ci(ci), .sum(sum[0]), .co(co));
        end
        else begin : recursive_case
            // Wires for lower half
            wire [K-1:0] sum_low;
            wire co_low;
            
            // Wires for upper half with carry-in = 0
            wire [N-K-1:0] sum_high_0;
            wire co_high_0;
            
            // Wires for upper half with carry-in = 1
            wire [N-K-1:0] sum_high_1;
            wire co_high_1;
            
            // Lower half CSA with actual carry-in
            CSA #(.N(K)) csa_low (
                .a(a[K-1:0]),
                .b(b[K-1:0]),
                .ci(ci),
                .sum(sum_low),
                .co(co_low)
            );
            
            // Upper half CSA assuming carry-in = 0
            CSA #(.N(N-K)) csa_high_0 (
                .a(a[N-1:K]),
                .b(b[N-1:K]),
                .ci(1'b0),
                .sum(sum_high_0),
                .co(co_high_0)
            );
            
            // Upper half CSA assuming carry-in = 1
            CSA #(.N(N-K)) csa_high_1 (
                .a(a[N-1:K]),
                .b(b[N-1:K]),
                .ci(1'b1),
                .sum(sum_high_1),
                .co(co_high_1)
            );
            
            // Assign lower half sum directly
            assign sum[K-1:0] = sum_low;
            
            // Mux to select upper half sum and carry-out based on lower carry-out
            assign sum[N-1:K] = co_low ? sum_high_1 : sum_high_0;
            assign co = co_low ? co_high_1 : co_high_0;
        end
    endgenerate

    
endmodule
