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
    input wire [4:0] i_L,
    input wire [7:0] i_M,
    input wire [4:0] i_N,
    input wire [1:0] i_CS,
    // N'
    input wire [1:0] i_N_ap,
    input wire [7:0] i_F,
    input wire [4:0] i_K,
    input wire [4:0] i_S,
    input wire i_HD,
    input wire [4:0] i_CF,

    // HGFEDCBA
    // at default this module would output K28.5 to fill the gap bewteen FSM
    // state switch
    output wire [7:0] o_data,
    output wire o_vld,
    output wire o_k,
    // active HIGH, pulse signal, lasts for 1 clock cycle
    // when ILA sequence is ended the signal would assert
    output wire o_seq_end
);


localparam IDLE = 1'b0;
localparam GEN_ILA = 1'b1;
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
                end else begin
                end
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
