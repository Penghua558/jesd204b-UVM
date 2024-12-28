module k_sequence_gen(
    input wire clk,
    output reg [7:0] o_data,
    output reg o_vld,
    output reg o_k
);

localparam [7:0] K28_5 = 8'b101_11100;

always@(posedge clk) begin
    o_data <= K28_5;
    o_vld <= 1'b1;
    o_k <= 1'b1;
end
endmodule
