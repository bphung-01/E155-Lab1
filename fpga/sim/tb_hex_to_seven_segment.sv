// Author: Troy Reyes, with AI assistance
// Email: TODO: add your email before submission.
// Created: 2026-09-07

// Purpose: Exhaustive decoder test, uniqueness checks, and X/Z fallback.
`timescale 1ns/1ps
module tb_hex_to_seven_segment;
    logic [3:0] hex_value;
    logic [6:0] segments;
    logic [6:0] seen [0:15];
    int checks = 0;
    `include "expected_segments.svh"
    hex_to_seven_segment dut (.hex_value(hex_value), .segments(segments));
    initial begin
        $dumpfile("decoder.vcd");
        $dumpvars(0, tb_hex_to_seven_segment);
        for (int value=0; value<16; value++) begin
            hex_value = 4'(value);
            #10;
            assert (segments === expected_segments(hex_value))
                else $fatal(1, "Decoder mismatch for %h: got %b", hex_value, segments);
            checks++;
            seen[value] = segments;
            for (int earlier=0; earlier<value; earlier++) begin
                assert (segments !== seen[earlier])
                    else $fatal(1, "Duplicate glyphs: %h and %h", value, earlier);
                checks++;
            end
        end
        hex_value=4'bxxxx; #10;
        assert (segments === 7'b1111111) else $fatal(1, "X input did not blank"); checks++;
        hex_value=4'bzzzz; #10;
        assert (segments === 7'b1111111) else $fatal(1, "Z input did not blank"); checks++;
        $display("PASS decoder: 16 glyphs, 120 uniqueness pairs, X/Z fallback; %0d checks", checks);
        $finish;
    end
endmodule
