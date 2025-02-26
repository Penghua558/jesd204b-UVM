`include "encoder_8b10b.v"
`include "k_sequence_gen.v"
`include "ila_generator.v"

module tx_link_layer(
    input wire clk, // character clock
    input wire rst_n,
    // HGFEDCBA
    input wire [7:0] i_data,
    input wire i_vld,
    input wire i_k,
    // position of current frame in current multiframe when SYNC~ de-asserted
    // used for LMFC and frame clock phase adjustment
    input wire [4:0] i_no_frame_de_assertion,

    // select which octect stream should be fed into 8b/10b encoder
    // 0: user data
    // 1: continous K
    // 2: ILA
    input wire [2:0] i_link_mux,
    // abcdeifghj
    output reg [9:0] o_data,
    output reg o_k_error
);

reg [7:0] data_after_mux;
reg data_vld_after_mux;
reg k_flag_after_mux;

reg link_test_en = 1'b0;

wire [7:0] user_data;
wire user_vld;
wire user_k;

wire [7:0] k_seq_data;
wire k_seq_vld;
wire k_seq_k;

k_sequence_gen k_seq_gen(
    .clk(clk),
    .o_data(k_seq_data),
    .o_vld(k_seq_vld),
    .o_k(k_seq_k)
);

assign user_data = (link_test_en)? 8'd10:i_data;
assign user_vld = (link_test_en)? 1'd1:i_vld;
assign user_k = (link_test_en)? 1'd0:i_k;


// MUX to select data streams for 8b10b encoder
always@(posedge clk) begin
    case(i_link_mux)
        3'd0: begin // user data
            data_after_mux <= user_data;
            data_vld_after_mux <= user_vld;
            k_flag_after_mux <= user_k;
        end
        3'd1: begin // continous K
            data_after_mux <= k_seq_data;
            data_vld_after_mux <= k_seq_vld;
            k_flag_after_mux <= k_seq_k;
        end
        3'd2: begin // ILA
            data_after_mux <= 8'd1;
            data_vld_after_mux <= 1'b1;
            k_flag_after_mux <= 1'b0;
        end
        default: begin
            data_after_mux <= user_data;
            data_vld_after_mux <= user_vld;
            k_flag_after_mux <= user_k;
        end
    endcase
end

encoder_8b10b u_encoder_8b10b(
    .clk(clk),
    .rst_n(rst_n),
    .i_data(data_after_mux),
    .i_vld(data_vld_after_mux),
    .i_k(k_flag_after_mux),
    .o_data(o_data),
    .o_k_error(o_k_error)
);
endmodule
