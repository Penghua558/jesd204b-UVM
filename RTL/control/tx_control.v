`include "ila_fsm.sv"

module tx_control(
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
    // number of octets per frame
    // 1 ~ 256, encoding: binary value - 1
    input wire [7:0] i_F,
    // number of multiframes an ILA lasts
    // 1 ~ 256, encoding: binary value - 1
    input wire [7:0] i_ila_multiframe_length,

    // select which octect stream should be fed into 8b/10b encoder
    // 0: user data
    // 1: continous K
    // 2: ILA
    output wire [2:0] o_link_mux
);

// states
localparam [2:0] SYNC = 3'b001;
localparam [2:0] INIT_LANE = 3'b010;
localparam [2:0] DATA_ENC = 3'b100;

// FSM actions encode
localparam [2:0] SEND_USER_DATA = 3'd0;
localparam [2:0] SEND_K = 3'd1;
localparam [2:0] SEND_LANE_SEQ = 3'd2;

reg [2:0] next_state;
reg [2:0] current_state;
reg [2:0] ila_next_state;
reg [2:0] ila_current_state;
// number of frames the K sequence has been sent in
// current link re-initialization procedure
reg [3:0] k_frame_cnt;
reg [3:0] k_sequence_min_frame;

// number of multiframes ILA sequence has been sent during
// initial lane alignment procedure
reg [8:0] ila_multiframe_cnt;

reg [2:0] link_mux_tx_control;
reg [2:0] link_mux_ila_fsm;

wire [8:0] i_F_decode;
wire [8:0] i_ila_multiframe_length_decode;
assign i_F_decode = i_F + 9'd1;
assign i_ila_multiframe_length_decode = i_ila_multiframe_length + 9'd1;

always@(posedge clk) begin
    if (i_F_decode == 9'd1)
        k_sequence_min_frame <= 4'd10;
    else if (i_F_decode == 9'd2)
        k_sequence_min_frame <= 4'd6;
    else if (i_F_decode == 9'd3 || i_F_decode == 9'd4)
        k_sequence_min_frame <= 4'd4;
    else if (i_F_decode >= 9'd5 && i_F_decode <= 4'd8)
        k_sequence_min_frame <= 4'd3;
    else
        k_sequence_min_frame <= 4'd2;
end

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= SYNC;
      link_mux_tx_control <= SEND_K;
    end else begin
        current_state <= next_state;

        case(current_state)
            SYNC: link_mux_tx_control <= SEND_K;
            INIT_LANE: link_mux_tx_control <= SEND_LANE_SEQ;
            DATA_ENC: link_mux_tx_control <= SEND_USER_DATA;
            default: link_mux_tx_control <= SEND_K;
        endcase
    end
end

always@(*) begin
    case(current_state)
        SYNC: begin
            if (i_sync_request_tx || !lmfc_clk ||
                (k_frame_cnt <= k_sequence_min_frame))
                next_state = SYNC;
            else
                next_state = INIT_LANE;
        end
        INIT_LANE: begin
            // ILA sequence does not end
            if (i_sync_request_tx)
                next_state = SYNC;
            else if (ila_multiframe_cnt <= i_ila_multiframe_length_decode)
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


ila_fsm u_ila_fsm(
.clk(clk),
.rst_n(rst_n),
.frame_clk(frame_clk),
.lmfc_clk(lmfc_clk),
.i_err_reporting(i_err_reporting),
.i_sync_request_tx(i_sync_request_tx),
.i_sync_de_assertion(i_sync_de_assertion),
.i_ila_multiframe_length(i_ila_multiframe_length),
.o_link_mux(link_mux_ila_fsm)
);

// if ILA FSM' output is SEND_USER_DATA, it means no error reporting is
// detected, so the FSM is actually untriggered, so tx_control's FSM's output
// takes effect.
assign o_link_mux = (link_mux_ila_fsm == SEND_USER_DATA)? 
    link_mux_tx_control: link_mux_ila_fsm;
endmodule
