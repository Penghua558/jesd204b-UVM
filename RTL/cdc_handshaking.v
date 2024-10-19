module cdc_handshaking(
    input wire old_clk,
    // input data should remain stable until it is sampled
    input wire data_in,
    input wire new_clk,

    output reg data_out
);

reg req = 1'b0;
reg last_req;
reg new_req;
reg new_req_pipe;
reg old_ack;
reg old_ack_pipe;
wire busy;

always@(posedge new_clk) begin
    {last_req, new_req, new_req_pipe} <= {new_req, new_req_pipe, req};
end

always@(posedge old_clk) begin
    {old_ack, old_ack_pipe} <= {old_ack_pipe, new_req};
end

// can not raise another request from old clock domain if there is still
// an ongoing request, or acknowledgement in old clock domain still presents
assign busy = (req) || (old_ack);

always@(posedge old_clk) begin
    if ((!busy) && data_in) begin
        req <= 1'b1;
    end else if (old_ack) begin
        req <= 1'b0;
    end else begin
        req <= req;
    end
end

// this is to send an event, every rising edge of data_in will only trigger
// 1 event for new clock domain
always@(posedge new_clk) begin
    data_out <= (!last_req) && new_req;
end

endmodule
