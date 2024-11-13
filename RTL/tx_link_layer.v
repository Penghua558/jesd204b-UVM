module tx_link_layer(
    input wire clk,
    input wire rst_n,
    input wire [7:0] i_data,
    input wire i_vld,
    input wire i_k,
    output reg [9:0] o_data,
    output reg o_k_error
);

encoder_8b10b u_encoder_8b10b(
    .clk(clk),
    .rst_n(rst_n),
    .i_data(i_data),
    .i_vld(i_vld),
    .i_k(i_k),
    .o_data(o_data),
    .o_k_error(o_k_error)
);
endmodule
