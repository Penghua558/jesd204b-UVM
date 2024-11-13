`include "timescale.v"
`include "clk_gen.sv"
`include "tx_link_layer/tx_link_layer.v"
`include "tx_phy_layer/tx_phy_layer.v"

// This module is designed to run at 1.25Gbps, device clock frequency is thus
// 125MHz
module tx_jesd204b(
    input wire clk, // 125MHz
    input wire rst_n,
    input wire [7:0] i_data,
    input wire i_vld,
    input wire i_k,
    output reg tx_p,
    output reg tx_n
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
    .tx_p(tx_p),
    .tx_n(tx_n)
);
endmodule
