// Author: Troy Reyes, with AI assistance
// Email: TODO: add your email before submission.
// Created: 2026-09-07

// Purpose: Check top-level wiring, all switch-to-LED combinations,
// oscillator period, and blink rollover connections with an accelerated count.
// The testbench OBSERVES dut.osc_clk. It never drives or forces that clock.
`timescale 1ns/1ps
module tb_lab1_tr;
    logic [3:0] s=0;
    logic [2:0] led;
    logic [6:0] seg;
    int clock_edges=0, edge_at_rise, edge_at_fall, checks=0;
    realtime t0, t1, period_ns;
    logic expected_xor, expected_and;
    `include "expected_segments.svh"
    lab1_tr #(.COUNTER_WIDTH(4), .MAX_COUNT(7)) dut (.*);
    always @(posedge dut.osc_clk) clock_edges++;
    initial begin
        $dumpfile("top.vcd"); $dumpvars(0,tb_lab1_tr);
        repeat (8) @(posedge dut.osc_clk);
        t0=$realtime; @(posedge dut.osc_clk); t1=$realtime;
        period_ns=t1-t0;
        assert (period_ns>20.6 && period_ns<21.1)
            else $fatal(1,"HSOSC period is %0.6f ns; expected about 20.833333 ns",period_ns);
        checks++;
        for (int value=0; value<16; value++) begin
            @(negedge dut.osc_clk); s=4'(value); #1;
            case (s[1:0])
                2'b01,2'b10: expected_xor=1;
                default: expected_xor=0;
            endcase
            expected_and=(s[3:2] == 2'b11);
            assert (led[0] === expected_xor && led[1] === expected_and)
                else $fatal(1,"Top LED logic failed for s=%h",s);
            checks++;
            assert (seg === expected_segments(s))
                else $fatal(1,"Decoder connection failed for s=%h",s);
            checks++;
        end
        @(posedge led[2]); edge_at_rise=clock_edges;
        @(negedge led[2]); edge_at_fall=clock_edges;
        assert (edge_at_fall-edge_at_rise == 8)
            else $fatal(1,"Incorrect high interval in accelerated top test"); checks++;
        @(posedge led[2]);
        assert (clock_edges-edge_at_fall == 8)
            else $fatal(1,"Incorrect low interval in accelerated top test"); checks++;
        $display("PASS top: all 16 switch values, decoder wiring, HSOSC %0.6f ns, 8-edge half-cycles; %0d checks",period_ns,checks);
        $finish;
    end
    initial begin #1_000_000; $fatal(1,"Top test timeout: check HSOSC library binding"); end
endmodule
