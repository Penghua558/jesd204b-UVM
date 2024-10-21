package decoder_8b10b_agent_dec;
    // D word array, value is abcdei, index is EDCBA, running disparity is RD-
    bit [5:0] d_5b_minus[32] = {
        6'b100111,
        6'b011101,
        6'b101101,
        6'b110001,
        6'b110101,
        6'b101001,
        6'b011001,
        6'b111000,
        6'b111001,
        6'b100101,
        6'b010101,
        6'b110100,
        6'b001101,
        6'b101100,
        6'b011100,
        6'b010111,
        6'b011011,
        6'b100011,
        6'b010011,
        6'b110010,
        6'b001011,
        6'b101010,
        6'b011010,
        6'b111010,
        6'b110011,
        6'b100110,
        6'b010110,
        6'b110110,
        6'b001110,
        6'b101110,
        6'b011110,
        6'b101011
        };

    // D word array, value is abcdei, index is EDCBA, running disparity is RD+
    bit [5:0] d_5b_plus[32] = {
        6'b011000,
        6'b100010,
        6'b010010,
        6'b110001,
        6'b001010,
        6'b101001,
        6'b011001,
        6'b000111,
        6'b000110,
        6'b100101,
        6'b010101,
        6'b110100,
        6'b001101,
        6'b101100,
        6'b011100,
        6'b101000,
        6'b100100,
        6'b100011,
        6'b010011,
        6'b110010,
        6'b001011,
        6'b101010,
        6'b011010,
        6'b000101,
        6'b001100,
        6'b100110,
        6'b010110,
        6'b001001,
        6'b001110,
        6'b010001,
        6'b100001,
        6'b010100
        };

    // D word array, value is fghi, index is HGF, running disparity is RD-
    bit [3:0] d_3b_minus[8] = {
        4'b1011,
        4'b1001,
        4'b0101,
        4'b1100,
        4'b1101,
        4'b1010,
        4'b0110,
        4'b1110
    };

    // D word array, value is fghi, index is HGF, running disparity is RD+
    bit [3:0] d_3b_plus[8] = {
        4'b0100,
        4'b1001,
        4'b0101,
        4'b0011,
        4'b0010,
        4'b1010,
        4'b0110,
        4'b0001
    };
endpackage: decoder_8b10b_agent_dec
