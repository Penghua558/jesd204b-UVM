module ila_generator(
    input wire clk, // character clock
    input wire rst_n,
    // position of current frame in current multiframe when SYNC~ de-asserted
    // used for LMFC and frame clock phase adjustment
    input wire [4:0] i_no_frame_de_assertion,
    // active HIGH, when it's asserted ILA sequence should be generated
    input wire i_seq_start,

    input wire [7:0] i_DID,
    input wire [3:0] i_BID,
    input wire [4:0] i_LID,
    input wire [4:0] i_L,
    input wire [7:0] i_M,
    input wire [4:0] i_N,
    input wire [1:0] i_CS,
    // N'
    input wire [1:0] i_N_ap,
    input wire [7:0] i_F,
    input wire [4:0] i_K,
    input wire [4:0] i_S,
    input wire i_HD,
    input wire [4:0] i_CF,

    // HGFEDCBA
    // at default this module would output K28.5 to fill the gap bewteen FSM
    // state switch
    output wire [7:0] o_data,
    output wire o_vld,
    output wire o_k,
    // active HIGH, pulse signal, lasts for 1 clock cycle
    // when ILA sequence is ended the signal would assert
    output wire o_seq_end
);

endmodule
