// Independent reference: describe each glyph by its lit segment letters.
// This deliberately does not copy the decoder's binary lookup table.
function automatic logic [6:0] expected_segments(input logic [3:0] value);
    string lit_letters;
    logic [6:0] lit_mask;
    case (value)
        4'h0: lit_letters = "abcdef";
        4'h1: lit_letters = "bc";
        4'h2: lit_letters = "abdeg";
        4'h3: lit_letters = "abcdg";
        4'h4: lit_letters = "bcfg";
        4'h5: lit_letters = "acdfg";
        4'h6: lit_letters = "acdefg";
        4'h7: lit_letters = "abc";
        4'h8: lit_letters = "abcdefg";
        4'h9: lit_letters = "abcdfg";
        4'hA: lit_letters = "abcefg";
        4'hB: lit_letters = "cdefg";
        4'hC: lit_letters = "adef";
        4'hD: lit_letters = "bcdeg";
        4'hE: lit_letters = "adefg";
        4'hF: lit_letters = "aefg";
        default: lit_letters = "";
    endcase
    lit_mask = '0;
    for (int k=0; k<lit_letters.len(); k++)
        lit_mask[lit_letters[k] - 8'd97] = 1'b1;
    return ~lit_mask;
endfunction
