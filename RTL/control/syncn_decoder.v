module syncn_decoder(
    // device clock, we use this as our detection clock as well, which is
    // twice as fast as frame clock
    input wire clk,
    input wire frame_clk,
    input wire i_sync_n, // SYNC~

    // assert when a link re-initialization request is detected
    // that is, when at least 4 consecutive frame clocks of SYNC~ assertion
    // is detected
    // deassert when SYNC~ is high
    output reg o_sync_request_tx,
    // assert when high to low transition of SYNC~ is detected,
    // deassert when SYNC~ is high
    output reg o_err_reporting
);

reg sync_n_dly;
reg [2:0] sync_requset_frame_cnt = 3'd0;

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
        o_sync_request_tx <= 1'b0;
    end else begin
        if (sync_requset_frame_cnt >= 3'd4)
            o_sync_request_tx <= 1'b1;
        else
            o_sync_request_tx <= 1'b0;
    end
end
endmodule
