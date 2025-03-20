module frame_lmfc_clk_gen(
    input wire clk, // device clock
    // number of frames per multiframe
    // 1 ~ 32, encoding: binary value - 1
    input wire [4:0] i_K,

    // frame clock's frequency is half of device clock
    // both frame clock and LMFC clock's duty cycle is not 50%,
    // their HIGH level will only lasts 1 device clock period per their own
    // period
    output wire o_frame_clk,
    output reg o_lmfc_clk
);


reg [5:0] lmfc_cnt = 6'd0;


always@(posedge clk) begin
    if (lmfc_cnt == i_K)
        lmfc_cnt <= 6'd0;
    else
        lmfc_cnt <= lmfc_cnt + 6'd1;
end

assign o_frame_clk = clk;

always@(posedge clk) begin
    if (lmfc_cnt == {1'b0, i_K})
        o_lmfc_clk <= 1'b1;
    else
        o_lmfc_clk <= 1'b0;
end
endmodule
