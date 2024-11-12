`include "timescale.v"
`include "rom.v"
`include "rd_fsm.v"
`include "rdminus_rom.v"
`include "rdplus_rom.v"
`include "clk_gen.sv"

// output latency: 2 clock cycles
//
module encoder_8b10b
(
    input wire clk,
    input wire rst_n,
    // HGFEDCBA
    input wire [7:0] i_data,
    // active high, assert to indicate current i_data is valid
    // if deassert then module will not process current i_data
    input wire i_vld,
    // 1 - this data is control word K
    // 0 - this data is data word D
    input wire i_k,
    // abcdeifghj
    output reg [9:0] o_data,
    // 1 - input data is not a valid control symbol
    // 0 - input data is a valid control symbol or it's a data symbol
    output reg o_k_error
);

wire [9:0] symbol_minus;
wire [9:0] symbol_plus;
wire k_error_minus;
wire k_error_plus;
// running disparity
// 1 - RD+
// 0 - RD-
wire rd; 

wire [9:0] data_encode;
wire k_error_encode;

rdminus_rom u_rdminus_rom(
.clk(clk),
.rst_n(rst_n),
.i_addr(i_data),
.i_rd_en(i_vld),
.i_k(i_k),
.o_out(symbol_minus),
.o_k_error(k_error_minus)
);

rdplus_rom u_rdplus_rom(
.clk(clk),
.rst_n(rst_n),
.i_addr(i_data),
.i_rd_en(i_vld),
.i_k(i_k),
.o_out(symbol_plus),
.o_k_error(k_error_plus)
);

rd_fsm u_rd_fsm(
.clk(clk),
.rst_n(rst_n),
.i_data(data_encode),
.o_rd(rd)
);

assign data_encode = (rd)? symbol_plus:symbol_minus;
assign k_error_encode = (rd)? k_error_plus:k_error_minus;

always @(posedge clk) begin
    o_data <= data_encode;
    o_k_error <= k_error_encode;
end

endmodule
