package decoder_8b10b_agent_dec;
    // D word array, value is abcdei, index is EDCBA, running disparity is RD-
    bit [5:0] d_5b_minus[bit[4:0]] = '{
        5'd0:6'b100111,
        5'd1:6'b011101,
        5'd2:6'b101101,
        5'd3:6'b110001,
        5'd4:6'b110101,
        5'd5:6'b101001,
        5'd6:6'b011001,
        5'd7:6'b111000,
        5'd8:6'b111001,
        5'd9:6'b100101,
        5'd10:6'b010101,
        5'd11:6'b110100,
        5'd12:6'b001101,
        5'd13:6'b101100,
        5'd14:6'b011100,
        5'd15:6'b010111,
        5'd16:6'b011011,
        5'd17:6'b100011,
        5'd18:6'b010011,
        5'd19:6'b110010,
        5'd20:6'b001011,
        5'd21:6'b101010,
        5'd22:6'b011010,
        5'd23:6'b111010,
        5'd24:6'b110011,
        5'd25:6'b100110,
        5'd26:6'b010110,
        5'd27:6'b110110,
        5'd28:6'b001110,
        5'd29:6'b101110,
        5'd30:6'b011110,
        5'd31:6'b101011
        };

    // D word array, value is abcdei, index is EDCBA, running disparity is RD+
    bit [5:0] d_5b_plus[bit[4:0]] = '{
        5'd0:6'b011000,
        5'd1:6'b100010,
        5'd2:6'b010010,
        5'd3:6'b110001,
        5'd4:6'b001010,
        5'd5:6'b101001,
        5'd6:6'b011001,
        5'd7:6'b000111,
        5'd8:6'b000110,
        5'd9:6'b100101,
        5'd10:6'b010101,
        5'd11:6'b110100,
        5'd12:6'b001101,
        5'd13:6'b101100,
        5'd14:6'b011100,
        5'd15:6'b101000,
        5'd16:6'b100100,
        5'd17:6'b100011,
        5'd18:6'b010011,
        5'd19:6'b110010,
        5'd20:6'b001011,
        5'd21:6'b101010,
        5'd22:6'b011010,
        5'd23:6'b000101,
        5'd24:6'b001100,
        5'd25:6'b100110,
        5'd26:6'b010110,
        5'd27:6'b001001,
        5'd28:6'b001110,
        5'd29:6'b010001,
        5'd30:6'b100001,
        5'd31:6'b010100
        };

    // D word array, value is fghj, index is HGF, running disparity is RD-
    bit [3:0] d_3b_minus[bit[3:0]] = '{
        4'd0:4'b1011,
        4'd1:4'b1001,
        4'd2:4'b0101,
        4'd3:4'b1100,
        4'd4:4'b1101,
        4'd5:4'b1010,
        4'd6:4'b0110,
        4'd7:4'b1110, // primary encode of D.x.7
        4'd8:4'b0111 // alternate encode of D.x.7
    };

    // D word array, value is fghj, index is HGF, running disparity is RD+
    bit [3:0] d_3b_plus[bit[3:0]] = '{
        4'd0:4'b0100,
        4'd1:4'b1001,
        4'd2:4'b0101,
        4'd3:4'b0011,
        4'd4:4'b0010,
        4'd5:4'b1010,
        4'd6:4'b0110,
        4'd7:4'b0001, // primary encode of D.x.7
        4'd8:4'b1000 // alternate encode of D.x.7
    };

    // K word array, value is abcdeifghj, index is HGFEDCBA, running disparity
    // is RD-
    bit [9:0] k_8b_minus[byte] = '{
        8'b000_11100:10'b001111_0100,
        8'b001_11100:10'b001111_1001,
        8'b010_11100:10'b001111_0101,
        8'b011_11100:10'b001111_0011,
        8'b100_11100:10'b001111_0010,
        8'b101_11100:10'b001111_1010,
        8'b110_11100:10'b001111_0110,
        8'b111_11100:10'b001111_1000,
        8'b111_10111:10'b111010_1000,
        8'b111_11011:10'b110110_1000,
        8'b111_11101:10'b101110_1000,
        8'b111_11110:10'b011110_1000
    };

    // K word array, value is abcdeifghj, index is HGFEDCBA, running disparity
    // is RD+
    bit [9:0] k_8b_plus[byte] = '{
        8'b000_11100:10'b110000_1011,
        8'b001_11100:10'b110000_0110,
        8'b010_11100:10'b110000_1010,
        8'b011_11100:10'b110000_1100,
        8'b100_11100:10'b110000_1101,
        8'b101_11100:10'b110000_0101,
        8'b110_11100:10'b110000_1001,
        8'b111_11100:10'b110000_0111,
        8'b111_10111:10'b000101_0111,
        8'b111_11011:10'b001001_0111,
        8'b111_11101:10'b010001_0111,
        8'b111_11110:10'b100001_0111
    };
endpackage: decoder_8b10b_agent_dec
