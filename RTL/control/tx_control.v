module tx_control(
    input wire clk,  // device clock
    input wire rst_n,
    input wire frame_clk,
    input wire lmfc_clk,
    // assert when link re-initialization is detected
    input wire i_sync_request_tx,
    // this signal only works when the FSM is at DATA_ENC
    // 1 - enable link test sequence
    // 0 - disable link test sequence
    input wire i_reg_link_test_en,
    input wire [1:0] i_reg_link_test_sel,

    // select which octect stream should be fed into 8b/10b encoder
    // 0: user data
    // 1: continous K
    // 2: ILA
    // 3: link layer test sequence, exact test sequence type is controled by
    //      o_link_test_sel
    output reg [2:0] o_link_mux,
    // link layer test sequence select
    output reg [1:0] o_link_test_sel
);

// states
localparam [2:0] SYNC = 3'b001;
localparam [2:0] INIT_LANE = 3'b010;
localparam [2:0] DATA_ENC = 3'b100;


// FSM actions encode
localparam [2:0] SEND_USER_DATA = 3'd0;
localparam [2:0] SEND_K = 3'd1;
localparam [2:0] SEND_LANE_SEQ = 3'd2;
localparam [2:0] SEND_LINK_TEST_SEQ = 3'd3;

reg [2:0] next_state;
reg [2:0] current_state;
// 1 - K sequence's length is shorter than 1 frame + 9 octets
reg k_sequence_too_short;
// assert to indicate end of ILA sequence
reg lane_seq_end;

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= SYNC;
      o_link_mux <= SEND_K;
    end else begin
        current_state <= next_state;

        case(current_state)
            SYNC: o_link_mux <= SEND_K;
            INIT_LANE: o_link_mux <= SEND_LANE_SEQ;
            DATA_ENC: begin
                o_link_mux <=
                    (i_reg_link_test_en)? SEND_LINK_TEST_SEQ:SEND_USER_DATA;
            end
            default: o_link_mux <= SEND_K;
        endcase
    end
end

always@(*) begin
    case(current_state)
        SYNC: begin
            if (i_sync_request_tx || !lmfc_clk || k_sequence_too_short)
                next_state = SYNC;
            else
                next_state = INIT_LANE;
        end
        INIT_LANE: begin
            if (!lane_seq_end)
                next_state = INIT_LANE;
            else
                next_state = DATA_ENC;
        end
        DATA_ENC: begin
            if (!i_sync_request_tx)
                next_state = DATA_ENC;
            else
                next_state = SYNC;
        end
        default: next_state = SYNC;
    endcase
end

always@(posedge clk) begin
    o_link_test_sel <= i_reg_link_test_sel;
end
endmodule
