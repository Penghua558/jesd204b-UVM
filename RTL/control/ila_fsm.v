module ila_fsm(
    input wire clk,  // device clock
    input wire rst_n,
    input wire frame_clk,
    input wire lmfc_clk,
    input wire i_err_reporting,
    // assert when link re-initialization is detected
    input wire i_sync_request_tx,

    // select which octect stream should be fed into 8b/10b encoder
    // 0: user data
    // 1: continous K
    // 2: ILA
    output reg [2:0] o_link_mux
);

// states
localparam [4:0] DETECT_ERR_REPORTING = 5'b00001;
localparam [4:0] DETECT_DEASSERT = 5'b00010;
localparam [4:0] CAL_ADJ = 5'b00100;
localparam [4:0] SEND_K = 5'b01000;
localparam [4:0] SEND_ILA = 5'b10000;


// FSM actions encode
localparam [2:0] SEND_USER_DATA = 3'd0;
localparam [2:0] SEND_K = 3'd1;
localparam [2:0] SEND_LANE_SEQ = 3'd2;

reg [2:0] next_state;
reg [2:0] current_state;
// number of frames the K sequence has been sent in
// current link re-initialization procedure
reg [3:0] k_frame_cnt;
reg [3:0] k_sequence_min_frame;

// number of multiframes ILA sequence has been sent during
// initial lane alignment procedure
reg [8:0] ila_multiframe_cnt;

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= DETECT_ERR_REPORTING;
      o_link_mux <= SEND_USER_DATA;
    end else begin
        current_state <= next_state;

        case(current_state)
            DETECT_ERR_REPORTING: o_link_mux <= SEND_USER_DATA;
            DETECT_DEASSERT: o_link_mux <= SEND_USER_DATA;
            CAL_ADJ: o_link_mux <= SEND_USER_DATA;
            SEND_K: o_link_mux <= SEND_K;
            SEND_ILA: o_link_mux <= SEND_LANE_SEQ;
            default: o_link_mux <= SEND_USER_DATA;
        endcase
    end
end

always@(*) begin
    case(current_state)
        DETECT_ERR_REPORTING: begin
        end
        INIT_LANE: begin
        end
        DATA_ENC: begin
        end
        default: next_state = SYNC;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        k_frame_cnt <= 4'd0;
    end else begin
        if (current_state == SYNC) begin
            if (frame_clk)
                k_frame_cnt <= k_frame_cnt + 4'd1;
            else
                k_frame_cnt <= k_frame_cnt;
        end else
            k_frame_cnt <= 4'd0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ila_multiframe_cnt <= 9'd0;
    end else begin
        if (current_state == INIT_LANE) begin
            if (lmfc_clk)
                ila_multiframe_cnt <= ila_multiframe_cnt + 9'd1;
            else
                ila_multiframe_cnt <= ila_multiframe_cnt;
        end else
            ila_multiframe_cnt <= 9'd0;
    end
end
endmodule
