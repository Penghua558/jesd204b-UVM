module ila_fsm(
    input wire clk,  // device clock
    input wire rst_n,
    input wire frame_clk,
    input wire lmfc_clk,
    // asserted during the whole SYNC~ assertion period
    input wire i_err_reporting,
    // assert when link re-initialization is detected
    input wire i_sync_request_tx,
    // assert when low to high transition of SYNC~ is detected,
    // deassert when SYNC~ is low
    input wire i_sync_de_assertion,
    // number of multiframes an ILA lasts
    // 1 ~ 256, encoding: binary value - 1
    input wire [7:0] i_ila_multiframe_length,

    // select which octect stream should be fed into 8b/10b encoder
    // 0: user data
    // 1: continous K
    // 2: ILA
    output reg [2:0] o_link_mux
);

localparam [3:0] K_SEQ_FRAME_CNT = 4'd4;

// states
localparam [3:0] DETECT_DEASSERT = 4'b0001;
localparam [3:0] CAL_ADJ = 4'b0010;
localparam [3:0] SEND_K = 4'b0100;
localparam [3:0] SEND_ILA = 4'b1000;


// FSM actions encode
localparam [2:0] SEND_USER_DATA = 3'd0;
localparam [2:0] SEND_K = 3'd1;
localparam [2:0] SEND_LANE_SEQ = 3'd2;

reg [3:0] next_state;
reg [3:0] current_state;

reg sync_request_tx_d;
reg err_reporting_d;

reg phadj;
reg phadj_valid;
// number of frames the K sequence has been sent in
// current link re-initialization procedure
reg [3:0] k_frame_cnt;
reg [3:0] k_sequence_min_frame;

// number of multiframes ILA sequence has been sent during
// initial lane alignment procedure
reg [8:0] ila_multiframe_cnt;

wire [8:0] i_ila_multiframe_length_decode;
assign i_ila_multiframe_length_decode = i_ila_multiframe_length + 9'd1;

always@(posedge clk) begin
    sync_request_tx_d <= i_sync_request_tx;
    err_reporting_d <= i_err_reporting;
end

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= DETECT_DEASSERT;
      o_link_mux <= SEND_USER_DATA;
    end else begin
        current_state <= next_state;

        case(current_state)
            DETECT_DEASSERT: o_link_mux <= SEND_USER_DATA;
            CAL_ADJ: o_link_mux <= SEND_USER_DATA;
            SEND_K: o_link_mux <= SEND_K;
            SEND_ILA: o_link_mux <= SEND_LANE_SEQ;
            default: o_link_mux <= SEND_USER_DATA;
        endcase
    end
end

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phadj <= 1'b0;
        phadj_valid <= 1'b0;
    end else begin
        if (current_state == CAL_ADJ) begin
        // calculate PHADJ, ADJDIR, ADJCNT
        end else begin
            phadj <= 1'b0;
            phadj_valid <= 1'b0;
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        k_frame_cnt <= 4'd0;
    end else begin
        if (current_state == SEND_K) begin
            if (frame_clk)
                k_frame_cnt <= k_frame_cnt + 4'd1;
            else
                k_frame_cnt <= k_frame_cnt;
        end else
            k_frame_cnt <= 4'd0;
    end
end

always@(*) begin
    case(current_state)
        DETECT_DEASSERT: begin
            if (i_sync_de_assertion &&
                err_reporting_d &&
                !sync_request_tx_d) begin
                next_state <= CAL_ADJ;
            end else begin
                next_state <= DETECT_DEASSERT;
            end
        end
        CAL_ADJ: begin
            if (!phadj && phadj_valid) begin
            // in protocol the transition can only happen if phadj is 0 AND
            // it's not a sync request, since this FSM only detects non sync
            // request, aka error reporting, so we eliminated the sync request
            // condition
                next_state <= DETECT_DEASSERT;
            end else if (phadj && phadj_valid) begin
                next_state <= SEND_K;
            end else begin
                next_state <= CAL_ADJ;
            end
        end
        SEND_K: begin
            if (k_frame_cnt >= K_SEQ_FRAME_CNT) begin
            // for error reporting trigger ILA, we only need to send
            // 4 K symbols, but since the module's working is device clock,
            // so for simplicity we send 4 frame periods long of K symbol
                next_state <= SEND_ILA;
            end else begin
                next_state <= SEND_K;
            end
        end
        SEND_ILA: begin
            if (ila_multiframe_cnt <= i_ila_multiframe_length_decode) begin
                next_state = SEND_ILA;
            end else begin
                next_state <= DETECT_DEASSERT;
            end
        end
        default: next_state = DETECT_DEASSERT;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ila_multiframe_cnt <= 9'd0;
    end else begin
        if (current_state == SEND_ILA) begin
            if (lmfc_clk)
                ila_multiframe_cnt <= ila_multiframe_cnt + 9'd1;
            else
                ila_multiframe_cnt <= ila_multiframe_cnt;
        end else
            ila_multiframe_cnt <= 9'd0;
    end
end
endmodule
