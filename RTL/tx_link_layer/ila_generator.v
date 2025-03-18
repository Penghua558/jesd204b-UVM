module ila_generator(
    input wire clk, // character clock
    input wire rst_n,
    // position of current frame in current multiframe when SYNC~ de-asserted
    // used for LMFC and frame clock phase adjustment
    input wire [4:0] i_no_frame_de_assertion,
    // active HIGH, when it's asserted ILA sequence should be generated
    input wire i_seq_start,
    // number of multiframes an ILA lasts
    // 1 ~ 256, encoding: binary value - 1
    input wire [7:0] i_ila_multiframe_length,

    // these values are directly supplied from registers, they are encoded
    input wire [7:0] i_DID,
    input wire [3:0] i_BID,
    input wire [4:0] i_LID,
    input wire i_SCR,
    input wire [4:0] i_L,
    input wire [7:0] i_M,
    input wire [4:0] i_N,
    input wire [1:0] i_CS,
    // N'
    input wire [4:0] i_N_ap,
    input wire [7:0] i_F,
    input wire [4:0] i_K,
    input wire [4:0] i_S,
    input wire i_HD,
    input wire [4:0] i_CF,

    // HGFEDCBA
    // at default this module would output K28.5 to fill the gap bewteen FSM
    // state switch
    output reg [7:0] o_data,
    output reg o_vld,
    output reg o_k,
    // active HIGH, pulse signal, lasts for 1 clock cycle
    // when ILA sequence is ended the signal would assert
    output reg o_seq_end
);


localparam ADVANCE_LMFC = 1'b0;
localparam DELAY_LMFC = 1'b1;
localparam [2:0] SUBCLASSV = 3'd2;
localparam [2:0] JESDV = 3'd1;
localparam IDLE = 1'b0;
localparam GEN_ILA = 1'b1;
localparam [3:0] LINK_CONF_OCTET_NUM = 4'd14;
localparam [7:0] K28_5 = 8'b101_11100;
localparam [7:0] K28_0 = 8'b000_11100;
localparam [7:0] K28_3 = 8'b011_11100;
localparam [7:0] K28_4 = 8'b100_11100;


reg current_state;
reg next_state;
reg [7:0] octet_value;
reg [7:0] octet_position_in_frame;
reg [4:0] frame_position_in_multiframe;
// as the rule of protocol, number of octets in a multiframe(K×F) is no more
// than 1024, to play safe I extend the bitwidth to 11 bits
reg [10:0] octet_position_in_multiframe;
// number of current multiframe in ILA
// 0 means the 1st multiframe
reg [7:0] no_multiframe_in_ila;
// position of current octet in link configuration data fields
// there are 14 octets in total in link configuration data
reg [3:0] octet_position_in_link_conf;
reg [3:0] adjcnt;
reg adjdir;
reg phadj;
// holds accumulation of all link configuration data fields
reg [11:0] fchk_accum;


always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adjdir <= 1'b0;
        adjcnt <= 4'd0;
        phadj <= 1'b0;
    end else begin
        if (current_state == GEN_ILA) begin
            if (i_no_frame_de_assertion == 5'd0) begin
                adjdir <= ADVANCE_LMFC;
                adjcnt <= 4'd0;
                phadj <= 1'b0;
            end else
            if (i_no_frame_de_assertion <=
                (i_K - i_no_frame_de_assertion)) begin
                adjdir <= ADVANCE_LMFC;
                phadj <= 1'b1;
                adjcnt <= i_no_frame_de_assertion;
            end else begin
                adjdir <= DELAY_LMFC;
                phadj <= 1'b1;
                adjcnt <= i_K - i_no_frame_de_assertion;
            end
        end else begin
            adjdir <= adjdir;
            adjcnt <= adjcnt;
            phadj <= phadj;
        end
    end
end


always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
        o_data <= K28_5;
        o_vld <= 1'b1;
        o_k <= 1'b1;
        o_seq_end <= 1'b0;
        octet_value <= 8'd0;
        octet_position_in_frame <= 8'd0;
        frame_position_in_multiframe <= 5'd0;
        octet_position_in_multiframe <= 11'd0;
        no_multiframe_in_ila <= 8'd0;
        octet_position_in_link_conf <= 4'd0;
        fchk_accum <= 12'd0;
    end else begin
        current_state <= next_state;
        case(current_state)
            IDLE: begin
                o_data <= K28_5;
                o_vld <= 1'b1;
                o_k <= 1'b1;
                o_seq_end <= 1'b0;
                octet_value <= 8'd0;
                octet_position_in_frame <= 8'd0;
                frame_position_in_multiframe <= 5'd0;
                octet_position_in_multiframe <= 11'd0;
                no_multiframe_in_ila <= 8'd0;
                octet_position_in_link_conf <= 4'd0;
                fchk_accum <= 12'd0;
            end
            GEN_ILA: begin
            // replace octet
                if (!(|octet_position_in_frame) &&
                    !(|frame_position_in_multiframe)) begin
                    // test for 1st octet in a multiframe
                    o_data <= K28_0;
                    o_vld <= 1'b1;
                    o_k <= 1'b1;
                    o_seq_end <= 1'b0;
                end else
                if (octet_position_in_frame == i_F &&
                frame_position_in_multiframe == i_K) begin
                    // test for last octet in a multiframe
                    o_data <= K28_3;
                    o_vld <= 1'b1;
                    o_k <= 1'b1;
                    o_seq_end <= 1'b0;
                end else
                if (octet_position_in_multiframe == 11'd1 &&
                    no_multiframe_in_ila == 8'd1) begin
                    // test for 2nd octet of 2nd multiframe
                    o_data <= K28_4;
                    o_vld <= 1'b1;
                    o_k <= 1'b1;
                    o_seq_end <= 1'b0;
                end else
                if (octet_position_in_multiframe == 11'd2 &&
                    no_multiframe_in_ila == 8'd1) begin
                    // test for 1st octet of link configuration data
                    o_data <= i_DID;
                    o_vld <= 1'b1;
                    o_k <= 1'b0;
                    o_seq_end <= 1'b0;
                    octet_position_in_link_conf <= 4'd1;
                    fchk_accum <= fchk_accum + {4'd0, i_DID};
                end else
                if (octet_position_in_link_conf < LINK_CONF_OCTET_NUM &&
                    octet_position_in_link_conf > 4'd1) begin
                    // test for the rest octets in link configuration data
                    case(octet_position_in_link_conf)
                        4'd1: begin
                            o_data <= {adjcnt, i_BID};
                            fchk_accum <= fchk_accum + {8'd0, adjcnt} +
                                {8'd0, i_BID};
                        end
                        4'd2: begin
                            o_data <= {1'b0, adjdir, phadj, i_LID};
                            fchk_accum <= fchk_accum + {11'd0, adjdir} +
                                {11'd0, phadj} + {7'd0, i_LID};
                        end
                        4'd3: begin
                            o_data <= {i_SCR, 2'b0, i_L};
                            fchk_accum <= fchk_accum + {11'd0, i_SCR} +
                                {7'd0, i_L};
                        end
                        4'd4: begin
                            o_data <= i_F;
                            fchk_accum <= fchk_accum + {4'd0, i_F};
                        end
                        4'd5: begin
                            o_data <= {3'b0, i_K};
                            fchk_accum <= fchk_accum + {7'd0, i_K};
                        end
                        4'd6: begin
                            o_data <= i_M;
                            fchk_accum <= fchk_accum + {4'd0, i_M};
                        end
                        4'd7: begin
                            o_data <= {i_CS, 1'b0, i_N};
                            fchk_accum <= fchk_accum + {10'd0, i_CS} +
                                {7'd0, i_N};
                        end
                        4'd8: begin
                            o_data <= {SUBCLASSV, i_N_ap};
                            fchk_accum <= fchk_accum + {9'd0, SUBCLASSV} +
                                {7'd0, i_N_ap};
                        end
                        4'd9: begin
                            o_data <= {JESDV, i_S};
                            fchk_accum <= fchk_accum + {9'd0, JESDV} +
                                {7'd0, i_S};
                        end
                        4'd10: begin
                            o_data <= {i_HD, 2'b0, i_CF};
                            fchk_accum <= fchk_accum + {11'd0, i_HD} +
                                {7'd0, i_CF};
                        end
                        4'd11: o_data <= 8'b0;
                        4'd12: o_data <= 8'b0;
                        // all link configuration data fields' sum mod 256
                        4'd13: o_data <= fchk_accum[7:0];
                        default: o_data <= 8'b0;
                    endcase
                    o_vld <= 1'b1;
                    o_k <= 1'b0;
                    o_seq_end <= 1'b0;
                    octet_position_in_link_conf <=
                        octet_position_in_link_conf + 4'd1;
                end else begin
                    o_data <= octet_value;
                    o_vld <= 1'b1;
                    o_k <= 1'b0;
                    if (no_multiframe_in_ila == i_ila_multiframe_length &&
                        octet_position_in_frame == i_F &&
                        frame_position_in_multiframe == i_K)
                        o_seq_end <= 1'b1;
                    else
                        o_seq_end <= 1'b0;
                end

                octet_value <= octet_value + 8'd1;

                if (octet_position_in_frame >= i_F) begin
                    octet_position_in_frame <= 8'd0;
                    if (frame_position_in_multiframe >= i_K) begin
                        frame_position_in_multiframe <= 5'd0;
                        octet_position_in_multiframe <= 11'd0;
                        no_multiframe_in_ila <= no_multiframe_in_ila + 8'd1;
                    end else begin
                        frame_position_in_multiframe <=
                            frame_position_in_multiframe + 5'd1;
                        octet_position_in_multiframe <=
                            octet_position_in_multiframe + 11'd1;
                    end
                end else
                    octet_position_in_frame <= octet_position_in_frame + 8'd1;
            end
            default: begin
                o_data <= K28_5;
                o_vld <= 1'b1;
                o_k <= 1'b1;
                o_seq_end <= 1'b0;
                octet_value <= 8'd0;
                octet_position_in_frame <= 8'd0;
                frame_position_in_multiframe <= 5'd0;
                octet_position_in_multiframe <= 11'd0;
                no_multiframe_in_ila <= 8'd0;
                octet_position_in_link_conf <= 4'd0;
                fchk_accum <= 12'd0;
            end
        endcase
    end
end


always@(*) begin
    case(current_state)
        IDLE: begin
            next_state = (i_seq_start) ? GEN_ILA: IDLE;
        end
        GEN_ILA: begin
            next_state = (o_seq_end) ? IDLE: GEN_ILA;
        end
    endcase
end
endmodule
