module syncn_decoder(
    // device clock, we use this as our detection clock as well, which is
    // twice as fast as frame clock
    input wire clk,
    input wire frame_clk,
    // number of frames per multiframe
    // 1 ~ 32, encoding: binary value - 1
    input wire [4:0] i_K,
    input wire i_sync_n, // SYNC~

    // assert when a link re-initialization request is detected
    // that is, when at least 4 consecutive frame clocks of SYNC~ assertion
    // is detected
    // deassert when SYNC~ is high
    output reg o_sync_request_tx,
    // assert when high to low transition of SYNC~ is detected,
    // deassert when SYNC~ is high
    output reg o_err_reporting,
    // assert when low to high transition of SYNC~ is detected,
    // deassert when SYNC~ is low
    output reg o_sync_de_assertion,
    // position of current frame in current multiframe when SYNC~ de-asserted
    output reg [4:0] o_no_frame_de_assertion
);

reg sync_n_dly;
reg [2:0] sync_requset_frame_cnt = 3'd0;
reg [4:0] no_frame_in_multiframe = 5'd0;

always@(posedge clk) begin
    sync_n_dly <= i_sync_n;
end

// count the number of consecutive frame clocks of assertion of SYNC~
always@(posedge clk) begin
    if (i_sync_n)
        sync_requset_frame_cnt <= 3'd0;
    else if (!i_sync_n && frame_clk)
        sync_requset_frame_cnt <= sync_requset_frame_cnt + 3'd1;
    else
        sync_requset_frame_cnt <= sync_requset_frame_cnt;
end

always@(posedge clk) begin
    if (i_sync_n) begin
        o_err_reporting <= 1'b0;
    end else begin
        // detect SYNC~'s high to low transition
        if (!i_sync_n && sync_n_dly) begin
            o_err_reporting <= 1'b1;
        end else begin
            o_err_reporting <= o_err_reporting;
        end
    end
end

always@(posedge clk) begin
    if (i_sync_n) begin
        no_frame_in_multiframe <= 5'd0;
    end else begin
        if (frame_clk) begin
            if (no_frame_in_multiframe < i_K)
                no_frame_in_multiframe <= no_frame_in_multiframe + 5'd1;
            else
                no_frame_in_multiframe <= 5'd0;
        end else begin
            no_frame_in_multiframe <= no_frame_in_multiframe;
        end
    end
end

always@(posedge clk) begin
    if (i_sync_n) begin
        o_sync_de_assertion <= 1'b0;
        o_no_frame_de_assertion <= 5'd0;
    end else begin
        // detect SYNC~'s low to high transition
        if (i_sync_n && !sync_n_dly) begin
            o_sync_de_assertion <= 1'b1;
            o_no_frame_de_assertion <= no_frame_in_multiframe;
        end else begin
            o_sync_de_assertion <= o_sync_de_assertion;
            o_no_frame_de_assertion <= o_no_frame_de_assertion;
        end
    end
end

always@(posedge clk) begin
    if (i_sync_n) begin
        o_sync_request_tx <= 1'b0;
    end else begin
        if (sync_requset_frame_cnt >= 3'd5)
            o_sync_request_tx <= 1'b1;
        else
            o_sync_request_tx <= 1'b0;
    end
end
endmodule
