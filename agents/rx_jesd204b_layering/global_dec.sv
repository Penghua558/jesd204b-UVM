package global_dec;

typedef bit[7:0] frame_data[];

parameter bit[7:0] R = 8'h1c;
parameter bit[7:0] K = 8'b101_11100;
parameter bit[7:0] A = 8'b011_11100;
parameter bit[7:0] F = 8'b111_11100;

`include "./circular_buffer.svh"

endpackage
