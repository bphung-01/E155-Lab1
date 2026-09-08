// Author: Troy Reyes, with AI assistance
// Email: TODO: add your email before submission.
// Created: 2026-09-07

// Purpose: Exercise reset priority, enable hold, wrap, and blink phase.
// Run with MAX=3 by default; the supplied script also tests MAX=0,1,13.
`timescale 1ns/1ps
module tb_blink_counter;
    parameter integer WIDTH=4;
    parameter integer MAX=3;
    logic clk=0, reset=0, enable=0;
    logic [WIDTH-1:0] count;
    logic blink;
    int checks=0;
    blink_counter #(.WIDTH(WIDTH), .MAX_COUNT(MAX)) dut (.*);
    always #5 clk=~clk;

    task automatic cycle(input bit rst, input bit en,
                         input integer expected_count, input bit expected_blink);
        @(negedge clk); reset=rst; enable=en;
        @(posedge clk); #1;
        assert (count === WIDTH'(expected_count) && blink === expected_blink)
            else $fatal(1,"Counter MAX=%0d reset=%b enable=%b: got %0d/%b expected %0d/%b",
                        MAX,reset,enable,count,blink,expected_count,expected_blink);
        checks++;
    endtask

    initial begin
        $dumpfile("counter.vcd"); $dumpvars(0,tb_blink_counter);
        #1;
        assert (count === '0 && blink === 0) else $fatal(1,"Incorrect initial state"); checks++;
        cycle(1,0,0,0); // reset has priority even when disabled
        cycle(0,0,0,0);
        for (int c=1; c<=MAX; c++) cycle(0,1,c,0);
        repeat (3) cycle(0,0,MAX,0); // freeze immediately before wrap
        cycle(0,1,0,1);             // rollover resets count and toggles blink
        repeat (2) cycle(0,0,0,1);  // blink must also freeze when disabled
        cycle(1,0,0,0);             // reset clears a high blink state
        for (int c=1; c<=MAX; c++) cycle(0,1,c,0);
        cycle(0,1,0,1);
        for (int c=1; c<=MAX; c++) cycle(0,1,c,1);
        cycle(0,1,0,0);
        cycle(1,1,0,0);             // reset beats an enabled count
        // Synchronous reset must not change state before a rising edge.
        for (int c=1; c<=MAX; c++) cycle(0,1,c,0);
        cycle(0,1,0,1);
        @(negedge clk); reset=1; enable=0; #1;
        assert (blink === 1) else $fatal(1,"Reset behaved asynchronously"); checks++;
        @(posedge clk); #1;
        assert (count === '0 && blink === 0) else $fatal(1,"Synchronous reset failed"); checks++;
        $display("PASS counter: WIDTH=%0d MAX=%0d; %0d checks", WIDTH,MAX,checks);
        $finish;
    end
    initial begin #10000; $fatal(1,"Counter test timeout"); end
endmodule
