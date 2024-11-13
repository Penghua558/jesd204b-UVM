`include "serializer.v"

module tx_phy_layer(
    input wire clk,
    input wire [9:0] in_data,
    output reg tx_p,
    output reg tx_n
);

reg serializer_out;

serializer u_serializer(
    .bit_clk(clk),
    .in_data(in_data),
    .out_data(serializer_out)
);

always @(posedge clk) begin
    tx_p <= serializer_out;
    tx_n <= ~serializer_out;
end
endmodule
