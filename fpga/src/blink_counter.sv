// Author: Troy Reyes, with AI assistance
// Email: TODO: add your email before submission.
// Created: 2026-09-07

// Purpose: Enabled modulo-(MAX_COUNT+1) counter with synchronous reset.
// blink toggles on each rollover, so f_blink = f_clk/[2*(MAX_COUNT+1)].
// Legal parameters: WIDTH >= 1; 0 <= MAX_COUNT < 2**WIDTH.
// Zero initial values model the UP5K's configuration-time global reset.
// reset remains a separately testable synchronous run-time input.
`timescale 1ns/1ps
module blink_counter #(
    parameter integer WIDTH = 24,
    parameter integer MAX_COUNT = 9_999_999
) (
    input  logic clk,
    input  logic reset,
    input  logic enable,
    output logic [WIDTH-1:0] count = '0,
    output logic blink = 1'b0
);
    logic at_max;
    logic [WIDTH-1:0] incremented_count;
    assign at_max = (count == WIDTH'(MAX_COUNT));
    assign incremented_count = count + 1'b1;

    // synthesis translate_off
    initial begin
        if (WIDTH < 1 || WIDTH > 30 || MAX_COUNT < 0 ||
            MAX_COUNT >= (2.0 ** WIDTH))
            $fatal(1, "Illegal counter parameters: WIDTH=%0d MAX_COUNT=%0d", WIDTH, MAX_COUNT);
    end
    // synthesis translate_on

    always_ff @(posedge clk) begin
        if (reset) begin
            count <= '0;
            blink <= 1'b0;
        end else if (enable) begin
            if (at_max) begin
                count <= '0;
                blink <= ~blink;
            end else begin
                count <= incremented_count;
            end
        end
    end
endmodule
