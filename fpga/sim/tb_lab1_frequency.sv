// Author: Troy Reyes, with AI assistance
// Email: TODO: add your email before submission.
// Created: 2026-09-07

// Purpose: Test the UNMODIFIED production parameters over a complete blink.
// Only LED output is dumped, to avoid an enormous 48 MHz waveform file.
`timescale 1ns/1ps
module tb_lab1_frequency;
    logic [3:0] s=0;
    logic [2:0] led;
    logic [6:0] seg;
    integer clock_edges=0, e0, e1, e2;
    realtime t0, t1, t2, measured_hz;
    lab1_tr dut (.*);
    always @(posedge dut.osc_clk) clock_edges++;
    initial begin
        $dumpfile("frequency.vcd"); $dumpvars(0,led);
        @(posedge led[2]); t0=$realtime; e0=clock_edges;
        @(negedge led[2]); t1=$realtime; e1=clock_edges;
        @(posedge led[2]); t2=$realtime; e2=clock_edges;
        measured_hz=1.0e9/(t2-t0);
        assert (e1-e0 == 10_000_000 && e2-e1 == 10_000_000)
            else $fatal(1,"Production divider is off by a clock edge");
        assert (measured_hz>2.376 && measured_hz<2.424)
            else $fatal(1,"Unexpected modeled frequency: %0.9f Hz",measured_hz);
        $display("PASS production frequency: rise-fall=%0d edges, fall-rise=%0d edges, period=%0.6f ns, f=%0.9f Hz",
                 e1-e0,e2-e1,t2-t0,measured_hz);
        $finish;
    end
    initial begin #1_000_000_000; $fatal(1,"Production frequency test timeout"); end
endmodule
