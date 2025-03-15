`include "timescale.v"
`include "clk_gen.sv"
`include "tx_link_layer/tx_link_layer.v"
`include "tx_phy_layer/tx_phy_layer.v"
`include "control/tx_control.v"
`include "control/frame_lmfc_clk_gen.v"
`include "control/syncn_decoder.v"

// This module targets at lane speed 12.5Gbps, thus character clock frequency
// is 1.25GHz
module tx_jesd204b(
    input wire clk, // 156.25MHz, device clock
    input wire rst_n,
    input wire [7:0] i_data,
    input wire i_vld,
    input wire i_k,
    // SYNC~
    input wire i_sync_n,
    // MSB is sent first, in other word a in sent first, j is sent last
    output reg o_tx_p,
    output reg o_tx_n
);

reg [9:0] o_link_data;
reg o_link_k_error;
wire bit_clk; // 12.5GHz
wire char_clk; // 1.25GHz
wire frame_clk; // 156.25MHz
wire lmfc_clk; // 156.25/K MHz
wire sync_request_tx;
wire [2:0] link_mux;
wire err_reporting;
wire syncn_de_assertion;
wire [4:0] no_frame_de_assertion;

// bit clock frequency is 12.5GHz to hit bitrate of 12.5Gbps
clk_gen#(
.half_period(40ps)
) bitclk_gen(
    .out_clk(bit_clk)
);

clk_gen#(
.half_period(400ps)
) charclk_gen(
    .out_clk(char_clk)
);

tx_link_layer link_layer(
    .clk(char_clk),
    .rst_n(rst_n),
    .i_data(i_data),
    .i_vld(i_vld),
    .i_k(i_k),
    .i_no_frame_de_assertion(no_frame_de_assertion),
    .i_link_mux(link_mux),
    .o_data(o_link_data),
    .o_k_error(o_link_k_error)
);


tx_phy_layer phy_layer(
    .clk(bit_clk),
    .in_data(o_link_data),
    .tx_p(o_tx_p),
    .tx_n(o_tx_n)
);

frame_lmfc_clk_gen fr_lmfc_clk_gen(
    .clk(clk),
    .i_K(5'd3), // currently is tied to K = 4
    .o_frame_clk(frame_clk),
    .o_lmfc_clk(lmfc_clk)
);

syncn_decoder syncn_dec(
    .clk(clk),
    .frame_clk(frame_clk),
    .i_K(5'd3), // currently is tied to K = 4
    .i_sync_n(i_sync_n),
    .o_sync_request_tx(sync_request_tx),
    .o_err_reporting(err_reporting),
    .o_sync_de_assertion(syncn_de_assertion),
    .o_no_frame_de_assertion(no_frame_de_assertion)
);

tx_control tx_ctrl(
    .clk(clk),
    .rst_n(rst_n),
    .frame_clk(frame_clk),
    .lmfc_clk(lmfc_clk),
    .i_err_reporting(err_reporting),
    .i_sync_request_tx(sync_request_tx),
    .i_sync_de_assertion(syncn_de_assertion),
    .i_F(8'd7), // currently is tied to F = 8
    .i_ila_multiframe_length(8'd3), // currently is tied to 4 multiframes
    .o_link_mux(link_mux)
);
endmodule
