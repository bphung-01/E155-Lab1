// Author: Troy Reyes, with AI assistance
// Email: TODO: add your email before submission.
// Created: 2026-09-07

// Purpose: Top-level Lab 1 design: hexadecimal display, XOR/AND LEDs,
// and a nominal 2.4 Hz blinking LED. No external clock port is needed.
`timescale 1ns/1ps
module lab1_tr #(
    parameter integer COUNTER_WIDTH = 24,
    parameter integer MAX_COUNT = 9_999_999
) (
    input  logic [3:0] s,
    output logic [2:0] led,
    output logic [6:0] seg
);
    logic osc_clk;
    logic [COUNTER_WIDTH-1:0] count_monitor;

    // Manufacturer-documented string parameter: "0b00" selects 48 MHz.
    HSOSC #(.CLKHF_DIV("0b00")) oscillator (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(osc_clk)
    );

    hex_to_seven_segment decoder (
        .hex_value(s),
        .segments(seg)
    );

    blink_counter #(
        .WIDTH(COUNTER_WIDTH),
        .MAX_COUNT(MAX_COUNT)
    ) counter (
        .clk(osc_clk),
        .reset(1'b0),
        .enable(1'b1),
        .count(count_monitor),
        .blink(led[2])
    );

    assign led[0] = s[1] ^ s[0];
    assign led[1] = s[3] & s[2];
endmodule
