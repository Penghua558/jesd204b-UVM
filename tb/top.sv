module top;

import uvm_pkg::*;
import env_pkg::*;
import testcase_lib_pkg::*;

// clk and rst_n
//
logic clk;
logic rst_n;

//
// Instantiate the pin interfaces:
//
decoder_8b10b_if u_dec_8b10b_if(clk, rst_n);
enc_bus_if u_enc_bus_if(clk, rst_n);

//
// Instantiate the BFM interfaces:
//
decoder_8b10b_monitor_bfm u_dec_8b10b_mon_bfm(
    .clk(u_dec_8b10b_if.clk),
    .rst_n(u_dec_8b10b_if.rst_n),
    .data(u_dec_8b10b_if.data),
    .k_error(u_dec_8b10b_if.k_error)
);

enc_bus_driver_bfm u_enc_bus_drv_bfm(
    .clk(u_enc_bus_if.clk),
    .rst_n(u_enc_bus_if.rst_n),
    .data(u_enc_bus_if.data),
    .valid(u_enc_bus_if.valid),
    .k(u_enc_bus_if.k)
);

enc_bus_monitor_bfm u_enc_bus_mon_bfm(
    .clk(u_enc_bus_if.clk),
    .rst_n(u_enc_bus_if.rst_n),
    .data(u_enc_bus_if.data),
    .valid(u_enc_bus_if.valid),
    .k(u_enc_bus_if.k)
);

// DUT
encoder_8b10b DUT(
    .clk(clk),
    .rst_n(rst_n),
    .i_data(u_enc_bus_if.data),
    .i_vld(u_enc_bus_if.valid),
    .i_k(u_enc_bus_if.k),
    .o_data(u_dec_8b10b_if.data),
    .o_k_error(u_dec_8b10b_if.k_error)
);

// UVM initial block:
// Virtual interface wrapping & run_test()
initial begin
    import uvm_pkg::uvm_config_db;
    uvm_config_db#(virtual decoder_8b10b_monitor_bfm)::set(null, "uvm_test_top",
      "dec_8b10b_mon_bfm", u_dec_8b10b_mon_bfm);


    uvm_config_db #(virtual enc_bus_monitor_bfm)::set(null, "uvm_test_top",
      "enc_bus_mon_bfm", u_enc_bus_mon_bfm);
    uvm_config_db #(virtual enc_bus_driver_bfm)::set(null, "uvm_test_top",
      "enc_bus_drv_bfm", u_enc_bus_drv_bfm);
    run_test();
end

//
// Clock and reset initial block:
//
initial begin
  // 125MHz, targeting at line speed of 1.25Gbps
  clk = 0;
  forever #4ns clk = ~clk;
end
initial begin
  rst_n = 0;
  repeat(4) @(posedge clk);
  rst_n = 0;
  repeat(4) @(posedge clk);
  rst_n = 1;
end

initial begin
  $wlfdumpvars();
end

endmodule: top
