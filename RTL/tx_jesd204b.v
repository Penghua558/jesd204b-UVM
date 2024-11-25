`include "timescale.v"
`include "clk_gen.sv"
`include "tx_link_layer/tx_link_layer.v"
`include "tx_phy_layer/tx_phy_layer.v"

// This module targets at lane speed 12.5Gbps, thus character clock frequency
// is 1.25GHz
module tx_jesd204b(
    input wire clk, // 1.25GHz
    input wire rst_n,
    input wire [7:0] i_data,
    input wire i_vld,
    input wire i_k,
    // MSB is sent first, in other word a in sent first, j is sent last
    output reg o_tx_p,
    output reg o_tx_n
);

reg [9:0] o_link_data;
reg o_link_k_error;
reg bitclk; // 1.25GHz

tx_link_layer link_layer(
    .clk(clk),
    .rst_n(rst_n),
    .i_data(i_data),
    .i_vld(i_vld),
    .i_k(i_k),
    .o_data(o_link_data),
    .o_k_error(o_link_k_error)
);

clk_gen#(
.half_period(400ps)
) bitclk_gen(
    .out_clk(bit_clk)
);

tx_phy_layer phy_layer(
    .clk(bit_clk),
    .in_data(o_link_data),
    .tx_p(o_tx_p),
    .tx_n(o_tx_n)
);
endmodule
