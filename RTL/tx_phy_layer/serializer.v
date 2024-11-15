module serializer(
    // bit clock is 10 times faster than character clock
    input wire bit_clk,
    input wire [9:0] in_data,
    // MSB is sent first
    output reg out_data
);

reg [9:0] phase = 10'b0000_0000_01;
reg [9:0] shift_reg = 10'b0;

always@(posedge bit_clk) begin
    out_data <= shift_reg[9];
end

always@(posedge bit_clk) begin
    // constantly shift 1 to left
    phase <= {phase[8:0], phase[9]};

    if (phase[0]) begin
        shift_reg <= in_data;
    end else begin
        shift_reg <= {shift_reg[8:0], 1'b0};
    end
end
endmodule
