module frame_lmfc_clk_gen(
    input wire clk, // device clock
    // number of frames per multiframe
    // 1 ~ 32, encoding: binary value - 1
    input wire [4:0] i_K,

    // frame clock's frequency is half of device clock
    // both frame clock and LMFC clock's duty cycle is not 50%,
    // their HIGH level will only lasts 1 device clock period per their own
    // period
    output reg o_frame_clk,
    output reg o_lmfc_clk
);


reg frame_cnt = 1'b0;
reg [5:0] lmfc_cnt = 6'd0;
reg lmfc_clk_d;


always@(posedge clk) begin
    frame_cnt <= ~frame_cnt;
    if (!frame_cnt) begin
        if (lmfc_cnt == i_K)
            lmfc_cnt <= 6'd0;
        else
            lmfc_cnt <= lmfc_cnt + 6'd1;
    end else
        lmfc_cnt <= lmfc_cnt;
end

always@(posedge clk) begin
    if (!frame_cnt)
        o_frame_clk <= 1'b1;
    else
        o_frame_clk <= 1'b0;
end

always@(posedge clk) begin
    if (lmfc_cnt == {1'b0, i_K} && frame_cnt)
        lmfc_clk_d <= 1'b1;
    else
        lmfc_clk_d <= 1'b0;
end

// delays LMFC clock to be aligned with frame clock
always@(posedge clk) begin
    o_lmfc_clk <= lmfc_clk_d;
end
endmodule
